import Foundation

/// Pure reward logic. Maps a grade + the current combo to XP/coins and the next
/// combo value. Stateless and side-effect free, so it is trivially testable.
enum RewardCalculator {

    /// Base payouts per grade, before any combo multiplier.
    private static func basePayout(for grade: AccuracyGrade) -> (xp: Int, coins: Int) {
        switch grade {
        case .legendary: return (100, 50)
        case .perfect:   return (75, 35)
        case .excellent: return (50, 25)
        case .great:     return (30, 15)
        case .good:      return (15, 8)
        case .close:     return (5, 3)
        case .miss:      return (1, 0)
        }
    }

    /// Coin multiplier from the *resulting* combo. XP is never multiplied.
    private static func coinMultiplier(forCombo combo: Int) -> Double {
        switch combo {
        case 0...4:   return 1.0
        case 5...9:   return 1.1
        case 10...19: return 1.25
        default:      return 1.5   // 20+
        }
    }

    /// - Parameters:
    ///   - grade: the grade earned this round.
    ///   - currentCombo: combo *before* this round.
    /// - Returns: XP, multiplied coins, and the new combo value.
    static func reward(for grade: AccuracyGrade, currentCombo: Int) -> RewardBundle {
        let newCombo = grade.isGoodOrBetter ? currentCombo + 1 : 0
        let base = basePayout(for: grade)
        let coins = Int((Double(base.coins) * coinMultiplier(forCombo: newCombo)).rounded())
        return RewardBundle(xp: base.xp, coins: coins, newCombo: newCombo)
    }
}

import Foundation

/// Pure reward logic. Rewards scale with *closeness* (0...1) so every attempt
/// that isn't wildly off pays something, while grade bonuses keep Perfect and
/// Legendary feeling special. Coins are deliberately harder to earn than XP.
enum RewardCalculator {

    /// Flat grade bonus on top of the closeness-based base.
    private static func gradeBonus(for grade: AccuracyGrade) -> (xp: Int, coins: Int) {
        switch grade {
        case .legendary: return (75, 40)
        case .perfect:   return (50, 25)
        case .excellent: return (25, 12)
        case .great:     return (15, 7)
        case .good:      return (8, 4)
        case .close:     return (3, 1)
        case .miss:      return (0, 0)
        }
    }

    /// Coins get a small combo (streak) multiplier from the resulting combo.
    private static func coinMultiplier(forCombo combo: Int) -> Double {
        switch combo {
        case 0...4:   return 1.0
        case 5...9:   return 1.1
        case 10...19: return 1.25
        default:      return 1.5
        }
    }

    /// - Parameters:
    ///   - grade: grade earned this round.
    ///   - closeness: 0...1 from `GameResult.closeness`.
    ///   - currentCombo: combo *before* this round.
    static func reward(for grade: AccuracyGrade,
                       closeness: Double,
                       currentCombo: Int) -> RewardBundle {
        let baseXP = Int((2 + 48 * pow(closeness, 1.4)).rounded())
        let baseCoins = closeness >= 0.15 ? Int((1 + 20 * pow(closeness, 2.0)).rounded()) : 0

        let bonus = gradeBonus(for: grade)
        let newCombo = grade.isGoodOrBetter ? currentCombo + 1 : 0

        let xp = baseXP + bonus.xp
        let rawCoins = baseCoins + bonus.coins
        let coins = Int((Double(rawCoins) * coinMultiplier(forCombo: newCombo)).rounded())

        return RewardBundle(xp: xp, coins: coins, newCombo: newCombo)
    }
}

import Foundation

/// One stage of the ladder. `isUnlocked` / `isCleared` are derived from
/// `PlayerProgress`, not stored here — the stage definition itself is pure.
struct StageLevel: Identifiable, Equatable {
    let stageNumber: Int
    let targetSeconds: Double
    let requiredAccuracyPercent: Int
    let distractionLevel: Int
    /// Bonus XP granted on clearing the stage.
    let rewardBonus: Int

    var id: Int { stageNumber }

    var difficultyLabel: String {
        switch stageNumber {
        case ...5:   return "Rookie"
        case ...10:  return "Steady"
        case ...20:  return "Sharp"
        case ...35:  return "Expert"
        default:     return "Insane"
        }
    }
}

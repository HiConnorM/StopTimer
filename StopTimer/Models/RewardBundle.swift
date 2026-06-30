import Foundation

/// What a single round paid out. Produced by `RewardCalculator`, shown on the
/// result screen, and used by `ProgressStore` to credit the player.
struct RewardBundle: Equatable {
    let xp: Int
    let coins: Int
    /// The combo count *after* this round (already incremented or reset).
    let newCombo: Int

    static let zero = RewardBundle(xp: 0, coins: 0, newCombo: 0)
}

import Foundation

/// All persisted player state. Codable so it round-trips to UserDefaults as JSON.
/// Stored locally only — no backend, no account, nothing that shouldn't live on device.
struct PlayerProgress: Codable, Equatable {

    // Currency & progression
    var xp: Int = 0
    var coins: Int = 0
    var currentCombo: Int = 0
    var longestCombo: Int = 0

    // Lifetime accuracy stats
    var lifetimeAttempts: Int = 0
    /// Best (smallest) absolute error ever achieved. `nil` until first attempt.
    var bestError: Double? = nil
    var totalAbsoluteError: Double = 0

    // Per-grade counts
    var legendaryCount: Int = 0
    var perfectCount: Int = 0
    var excellentCount: Int = 0
    var greatCount: Int = 0
    var goodCount: Int = 0
    var closeCount: Int = 0
    var missCount: Int = 0

    // MARK: Computed (never stored)

    /// Mean absolute error across all attempts. 0 before the first attempt.
    var averageError: Double {
        lifetimeAttempts > 0 ? totalAbsoluteError / Double(lifetimeAttempts) : 0
    }

    /// Player level, derived from XP. Levels start at 1.
    var playerLevel: Int {
        xp / Constants.xpPerLevel + 1
    }

    /// XP accumulated inside the current level (0..<xpPerLevel).
    var xpIntoLevel: Int {
        xp % Constants.xpPerLevel
    }

    /// Progress through the current level, 0...1, for the XP bar.
    var levelProgress: Double {
        Double(xpIntoLevel) / Double(Constants.xpPerLevel)
    }
}

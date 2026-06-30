import SwiftUI

/// Central place for tuning values, the theme palette, and the locked game
/// constants (grade thresholds, reward table, combo tiers). Keeping these here
/// means the scoring/reward logic reads from one source of truth.
enum Constants {

    // MARK: Target generation
    static let targetMin: Double = 3.0
    static let targetMax: Double = 15.0

    // MARK: Progression
    /// XP required per player level. Level = xp / xpPerLevel + 1.
    static let xpPerLevel: Int = 500

    // MARK: Persistence keys
    static let progressKey = "stoptimer.player.progress.v1"
    static let settingsKey = "stoptimer.game.settings.v1"

    // MARK: Theme
    enum Theme {
        static let background    = Color(red: 0.04, green: 0.05, blue: 0.10)
        static let backgroundTop = Color(red: 0.07, green: 0.09, blue: 0.16)
        static let card          = Color(red: 0.10, green: 0.12, blue: 0.18)
        static let cardStroke    = Color.white.opacity(0.08)
        static let accent        = Color(red: 0.25, green: 0.65, blue: 1.00)
        static let textPrimary   = Color.white
        static let textSecondary = Color(white: 0.62)
    }
}

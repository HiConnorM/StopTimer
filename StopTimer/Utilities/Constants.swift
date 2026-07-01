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

    // MARK: Theme — "Bright arcade": warm cream, candy red, chunky & glossy.
    enum Theme {
        static let background    = Color(red: 0.97, green: 0.95, blue: 0.90)  // warm cream
        static let backgroundTop = Color(red: 1.00, green: 0.99, blue: 0.96)  // near-white top
        static let card          = Color.white
        static let cardStroke    = Color.black.opacity(0.06)

        // Candy-red primary button + its darker "lip"/shadow.
        static let accent        = Color(red: 0.96, green: 0.26, blue: 0.30)
        static let accentDark    = Color(red: 0.80, green: 0.13, blue: 0.18)

        // Ink (used for the Stop button) + its lip.
        static let ink           = Color(red: 0.16, green: 0.17, blue: 0.22)
        static let inkDark       = Color(red: 0.07, green: 0.08, blue: 0.11)

        static let textPrimary   = Color(red: 0.13, green: 0.12, blue: 0.15)  // near-black
        static let textSecondary = Color(red: 0.46, green: 0.44, blue: 0.48)

        // Fun accents for stats / coins.
        static let coin          = Color(red: 0.98, green: 0.74, blue: 0.12)
        static let mint          = Color(red: 0.18, green: 0.78, blue: 0.55)

        // Vibrant "Blockout"-style palette used for categories, meters, cosmetics.
        static let blue    = Color(red: 0.20, green: 0.55, blue: 0.98)
        static let purple  = Color(red: 0.58, green: 0.35, blue: 0.96)
        static let pink    = Color(red: 0.96, green: 0.30, blue: 0.62)
        static let green   = Color(red: 0.22, green: 0.80, blue: 0.44)
        static let teal    = Color(red: 0.10, green: 0.72, blue: 0.72)
        static let orange  = Color(red: 0.98, green: 0.55, blue: 0.15)
        static let yellow  = Color(red: 0.99, green: 0.80, blue: 0.16)
    }
}

import SwiftUI

/// A skill-based achievement. Earning it unlocks a prestige cosmetic (`unlocksCosmeticID`)
/// that can never be bought. `isEarned` / `progress` are pure functions of progress.
struct Achievement: Identifiable {
    let id: String
    let name: String
    let detail: String
    let symbol: String
    let color: Color
    let unlocksCosmeticID: String
    let isEarned: (PlayerProgress) -> Bool
    /// 0...1 toward earning, for the locked-state progress bar.
    let progress: (PlayerProgress) -> Double
}

import SwiftUI

/// A single cosmetic. The catalog is static; ownership and equipped state live in
/// `PlayerProgress`. Buyable items have a coin `price`; `earnedOnly` (prestige)
/// items can't be bought — they unlock via an achievement.
struct CosmeticItem: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: CosmeticType
    let price: Int
    /// Two-colour swatch used to render the item and to theme the game when equipped.
    let colors: [Color]
    /// SF Symbol for badges / frames.
    var symbol: String? = nil
    /// Prestige items: earned via an achievement, never purchasable.
    var earnedOnly: Bool = false
    var requiredPlayerLevel: Int? = nil
    var requiredStage: Int? = nil

    /// Default (free, always-owned) items are priced 0 and aren't prestige.
    var isDefault: Bool { price == 0 && !earnedOnly }
}

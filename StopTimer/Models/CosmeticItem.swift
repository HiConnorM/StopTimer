import SwiftUI

/// A single purchasable cosmetic. The catalog is static; ownership and equipped
/// state live in `PlayerProgress` and are resolved at read time.
struct CosmeticItem: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: CosmeticType
    let price: Int
    /// Two-colour swatch used to render the item and to theme the game when equipped.
    let colors: [Color]
    var requiredPlayerLevel: Int? = nil
    var requiredStage: Int? = nil

    /// Default (free, always-owned) items are priced 0.
    var isDefault: Bool { price == 0 }
}

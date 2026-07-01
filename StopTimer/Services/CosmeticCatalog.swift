import SwiftUI

/// The static catalog of every cosmetic. Ownership/equipped state is stored in
/// `PlayerProgress`; this just defines what exists, its price, and its colours.
/// Backgrounds are intentionally light so the dark text + white cards stay readable.
enum CosmeticCatalog {

    /// Free, always-owned default per type (price 0). These keep the signature look —
    /// the default button stays candy red.
    static let defaultIDs: [CosmeticType: String] = [
        .orb: "orb.classic",
        .background: "bg.cream",
        .button: "btn.candy",
        .resultEffect: "fx.classic",
        .title: "title.rookie",
    ]

    static let all: [CosmeticItem] = [
        // Orbs
        CosmeticItem(id: "orb.classic", name: "Classic Red", description: "The original.", type: .orb, price: 0,
                     colors: [Constants.Theme.accent, Constants.Theme.accentDark]),
        CosmeticItem(id: "orb.neon", name: "Neon Blue Orb", description: "Cool electric glow.", type: .orb, price: 60,
                     colors: [Constants.Theme.blue, Constants.Theme.teal]),
        CosmeticItem(id: "orb.candy", name: "Candy Pop Orb", description: "Sweet and bright.", type: .orb, price: 80,
                     colors: [Constants.Theme.pink, Constants.Theme.purple]),
        CosmeticItem(id: "orb.lava", name: "Lava Pulse Orb", description: "Molten heat.", type: .orb, price: 120,
                     colors: [Constants.Theme.orange, Constants.Theme.accent], requiredStage: 5),
        CosmeticItem(id: "orb.galaxy", name: "Galaxy Timer", description: "A pocket universe.", type: .orb, price: 200,
                     colors: [Constants.Theme.purple, Constants.Theme.blue], requiredPlayerLevel: 3),

        // Backgrounds (kept light for readability)
        CosmeticItem(id: "bg.cream", name: "Cream", description: "Warm and clean.", type: .background, price: 0,
                     colors: [Constants.Theme.backgroundTop, Constants.Theme.background]),
        CosmeticItem(id: "bg.arcade", name: "Arcade Green", description: "Fresh mint vibes.", type: .background, price: 100,
                     colors: [Color(red: 0.90, green: 0.99, blue: 0.93), Color(red: 0.80, green: 0.96, blue: 0.86)]),
        CosmeticItem(id: "bg.sunset", name: "Sunset", description: "Peach and rose.", type: .background, price: 100,
                     colors: [Color(red: 1.00, green: 0.95, blue: 0.90), Color(red: 1.00, green: 0.88, blue: 0.86)]),
        CosmeticItem(id: "bg.bubblegum", name: "Bubblegum", description: "Pink to lavender.", type: .background, price: 140,
                     colors: [Color(red: 1.00, green: 0.94, blue: 0.98), Color(red: 0.93, green: 0.92, blue: 1.00)], requiredStage: 10),

        // Button styles (default stays red)
        CosmeticItem(id: "btn.candy", name: "Candy Red", description: "The signature button.", type: .button, price: 0,
                     colors: [Constants.Theme.accent, Constants.Theme.accentDark]),
        CosmeticItem(id: "btn.chrome", name: "Chrome Buttons", description: "Sleek metal.", type: .button, price: 90,
                     colors: [Color(red: 0.42, green: 0.46, blue: 0.52), Color(red: 0.24, green: 0.27, blue: 0.32)]),
        CosmeticItem(id: "btn.ocean", name: "Ocean Buttons", description: "Deep sea blue.", type: .button, price: 90,
                     colors: [Constants.Theme.blue, Color(red: 0.10, green: 0.30, blue: 0.65)]),

        // Result effects (burst colour)
        CosmeticItem(id: "fx.classic", name: "Classic Burst", description: "Matches your grade.", type: .resultEffect, price: 0,
                     colors: [Constants.Theme.accent]),
        CosmeticItem(id: "fx.rainbow", name: "Rainbow Burst", description: "Every colour at once.", type: .resultEffect, price: 70,
                     colors: [Constants.Theme.pink]),
        CosmeticItem(id: "fx.gold", name: "Golden Burst", description: "Champion sparkle.", type: .resultEffect, price: 90,
                     colors: [Constants.Theme.coin], requiredPlayerLevel: 5),

        // Titles
        CosmeticItem(id: "title.rookie", name: "Time Rookie", description: "Everyone starts here.", type: .title, price: 0,
                     colors: [Constants.Theme.textSecondary]),
        CosmeticItem(id: "title.almost", name: "Almost Perfect", description: "So very close.", type: .title, price: 50,
                     colors: [Constants.Theme.blue]),
        CosmeticItem(id: "title.stopwatch", name: "Human Stopwatch", description: "Precision incarnate.", type: .title, price: 150,
                     colors: [Constants.Theme.green], requiredStage: 15),
        CosmeticItem(id: "title.legend", name: "Living Legend", description: "The 0.001 club.", type: .title, price: 300,
                     colors: [Constants.Theme.coin], requiredPlayerLevel: 8),
    ]

    static func item(_ id: String) -> CosmeticItem? {
        all.first { $0.id == id }
    }

    static func items(of type: CosmeticType) -> [CosmeticItem] {
        all.filter { $0.type == type }
    }

    static func defaultID(for type: CosmeticType) -> String {
        defaultIDs[type] ?? ""
    }
}

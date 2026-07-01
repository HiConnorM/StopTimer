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
        .badge: "badge.none",
        .frame: "frame.none",
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

        // MARK: Prestige titles (earned via achievements — never for sale)
        prestigeTitle("title.precise", "Precise", "Landed a Perfect.", Constants.Theme.blue),
        prestigeTitle("title.perfectionist", "Perfectionist", "Best error ≤ 0.010s.", Constants.Theme.mint),
        prestigeTitle("title.onfire", "On Fire", "5 Perfects in a row.", Constants.Theme.orange),
        prestigeTitle("title.steady", "Steady Hands", "15 rounds, no Miss.", Constants.Theme.teal),
        prestigeTitle("title.centurion", "Centurion", "Played 100 rounds.", Constants.Theme.textSecondary),

        // MARK: Badges (default + prestige)
        CosmeticItem(id: "badge.none", name: "No Badge", description: "Keep it clean.", type: .badge, price: 0,
                     colors: [Constants.Theme.textSecondary], symbol: "circle.dashed"),
        prestigeBadge("badge.legend", "Legend", "Scored a Legendary.", Constants.Theme.coin, "crown.fill"),
        prestigeBadge("badge.club001", "0.001 Club", "Best error ≤ 0.001s.", Constants.Theme.pink, "target"),
        prestigeBadge("badge.perfect10", "Perfect 10", "10 Perfects in a row.", Constants.Theme.purple, "10.circle.fill"),
        prestigeBadge("badge.sharpshooter", "Sharpshooter", "25 Perfect stops.", Constants.Theme.green, "scope"),
        prestigeBadge("badge.apex", "Apex Crown", "Reached Apex rank.", Constants.Theme.pink, "mountain.2.fill"),

        // MARK: Profile frames (default + prestige)
        CosmeticItem(id: "frame.none", name: "No Frame", description: "Just you.", type: .frame, price: 0,
                     colors: [Constants.Theme.cardStroke, Constants.Theme.cardStroke]),
        prestigeFrame("frame.frost", "Frost Frame", "25 rounds, no Miss.", [Constants.Theme.blue, Constants.Theme.teal]),
        prestigeFrame("frame.bronze", "Bronze Frame", "Cleared Stage 10.", [Color(red: 0.80, green: 0.50, blue: 0.20), Constants.Theme.orange]),
        prestigeFrame("frame.gold", "Gold Frame", "Cleared Stage 25.", [Constants.Theme.coin, Constants.Theme.yellow]),
    ]

    // MARK: Prestige item builders

    private static func prestigeTitle(_ id: String, _ name: String, _ hint: String, _ color: Color) -> CosmeticItem {
        CosmeticItem(id: id, name: name, description: hint, type: .title, price: 0, colors: [color], earnedOnly: true)
    }
    private static func prestigeBadge(_ id: String, _ name: String, _ hint: String, _ color: Color, _ symbol: String) -> CosmeticItem {
        CosmeticItem(id: id, name: name, description: hint, type: .badge, price: 0, colors: [color], symbol: symbol, earnedOnly: true)
    }
    private static func prestigeFrame(_ id: String, _ name: String, _ hint: String, _ colors: [Color]) -> CosmeticItem {
        CosmeticItem(id: id, name: name, description: hint, type: .frame, price: 0, colors: colors, earnedOnly: true)
    }

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

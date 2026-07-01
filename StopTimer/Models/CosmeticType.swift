import Foundation

/// The kinds of cosmetics a player can own and equip. One item per type is
/// equipped at a time; each type has a free default.
enum CosmeticType: String, Codable, CaseIterable, Identifiable {
    case orb
    case background
    case button
    case resultEffect
    case title

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .orb:          return "Timer Orbs"
        case .background:   return "Backgrounds"
        case .button:       return "Button Styles"
        case .resultEffect: return "Result Effects"
        case .title:        return "Titles"
        }
    }

    var symbol: String {
        switch self {
        case .orb:          return "circle.circle.fill"
        case .background:   return "square.stack.fill"
        case .button:       return "capsule.fill"
        case .resultEffect: return "sparkles"
        case .title:        return "person.text.rectangle.fill"
        }
    }
}

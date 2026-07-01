import SwiftUI

/// The playable modes. Classic is the stage ladder; Endless and Tap Rush are
/// their own loops. More (Blitz, Perfect Hunt, Daily) can slot in here.
enum GameMode: String, Identifiable, CaseIterable {
    case classic
    case endless
    case tapRush

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic:  return "Classic"
        case .endless:  return "Endless"
        case .tapRush:  return "Tap Rush"
        }
    }

    var subtitle: String {
        switch self {
        case .classic:  return "Climb the stage ladder"
        case .endless:  return "3 lives — how far can you go?"
        case .tapRush:  return "Tap as fast as you can!"
        }
    }

    var symbol: String {
        switch self {
        case .classic:  return "flag.checkered"
        case .endless:  return "infinity"
        case .tapRush:  return "hand.tap.fill"
        }
    }

    var color: Color {
        switch self {
        case .classic:  return Constants.Theme.accent
        case .endless:  return Constants.Theme.purple
        case .tapRush:  return Constants.Theme.orange
        }
    }
}

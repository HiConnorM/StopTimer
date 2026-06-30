import SwiftUI

/// The seven accuracy tiers, plus the pure mapping from absolute error to grade.
/// Color + symbol live here so the grade can never disagree with its presentation.
enum AccuracyGrade: String, CaseIterable, Codable {
    case legendary, perfect, excellent, great, good, close, miss

    /// Maps absolute error (seconds) to a grade. Single source of truth for thresholds.
    static func grade(forError error: Double) -> AccuracyGrade {
        switch error {
        case ...0.003: return .legendary
        case ...0.010: return .perfect
        case ...0.030: return .excellent
        case ...0.080: return .great
        case ...0.150: return .good
        case ...0.300: return .close
        default:       return .miss
        }
    }

    /// True for Good or better — the threshold that grows a combo / passes a stage.
    var isGoodOrBetter: Bool {
        switch self {
        case .legendary, .perfect, .excellent, .great, .good: return true
        case .close, .miss: return false
        }
    }

    var title: String {
        switch self {
        case .legendary: return "LEGENDARY"
        case .perfect:   return "PERFECT"
        case .excellent: return "EXCELLENT"
        case .great:     return "GREAT"
        case .good:      return "GOOD"
        case .close:     return "CLOSE"
        case .miss:      return "MISS"
        }
    }

    /// Punchy colors tuned to read on the light/cream arcade background.
    var color: Color {
        switch self {
        case .legendary: return Color(red: 0.96, green: 0.62, blue: 0.04)  // gold
        case .perfect:   return Color(red: 0.93, green: 0.20, blue: 0.55)  // hot pink
        case .excellent: return Color(red: 0.10, green: 0.70, blue: 0.46)  // mint green
        case .great:     return Color(red: 0.16, green: 0.62, blue: 0.85)  // sky blue
        case .good:      return Color(red: 0.45, green: 0.55, blue: 0.95)  // periwinkle
        case .close:     return Color(red: 0.95, green: 0.55, blue: 0.15)  // orange
        case .miss:      return Color(red: 0.93, green: 0.26, blue: 0.30)  // red
        }
    }

    /// SF Symbol — accessibility: grade is never communicated by color alone.
    var symbolName: String {
        switch self {
        case .legendary: return "crown.fill"
        case .perfect:   return "star.fill"
        case .excellent: return "sparkles"
        case .great:     return "hand.thumbsup.fill"
        case .good:      return "checkmark.circle.fill"
        case .close:     return "exclamationmark.circle.fill"
        case .miss:      return "xmark.circle.fill"
        }
    }
}

import Foundation

/// Pure result of one round. The difference, error, and grade are *computed* from
/// the raw target/actual values so they can never drift out of sync.
struct GameResult: Equatable {
    let targetSeconds: Double
    let actualSeconds: Double

    /// Positive = stopped late, negative = stopped early.
    var signedDifference: Double { actualSeconds - targetSeconds }

    var absoluteError: Double { abs(signedDifference) }

    var grade: AccuracyGrade { AccuracyGrade.grade(forError: absoluteError) }

    // MARK: Closeness / accuracy

    /// The window (seconds) within which a stop earns partial credit. Scales a
    /// little with the target so long targets aren't punished as harshly.
    var maxRewardWindow: Double { max(0.75, targetSeconds * 0.12) }

    /// 0...1 — how close the stop was, on a forgiving curve.
    var closeness: Double { max(0, 1 - absoluteError / maxRewardWindow) }

    /// 0...100 for display, e.g. "82% Accurate".
    var accuracyPercent: Int { Int((closeness * 100).rounded()) }

    /// Encouraging line for near misses (shown when the grade isn't a win).
    var encouragement: String {
        switch accuracyPercent {
        case 85...:  return "So close"
        case 70..<85: return "Almost locked"
        case 50..<70: return "You felt that one"
        case 30..<50: return "Tiny bit off"
        default:      return "Keep feeling it"
        }
    }

    /// Plain-text share card for the native share sheet.
    var shareText: String {
        """
        ⏱️ STOP TIMER

        Target: \(TimeFormatting.seconds(targetSeconds))
        Actual: \(TimeFormatting.seconds(actualSeconds))
        Diff: \(TimeFormatting.signed(signedDifference))

        \(grade.title)

        Can you beat me?
        """
    }
}

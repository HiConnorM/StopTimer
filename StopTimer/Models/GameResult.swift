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

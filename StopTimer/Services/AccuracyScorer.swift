import Foundation

/// Pure scoring. The single entry point for turning a target + measured time into
/// a `GameResult`. Stateless and side-effect free, so it is trivially testable.
/// Future weighting/curves would live here.
enum AccuracyScorer {
    static func score(targetSeconds: Double, actualSeconds: Double) -> GameResult {
        GameResult(targetSeconds: targetSeconds, actualSeconds: actualSeconds)
    }
}

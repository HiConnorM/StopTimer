import Foundation

/// Generates the target time for a round: a random `Double` in [3.000, 15.000].
/// Later phases can swap in difficulty pools / readable presets behind this API.
enum TargetGenerator {
    static func next() -> Double {
        Double.random(in: Constants.targetMin...Constants.targetMax)
    }
}

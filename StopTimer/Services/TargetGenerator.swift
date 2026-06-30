import Foundation

/// Generates the target time for a round, ramping difficulty with experience so
/// the first rounds are easy, readable whole seconds and precision grows over time.
///
/// - first 5 attempts:   whole seconds (3...10)           e.g. 3, 7, 10
/// - next 10 attempts:   half seconds (3...12)            e.g. 4.5, 9.0
/// - next 15 attempts:   tenths (3...14)                  e.g. 7.3, 11.8
/// - thereafter:         full precision (3...15)          e.g. 9.842
enum TargetGenerator {

    static func next(forAttempts attempts: Int) -> Double {
        switch attempts {
        case ..<5:
            return Double(Int.random(in: 3...10))
        case ..<15:
            return (Double.random(in: 3...12) * 2).rounded() / 2
        case ..<30:
            return (Double.random(in: 3...14) * 10).rounded() / 10
        default:
            return Double.random(in: Constants.targetMin...Constants.targetMax)
        }
    }
}

import Foundation

/// Deterministically builds each stage from its number, so a given stage always
/// has the same target (retry / stage-select stay consistent). Early stages are
/// easy whole seconds with no distractions to keep momentum.
enum StageCatalog {

    static func stage(_ number: Int) -> StageLevel {
        let n = max(1, number)
        return StageLevel(
            stageNumber: n,
            targetSeconds: target(for: n),
            requiredAccuracyPercent: requiredAccuracy(for: n),
            distractionLevel: distraction(for: n),
            rewardBonus: n * 3
        )
    }

    // MARK: Rules

    private static func requiredAccuracy(for n: Int) -> Int {
        switch n {
        case ...5:   return 40
        case ...10:  return 55
        case ...20:  return 65
        case ...35:  return 75
        default:     return 85
        }
    }

    private static func distraction(for n: Int) -> Int {
        switch n {
        case ...2:   return 0
        case ...4:   return 1
        case ...7:   return 2
        case ...11:  return 3
        case ...16:  return 4
        case ...22:  return 5
        case ...30:  return 6
        case ...40:  return 7
        default:     return 8
        }
    }

    /// Seeded by the stage number so it's stable; difficulty (precision) ramps up.
    private static func target(for n: Int) -> Double {
        var rng = SeededGenerator(seed: UInt64(n) &* 0x9E3779B97F4A7C15)
        switch n {
        case ...5:
            return Double(Int.random(in: 3...10, using: &rng))
        case ...10:
            return (Double.random(in: 3...12, using: &rng) * 2).rounded() / 2
        case ...20:
            return (Double.random(in: 3...14, using: &rng) * 10).rounded() / 10
        default:
            return (Double.random(in: 3...15, using: &rng) * 1000).rounded() / 1000
        }
    }
}

/// Tiny deterministic RNG (SplitMix64) so stage targets are reproducible.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0xDEADBEEF : seed }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

import XCTest
@testable import StopTimer

/// Locks the closeness-based reward curve, grade bonuses, and the coin multiplier.
final class RewardCalculatorTests: XCTestCase {

    func testFarMissGivesAlmostNothing() {
        let r = RewardCalculator.reward(for: .miss, closeness: 0, currentCombo: 0)
        XCTAssertEqual(r.xp, 2)          // tiny base only
        XCTAssertEqual(r.coins, 0)
        XCTAssertEqual(r.newCombo, 0)
    }

    func testPerfectClosenessLegendary() {
        // base: xp 2+48=50, coins 1+20=21; +legendary bonus 75/40; combo x1.0
        let r = RewardCalculator.reward(for: .legendary, closeness: 1, currentCombo: 0)
        XCTAssertEqual(r.xp, 125)
        XCTAssertEqual(r.coins, 61)
        XCTAssertEqual(r.newCombo, 1)
    }

    func testPerfectClosenessPerfect() {
        let r = RewardCalculator.reward(for: .perfect, closeness: 1, currentCombo: 0)
        XCTAssertEqual(r.xp, 100)   // 50 + 50
        XCTAssertEqual(r.coins, 46) // 21 + 25
    }

    func testXPRewardsScaleWithCloseness() {
        let weak = RewardCalculator.reward(for: .good, closeness: 0.5, currentCombo: 0).xp
        let strong = RewardCalculator.reward(for: .good, closeness: 1.0, currentCombo: 0).xp
        XCTAssertLessThan(weak, strong)
    }

    func testCoinsRequireMinimumCloseness() {
        // Below 0.15 closeness the base coin term is 0 (miss has no coin bonus).
        XCTAssertEqual(RewardCalculator.reward(for: .miss, closeness: 0.10, currentCombo: 0).coins, 0)
        // Above the threshold, coins appear.
        XCTAssertGreaterThan(RewardCalculator.reward(for: .miss, closeness: 0.20, currentCombo: 0).coins, 0)
    }

    func testComboIncrementsAndResets() {
        XCTAssertEqual(RewardCalculator.reward(for: .good, closeness: 0.5, currentCombo: 3).newCombo, 4)
        XCTAssertEqual(RewardCalculator.reward(for: .close, closeness: 0.5, currentCombo: 9).newCombo, 0)
        XCTAssertEqual(RewardCalculator.reward(for: .miss, closeness: 0.5, currentCombo: 25).newCombo, 0)
    }

    func testCoinMultiplierTiers() {
        // good @ closeness 1 -> base coins 25 (21+4 bonus).
        XCTAssertEqual(RewardCalculator.reward(for: .good, closeness: 1, currentCombo: 4).coins, 28)  // combo 5  x1.1
        XCTAssertEqual(RewardCalculator.reward(for: .good, closeness: 1, currentCombo: 19).coins, 38) // combo 20 x1.5
    }

    func testXPIsNeverMultipliedByCombo() {
        let a = RewardCalculator.reward(for: .good, closeness: 1, currentCombo: 0).xp
        let b = RewardCalculator.reward(for: .good, closeness: 1, currentCombo: 50).xp
        XCTAssertEqual(a, b)
    }
}

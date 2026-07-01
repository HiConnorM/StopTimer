import XCTest
@testable import StopTimer

/// Locks the reward table, combo growth/reset, and the coins-only combo multiplier.
final class RewardCalculatorTests: XCTestCase {

    func testBasePayouts() {
        // Combo 0 -> newCombo 1 -> multiplier x1.0, so coins equal the base table.
        XCTAssertEqual(RewardCalculator.reward(for: .legendary, currentCombo: 0), RewardBundle(xp: 100, coins: 50, newCombo: 1))
        XCTAssertEqual(RewardCalculator.reward(for: .perfect,   currentCombo: 0), RewardBundle(xp: 75,  coins: 35, newCombo: 1))
        XCTAssertEqual(RewardCalculator.reward(for: .excellent, currentCombo: 0), RewardBundle(xp: 50,  coins: 25, newCombo: 1))
        XCTAssertEqual(RewardCalculator.reward(for: .great,     currentCombo: 0), RewardBundle(xp: 30,  coins: 15, newCombo: 1))
        XCTAssertEqual(RewardCalculator.reward(for: .good,      currentCombo: 0), RewardBundle(xp: 15,  coins: 8,  newCombo: 1))
    }

    func testComboIncrementsOnGoodOrBetter() {
        XCTAssertEqual(RewardCalculator.reward(for: .good, currentCombo: 3).newCombo, 4)
        XCTAssertEqual(RewardCalculator.reward(for: .legendary, currentCombo: 11).newCombo, 12)
    }

    func testComboResetsOnCloseOrMiss() {
        XCTAssertEqual(RewardCalculator.reward(for: .close, currentCombo: 9).newCombo, 0)
        XCTAssertEqual(RewardCalculator.reward(for: .miss, currentCombo: 25).newCombo, 0)
    }

    func testCloseAndMissPayouts() {
        // Close still pays a little (x1.0 since combo resets to 0); Miss pays no coins.
        XCTAssertEqual(RewardCalculator.reward(for: .close, currentCombo: 4), RewardBundle(xp: 5, coins: 3, newCombo: 0))
        XCTAssertEqual(RewardCalculator.reward(for: .miss,  currentCombo: 4), RewardBundle(xp: 1, coins: 0, newCombo: 0))
    }

    func testCoinMultiplierTiers() {
        // "good" base coins = 8. Tiers apply on the *resulting* combo.
        XCTAssertEqual(RewardCalculator.reward(for: .good, currentCombo: 4).coins, 9)   // newCombo 5  -> x1.1 -> 8.8 -> 9
        XCTAssertEqual(RewardCalculator.reward(for: .good, currentCombo: 9).coins, 10)  // newCombo 10 -> x1.25 -> 10
        XCTAssertEqual(RewardCalculator.reward(for: .good, currentCombo: 19).coins, 12) // newCombo 20 -> x1.5  -> 12
    }

    func testXPIsNeverMultipliedByCombo() {
        XCTAssertEqual(RewardCalculator.reward(for: .good, currentCombo: 50).xp, 15)
    }
}

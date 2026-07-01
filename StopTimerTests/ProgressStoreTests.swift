import XCTest
@testable import StopTimer

/// Locks progression bookkeeping and the UserDefaults save/load round-trip.
final class ProgressStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "stoptimer.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testApplyPerfectResultUpdatesStats() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004)) // perfect

        let p = store.progress
        XCTAssertEqual(p.lifetimeAttempts, 1)
        XCTAssertEqual(p.perfectCount, 1)
        XCTAssertEqual(p.xp, 75)
        XCTAssertEqual(p.coins, 35)
        XCTAssertEqual(p.currentCombo, 1)
        XCTAssertEqual(p.longestCombo, 1)
        XCTAssertEqual(p.bestError ?? -1, 0.004, accuracy: 1e-9)
        XCTAssertEqual(p.totalAbsoluteError, 0.004, accuracy: 1e-9)
    }

    func testComboResetsAndBestErrorKeepsMinimum() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004)) // perfect, combo 1
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.500)) // miss, combo reset

        let p = store.progress
        XCTAssertEqual(p.lifetimeAttempts, 2)
        XCTAssertEqual(p.missCount, 1)
        XCTAssertEqual(p.currentCombo, 0)
        XCTAssertEqual(p.longestCombo, 1)                 // longest is remembered
        XCTAssertEqual(p.bestError ?? -1, 0.004, accuracy: 1e-9) // miss didn't worsen best
    }

    func testAverageError() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.010)) // error 0.010
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.030)) // error 0.030
        XCTAssertEqual(store.progress.averageError, 0.020, accuracy: 1e-9)
    }

    func testSaveLoadRoundTrip() {
        let a = ProgressStore(defaults: defaults)
        a.applyResult(GameResult(targetSeconds: 8, actualSeconds: 8.002))  // legendary
        a.applyResult(GameResult(targetSeconds: 5, actualSeconds: 5.070))  // great

        // A fresh store reading the same defaults must see identical progress.
        let b = ProgressStore(defaults: defaults)
        XCTAssertEqual(a.progress, b.progress)
        XCTAssertEqual(b.progress.lifetimeAttempts, 2)
        XCTAssertEqual(b.progress.legendaryCount, 1)
        XCTAssertEqual(b.progress.greatCount, 1)
    }

    func testResetClearsEverything() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004))
        store.reset()
        XCTAssertEqual(store.progress, PlayerProgress())

        // Reset must also persist: a fresh store sees the cleared state.
        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.progress, PlayerProgress())
    }
}

import XCTest
@testable import StopTimer

/// Locks the Tap Rush and Endless scoring/persistence in ProgressStore.
final class GameModeTests: XCTestCase {

    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() {
        super.setUp()
        suite = "stoptimer.modes.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: suite); defaults = nil; suite = nil
        super.tearDown()
    }

    func testTapRushCreditsAndTracksBest() {
        let store = ProgressStore(defaults: defaults)
        XCTAssertTrue(store.recordTapRush(taps: 40))         // first run is a best
        XCTAssertEqual(store.progress.bestTapCount, 40)
        XCTAssertEqual(store.progress.xp, 120)               // 40 * 3
        XCTAssertEqual(store.progress.coins, 20)             // 40 / 2

        XCTAssertFalse(store.recordTapRush(taps: 30))        // not a best
        XCTAssertEqual(store.progress.bestTapCount, 40)
        XCTAssertTrue(store.recordTapRush(taps: 55))         // new best
        XCTAssertEqual(store.progress.bestTapCount, 55)
    }

    func testEndlessCreditsAndTracksBest() {
        let store = ProgressStore(defaults: defaults)
        XCTAssertTrue(store.recordEndless(streak: 7))
        XCTAssertEqual(store.progress.endlessBest, 7)
        XCTAssertEqual(store.progress.xp, 70)                // 7 * 10
        XCTAssertEqual(store.progress.coins, 14)             // 7 * 2

        XCTAssertFalse(store.recordEndless(streak: 5))
        XCTAssertEqual(store.progress.endlessBest, 7)
    }

    func testModeBestsPersist() {
        let a = ProgressStore(defaults: defaults)
        a.recordTapRush(taps: 33)
        a.recordEndless(streak: 9)

        let b = ProgressStore(defaults: defaults)
        XCTAssertEqual(b.progress.bestTapCount, 33)
        XCTAssertEqual(b.progress.endlessBest, 9)
    }

    func testAllModesHaveMetadata() {
        for mode in GameMode.allCases {
            XCTAssertFalse(mode.title.isEmpty)
            XCTAssertFalse(mode.subtitle.isEmpty)
            XCTAssertFalse(mode.symbol.isEmpty)
        }
    }
}

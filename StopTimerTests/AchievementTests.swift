import XCTest
@testable import StopTimer

/// Locks streak tracking, achievement earning, and prestige-cosmetic ownership.
final class AchievementTests: XCTestCase {

    private var defaults: UserDefaults!
    private var suite: String!

    override func setUp() {
        super.setUp()
        suite = "stoptimer.ach.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: suite); defaults = nil; suite = nil
        super.tearDown()
    }

    func testPerfectStreakTracksAndResets() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004)) // perfect
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.002)) // perfect
        XCTAssertEqual(store.progress.currentPerfectStreak, 2)
        XCTAssertEqual(store.progress.bestPerfectStreak, 2)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.2))   // not perfect
        XCTAssertEqual(store.progress.currentPerfectStreak, 0)
        XCTAssertEqual(store.progress.bestPerfectStreak, 2)                      // best remembered
    }

    func testNoMissStreakResetsOnMiss() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.1))  // good, not miss
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.1))
        XCTAssertEqual(store.progress.currentNoMissStreak, 2)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 13.0))  // miss
        XCTAssertEqual(store.progress.currentNoMissStreak, 0)
        XCTAssertEqual(store.progress.bestNoMissStreak, 2)
    }

    func testEarningAchievementUnlocksPrestigeCosmetic() {
        let store = ProgressStore(defaults: defaults)
        // A single Legendary should earn "legend" -> unlocks badge.legend.
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.001)) // legendary
        let newly = store.refreshAchievements()

        XCTAssertTrue(newly.contains { $0.id == "legend" })
        XCTAssertTrue(store.isAchievementEarned("legend"))
        XCTAssertTrue(store.isOwned("badge.legend"))          // prestige now owned
    }

    func testPrestigeCosmeticCannotBeBoughtUntilEarned() {
        let store = ProgressStore(defaults: defaults)
        let badge = CosmeticCatalog.item("badge.legend")!
        XCTAssertFalse(store.isOwned("badge.legend"))
        XCTAssertFalse(store.isAvailable(badge))              // locked until earned
        XCTAssertFalse(store.purchase(badge))                 // never purchasable
    }

    func testEquipEarnedBadge() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.001)) // legendary
        store.refreshAchievements()
        store.equip(CosmeticCatalog.item("badge.legend")!)
        XCTAssertEqual(store.equippedBadge?.id, "badge.legend")
    }

    func testCatalogRewardIdsAllExist() {
        for a in AchievementCatalog.all {
            XCTAssertNotNil(CosmeticCatalog.item(a.unlocksCosmeticID),
                            "Missing cosmetic \(a.unlocksCosmeticID) for achievement \(a.id)")
        }
    }
}

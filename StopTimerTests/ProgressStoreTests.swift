import XCTest
@testable import StopTimer

/// Locks progression bookkeeping, the save/load round-trip, stage clears, and
/// the cosmetic purchase/equip flow.
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
        defaults = nil; suiteName = nil
        super.tearDown()
    }

    func testApplyResultCreditsRewardAndStats() {
        let store = ProgressStore(defaults: defaults)
        let result = GameResult(targetSeconds: 10, actualSeconds: 10.004) // perfect
        let expected = RewardCalculator.reward(for: result.grade, closeness: result.closeness, currentCombo: 0)

        store.applyResult(result)
        let p = store.progress
        XCTAssertEqual(p.lifetimeAttempts, 1)
        XCTAssertEqual(p.perfectCount, 1)
        XCTAssertEqual(p.xp, expected.xp)
        XCTAssertEqual(p.coins, expected.coins)
        XCTAssertEqual(p.currentCombo, 1)
        XCTAssertEqual(p.bestError ?? -1, 0.004, accuracy: 1e-9)
    }

    func testComboResetsAndBestErrorKeepsMinimum() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004)) // perfect
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 13.0))   // far miss

        let p = store.progress
        XCTAssertEqual(p.lifetimeAttempts, 2)
        XCTAssertEqual(p.missCount, 1)
        XCTAssertEqual(p.currentCombo, 0)
        XCTAssertEqual(p.longestCombo, 1)
        XCTAssertEqual(p.bestError ?? -1, 0.004, accuracy: 1e-9)
    }

    func testSaveLoadRoundTripIncludingCosmetics() {
        let a = ProgressStore(defaults: defaults)
        a.applyResult(GameResult(targetSeconds: 8, actualSeconds: 8.001))  // legendary, banks coins
        let item = CosmeticCatalog.item("title.almost")!
        XCTAssertTrue(a.purchase(item))
        a.equip(item)

        let b = ProgressStore(defaults: defaults)
        XCTAssertEqual(a.progress, b.progress)
        XCTAssertTrue(b.isOwned("title.almost"))
        XCTAssertTrue(b.isEquipped("title.almost"))
    }

    func testStageClearRequirement() {
        let store = ProgressStore(defaults: defaults)
        let stage1 = StageCatalog.stage(1) // requires 40%

        XCTAssertFalse(store.clearStageIfMet(stage1, accuracyPercent: 30))
        XCTAssertEqual(store.progress.highestStageCleared, 0)

        XCTAssertTrue(store.clearStageIfMet(stage1, accuracyPercent: 50))
        XCTAssertEqual(store.progress.highestStageCleared, 1)
        XCTAssertTrue(store.isStageUnlocked(2))
        XCTAssertFalse(store.isStageUnlocked(3))
    }

    func testStageBonusGrantedOnlyOnFirstClear() {
        let store = ProgressStore(defaults: defaults)
        let stage1 = StageCatalog.stage(1)
        store.clearStageIfMet(stage1, accuracyPercent: 100)
        let afterFirst = store.progress.xp
        XCTAssertEqual(afterFirst, stage1.rewardBonus)   // only the stage bonus so far
        store.clearStageIfMet(stage1, accuracyPercent: 100)
        XCTAssertEqual(store.progress.xp, afterFirst)    // no second bonus
    }

    func testPurchaseRequiresCoinsAndEquipRequiresOwnership() {
        let store = ProgressStore(defaults: defaults)
        let item = CosmeticCatalog.item("orb.neon")! // price 60
        XCTAssertFalse(store.purchase(item))          // 0 coins
        XCTAssertFalse(store.isOwned("orb.neon"))

        store.applyResult(GameResult(targetSeconds: 8, actualSeconds: 8.001)) // banks coins
        let before = store.progress.coins
        XCTAssertGreaterThanOrEqual(before, item.price)
        XCTAssertTrue(store.purchase(item))
        XCTAssertEqual(store.progress.coins, before - item.price)
        store.equip(item)
        XCTAssertTrue(store.isEquipped("orb.neon"))
    }

    func testDefaultCosmeticsAlwaysOwnedAndEquipped() {
        let store = ProgressStore(defaults: defaults)
        XCTAssertTrue(store.isOwned("btn.candy"))                 // default is free
        XCTAssertEqual(store.equippedID(for: .button), "btn.candy")
    }

    func testResetClearsEverything() {
        let store = ProgressStore(defaults: defaults)
        store.applyResult(GameResult(targetSeconds: 10, actualSeconds: 10.004))
        store.clearStageIfMet(StageCatalog.stage(1), accuracyPercent: 100)
        store.reset()
        XCTAssertEqual(store.progress, PlayerProgress())
    }
}

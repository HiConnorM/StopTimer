import XCTest
@testable import StopTimer

/// Locks the composite leaderboard rating and the local service ordering.
final class LeaderboardTests: XCTestCase {

    func testRatingCombinesStagePrecisionAndPerfects() {
        var p = PlayerProgress()
        XCTAssertEqual(p.leaderboardRating, 0)

        p.highestStageCleared = 5      // 5 * 120 = 600
        p.bestError = 0.010            // 500 - 10 = 490
        p.perfectCount = 3
        p.legendaryCount = 1           // (3 + 1) * 3 = 12
        XCTAssertEqual(p.leaderboardRating, 600 + 490 + 12)
    }

    func testRatingPrecisionFloorsAtZero() {
        var p = PlayerProgress()
        p.bestError = 0.8              // 500 - 800 < 0 -> 0
        XCTAssertEqual(p.leaderboardRating, 0)
    }

    func testServiceSortsPlayerByRating() {
        let service = LocalLeaderboardService()

        let strong = LeaderboardEntry(id: "player", name: "You", rating: 9999,
                                      bestError: 0.001, highestStage: 80, isPlayer: true)
        XCTAssertEqual(service.leaderboard(including: strong).first?.isPlayer, true)

        let weak = LeaderboardEntry(id: "player", name: "You", rating: 0,
                                    bestError: nil, highestStage: 0, isPlayer: true)
        XCTAssertEqual(service.leaderboard(including: weak).last?.isPlayer, true)
    }
}

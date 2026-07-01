import XCTest
@testable import StopTimer

/// Locks the closeness / accuracy math added for the generous reward curve.
final class GameResultTests: XCTestCase {

    func testMaxRewardWindow() {
        // Floors at 0.75, otherwise 12% of the target.
        XCTAssertEqual(GameResult(targetSeconds: 3, actualSeconds: 3).maxRewardWindow, 0.75, accuracy: 1e-9)
        XCTAssertEqual(GameResult(targetSeconds: 10, actualSeconds: 10).maxRewardWindow, 1.2, accuracy: 1e-9)
    }

    func testClosenessAndAccuracy() {
        // target 10 -> window 1.2; error 0.6 -> closeness 0.5 -> 50%.
        let r = GameResult(targetSeconds: 10, actualSeconds: 10.6)
        XCTAssertEqual(r.closeness, 0.5, accuracy: 1e-9)
        XCTAssertEqual(r.accuracyPercent, 50)
    }

    func testPerfectStopIsFullAccuracy() {
        let r = GameResult(targetSeconds: 8, actualSeconds: 8)
        XCTAssertEqual(r.closeness, 1, accuracy: 1e-9)
        XCTAssertEqual(r.accuracyPercent, 100)
    }

    func testFarOffClampsToZero() {
        let r = GameResult(targetSeconds: 10, actualSeconds: 13) // error 3 > window 1.2
        XCTAssertEqual(r.closeness, 0, accuracy: 1e-9)
        XCTAssertEqual(r.accuracyPercent, 0)
    }
}

import XCTest
@testable import StopTimer

/// Locks the scoring core: grade thresholds and the signed/absolute error math.
final class AccuracyScorerTests: XCTestCase {

    // MARK: Grade bands

    /// Boundary values, tested against the pure mapping with exact literals so
    /// the same `Double` sits on both sides of the comparison (no FP drift).
    func testGradeBoundariesInclusive() {
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.003), .legendary)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.010), .perfect)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.030), .excellent)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.080), .great)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.150), .good)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.300), .close)
    }

    /// Values comfortably inside each band (immune to FP boundary drift).
    func testGradeBandsMidRange() {
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.000), .legendary)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.006), .perfect)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.020), .excellent)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.050), .great)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.120), .good)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.250), .close)
        XCTAssertEqual(AccuracyGrade.grade(forError: 0.500), .miss)
    }

    func testIsGoodOrBetter() {
        XCTAssertTrue(AccuracyGrade.good.isGoodOrBetter)
        XCTAssertTrue(AccuracyGrade.legendary.isGoodOrBetter)
        XCTAssertFalse(AccuracyGrade.close.isGoodOrBetter)
        XCTAssertFalse(AccuracyGrade.miss.isGoodOrBetter)
    }

    // MARK: Scorer wiring (mid-band actual values, either side of the target)

    func testScorerGradesFromTargetAndActual() {
        XCTAssertEqual(AccuracyScorer.score(targetSeconds: 10, actualSeconds: 10.005).grade, .perfect)
        XCTAssertEqual(AccuracyScorer.score(targetSeconds: 10, actualSeconds: 9.980).grade, .excellent)
        XCTAssertEqual(AccuracyScorer.score(targetSeconds: 10, actualSeconds: 10.100).grade, .good)
        XCTAssertEqual(AccuracyScorer.score(targetSeconds: 10, actualSeconds: 9.500).grade, .miss)
    }

    func testSignedDifferenceAndAbsoluteError() {
        let late = AccuracyScorer.score(targetSeconds: 10, actualSeconds: 10.004)
        XCTAssertEqual(late.signedDifference, 0.004, accuracy: 1e-9)
        XCTAssertEqual(late.absoluteError, 0.004, accuracy: 1e-9)

        let early = AccuracyScorer.score(targetSeconds: 10, actualSeconds: 9.994)
        XCTAssertEqual(early.signedDifference, -0.006, accuracy: 1e-9)
        XCTAssertEqual(early.absoluteError, 0.006, accuracy: 1e-9)
    }
}

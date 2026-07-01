import Foundation
import Combine

enum HuntState { case ready, running, attemptResult, won }

/// Perfect Hunt: one fixed target, retry until you hit Perfect or Legendary.
/// Score = attempts taken (fewer is better). Great for obsession.
@MainActor
final class PerfectHuntViewModel: ObservableObject {

    @Published private(set) var state: HuntState = .ready
    @Published private(set) var targetSeconds: Double = 6
    @Published private(set) var attempts = 0
    @Published private(set) var lastResult: GameResult?
    @Published private(set) var isNewBest = false
    @Published private(set) var newAchievements: [Achievement] = []

    private let timer = PrecisionTimer()
    private let progressStore: ProgressStore
    private let haptics: HapticsManager

    init(progressStore: ProgressStore, haptics: HapticsManager) {
        self.progressStore = progressStore
        self.haptics = haptics
        targetSeconds = Self.randomTarget()
    }

    var best: Int { progressStore.progress.perfectHuntBest }

    private static func randomTarget() -> Double { Double(Int.random(in: 4...10)) }

    func startRound() {
        guard state == .ready else { return }
        haptics.startTapped()
        timer.start()
        state = .running
    }

    func stop() {
        guard state == .running else { return }
        guard let elapsed = timer.stop() else { return }
        haptics.stopTapped()

        let result = AccuracyScorer.score(targetSeconds: targetSeconds, actualSeconds: elapsed)
        lastResult = result
        progressStore.applyResult(result)
        newAchievements = progressStore.refreshAchievements()
        haptics.play(for: result.grade)
        attempts += 1

        if result.grade == .perfect || result.grade == .legendary {
            isNewBest = progressStore.recordPerfectHunt(attempts: attempts)
            state = .won
        } else {
            state = .attemptResult
        }
    }

    func tryAgain() {
        guard state == .attemptResult else { return }
        lastResult = nil
        state = .ready
    }

    func retry() {
        timer.reset()
        attempts = 0
        isNewBest = false
        lastResult = nil
        targetSeconds = Self.randomTarget()
        state = .ready
    }
}

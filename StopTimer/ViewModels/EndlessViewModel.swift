import Foundation
import Combine

enum EndlessState { case ready, running, roundResult, gameOver }

/// Endless: 3 lives. Good-or-better continues and grows the streak; Close/Miss
/// costs a life. Each stop still feeds lifetime stats/achievements via `applyResult`.
@MainActor
final class EndlessViewModel: ObservableObject {

    @Published private(set) var state: EndlessState = .ready
    @Published private(set) var targetSeconds: Double = 6
    @Published private(set) var lives: Int = 3
    @Published private(set) var streak: Int = 0
    @Published private(set) var lastResult: GameResult?
    @Published private(set) var lostLife = false
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

    var best: Int { progressStore.progress.endlessBest }

    private static func randomTarget() -> Double {
        (Double.random(in: 3...12) * 2).rounded() / 2
    }

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

        if result.grade.isGoodOrBetter {
            streak += 1
            lostLife = false
        } else {
            lives -= 1
            lostLife = true
        }

        if lives <= 0 {
            isNewBest = progressStore.recordEndless(streak: streak)
            state = .gameOver
        } else {
            state = .roundResult
        }
    }

    func continueRun() {
        guard state == .roundResult else { return }
        targetSeconds = Self.randomTarget()
        lastResult = nil
        newAchievements = []
        state = .ready
    }

    func retry() {
        timer.reset()
        lives = 3
        streak = 0
        lostLife = false
        isNewBest = false
        lastResult = nil
        targetSeconds = Self.randomTarget()
        state = .ready
    }
}

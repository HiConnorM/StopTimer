import Foundation
import Combine

enum BlitzState { case ready, running, finished }

/// Blitz: 7 short targets (1–4s) back to back. Score = total accuracy across the
/// set. Fast and twitchy. Per-round precision still feeds stats/achievements.
@MainActor
final class BlitzViewModel: ObservableObject {

    let rounds = 7

    @Published private(set) var state: BlitzState = .ready
    @Published private(set) var roundIndex = 0
    @Published private(set) var totalScore = 0
    @Published private(set) var targetSeconds: Double = 2
    @Published private(set) var isNewBest = false
    @Published private(set) var newAchievements: [Achievement] = []

    private let timer = PrecisionTimer()
    private let progressStore: ProgressStore
    private let haptics: HapticsManager

    init(progressStore: ProgressStore, haptics: HapticsManager) {
        self.progressStore = progressStore
        self.haptics = haptics
        targetSeconds = Self.randomShort()
    }

    var best: Int { progressStore.progress.blitzBest }
    var roundLabel: String { "\(min(roundIndex + 1, rounds)) / \(rounds)" }

    private static func randomShort() -> Double {
        (Double.random(in: 1...4) * 10).rounded() / 10
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
        progressStore.applyResult(result)
        newAchievements = progressStore.refreshAchievements()
        haptics.play(for: result.grade)

        totalScore += result.accuracyPercent
        roundIndex += 1

        if roundIndex >= rounds {
            isNewBest = progressStore.recordBlitz(score: totalScore)
            state = .finished
        } else {
            targetSeconds = Self.randomShort()
            state = .ready
        }
    }

    func retry() {
        timer.reset()
        roundIndex = 0
        totalScore = 0
        isNewBest = false
        targetSeconds = Self.randomShort()
        state = .ready
    }
}

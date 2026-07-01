import Foundation
import Combine

/// The three meaningful states of a round.
enum RoundState {
    case ready          // target visible, Start button visible
    case running        // timer hidden, orb pulsing, tap-to-stop
    case showingResult  // result panel visible
}

/// Coordinates one round of a *stage*: drives the precision timer, scores the
/// result, applies rewards, records stage clears, and surfaces new unlocks.
@MainActor
final class GameViewModel: ObservableObject {

    @Published private(set) var state: RoundState = .ready
    @Published private(set) var stage: StageLevel
    @Published private(set) var lastResult: GameResult?
    @Published private(set) var lastReward: RewardBundle = .zero
    @Published private(set) var lastStageCleared = false
    @Published private(set) var lastLeveledUp = false
    @Published private(set) var newUnlocks: [CosmeticItem] = []
    @Published private(set) var newAchievements: [Achievement] = []

    private let timer = PrecisionTimer()
    private let progressStore: ProgressStore
    private let haptics: HapticsManager

    init(progressStore: ProgressStore, haptics: HapticsManager, startStage: StageLevel) {
        self.progressStore = progressStore
        self.haptics = haptics
        self.stage = startStage
    }

    var targetSeconds: Double { stage.targetSeconds }
    var currentCombo: Int { progressStore.progress.currentCombo }

    // MARK: Transitions

    func startRound() {
        guard state == .ready else { return }
        haptics.startTapped()
        timer.start()
        state = .running
    }

    func stopRound() {
        guard state == .running else { return }
        guard let elapsed = timer.stop() else { return }
        haptics.stopTapped()

        let result = AccuracyScorer.score(targetSeconds: targetSeconds, actualSeconds: elapsed)
        let levelBefore = progressStore.progress.playerLevel
        let unlockableBefore = progressStore.availableUnlockableIDs()

        lastResult = result
        lastReward = progressStore.applyResult(result)
        lastStageCleared = progressStore.clearStageIfMet(stage, accuracyPercent: result.accuracyPercent)
        newAchievements = progressStore.refreshAchievements()

        lastLeveledUp = progressStore.progress.playerLevel > levelBefore
        let unlockableAfter = progressStore.availableUnlockableIDs()
        newUnlocks = unlockableAfter.subtracting(unlockableBefore)
            .compactMap { CosmeticCatalog.item($0) }

        haptics.play(for: result.grade)
        state = .showingResult
    }

    /// Replay the same stage.
    func retry() {
        timer.reset()
        clearRoundOutput()
        state = .ready
    }

    /// Advance to the next stage (only meaningful when the current one was cleared).
    func nextStage() {
        stage = StageCatalog.stage(stage.stageNumber + 1)
        timer.reset()
        clearRoundOutput()
        state = .ready
    }

    private func clearRoundOutput() {
        lastResult = nil
        lastReward = .zero
        lastStageCleared = false
        lastLeveledUp = false
        newUnlocks = []
        newAchievements = []
    }
}

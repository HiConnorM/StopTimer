import Foundation
import Combine

/// The three meaningful states of a round. The instantaneous "stopped" frame is
/// collapsed into the `stopRound()` transition.
enum RoundState {
    case ready          // target visible, Start button visible
    case running        // timer hidden, orb pulsing, Stop button visible
    case showingResult  // result panel visible
}

/// Coordinates one round of play: owns the target, drives the precision timer,
/// scores the result, applies rewards to the store, and exposes everything the
/// game/result views render.
@MainActor
final class GameViewModel: ObservableObject {

    @Published private(set) var state: RoundState = .ready
    @Published private(set) var targetSeconds: Double = TargetGenerator.next()
    @Published private(set) var lastResult: GameResult?
    @Published private(set) var lastReward: RewardBundle = .zero

    private let timer = PrecisionTimer()
    private let progressStore: ProgressStore
    private let haptics: HapticsManager

    init(progressStore: ProgressStore, haptics: HapticsManager) {
        self.progressStore = progressStore
        self.haptics = haptics
    }

    /// Combo coming into the current round (for the "Trust your timing" prompt etc.).
    var currentCombo: Int { progressStore.progress.currentCombo }

    // MARK: Transitions

    func startRound() {
        guard state == .ready else { return }   // can only start from ready
        haptics.startTapped()
        timer.start()
        state = .running
    }

    func stopRound() {
        guard state == .running else { return }  // no stop before start, no double stop
        guard let elapsed = timer.stop() else { return }

        haptics.stopTapped()
        let result = AccuracyScorer.score(targetSeconds: targetSeconds, actualSeconds: elapsed)
        lastResult = result
        lastReward = progressStore.applyResult(result)
        haptics.play(for: result.grade)
        state = .showingResult
    }

    /// Replay the same target.
    func retry() {
        timer.reset()
        lastResult = nil
        lastReward = .zero
        state = .ready
    }

    /// Fresh target.
    func next() {
        targetSeconds = TargetGenerator.next()
        timer.reset()
        lastResult = nil
        lastReward = .zero
        state = .ready
    }
}

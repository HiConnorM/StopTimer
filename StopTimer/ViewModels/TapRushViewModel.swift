import Foundation
import Combine

enum TapRushState { case ready, running, result }

/// Tap Rush: tap as many times as possible within the countdown. Score = tap count.
/// The window is measured by the monotonic `PrecisionTimer`; a UI ticker just
/// drives the countdown display and ends the round (no precision scoring here).
@MainActor
final class TapRushViewModel: ObservableObject {

    let duration: Double = 5.0

    @Published private(set) var state: TapRushState = .ready
    @Published private(set) var tapCount: Int = 0
    @Published private(set) var timeRemaining: Double = 5.0
    @Published private(set) var isNewBest = false
    @Published private(set) var xpEarned = 0
    @Published private(set) var coinsEarned = 0

    private let timer = PrecisionTimer()
    private let progressStore: ProgressStore
    private let haptics: HapticsManager

    init(progressStore: ProgressStore, haptics: HapticsManager) {
        self.progressStore = progressStore
        self.haptics = haptics
    }

    var best: Int { progressStore.progress.bestTapCount }
    var tapsPerSecond: Double { Double(tapCount) / duration }

    func start() {
        guard state == .ready else { return }
        tapCount = 0
        timeRemaining = duration
        haptics.startTapped()
        timer.start()
        state = .running
    }

    func tap() {
        guard state == .running else { return }
        tapCount += 1
        haptics.tick()
    }

    /// Called frequently by the view while running to update the countdown.
    func tick() {
        guard state == .running else { return }
        let elapsed = timer.elapsedSeconds
        timeRemaining = max(0, duration - elapsed)
        if elapsed >= duration { end() }
    }

    private func end() {
        timer.reset()
        xpEarned = tapCount * 3
        coinsEarned = max(0, tapCount / 2)
        isNewBest = progressStore.recordTapRush(taps: tapCount)
        state = .result
    }

    func retry() {
        timer.reset()
        tapCount = 0
        timeRemaining = duration
        isNewBest = false
        state = .ready
    }
}

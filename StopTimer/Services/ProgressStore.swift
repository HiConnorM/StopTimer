import Foundation
import Combine

/// Owns the player's persisted progress. Single shared instance, injected via
/// `.environmentObject`. Loads on init, saves after every mutation. JSON in
/// UserDefaults keeps the MVP simple (no backend, no files to manage).
final class ProgressStore: ObservableObject {

    @Published private(set) var progress: PlayerProgress

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.progress = ProgressStore.load(from: defaults)
    }

    // MARK: Mutation

    /// Applies one round's result: updates stats, combo, and currency, then saves.
    /// Returns the `RewardBundle` so the result screen can show what was earned.
    @discardableResult
    func applyResult(_ result: GameResult) -> RewardBundle {
        let reward = RewardCalculator.reward(for: result.grade,
                                             currentCombo: progress.currentCombo)

        var p = progress
        p.lifetimeAttempts += 1
        p.totalAbsoluteError += result.absoluteError
        p.bestError = min(p.bestError ?? result.absoluteError, result.absoluteError)

        p.xp += reward.xp
        p.coins += reward.coins
        p.currentCombo = reward.newCombo
        p.longestCombo = max(p.longestCombo, reward.newCombo)

        switch result.grade {
        case .legendary: p.legendaryCount += 1
        case .perfect:   p.perfectCount += 1
        case .excellent: p.excellentCount += 1
        case .great:     p.greatCount += 1
        case .good:      p.goodCount += 1
        case .close:     p.closeCount += 1
        case .miss:      p.missCount += 1
        }

        progress = p
        save()
        return reward
    }

    func reset() {
        progress = PlayerProgress()
        save()
    }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Constants.progressKey)
    }

    private static func load(from defaults: UserDefaults) -> PlayerProgress {
        guard
            let data = defaults.data(forKey: Constants.progressKey),
            let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data)
        else { return PlayerProgress() }
        return decoded
    }
}

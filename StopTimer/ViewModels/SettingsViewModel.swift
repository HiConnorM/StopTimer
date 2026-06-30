import Foundation
import Combine

/// Owns `GameSettings`, persists changes immediately, and exposes the reset action.
/// A single shared instance is injected so `HapticsManager` can read live settings.
@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var settings: GameSettings {
        didSet { save() }
    }

    private let defaults: UserDefaults
    private let progressStore: ProgressStore

    init(progressStore: ProgressStore, defaults: UserDefaults = .standard) {
        self.progressStore = progressStore
        self.defaults = defaults
        self.settings = SettingsViewModel.load(from: defaults)
    }

    func resetProgress() {
        progressStore.reset()
    }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: Constants.settingsKey)
    }

    private static func load(from defaults: UserDefaults) -> GameSettings {
        guard
            let data = defaults.data(forKey: Constants.settingsKey),
            let decoded = try? JSONDecoder().decode(GameSettings.self, from: data)
        else { return .default }
        return decoded
    }
}

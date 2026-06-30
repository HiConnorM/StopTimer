import SwiftUI

@main
struct StopTimerApp: App {

    /// Composition root: one shared progress store, one settings view model, one
    /// haptics manager. The haptics manager reads live settings so toggling them
    /// takes effect immediately.
    @StateObject private var progressStore: ProgressStore
    @StateObject private var settingsVM: SettingsViewModel
    private let haptics = HapticsManager()

    init() {
        let store = ProgressStore()
        let settings = SettingsViewModel(progressStore: store)
        _progressStore = StateObject(wrappedValue: store)
        _settingsVM = StateObject(wrappedValue: settings)
        haptics.settingsProvider = { settings.settings }
    }

    var body: some Scene {
        WindowGroup {
            RootView(progressStore: progressStore,
                     settingsVM: settingsVM,
                     haptics: haptics)
                .environmentObject(progressStore)
                .environmentObject(settingsVM)
        }
    }
}

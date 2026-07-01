import SwiftUI

/// App shell: bottom-tab navigation (Play / Store / Profile / Settings). The
/// gameplay flow is presented full-screen from within the Play (Home) tab.
struct RootView: View {
    let progressStore: ProgressStore
    let settingsVM: SettingsViewModel
    let haptics: HapticsManager

    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            HomeView(progressStore: progressStore, haptics: haptics)
                .tabItem { Label("Play", systemImage: "play.fill") }.tag(0)

            StoreView()
                .tabItem { Label("Store", systemImage: "bag.fill") }.tag(1)

            ProfileView(progressStore: progressStore)
                .tabItem { Label("Profile", systemImage: "person.fill") }.tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(3)
        }
        .tint(Constants.Theme.accent)
        .preferredColorScheme(.light)
    }
}

import SwiftUI

/// App shell: bottom-tab navigation (Play / Profile / Settings). The Play tab is
/// the Home screen; tapping Play presents the gameplay flow full-screen.
struct RootView: View {
    let progressStore: ProgressStore
    let settingsVM: SettingsViewModel
    let haptics: HapticsManager

    @State private var showingGame = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(progressStore: progressStore, onPlay: { showingGame = true })
                .tabItem { Label("Play", systemImage: "play.fill") }
                .tag(0)

            ProfileView(progressStore: progressStore)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(2)
        }
        .tint(Constants.Theme.accent)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showingGame) {
            GameView(progressStore: progressStore,
                     haptics: haptics,
                     onHome: { showingGame = false })
                .environmentObject(settingsVM)
                .preferredColorScheme(.dark)
        }
    }
}

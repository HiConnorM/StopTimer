import SwiftUI

/// Settings: feedback/motion toggles, destructive reset, and credits.
struct SettingsView: View {
    @EnvironmentObject private var vm: SettingsViewModel
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Constants.Theme.backgroundTop, Constants.Theme.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            Form {
                Section("Feedback") {
                    Toggle("Haptics", isOn: $vm.settings.hapticsEnabled)
                    Toggle("Sound", isOn: $vm.settings.soundEnabled)
                }

                Section("Accessibility") {
                    Toggle("Reduced Motion", isOn: $vm.settings.reducedMotion)
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset Progress", systemImage: "trash")
                    }
                }

                Section("About") {
                    LabeledContent("Game", value: "Stop Timer")
                    LabeledContent("Version", value: "1.0 (MVP)")
                    Text("Privacy: all data stays on your device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .tint(Constants.Theme.accent)
        }
        .confirmationDialog("Reset all progress?",
                            isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) { vm.resetProgress() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently clears XP, coins, combos, and all stats.")
        }
    }
}

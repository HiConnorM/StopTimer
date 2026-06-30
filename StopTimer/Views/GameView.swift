import SwiftUI

/// The gameplay screen. Switches between the three round states and hosts the
/// result panel. Owns its `GameViewModel`; reads settings for reduced motion.
struct GameView: View {
    @StateObject private var vm: GameViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    let onHome: () -> Void

    init(progressStore: ProgressStore, haptics: HapticsManager, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: GameViewModel(progressStore: progressStore, haptics: haptics))
        self.onHome = onHome
    }

    private var reducedMotion: Bool { settingsVM.settings.reducedMotion }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Constants.Theme.backgroundTop, Constants.Theme.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch vm.state {
            case .ready:   readyView
            case .running: runningView
            case .showingResult:
                if let result = vm.lastResult {
                    ResultView(result: result,
                               reward: vm.lastReward,
                               reducedMotion: reducedMotion,
                               onRetry: { vm.retry() },
                               onNext:  { vm.next() },
                               onHome:  onHome)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.state == .showingResult)
        .overlay(alignment: .topLeading) { closeButton }
    }

    // MARK: States

    private var readyView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("STOP AT EXACTLY")
                .font(.subheadline.weight(.semibold))
                .tracking(3)
                .foregroundStyle(Constants.Theme.textSecondary)
            Text(TimeFormatting.seconds(vm.targetSeconds))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Constants.Theme.textPrimary)
                .shadow(color: Constants.Theme.accent.opacity(0.35), radius: 18)
            Text("seconds")
                .foregroundStyle(Constants.Theme.textSecondary)
            if vm.currentCombo > 0 {
                Label("\(vm.currentCombo) combo", systemImage: "flame.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
            Spacer()
            PrimaryButton(title: "START") { vm.startRound() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }

    private var runningView: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Trust your timing")
                .font(.headline)
                .foregroundStyle(Constants.Theme.textSecondary)
            TimerOrbView(reducedMotion: reducedMotion)
            Text("Target \(TimeFormatting.seconds(vm.targetSeconds))s")
                .font(.footnote)
                .foregroundStyle(Constants.Theme.textSecondary.opacity(0.7))
            Spacer()
            PrimaryButton(title: "STOP", tint: .white, foreground: .black) { vm.stopRound() }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
        }
    }

    @ViewBuilder private var closeButton: some View {
        if vm.state != .showingResult {
            Button(action: onHome) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(Constants.Theme.textSecondary)
                    .padding(12)
                    .background(Constants.Theme.card, in: Circle())
            }
            .padding(.leading, 20)
            .padding(.top, 8)
        }
    }
}

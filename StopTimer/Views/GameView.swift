import SwiftUI

/// The gameplay screen. Switches between the three round states and hosts the
/// result panel. Owns its `GameViewModel`; reads settings for reduced motion.
struct GameView: View {
    @StateObject private var vm: GameViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    let onHome: () -> Void

    @State private var comboPop = false

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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.state == .showingResult)
        .overlay(alignment: .topLeading) { closeButton }
    }

    // MARK: States

    private var readyView: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("STOP AT EXACTLY")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .tracking(3)
                .foregroundStyle(Constants.Theme.textSecondary)

            Text(TimeFormatting.target(vm.targetSeconds))
                .font(.system(size: 116, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("seconds")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)

            if vm.currentCombo > 0 {
                comboBadge
            }
            Spacer()
            PrimaryButton(title: "START") { vm.startRound() }
                .padding(.horizontal, 26)
                .padding(.bottom, 34)
        }
    }

    private var runningView: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("Trust your timing")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textSecondary)
            TimerOrbView(reducedMotion: reducedMotion)
            Text("Tap when you feel it")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Constants.Theme.textSecondary.opacity(0.8))
            Spacer()
            PrimaryButton(title: "STOP",
                          face: Constants.Theme.ink,
                          lip: Constants.Theme.inkDark) { vm.stopRound() }
                .padding(.horizontal, 26)
                .padding(.bottom, 34)
        }
    }

    private var comboBadge: some View {
        Label("\(vm.currentCombo) streak", systemImage: "flame.fill")
            .font(.system(.subheadline, design: .rounded).weight(.heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Constants.Theme.coin, in: Capsule())
            .shadow(color: Constants.Theme.coin.opacity(0.5), radius: 8, y: 3)
            .scaleEffect(comboPop ? 1.0 : 0.6)
            .onAppear {
                guard !reducedMotion else { comboPop = true; return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) { comboPop = true }
            }
            .onDisappear { comboPop = false }
    }

    @ViewBuilder private var closeButton: some View {
        if vm.state != .showingResult {
            Button(action: onHome) {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Constants.Theme.textSecondary)
                    .padding(12)
                    .background(Constants.Theme.card, in: Circle())
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            }
            .padding(.leading, 20)
            .padding(.top, 8)
        }
    }
}

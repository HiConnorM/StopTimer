import SwiftUI

/// The gameplay screen for a stage. Themed by the equipped cosmetics, shows the
/// stage HUD, runs distractions while the timer is hidden, and hosts the result.
struct GameView: View {
    @StateObject private var vm: GameViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progress: ProgressStore
    let onHome: () -> Void

    @State private var comboPop = false

    init(progressStore: ProgressStore, haptics: HapticsManager, stage: StageLevel, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: GameViewModel(progressStore: progressStore, haptics: haptics, startStage: stage))
        self.onHome = onHome
    }

    private var reducedMotion: Bool { settingsVM.settings.reducedMotion }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch vm.state {
            case .ready:   readyView
            case .running: runningView
            case .showingResult:
                if let result = vm.lastResult {
                    ResultView(result: result,
                               reward: vm.lastReward,
                               stage: vm.stage,
                               stageCleared: vm.lastStageCleared,
                               leveledUp: vm.lastLeveledUp,
                               newUnlocks: vm.newUnlocks,
                               reducedMotion: reducedMotion,
                               onRetry: { vm.retry() },
                               onNext:  { vm.nextStage() },
                               onHome:  onHome)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.state == .showingResult)
        .overlay(alignment: .top) { if vm.state != .showingResult { stageHUD } }
        .overlay(alignment: .topLeading) { closeButton }
    }

    // MARK: HUD

    private var stageHUD: some View {
        HStack(spacing: 10) {
            hudChip(symbol: "flag.checkered", text: "Stage \(vm.stage.stageNumber)", tint: Constants.Theme.accent)
            hudChip(symbol: "target", text: "\(vm.stage.requiredAccuracyPercent)% to clear", tint: Constants.Theme.green)
            if vm.stage.distractionLevel > 0 {
                hudChip(symbol: "bolt.trianglebadge.exclamationmark.fill",
                        text: "D\(vm.stage.distractionLevel)", tint: Constants.Theme.purple)
            }
        }
        .padding(.top, 6)
    }

    private func hudChip(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol).font(.caption2)
            Text(text).font(.system(.caption2, design: .rounded).weight(.bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Constants.Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
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
                .font(.system(size: 112, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("seconds")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)

            if vm.currentCombo > 0 { comboBadge }
            Spacer()
            BigRedButton(title: "START") { vm.startRound() }
                .padding(.bottom, 24)
        }
    }

    private var runningView: some View {
        ZStack {
            DistractionOverlayView(level: vm.stage.distractionLevel, reducedMotion: reducedMotion)

            VStack(spacing: 26) {
                Spacer()
                Text("Trust your timing")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.textSecondary)

                // The orb IS the stop button.
                Button { vm.stopRound() } label: {
                    TimerOrbView(colors: progress.orbColors, reducedMotion: reducedMotion)
                        .overlay(
                            Text("STOP")
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .tracking(2)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
                        )
                }
                .buttonStyle(PressableStyle(scale: 0.90))

                Text("Tap the orb to stop")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(Constants.Theme.textSecondary.opacity(0.85))
                Spacer()
            }
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
            .padding(.top, 44)
        }
    }
}

import SwiftUI

/// Endless mode screen: hearts + streak HUD, tap-the-orb timing, a compact
/// per-round result, and a game-over screen with confetti on a new best.
struct EndlessGameView: View {
    @StateObject private var vm: EndlessViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progress: ProgressStore
    let onHome: () -> Void

    init(progressStore: ProgressStore, haptics: HapticsManager, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: EndlessViewModel(progressStore: progressStore, haptics: haptics))
        self.onHome = onHome
    }

    private var reducedMotion: Bool { settingsVM.settings.reducedMotion }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if vm.state == .roundResult && vm.lostLife { LoseFlashView(reducedMotion: reducedMotion) }

            switch vm.state {
            case .ready:       readyView
            case .running:     runningView
            case .roundResult: roundResultView
            case .gameOver:    gameOverView
            }

            if vm.state == .gameOver && vm.isNewBest { ConfettiView(reducedMotion: reducedMotion) }
        }
        .overlay(alignment: .top) { if vm.state == .ready || vm.state == .running { hud } }
        .overlay(alignment: .topLeading) { if vm.state != .gameOver { closeButton } }
    }

    // MARK: HUD

    private var hud: some View {
        HStack(spacing: 14) {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < vm.lives ? "heart.fill" : "heart")
                        .foregroundStyle(Constants.Theme.accent)
                }
            }
            .font(.headline)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Constants.Theme.card, in: Capsule())

            Label("\(vm.streak)", systemImage: "flame.fill")
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.orange)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Constants.Theme.card, in: Capsule())
        }
        .padding(.top, 6)
    }

    // MARK: States

    private var readyView: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("STOP AT EXACTLY")
                .font(.system(.subheadline, design: .rounded).weight(.bold)).tracking(3)
                .foregroundStyle(Constants.Theme.textSecondary)
            Text(TimeFormatting.target(vm.targetSeconds))
                .font(.system(size: 108, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
                .minimumScaleFactor(0.5).lineLimit(1)
            Text("seconds").font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
            BigRedButton(title: "START") { vm.startRound() }.padding(.bottom, 24)
        }
    }

    private var runningView: some View {
        VStack(spacing: 26) {
            Spacer()
            Text("Trust your timing")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textSecondary)
            Button { vm.stop() } label: {
                TimerOrbView(colors: progress.orbColors, reducedMotion: reducedMotion)
                    .overlay(Text("STOP").font(.system(size: 40, weight: .black, design: .rounded))
                        .tracking(2).foregroundStyle(.white).shadow(color: .black.opacity(0.35), radius: 2, y: 2))
            }
            .buttonStyle(PressableStyle(scale: 0.90))
            Text("Tap the orb to stop")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(Constants.Theme.textSecondary.opacity(0.85))
            Spacer()
        }
    }

    private var roundResultView: some View {
        VStack(spacing: 18) {
            Spacer()
            if let r = vm.lastResult {
                GradeBadge(grade: r.grade, reducedMotion: reducedMotion)
                Text(vm.lostLife ? "Life lost!" : "Streak \(vm.streak)")
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(vm.lostLife ? Constants.Theme.accent : Constants.Theme.green)
                Text("\(vm.lives) lives left · \(TimeFormatting.signed(r.signedDifference))s")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            Spacer()
            PrimaryButton(title: "CONTINUE", face: Constants.Theme.purple, icon: "arrow.right") { vm.continueRun() }
                .padding(.horizontal, 30).padding(.bottom, 34)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("GAME OVER").font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text(vm.isNewBest ? "NEW BEST STREAK!" : "Streak")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(vm.isNewBest ? Constants.Theme.coin : Constants.Theme.textSecondary)
            Text("\(vm.streak)")
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.purple)
            Label("Best: \(vm.best)", systemImage: "trophy.fill")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.coin)
            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: "PLAY AGAIN", face: Constants.Theme.purple, icon: "arrow.counterclockwise") { vm.retry() }
                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Constants.Theme.textSecondary)
                }
            }
            .padding(.horizontal, 30).padding(.bottom, 30)
        }
    }

    private var closeButton: some View {
        Button(action: onHome) {
            Image(systemName: "xmark").font(.headline.weight(.bold))
                .foregroundStyle(Constants.Theme.textSecondary)
                .padding(12).background(Constants.Theme.card, in: Circle())
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        }
        .padding(.leading, 20).padding(.top, 44)
    }
}

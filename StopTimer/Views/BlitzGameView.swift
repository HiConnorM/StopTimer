import SwiftUI

/// Blitz mode: rapid short-target rounds with a running score, then a finish
/// screen (confetti on a new best).
struct BlitzGameView: View {
    @StateObject private var vm: BlitzViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progress: ProgressStore
    let onHome: () -> Void

    init(progressStore: ProgressStore, haptics: HapticsManager, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: BlitzViewModel(progressStore: progressStore, haptics: haptics))
        self.onHome = onHome
    }

    private var reducedMotion: Bool { settingsVM.settings.reducedMotion }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch vm.state {
            case .ready:    readyView
            case .running:  runningView
            case .finished: finishedView
            }

            if vm.state == .finished && vm.isNewBest { ConfettiView(reducedMotion: reducedMotion) }
        }
        .overlay(alignment: .top) { if vm.state != .finished { hud } }
        .overlay(alignment: .topLeading) { if vm.state != .finished { closeButton } }
    }

    private var hud: some View {
        HStack(spacing: 14) {
            chip(symbol: "bolt.fill", text: "Round \(vm.roundLabel)", tint: Constants.Theme.teal)
            chip(symbol: "star.fill", text: "\(vm.totalScore)", tint: Constants.Theme.coin)
        }
        .padding(.top, 6)
    }

    private var readyView: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("QUICK! STOP AT")
                .font(.system(.subheadline, design: .rounded).weight(.bold)).tracking(3)
                .foregroundStyle(Constants.Theme.textSecondary)
            Text(TimeFormatting.target(vm.targetSeconds))
                .font(.system(size: 112, weight: .black, design: .rounded))
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

    private var finishedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(vm.isNewBest ? "NEW BEST!" : "BLITZ DONE")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(vm.isNewBest ? Constants.Theme.coin : Constants.Theme.textPrimary)
            Text("\(vm.totalScore)")
                .font(.system(size: 100, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.teal)
            Text("total accuracy · \(vm.rounds) rounds")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)
            Label("Best: \(vm.best)", systemImage: "trophy.fill")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.coin)
            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: "PLAY AGAIN", face: Constants.Theme.teal, icon: "arrow.counterclockwise") { vm.retry() }
                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Constants.Theme.textSecondary)
                }
            }
            .padding(.horizontal, 30).padding(.bottom, 30)
        }
    }

    private func chip(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol).font(.caption2)
            Text(text).font(.system(.caption, design: .rounded).weight(.bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Constants.Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
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

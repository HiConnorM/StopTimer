import SwiftUI

/// Perfect Hunt: keep retrying one target until you hit Perfect/Legendary.
struct PerfectHuntView: View {
    @StateObject private var vm: PerfectHuntViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progress: ProgressStore
    let onHome: () -> Void

    init(progressStore: ProgressStore, haptics: HapticsManager, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: PerfectHuntViewModel(progressStore: progressStore, haptics: haptics))
        self.onHome = onHome
    }

    private var reducedMotion: Bool { settingsVM.settings.reducedMotion }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch vm.state {
            case .ready:         readyView
            case .running:       runningView
            case .attemptResult: attemptResultView
            case .won:           wonView
            }

            if vm.state == .won { ConfettiView(reducedMotion: reducedMotion) }
        }
        .overlay(alignment: .top) { if vm.state != .won { hud } }
        .overlay(alignment: .topLeading) { if vm.state != .won { closeButton } }
    }

    private var hud: some View {
        HStack(spacing: 14) {
            chip(symbol: "scope", text: "Target \(TimeFormatting.target(vm.targetSeconds))s", tint: Constants.Theme.pink)
            chip(symbol: "arrow.counterclockwise", text: "Try \(vm.attempts + (vm.state == .attemptResult ? 0 : 1))", tint: Constants.Theme.purple)
            if vm.best > 0 { chip(symbol: "trophy.fill", text: "Best \(vm.best)", tint: Constants.Theme.coin) }
        }
        .padding(.top, 6)
    }

    private var readyView: some View {
        VStack(spacing: 22) {
            Spacer()
            Text("HIT PERFECT AT")
                .font(.system(.subheadline, design: .rounded).weight(.bold)).tracking(3)
                .foregroundStyle(Constants.Theme.textSecondary)
            Text(TimeFormatting.target(vm.targetSeconds))
                .font(.system(size: 112, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
                .minimumScaleFactor(0.5).lineLimit(1)
            Text("within 0.010s").font(.system(.title3, design: .rounded).weight(.semibold))
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

    private var attemptResultView: some View {
        VStack(spacing: 16) {
            Spacer()
            if let r = vm.lastResult {
                GradeBadge(grade: r.grade, reducedMotion: reducedMotion)
                Text(r.encouragement)
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(Constants.Theme.orange)
                Text("Off by \(TimeFormatting.seconds(r.absoluteError))s · attempt \(vm.attempts)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            Spacer()
            PrimaryButton(title: "TRY AGAIN", face: Constants.Theme.pink, icon: "arrow.counterclockwise") { vm.tryAgain() }
                .padding(.horizontal, 30).padding(.bottom, 34)
        }
    }

    private var wonView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "star.fill").font(.system(size: 56)).foregroundStyle(Constants.Theme.coin)
            Text("PERFECT!").font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.pink)
            Text("in \(vm.attempts) attempt\(vm.attempts == 1 ? "" : "s")")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textPrimary)
            Label(vm.isNewBest ? "New record — fewest attempts!" : "Best: \(vm.best)", systemImage: "trophy.fill")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.coin)
            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: "NEW TARGET", face: Constants.Theme.pink, icon: "arrow.right") { vm.retry() }
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
            Text(text).font(.system(.caption2, design: .rounded).weight(.bold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10).padding(.vertical, 6)
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

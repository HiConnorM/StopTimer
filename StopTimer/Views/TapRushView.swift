import SwiftUI

/// Tap Rush screen: mash the button as fast as you can before the countdown ends.
struct TapRushView: View {
    @StateObject private var vm: TapRushViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progress: ProgressStore
    let onHome: () -> Void

    private let ticker = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    init(progressStore: ProgressStore, haptics: HapticsManager, onHome: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: TapRushViewModel(progressStore: progressStore, haptics: haptics))
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
            case .result:  resultView
            }

            if vm.state == .result && vm.isNewBest { ConfettiView(reducedMotion: reducedMotion) }
        }
        .overlay(alignment: .topLeading) {
            if vm.state != .result { closeButton }
        }
        .onReceive(ticker) { _ in vm.tick() }
    }

    // MARK: States

    private var readyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hand.tap.fill").font(.system(size: 56)).foregroundStyle(Constants.Theme.orange)
            Text("TAP RUSH")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text("Tap as fast as you can for \(Int(vm.duration)) seconds!")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)
                .multilineTextAlignment(.center)
            Label("Best: \(vm.best)", systemImage: "trophy.fill")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.coin)
            Spacer()
            PrimaryButton(title: "START", face: Constants.Theme.orange, icon: "bolt.fill") { vm.start() }
                .padding(.horizontal, 30).padding(.bottom, 34)
        }
    }

    private var runningView: some View {
        VStack(spacing: 18) {
            Spacer().frame(height: 40)
            countdownBar
            Text("\(vm.tapCount)")
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
                .contentTransition(.numericText())
            Text("TAPS").font(.system(.headline, design: .rounded).weight(.bold))
                .tracking(3).foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
            BigRedButton(title: "TAP!", diameter: 200) { vm.tap() }
            Spacer()
        }
    }

    private var countdownBar: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1fs", vm.timeRemaining))
                .font(.system(.title3, design: .monospaced).weight(.black))
                .foregroundStyle(Constants.Theme.orange)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.08))
                    Capsule().fill(LinearGradient(colors: [Constants.Theme.orange, Constants.Theme.accent],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * (vm.timeRemaining / vm.duration))
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 40)
    }

    private var resultView: some View {
        VStack(spacing: 18) {
            Spacer()
            Text(vm.isNewBest ? "NEW BEST!" : "TIME'S UP")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(vm.isNewBest ? Constants.Theme.coin : Constants.Theme.textPrimary)
            Text("\(vm.tapCount)")
                .font(.system(size: 100, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.orange)
            Text("taps · \(String(format: "%.1f", vm.tapsPerSecond))/sec")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)

            HStack(spacing: 24) {
                stat("XP", "+\(vm.xpEarned)", "bolt.fill", Constants.Theme.blue)
                stat("Coins", "+\(vm.coinsEarned)", "dollarsign.circle.fill", Constants.Theme.coin)
                stat("Best", "\(vm.best)", "trophy.fill", Constants.Theme.orange)
            }
            .padding(.top, 4)

            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: "RETRY", face: Constants.Theme.orange, icon: "arrow.counterclockwise") { vm.retry() }
                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Constants.Theme.textSecondary)
                }
            }
            .padding(.horizontal, 30).padding(.bottom, 30)
        }
    }

    private func stat(_ label: String, _ value: String, _ symbol: String, _ tint: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(value).font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text(label.uppercased()).font(.caption2.weight(.bold)).foregroundStyle(Constants.Theme.textSecondary)
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

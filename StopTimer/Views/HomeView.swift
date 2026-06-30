import SwiftUI

/// Landing screen. Logo, level/coins header, a punchy hook, the big juicy Play
/// button, and two at-a-glance stat cards.
struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    let onPlay: () -> Void

    init(progressStore: ProgressStore, onPlay: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: HomeViewModel(progressStore: progressStore))
        self.onPlay = onPlay
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Constants.Theme.backgroundTop, Constants.Theme.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                header

                Spacer()

                VStack(spacing: 8) {
                    Text("STOP")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Constants.Theme.accent)
                    Text("TIMER")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Constants.Theme.textPrimary)
                        .offset(y: -18)
                }
                .shadow(color: Constants.Theme.accent.opacity(0.20), radius: 14, y: 6)

                Text("One try. No excuses.")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
                    .offset(y: -10)

                Spacer()

                HStack(spacing: 14) {
                    StatCard(label: "Best Error", value: vm.bestErrorText,
                             systemImage: "target")
                    StatCard(label: "Perfects", value: "\(vm.perfectCount)",
                             systemImage: "star.fill", tint: Constants.Theme.coin)
                }
                .padding(.horizontal, 24)

                PrimaryButton(title: "PLAY") { onPlay() }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 6)
            }
            .padding(.top, 12)
        }
    }

    private var header: some View {
        HStack {
            pill(symbol: "person.fill", text: "Lv \(vm.playerLevel)", tint: Constants.Theme.accent)
            Spacer()
            pill(symbol: "dollarsign.circle.fill", text: "\(vm.coins)", tint: Constants.Theme.coin)
        }
        .padding(.horizontal, 24)
    }

    private func pill(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(text)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textPrimary)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Constants.Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }
}

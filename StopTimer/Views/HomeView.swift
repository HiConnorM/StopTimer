import SwiftUI

/// Landing screen. Logo, level/coins header, the big Play button, and two
/// at-a-glance stat cards. Play opens the gameplay flow.
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

            VStack(spacing: 24) {
                header

                Spacer()

                VStack(spacing: 6) {
                    Text("STOP TIMER")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Constants.Theme.textPrimary)
                        .shadow(color: Constants.Theme.accent.opacity(0.4), radius: 16)
                    Text("Perfect Second Challenge")
                        .font(.subheadline)
                        .foregroundStyle(Constants.Theme.textSecondary)
                }

                Spacer()

                HStack(spacing: 14) {
                    StatCard(label: "Best Error", value: vm.bestErrorText,
                             systemImage: "target")
                    StatCard(label: "Perfects", value: "\(vm.perfectCount)",
                             systemImage: "star.fill", tint: .yellow)
                }
                .padding(.horizontal, 24)

                PrimaryButton(title: "PLAY") { onPlay() }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
            .padding(.top, 12)
        }
    }

    private var header: some View {
        HStack {
            pill(symbol: "person.fill", text: "Lv \(vm.playerLevel)", tint: Constants.Theme.accent)
            Spacer()
            pill(symbol: "dollarsign.circle.fill", text: "\(vm.coins)", tint: .yellow)
        }
        .padding(.horizontal, 24)
    }

    private func pill(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(text).font(.subheadline.weight(.semibold))
                .foregroundStyle(Constants.Theme.textPrimary)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Constants.Theme.card, in: Capsule())
        .overlay(Capsule().stroke(Constants.Theme.cardStroke, lineWidth: 1))
    }
}

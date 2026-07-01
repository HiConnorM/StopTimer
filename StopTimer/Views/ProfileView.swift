import SwiftUI

/// Stats screen: level + XP bar, coins, rank placeholder, and a grid of lifetime stats.
struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel

    init(progressStore: ProgressStore) {
        _vm = StateObject(wrappedValue: ProfileViewModel(progressStore: progressStore))
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Constants.Theme.backgroundTop, Constants.Theme.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    levelHeader

                    LazyVGrid(columns: columns, spacing: 14) {
                        StatCard(label: "Best Error", value: vm.bestErrorText, systemImage: "target", tint: Constants.Theme.accent)
                        StatCard(label: "Avg Error", value: vm.averageErrorText, systemImage: "chart.line.downtrend.xyaxis", tint: Constants.Theme.mint)
                        StatCard(label: "Stages Cleared", value: "\(vm.highestStageCleared)", systemImage: "flag.checkered", tint: Constants.Theme.green)
                        StatCard(label: "Perfects", value: "\(vm.perfectCount)", systemImage: "star.fill", tint: Constants.Theme.coin)
                        StatCard(label: "Legendary", value: "\(vm.legendaryCount)", systemImage: "crown.fill", tint: Constants.Theme.purple)
                        StatCard(label: "Longest Combo", value: "\(vm.longestCombo)", systemImage: "flame.fill", tint: Constants.Theme.orange)
                    }
                }
                .padding(20)
            }
        }
    }

    private var levelHeader: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LEVEL")
                        .font(.caption2.weight(.bold)).tracking(2)
                        .foregroundStyle(Constants.Theme.textSecondary)
                    Text("\(vm.playerLevel)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Constants.Theme.textPrimary)
                    if let title = vm.equippedTitle {
                        Text("“\(title)”")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .foregroundStyle(Constants.Theme.purple)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Label(vm.rankTitle, systemImage: "rosette")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(Constants.Theme.accent)
                    Label("\(vm.coins)", systemImage: "dollarsign.circle.fill")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Constants.Theme.coin)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.07))
                        Capsule().fill(Constants.Theme.accent)
                            .frame(width: max(8, geo.size.width * vm.levelProgress))
                    }
                }
                .frame(height: 12)
                Text("\(vm.xpIntoLevel) / \(Constants.xpPerLevel) XP")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
    }
}

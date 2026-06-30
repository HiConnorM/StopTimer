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
                        StatCard(label: "Best Error", value: vm.bestErrorText, systemImage: "target")
                        StatCard(label: "Avg Error", value: vm.averageErrorText, systemImage: "chart.line.downtrend.xyaxis")
                        StatCard(label: "Perfects", value: "\(vm.perfectCount)", systemImage: "star.fill", tint: .yellow)
                        StatCard(label: "Legendary", value: "\(vm.legendaryCount)", systemImage: "crown.fill", tint: .yellow)
                        StatCard(label: "Longest Combo", value: "\(vm.longestCombo)", systemImage: "flame.fill", tint: .orange)
                        StatCard(label: "Attempts", value: "\(vm.lifetimeAttempts)", systemImage: "number")
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
                        .font(.caption2.weight(.semibold)).tracking(2)
                        .foregroundStyle(Constants.Theme.textSecondary)
                    Text("\(vm.playerLevel)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Constants.Theme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Label(vm.rankTitle, systemImage: "rosette")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Constants.Theme.accent)
                    Label("\(vm.coins)", systemImage: "dollarsign.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Constants.Theme.background)
                        Capsule().fill(Constants.Theme.accent)
                            .frame(width: max(8, geo.size.width * vm.levelProgress))
                    }
                }
                .frame(height: 12)
                Text("\(vm.xpIntoLevel) / \(Constants.xpPerLevel) XP")
                    .font(.caption2)
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(Constants.Theme.cardStroke, lineWidth: 1))
    }
}

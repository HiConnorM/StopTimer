import SwiftUI

/// Profile: avatar with equipped frame + badge + title, level/XP + rank, a link
/// to Achievements, and a grid of lifetime stats.
struct ProfileView: View {
    @StateObject private var vm: ProfileViewModel
    @EnvironmentObject private var progress: ProgressStore

    init(progressStore: ProgressStore) {
        _vm = StateObject(wrappedValue: ProfileViewModel(progressStore: progressStore))
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        identityCard
                        achievementsLink

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
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Identity

    private var identityCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                avatar
                VStack(alignment: .leading, spacing: 3) {
                    Text("LEVEL \(vm.playerLevel)")
                        .font(.caption2.weight(.bold)).tracking(2)
                        .foregroundStyle(Constants.Theme.textSecondary)
                    if let title = vm.equippedTitle {
                        Text("“\(title)”")
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .foregroundStyle(Constants.Theme.purple)
                    }
                    HStack(spacing: 8) {
                        Label(vm.rankTitle, systemImage: "rosette")
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(Constants.Theme.accent)
                        if let badge = progress.equippedBadge {
                            Label(badge.name, systemImage: badge.symbol ?? "rosette")
                                .font(.system(.caption, design: .rounded).weight(.bold))
                                .foregroundStyle(badge.colors.first ?? Constants.Theme.coin)
                        }
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.07))
                        Capsule().fill(LinearGradient(colors: [Constants.Theme.blue, Constants.Theme.purple],
                                                      startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(8, geo.size.width * vm.levelProgress))
                    }
                }
                .frame(height: 12)
                Text("\(vm.xpIntoLevel) / \(Constants.xpPerLevel) XP · \(vm.coins) coins")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
    }

    private var avatar: some View {
        ZStack {
            Circle().fill(Constants.Theme.background).frame(width: 68, height: 68)
            Image(systemName: "person.fill")
                .font(.system(size: 30))
                .foregroundStyle(Constants.Theme.textSecondary)
            if let frame = progress.equippedFrameColors {
                Circle()
                    .strokeBorder(LinearGradient(colors: frame, startPoint: .topLeading, endPoint: .bottomTrailing),
                                  lineWidth: 4)
                    .frame(width: 72, height: 72)
            }
        }
    }

    private var achievementsLink: some View {
        NavigationLink {
            AchievementsView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "medal.fill").font(.title3).foregroundStyle(Constants.Theme.coin)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Achievements")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(Constants.Theme.textPrimary)
                    Text("\(progress.earnedAchievementCount) of \(AchievementCatalog.all.count) earned")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Constants.Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.bold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            .padding(16)
            .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

/// Full achievements list with earned/locked state and progress toward each.
/// Earning one grants a prestige cosmetic (shown on the row). Pushed from Profile.
struct AchievementsView: View {
    @EnvironmentObject private var progress: ProgressStore

    private var earnedCount: Int { progress.earnedAchievementCount }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    header
                    ForEach(AchievementCatalog.all) { row($0) }
                }
                .padding(20)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "medal.fill").font(.title).foregroundStyle(Constants.Theme.coin)
            Text("\(earnedCount) of \(AchievementCatalog.all.count) earned")
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }

    private func row(_ a: Achievement) -> some View {
        let earned = progress.isAchievementEarned(a.id)
        let pct = a.progress(progress.progress)
        let reward = CosmeticCatalog.item(a.unlocksCosmeticID)

        return HStack(spacing: 14) {
            Image(systemName: a.symbol)
                .font(.title2)
                .foregroundStyle(earned ? .white : Constants.Theme.textSecondary)
                .frame(width: 46, height: 46)
                .background(earned ? a.color : Color.black.opacity(0.06), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(a.name)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(Constants.Theme.textPrimary)
                    if earned {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(Constants.Theme.green)
                    }
                }
                Text(a.detail)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)

                if earned {
                    if let reward {
                        Text("Reward: \(reward.name)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(a.color)
                    }
                } else {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.black.opacity(0.07))
                            Capsule().fill(a.color).frame(width: max(4, geo.size.width * pct))
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(earned ? a.color.opacity(0.5) : Constants.Theme.cardStroke, lineWidth: earned ? 1.5 : 1))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .opacity(earned ? 1 : 0.92)
    }
}

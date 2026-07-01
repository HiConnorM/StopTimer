import SwiftUI

/// Global leaderboard (local placeholder). Shows the player's rank against seeded
/// sample players, ranked by the composite rating (stage + precision + perfects).
struct LeaderboardView: View {
    @StateObject private var vm: LeaderboardViewModel
    @EnvironmentObject private var progress: ProgressStore

    init(progressStore: ProgressStore) {
        _vm = StateObject(wrappedValue: LeaderboardViewModel(progressStore: progressStore))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        rankBanner
                        previewNote
                        ForEach(Array(vm.entries.enumerated()), id: \.element.id) { index, entry in
                            row(rank: index + 1, entry: entry)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var rankBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 30))
                .foregroundStyle(Constants.Theme.coin)
            VStack(alignment: .leading, spacing: 2) {
                Text("You're ranked")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(Constants.Theme.textSecondary)
                Text("#\(vm.playerRank) of \(vm.total)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Constants.Theme.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("RATING").font(.caption2.weight(.bold)).tracking(1)
                    .foregroundStyle(Constants.Theme.textSecondary)
                Text("\(progress.progress.leaderboardRating)")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(Constants.Theme.accent)
            }
        }
        .padding(18)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }

    private var previewNote: some View {
        Label("Preview — local ranks. Global play arrives with online sign-in.", systemImage: "globe")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Constants.Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private func row(rank: Int, entry: LeaderboardEntry) -> some View {
        HStack(spacing: 14) {
            rankBadge(rank)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.isPlayer ? "You" : entry.name)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.textPrimary)
                Text("Stage \(entry.highestStage) · best \(entry.bestErrorText)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            Spacer()
            Text("\(entry.rating)")
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(entry.isPlayer ? Constants.Theme.accent : Constants.Theme.textPrimary)
        }
        .padding(14)
        .background(entry.isPlayer ? Constants.Theme.accent.opacity(0.10) : Constants.Theme.card,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(entry.isPlayer ? Constants.Theme.accent : Constants.Theme.cardStroke,
                    lineWidth: entry.isPlayer ? 2 : 1))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    private func rankBadge(_ rank: Int) -> some View {
        let medal: Color? = rank == 1 ? Constants.Theme.coin
            : rank == 2 ? Color(white: 0.7)
            : rank == 3 ? Color(red: 0.80, green: 0.50, blue: 0.20) : nil
        return ZStack {
            Circle().fill(medal ?? Constants.Theme.background)
                .frame(width: 34, height: 34)
            Text("\(rank)")
                .font(.system(.subheadline, design: .rounded).weight(.black))
                .foregroundStyle(medal == nil ? Constants.Theme.textSecondary : .white)
        }
    }
}

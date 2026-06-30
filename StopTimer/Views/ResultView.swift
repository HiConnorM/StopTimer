import SwiftUI

/// The result panel. Shows the grade, all timing metrics, and the rewards earned,
/// then offers Retry (same target) / Next (new target) / Home.
struct ResultView: View {
    let result: GameResult
    let reward: RewardBundle
    var reducedMotion: Bool = false
    let onRetry: () -> Void
    let onNext: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 12)

            GradeBadge(grade: result.grade, reducedMotion: reducedMotion)

            metricsCard
            rewardsCard

            Spacer(minLength: 12)

            HStack(spacing: 14) {
                PrimaryButton(title: "RETRY", filled: false) { onRetry() }
                PrimaryButton(title: "NEXT") { onNext() }
            }
            .padding(.horizontal, 24)

            Button(action: onHome) {
                Label("Home", systemImage: "house.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            .padding(.bottom, 28)
        }
    }

    private var metricsCard: some View {
        VStack(spacing: 12) {
            row("Target",          TimeFormatting.seconds(result.targetSeconds))
            row("You stopped at",  TimeFormatting.seconds(result.actualSeconds))
            row("Difference",      TimeFormatting.signed(result.signedDifference),
                tint: result.signedDifference >= 0 ? .orange : Constants.Theme.accent)
            row("Error",           TimeFormatting.seconds(result.absoluteError))
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Constants.Theme.cardStroke, lineWidth: 1))
        .padding(.horizontal, 24)
    }

    private var rewardsCard: some View {
        HStack {
            reward("XP", value: "+\(reward.xp)", symbol: "bolt.fill", tint: Constants.Theme.accent)
            divider
            reward("Coins", value: "+\(reward.coins)", symbol: "dollarsign.circle.fill", tint: .yellow)
            divider
            reward("Combo", value: "\(reward.newCombo)", symbol: "flame.fill", tint: .orange)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Constants.Theme.card.opacity(0.6),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 24)
    }

    private var divider: some View {
        Rectangle().fill(Constants.Theme.cardStroke).frame(width: 1, height: 34)
    }

    private func reward(_ label: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1)
                .foregroundStyle(Constants.Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(_ title: String, _ value: String, tint: Color = Constants.Theme.textPrimary) -> some View {
        HStack {
            Text(title).foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .foregroundStyle(tint)
        }
    }
}

#Preview {
    ZStack {
        Constants.Theme.background.ignoresSafeArea()
        ResultView(
            result: GameResult(targetSeconds: 10.0, actualSeconds: 10.014),
            reward: RewardBundle(xp: 75, coins: 35, newCombo: 3),
            onRetry: {}, onNext: {}, onHome: {}
        )
    }
}

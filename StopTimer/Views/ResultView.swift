import SwiftUI

/// The result panel. Shows the grade, all timing metrics, the rewards earned, a
/// share button, then Retry (same target) / Next (new target) / Home.
struct ResultView: View {
    let result: GameResult
    let reward: RewardBundle
    var reducedMotion: Bool = false
    let onRetry: () -> Void
    let onNext: () -> Void
    let onHome: () -> Void

    @State private var cardsIn = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 8)

            GradeBadge(grade: result.grade, reducedMotion: reducedMotion)

            metricsCard
                .modifier(PopIn(shown: cardsIn, delay: 0.05, reducedMotion: reducedMotion))
            rewardsCard
                .modifier(PopIn(shown: cardsIn, delay: 0.12, reducedMotion: reducedMotion))

            Spacer(minLength: 8)

            ShareLink(item: result.shareText) {
                Label("Share Result", systemImage: "square.and.arrow.up")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.accent)
            }

            HStack(spacing: 14) {
                PrimaryButton(title: "RETRY",
                              face: .white, lip: Color.black.opacity(0.12),
                              foreground: Constants.Theme.textPrimary,
                              depth: 7, height: 58) { onRetry() }
                PrimaryButton(title: "NEXT", depth: 7, height: 58) { onNext() }
            }
            .padding(.horizontal, 24)

            Button(action: onHome) {
                Label("Home", systemImage: "house.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            if reducedMotion { cardsIn = true }
            else { withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { cardsIn = true } }
        }
    }

    private var metricsCard: some View {
        VStack(spacing: 12) {
            row("Target",          TimeFormatting.seconds(result.targetSeconds))
            row("You stopped at",  TimeFormatting.seconds(result.actualSeconds))
            row("Difference",      TimeFormatting.signed(result.signedDifference),
                tint: result.signedDifference >= 0 ? Constants.Theme.accent : Constants.Theme.mint)
            row("Error",           TimeFormatting.seconds(result.absoluteError))
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
        .padding(.horizontal, 24)
    }

    private var rewardsCard: some View {
        HStack {
            rewardCell("XP", value: "+\(reward.xp)", symbol: "bolt.fill", tint: Constants.Theme.accent)
            divider
            rewardCell("Coins", value: "+\(reward.coins)", symbol: "dollarsign.circle.fill", tint: Constants.Theme.coin)
            divider
            rewardCell("Streak", value: "\(reward.newCombo)", symbol: "flame.fill", tint: .orange)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal, 24)
    }

    private var divider: some View {
        Rectangle().fill(Constants.Theme.cardStroke).frame(width: 1, height: 34)
    }

    private func rewardCell(_ label: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(Constants.Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(_ title: String, _ value: String, tint: Color = Constants.Theme.textPrimary) -> some View {
        HStack {
            Text(title)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced).weight(.bold))
                .foregroundStyle(tint)
        }
    }
}

/// Staggered pop-in: scale + fade with an optional delay. Skipped for reduced motion.
private struct PopIn: ViewModifier {
    let shown: Bool
    let delay: Double
    let reducedMotion: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(reducedMotion ? 1 : (shown ? 1 : 0.85))
            .opacity(shown ? 1 : 0)
            .animation(reducedMotion ? nil :
                .spring(response: 0.45, dampingFraction: 0.7).delay(delay), value: shown)
    }
}

#Preview {
    ZStack {
        Constants.Theme.background.ignoresSafeArea()
        ResultView(
            result: GameResult(targetSeconds: 10.0, actualSeconds: 10.004),
            reward: RewardBundle(xp: 75, coins: 35, newCombo: 3),
            onRetry: {}, onNext: {}, onHome: {}
        )
    }
}

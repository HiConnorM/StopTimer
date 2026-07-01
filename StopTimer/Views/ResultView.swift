import SwiftUI

/// The result panel: grade, accuracy meter, stage clear/fail, metrics, rewards,
/// level-up + new unlocks, and Retry / Next Stage (gated on clearing) / Home / Share.
struct ResultView: View {
    let result: GameResult
    let reward: RewardBundle
    let stage: StageLevel
    let stageCleared: Bool
    let leveledUp: Bool
    let newUnlocks: [CosmeticItem]
    var newAchievements: [Achievement] = []
    var reducedMotion: Bool = false
    let onRetry: () -> Void
    let onNext: () -> Void
    let onHome: () -> Void

    @EnvironmentObject private var progress: ProgressStore
    @State private var cardsIn = false

    private var isWin: Bool {
        stageCleared || !newAchievements.isEmpty || result.grade == .legendary || result.grade == .perfect
    }
    private var isLoss: Bool { result.grade == .miss }

    var body: some View {
        ZStack {
            if isLoss { LoseFlashView(reducedMotion: reducedMotion) }
            content
            if isWin { ConfettiView(reducedMotion: reducedMotion) }
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                GradeBadge(grade: result.grade,
                           burstColor: progress.resultBurstColor(gradeColor: result.grade.color),
                           reducedMotion: reducedMotion)
                    .padding(.top, 12)

                stageBanner
                AccuracyMeterView(accuracyPercent: result.accuracyPercent, reducedMotion: reducedMotion)
                    .padding(.horizontal, 30)

                if !newAchievements.isEmpty {
                    achievementsCard.modifier(PopIn(shown: cardsIn, delay: 0.02, reducedMotion: reducedMotion))
                }

                metricsCard.modifier(PopIn(shown: cardsIn, delay: 0.05, reducedMotion: reducedMotion))
                rewardsCard.modifier(PopIn(shown: cardsIn, delay: 0.11, reducedMotion: reducedMotion))
                levelBar.modifier(PopIn(shown: cardsIn, delay: 0.16, reducedMotion: reducedMotion))

                if leveledUp || !newUnlocks.isEmpty {
                    unlocksCard.modifier(PopIn(shown: cardsIn, delay: 0.2, reducedMotion: reducedMotion))
                }

                actions.padding(.top, 4)
            }
            .padding(.bottom, 28)
        }
        .onAppear {
            if reducedMotion { cardsIn = true }
            else { withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { cardsIn = true } }
        }
    }

    // MARK: Stage banner

    private var stageBanner: some View {
        Group {
            if stageCleared {
                banner(text: "STAGE \(stage.stageNumber) CLEARED", color: Constants.Theme.green, symbol: "checkmark.seal.fill")
            } else {
                VStack(spacing: 2) {
                    banner(text: result.encouragement, color: Constants.Theme.orange, symbol: "hand.raised.fill")
                    Text("Need \(stage.requiredAccuracyPercent)% to clear this stage")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Constants.Theme.textSecondary)
                }
            }
        }
    }

    private func banner(text: String, color: Color, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(.subheadline, design: .rounded).weight(.heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(color, in: Capsule())
            .shadow(color: color.opacity(0.4), radius: 8, y: 3)
    }

    // MARK: Cards

    private var metricsCard: some View {
        VStack(spacing: 12) {
            row("Target",         TimeFormatting.seconds(result.targetSeconds))
            row("You stopped at", TimeFormatting.seconds(result.actualSeconds))
            row("Difference",     TimeFormatting.signed(result.signedDifference),
                tint: result.signedDifference >= 0 ? Constants.Theme.accent : Constants.Theme.mint)
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 6)
        .padding(.horizontal, 24)
    }

    private var rewardsCard: some View {
        HStack {
            rewardCell("XP", value: "+\(reward.xp)", symbol: "bolt.fill", tint: Constants.Theme.blue)
            divider
            rewardCell("Coins", value: "+\(reward.coins)", symbol: "dollarsign.circle.fill", tint: Constants.Theme.coin)
            divider
            rewardCell("Streak", value: "\(reward.newCombo)", symbol: "flame.fill", tint: Constants.Theme.orange)
        }
        .padding(.vertical, 16).padding(.horizontal, 12)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal, 24)
    }

    private var levelBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Level \(progress.progress.playerLevel)")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.textPrimary)
                Spacer()
                Text("\(progress.progress.xpIntoLevel) / \(Constants.xpPerLevel) XP")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.07))
                    Capsule().fill(LinearGradient(colors: [Constants.Theme.blue, Constants.Theme.purple],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * progress.progress.levelProgress))
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 28)
    }

    private var achievementsCard: some View {
        VStack(spacing: 10) {
            Text("ACHIEVEMENT UNLOCKED")
                .font(.system(.caption, design: .rounded).weight(.black))
                .tracking(2)
                .foregroundStyle(.white)
            ForEach(newAchievements) { a in
                HStack(spacing: 12) {
                    Image(systemName: a.symbol)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.22), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(a.name)
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .foregroundStyle(.white)
                        if let reward = CosmeticCatalog.item(a.unlocksCosmeticID) {
                            Text("Unlocked \(reward.type.displayName.dropLast()): \(reward.name)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Constants.Theme.coin, Constants.Theme.orange],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Constants.Theme.orange.opacity(0.45), radius: 14, y: 6)
        .padding(.horizontal, 24)
    }

    private var unlocksCard: some View {
        VStack(spacing: 8) {
            if leveledUp {
                Label("Level Up! Now Level \(progress.progress.playerLevel)", systemImage: "arrow.up.circle.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.purple)
            }
            ForEach(newUnlocks) { item in
                Label("Unlocked: \(item.name)", systemImage: "gift.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.pink)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 24)
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 12) {
            ShareLink(item: result.shareText) {
                Label("Share Result", systemImage: "square.and.arrow.up")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.accent)
            }

            HStack(spacing: 14) {
                PrimaryButton(title: "RETRY", face: Constants.Theme.blue, height: 58, icon: "arrow.counterclockwise") { onRetry() }
                if stageCleared {
                    PrimaryButton(title: "NEXT", face: Constants.Theme.green, height: 58, icon: "arrow.right") { onNext() }
                }
            }
            .padding(.horizontal, 24)

            Button(action: onHome) {
                Label("Home", systemImage: "house.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
        }
    }

    // MARK: Bits

    private var divider: some View {
        Rectangle().fill(Constants.Theme.cardStroke).frame(width: 1, height: 34)
    }

    private func rewardCell(_ label: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(value).font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text(label.uppercased()).font(.caption2.weight(.bold)).tracking(1)
                .foregroundStyle(Constants.Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func row(_ title: String, _ value: String, tint: Color = Constants.Theme.textPrimary) -> some View {
        HStack {
            Text(title).font(.system(.body, design: .rounded)).foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
            Text(value).font(.system(.body, design: .monospaced).weight(.bold)).foregroundStyle(tint)
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

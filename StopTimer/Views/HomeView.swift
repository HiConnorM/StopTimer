import SwiftUI

/// Home hub: header, logo + equipped title, a featured "current stage" PLAY card,
/// a Stages entry, level/rank card, and a stats grid. Owns the game presentation.
struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var progressStore: ProgressStore
    private let haptics: HapticsManager

    @State private var appeared = false
    @State private var showStages = false
    @State private var playingStage: StageLevel?

    init(progressStore: ProgressStore, haptics: HapticsManager) {
        _vm = StateObject(wrappedValue: HomeViewModel(progressStore: progressStore))
        self.haptics = haptics
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: progressStore.backgroundColors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header.appearSlide(appeared, delay: 0.00)
                        logo.appearSlide(appeared, delay: 0.05)
                        playHero.appearSlide(appeared, delay: 0.10)
                        stagesButton.appearSlide(appeared, delay: 0.14)
                        levelCard.appearSlide(appeared, delay: 0.18)
                        statsGrid.appearSlide(appeared, delay: 0.22)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(isPresented: $showStages) {
                StageSelectView(onPick: { stage in showStages = false; playingStage = stage })
            }
        }
        .onAppear { appeared = true }
        .fullScreenCover(item: $playingStage) { stage in
            GameView(progressStore: progressStore, haptics: haptics, stage: stage,
                     onHome: { playingStage = nil })
                .environmentObject(settingsVM)
                .environmentObject(progressStore)
                .preferredColorScheme(.light)
        }
    }

    // MARK: Header / logo

    private var header: some View {
        HStack {
            pill(symbol: "person.fill", text: "Lv \(vm.playerLevel)", tint: Constants.Theme.blue)
            Spacer()
            pill(symbol: "dollarsign.circle.fill", text: "\(vm.coins)", tint: Constants.Theme.coin)
        }
    }

    private var logo: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Text("STOP").foregroundStyle(Constants.Theme.accent)
                Text("TIMER").foregroundStyle(Constants.Theme.textPrimary)
            }
            .font(.system(size: 42, weight: .black, design: .rounded))
            if let title = vm.equippedTitle {
                Text("“\(title)”")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.purple)
            }
        }
        .shadow(color: Constants.Theme.accent.opacity(0.15), radius: 10, y: 4)
        .padding(.top, 4)
    }

    // MARK: Featured stage play

    private var playHero: some View {
        Button(action: { playingStage = vm.currentStage }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.22)).frame(width: 58, height: 58)
                    Image(systemName: "play.fill").font(.system(size: 24, weight: .black)).foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("PLAY STAGE \(vm.currentStageNumber)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7).lineLimit(1)
                    Text("\(vm.currentStage.requiredAccuracyPercent)% to clear · \(vm.currentStage.difficultyLabel)")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.92))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.headline.weight(.bold)).foregroundStyle(.white.opacity(0.85))
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Constants.Theme.accent, Constants.Theme.accentDark],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .top, endPoint: .center))
                .padding(2))
            .shadow(color: Constants.Theme.accent.opacity(0.40), radius: 18, y: 9)
        }
        .buttonStyle(PressableStyle(scale: 0.97))
    }

    private var stagesButton: some View {
        Button(action: { showStages = true }) {
            HStack {
                Label("Choose Stage", systemImage: "square.grid.2x2.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                Spacer()
                Image(systemName: "chevron.right").font(.caption.weight(.bold))
            }
            .foregroundStyle(Constants.Theme.textPrimary)
            .padding(16)
            .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(PressableStyle(scale: 0.98))
    }

    // MARK: Level + stats

    private var levelCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("LEVEL").font(.caption2.weight(.bold)).tracking(2)
                        .foregroundStyle(Constants.Theme.textSecondary)
                    Text("\(vm.playerLevel)").font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(Constants.Theme.textPrimary)
                }
                Spacer()
                Label(vm.rank, systemImage: "rosette")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Constants.Theme.purple, in: Capsule())
                    .shadow(color: Constants.Theme.purple.opacity(0.4), radius: 8, y: 3)
            }
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.07))
                        Capsule().fill(LinearGradient(colors: [Constants.Theme.blue, Constants.Theme.purple],
                                                      startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(10, geo.size.width * vm.levelProgress))
                    }
                }
                .frame(height: 12)
                Text("\(vm.xpIntoLevel) / \(Constants.xpPerLevel) XP to next level")
                    .font(.caption2.weight(.semibold)).foregroundStyle(Constants.Theme.textSecondary)
            }
        }
        .padding(20)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            StatCard(label: "Best Error", value: vm.bestErrorText, systemImage: "target", tint: Constants.Theme.accent)
            StatCard(label: "Avg Error", value: vm.averageErrorText, systemImage: "chart.line.downtrend.xyaxis", tint: Constants.Theme.mint)
            StatCard(label: "Perfects", value: "\(vm.perfectCount)", systemImage: "star.fill", tint: Constants.Theme.coin)
            StatCard(label: "Best Streak", value: "\(vm.longestCombo)", systemImage: "flame.fill", tint: Constants.Theme.orange)
            StatCard(label: "Legendary", value: "\(vm.legendaryCount)", systemImage: "crown.fill", tint: Constants.Theme.purple)
            StatCard(label: "Attempts", value: "\(vm.lifetimeAttempts)", systemImage: "number", tint: Constants.Theme.blue)
        }
    }

    private func pill(symbol: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).foregroundStyle(tint)
            Text(text).font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(Constants.Theme.textPrimary)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Constants.Theme.card, in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }
}

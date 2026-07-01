import SwiftUI

/// Grid of stages. Cleared stages show a check, the next one is highlighted, and
/// locked stages are disabled. Picking an unlocked stage starts it.
struct StageSelectView: View {
    let onPick: (StageLevel) -> Void
    @EnvironmentObject private var progress: ProgressStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    private var stageCount: Int { max(12, progress.progress.highestUnlockedStage + 5) }

    var body: some View {
        ZStack {
            LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(1...stageCount, id: \.self) { n in
                        cell(StageCatalog.stage(n))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Stages")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func cell(_ stage: StageLevel) -> some View {
        let unlocked = progress.isStageUnlocked(stage.stageNumber)
        let cleared = progress.isStageCleared(stage.stageNumber)
        let isNext = unlocked && !cleared

        return Button {
            if unlocked { onPick(stage) }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if cleared {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(Constants.Theme.green)
                    } else if !unlocked {
                        Image(systemName: "lock.fill").foregroundStyle(Constants.Theme.textSecondary)
                    }
                }
                .font(.headline)
                .frame(height: 20)

                Text("\(stage.stageNumber)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(unlocked ? Constants.Theme.textPrimary : Constants.Theme.textSecondary)
                Text("\(stage.requiredAccuracyPercent)%")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isNext ? Constants.Theme.accent : Constants.Theme.cardStroke,
                        lineWidth: isNext ? 2.5 : 1))
            .shadow(color: .black.opacity(unlocked ? 0.06 : 0.0), radius: 8, y: 4)
            .opacity(unlocked ? 1 : 0.6)
        }
        .buttonStyle(PressableStyle(scale: 0.95))
        .disabled(!unlocked)
    }
}

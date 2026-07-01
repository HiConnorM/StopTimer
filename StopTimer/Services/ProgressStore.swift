import SwiftUI
import Combine

/// Owns the player's persisted progress. Single shared instance, injected via
/// `.environmentObject`. Loads on init, saves after every mutation.
final class ProgressStore: ObservableObject {

    @Published private(set) var progress: PlayerProgress

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.progress = ProgressStore.load(from: defaults)
    }

    // MARK: Rounds

    /// Applies one round's result: closeness-based rewards, stats, combo. Saves.
    @discardableResult
    func applyResult(_ result: GameResult) -> RewardBundle {
        let reward = RewardCalculator.reward(for: result.grade,
                                             closeness: result.closeness,
                                             currentCombo: progress.currentCombo)
        var p = progress
        p.lifetimeAttempts += 1
        p.totalAbsoluteError += result.absoluteError
        p.bestError = min(p.bestError ?? result.absoluteError, result.absoluteError)

        p.xp += reward.xp
        p.coins += reward.coins
        p.currentCombo = reward.newCombo
        p.longestCombo = max(p.longestCombo, reward.newCombo)

        switch result.grade {
        case .legendary: p.legendaryCount += 1
        case .perfect:   p.perfectCount += 1
        case .excellent: p.excellentCount += 1
        case .great:     p.greatCount += 1
        case .good:      p.goodCount += 1
        case .close:     p.closeCount += 1
        case .miss:      p.missCount += 1
        }

        progress = p
        save()
        return reward
    }

    func reset() {
        progress = PlayerProgress()
        save()
    }

    // MARK: Stages

    func isStageUnlocked(_ n: Int) -> Bool { n <= progress.highestUnlockedStage }
    func isStageCleared(_ n: Int) -> Bool { n <= progress.highestStageCleared }

    /// Marks a stage cleared if the accuracy met its requirement. Grants the
    /// stage's bonus XP only on the *first* clear. Returns whether it was cleared.
    @discardableResult
    func clearStageIfMet(_ stage: StageLevel, accuracyPercent: Int) -> Bool {
        guard accuracyPercent >= stage.requiredAccuracyPercent else { return false }
        var p = progress
        let firstClear = stage.stageNumber > p.highestStageCleared
        p.highestStageCleared = max(p.highestStageCleared, stage.stageNumber)
        p.currentStage = max(p.currentStage, stage.stageNumber + 1)
        if firstClear { p.xp += stage.rewardBonus }
        progress = p
        save()
        return true
    }

    // MARK: Cosmetics — ownership

    func isOwned(_ id: String) -> Bool {
        if CosmeticCatalog.item(id)?.isDefault == true { return true }
        return progress.ownedCosmeticIDs.contains(id)
    }

    func isEquipped(_ id: String) -> Bool {
        guard let type = CosmeticCatalog.item(id)?.type else { return false }
        return equippedID(for: type) == id
    }

    /// Whether the level/stage requirement (if any) is met.
    func isAvailable(_ item: CosmeticItem) -> Bool {
        if let lvl = item.requiredPlayerLevel, progress.playerLevel < lvl { return false }
        if let stg = item.requiredStage, progress.highestStageCleared < stg { return false }
        return true
    }

    func canAfford(_ item: CosmeticItem) -> Bool { progress.coins >= item.price }

    @discardableResult
    func purchase(_ item: CosmeticItem) -> Bool {
        guard !isOwned(item.id), isAvailable(item), canAfford(item) else { return false }
        var p = progress
        p.coins -= item.price
        p.ownedCosmeticIDs.append(item.id)
        progress = p
        save()
        return true
    }

    func equip(_ item: CosmeticItem) {
        guard isOwned(item.id) else { return }
        var p = progress
        p.equippedCosmetics[item.type.rawValue] = item.id
        progress = p
        save()
    }

    /// Non-default cosmetics whose requirements are currently met (for the store /
    /// "new unlock" toasts).
    func availableUnlockableIDs() -> Set<String> {
        Set(CosmeticCatalog.all.filter { !$0.isDefault && isAvailable($0) }.map { $0.id })
    }

    // MARK: Cosmetics — equipped resolution (theming)

    func equippedID(for type: CosmeticType) -> String {
        progress.equippedCosmetics[type.rawValue] ?? CosmeticCatalog.defaultID(for: type)
    }

    private func equippedItem(_ type: CosmeticType) -> CosmeticItem? {
        CosmeticCatalog.item(equippedID(for: type))
    }

    var backgroundColors: [Color] {
        equippedItem(.background)?.colors ?? [Constants.Theme.backgroundTop, Constants.Theme.background]
    }
    var orbColors: [Color] {
        equippedItem(.orb)?.colors ?? [Constants.Theme.accent, Constants.Theme.accentDark]
    }
    var buttonFace: Color { equippedItem(.button)?.colors.first ?? Constants.Theme.accent }
    var buttonLip: Color { equippedItem(.button)?.colors.last ?? Constants.Theme.accentDark }

    func resultBurstColor(gradeColor: Color) -> Color {
        let id = equippedID(for: .resultEffect)
        if id == CosmeticCatalog.defaultID(for: .resultEffect) { return gradeColor }
        return CosmeticCatalog.item(id)?.colors.first ?? gradeColor
    }

    var equippedTitle: String? { equippedItem(.title)?.name }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Constants.progressKey)
    }

    private static func load(from defaults: UserDefaults) -> PlayerProgress {
        guard
            let data = defaults.data(forKey: Constants.progressKey),
            let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data)
        else { return PlayerProgress() }
        return decoded
    }
}

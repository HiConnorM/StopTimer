import Foundation
import Combine

/// Read model for the Profile screen. Exposes the full stat set plus a local,
/// skill-weighted rank placeholder (online rank comes later).
@MainActor
final class ProfileViewModel: ObservableObject {

    private let progressStore: ProgressStore
    private var cancellable: AnyCancellable?

    init(progressStore: ProgressStore) {
        self.progressStore = progressStore
        cancellable = progressStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    private var p: PlayerProgress { progressStore.progress }

    var playerLevel: Int { p.playerLevel }
    var levelProgress: Double { p.levelProgress }
    var xpIntoLevel: Int { p.xpIntoLevel }
    var coins: Int { p.coins }
    var longestCombo: Int { p.longestCombo }
    var lifetimeAttempts: Int { p.lifetimeAttempts }
    var legendaryCount: Int { p.legendaryCount }
    var perfectCount: Int { p.perfectCount }

    var bestErrorText: String {
        guard let best = p.bestError else { return "—" }
        return TimeFormatting.seconds(best)
    }

    var averageErrorText: String {
        p.lifetimeAttempts > 0 ? TimeFormatting.seconds(p.averageError) : "—"
    }

    /// Local rank placeholder. Skill-weighted: rewards low average error and high
    /// precision count, gated lightly by experience. Online rank arrives later.
    var rankTitle: String {
        guard p.lifetimeAttempts >= 5 else { return "Unranked" }
        let avg = p.averageError
        let precise = p.legendaryCount + p.perfectCount
        switch (avg, precise) {
        case (..<0.020, _) where precise >= 10: return "Apex"
        case (..<0.030, _):                     return "Legend"
        case (..<0.050, _):                     return "Grandmaster"
        case (..<0.070, _):                     return "Master"
        case (..<0.090, _):                     return "Diamond"
        case (..<0.120, _):                     return "Platinum"
        case (..<0.160, _):                     return "Gold"
        case (..<0.220, _):                     return "Silver"
        default:                                return "Bronze"
        }
    }
}

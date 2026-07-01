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

    var rankTitle: String { p.rank }
    var equippedTitle: String? { progressStore.equippedTitle }
    var highestStageCleared: Int { p.highestStageCleared }
}

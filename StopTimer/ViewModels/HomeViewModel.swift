import Foundation
import Combine

/// Read model for the Home hub. Derives display values from the shared store.
@MainActor
final class HomeViewModel: ObservableObject {

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
    var coins: Int { p.coins }
    var currentCombo: Int { p.currentCombo }
    var longestCombo: Int { p.longestCombo }
    var perfectCount: Int { p.perfectCount + p.legendaryCount }
    var legendaryCount: Int { p.legendaryCount }
    var lifetimeAttempts: Int { p.lifetimeAttempts }
    var levelProgress: Double { p.levelProgress }
    var xpIntoLevel: Int { p.xpIntoLevel }
    var rank: String { p.rank }

    var bestErrorText: String {
        guard let best = p.bestError else { return "—" }
        return TimeFormatting.seconds(best)
    }

    var averageErrorText: String {
        p.lifetimeAttempts > 0 ? TimeFormatting.seconds(p.averageError) : "—"
    }
}

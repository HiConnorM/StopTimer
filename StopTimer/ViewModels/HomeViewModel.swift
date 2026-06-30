import Foundation
import Combine

/// Read model for the Home screen. Derives display values from the shared store.
@MainActor
final class HomeViewModel: ObservableObject {

    private let progressStore: ProgressStore
    private var cancellable: AnyCancellable?

    init(progressStore: ProgressStore) {
        self.progressStore = progressStore
        // Re-publish whenever the underlying progress changes.
        cancellable = progressStore.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    private var progress: PlayerProgress { progressStore.progress }

    var playerLevel: Int { progress.playerLevel }
    var coins: Int { progress.coins }
    var currentCombo: Int { progress.currentCombo }
    var perfectCount: Int { progress.perfectCount + progress.legendaryCount }

    var bestErrorText: String {
        guard let best = progress.bestError else { return "—" }
        return TimeFormatting.seconds(best)
    }
}

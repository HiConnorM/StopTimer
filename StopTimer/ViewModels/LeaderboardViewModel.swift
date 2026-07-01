import Foundation
import Combine

/// Builds the leaderboard rows from the player's progress + the injected service,
/// and tracks the player's rank. Refreshes whenever progress changes.
@MainActor
final class LeaderboardViewModel: ObservableObject {

    @Published private(set) var entries: [LeaderboardEntry] = []
    @Published private(set) var playerRank: Int = 0

    private let progressStore: ProgressStore
    private let service: LeaderboardService
    private var cancellable: AnyCancellable?

    init(progressStore: ProgressStore, service: LeaderboardService = LocalLeaderboardService()) {
        self.progressStore = progressStore
        self.service = service
        refresh()
        cancellable = progressStore.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }
    }

    var total: Int { entries.count }

    private func refresh() {
        let p = progressStore.progress
        let playerEntry = LeaderboardEntry(
            id: "player", name: "You", rating: p.leaderboardRating,
            bestError: p.bestError, highestStage: p.highestStageCleared, isPlayer: true
        )
        entries = service.leaderboard(including: playerEntry)
        playerRank = (entries.firstIndex(where: { $0.isPlayer }) ?? 0) + 1
    }
}

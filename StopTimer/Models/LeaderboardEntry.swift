import Foundation

/// One row on the leaderboard. `isPlayer` marks the local player's entry so the
/// UI can highlight it. Kept transport-agnostic so a Game Center / backend
/// source can produce the same type later.
struct LeaderboardEntry: Identifiable, Equatable {
    let id: String
    let name: String
    let rating: Int
    let bestError: Double?
    let highestStage: Int
    var isPlayer: Bool = false

    var bestErrorText: String {
        guard let bestError else { return "—" }
        return TimeFormatting.seconds(bestError)
    }
}

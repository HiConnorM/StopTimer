import Foundation

/// Supplies leaderboard rows. The app talks to this protocol only, so the local
/// placeholder can later be swapped for a Game Center or backend implementation
/// without touching the view/view-model.
protocol LeaderboardService {
    /// Returns all rows (sample "global" players + the given player), sorted best-first.
    func leaderboard(including player: LeaderboardEntry) -> [LeaderboardEntry]
}

/// Placeholder source: a fixed set of seeded "global" players. NOT truly
/// worldwide yet — swap in `GameCenterLeaderboardService` (GameKit) or a backend
/// implementation of `LeaderboardService` when ready.
struct LocalLeaderboardService: LeaderboardService {

    func leaderboard(including player: LeaderboardEntry) -> [LeaderboardEntry] {
        (Self.sample + [player]).sorted { $0.rating > $1.rating }
    }

    /// Seeded sample players spanning a range of ratings.
    static let sample: [LeaderboardEntry] = [
        .init(id: "s1",  name: "ChronoKing",   rating: 6240, bestError: 0.001, highestStage: 51),
        .init(id: "s2",  name: "TicTacToe",    rating: 5480, bestError: 0.002, highestStage: 45),
        .init(id: "s3",  name: "MsMillisecond",rating: 4870, bestError: 0.002, highestStage: 40),
        .init(id: "s4",  name: "SplitSecond",  rating: 4110, bestError: 0.004, highestStage: 34),
        .init(id: "s5",  name: "PocketAtomic", rating: 3560, bestError: 0.006, highestStage: 29),
        .init(id: "s6",  name: "QuickDraw",    rating: 2980, bestError: 0.009, highestStage: 24),
        .init(id: "s7",  name: "SteadyHands",  rating: 2440, bestError: 0.012, highestStage: 20),
        .init(id: "s8",  name: "NeonNinja",    rating: 1980, bestError: 0.018, highestStage: 16),
        .init(id: "s9",  name: "PixelPulse",   rating: 1520, bestError: 0.025, highestStage: 12),
        .init(id: "s10", name: "TapTitan",     rating: 1160, bestError: 0.034, highestStage: 9),
        .init(id: "s11", name: "SlowClap",     rating: 820,  bestError: 0.051, highestStage: 6),
        .init(id: "s12", name: "RookieRush",   rating: 540,  bestError: 0.072, highestStage: 4),
        .init(id: "s13", name: "FirstTimer",   rating: 300,  bestError: 0.110, highestStage: 2),
        .init(id: "s14", name: "JustLanded",   rating: 140,  bestError: 0.180, highestStage: 1),
    ]
}

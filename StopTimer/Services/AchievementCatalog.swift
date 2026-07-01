import SwiftUI

/// Every skill-based achievement, each granting one prestige cosmetic.
/// These are the "chase" rewards — they tell a story that random store items can't.
enum AchievementCatalog {

    private static func ratio(_ value: Int, _ target: Int) -> Double {
        target <= 0 ? 1 : min(1, Double(value) / Double(target))
    }

    static let all: [Achievement] = [
        Achievement(id: "firstPerfect", name: "Dialed In", detail: "Land your first Perfect.",
                    symbol: "star.fill", color: Constants.Theme.blue, unlocksCosmeticID: "title.precise",
                    isEarned: { $0.perfectCount + $0.legendaryCount >= 1 },
                    progress: { ratio($0.perfectCount + $0.legendaryCount, 1) }),

        Achievement(id: "legend", name: "Legendary", detail: "Score a Legendary (≤0.003s).",
                    symbol: "crown.fill", color: Constants.Theme.coin, unlocksCosmeticID: "badge.legend",
                    isEarned: { $0.legendaryCount >= 1 },
                    progress: { ratio($0.legendaryCount, 1) }),

        Achievement(id: "club010", name: "Perfectionist", detail: "Best error within 0.010s.",
                    symbol: "scope", color: Constants.Theme.mint, unlocksCosmeticID: "title.perfectionist",
                    isEarned: { ($0.bestError ?? 1) <= 0.010 },
                    progress: { p in p.bestError.map { min(1, 0.010 / max($0, 0.0001)) } ?? 0 }),

        Achievement(id: "club001", name: "0.001 Club", detail: "Best error within 0.001s.",
                    symbol: "target", color: Constants.Theme.pink, unlocksCosmeticID: "badge.club001",
                    isEarned: { ($0.bestError ?? 1) <= 0.001 },
                    progress: { p in p.bestError.map { min(1, 0.001 / max($0, 0.0001)) } ?? 0 }),

        Achievement(id: "onFire", name: "On Fire", detail: "5 Perfects in a row.",
                    symbol: "flame.fill", color: Constants.Theme.orange, unlocksCosmeticID: "title.onfire",
                    isEarned: { $0.bestPerfectStreak >= 5 },
                    progress: { ratio($0.bestPerfectStreak, 5) }),

        Achievement(id: "perfect10", name: "Perfect 10", detail: "10 Perfects in a row.",
                    symbol: "10.circle.fill", color: Constants.Theme.purple, unlocksCosmeticID: "badge.perfect10",
                    isEarned: { $0.bestPerfectStreak >= 10 },
                    progress: { ratio($0.bestPerfectStreak, 10) }),

        Achievement(id: "steady", name: "Steady Hands", detail: "15 rounds with no Miss.",
                    symbol: "hand.raised.fill", color: Constants.Theme.teal, unlocksCosmeticID: "title.steady",
                    isEarned: { $0.bestNoMissStreak >= 15 },
                    progress: { ratio($0.bestNoMissStreak, 15) }),

        Achievement(id: "iceBlooded", name: "Ice Blooded", detail: "25 rounds with no Miss.",
                    symbol: "snowflake", color: Constants.Theme.blue, unlocksCosmeticID: "frame.frost",
                    isEarned: { $0.bestNoMissStreak >= 25 },
                    progress: { ratio($0.bestNoMissStreak, 25) }),

        Achievement(id: "climber", name: "Climber", detail: "Clear Stage 10.",
                    symbol: "figure.climbing", color: Color(red: 0.80, green: 0.50, blue: 0.20), unlocksCosmeticID: "frame.bronze",
                    isEarned: { $0.highestStageCleared >= 10 },
                    progress: { ratio($0.highestStageCleared, 10) }),

        Achievement(id: "ladderMaster", name: "Ladder Master", detail: "Clear Stage 25.",
                    symbol: "stairs", color: Constants.Theme.coin, unlocksCosmeticID: "frame.gold",
                    isEarned: { $0.highestStageCleared >= 25 },
                    progress: { ratio($0.highestStageCleared, 25) }),

        Achievement(id: "sharpshooter", name: "Sharpshooter", detail: "25 Perfect-or-better stops.",
                    symbol: "scope", color: Constants.Theme.green, unlocksCosmeticID: "badge.sharpshooter",
                    isEarned: { $0.perfectCount + $0.legendaryCount >= 25 },
                    progress: { ratio($0.perfectCount + $0.legendaryCount, 25) }),

        Achievement(id: "apex", name: "Apex Timer", detail: "Reach the Apex rank.",
                    symbol: "mountain.2.fill", color: Constants.Theme.pink, unlocksCosmeticID: "badge.apex",
                    isEarned: { $0.rank == "Apex" },
                    progress: { $0.rank == "Apex" ? 1 : 0 }),

        Achievement(id: "centurion", name: "Centurion", detail: "Play 100 rounds.",
                    symbol: "number.circle.fill", color: Constants.Theme.textSecondary, unlocksCosmeticID: "title.centurion",
                    isEarned: { $0.lifetimeAttempts >= 100 },
                    progress: { ratio($0.lifetimeAttempts, 100) }),
    ]

    static func achievement(_ id: String) -> Achievement? { all.first { $0.id == id } }

    /// Set of achievement ids currently satisfied by this progress.
    static func earnedIDs(for progress: PlayerProgress) -> Set<String> {
        Set(all.filter { $0.isEarned(progress) }.map { $0.id })
    }

    /// The prestige cosmetic id an earned achievement unlocks.
    static func unlockedCosmeticID(forAchievement id: String) -> String? {
        achievement(id)?.unlocksCosmeticID
    }
}

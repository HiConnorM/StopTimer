import Foundation

/// All persisted player state. Stored locally only (no backend). Uses a custom
/// decoder with `decodeIfPresent` so adding new fields never wipes an old save.
struct PlayerProgress: Codable, Equatable {

    // Currency & progression
    var xp: Int = 0
    var coins: Int = 0
    var currentCombo: Int = 0
    var longestCombo: Int = 0

    // Lifetime accuracy stats
    var lifetimeAttempts: Int = 0
    /// Best (smallest) absolute error ever achieved. `nil` until first attempt.
    var bestError: Double? = nil
    var totalAbsoluteError: Double = 0

    // Per-grade counts
    var legendaryCount: Int = 0
    var perfectCount: Int = 0
    var excellentCount: Int = 0
    var greatCount: Int = 0
    var goodCount: Int = 0
    var closeCount: Int = 0
    var missCount: Int = 0

    // Streaks (for prestige achievements)
    var currentPerfectStreak: Int = 0
    var bestPerfectStreak: Int = 0
    var currentNoMissStreak: Int = 0
    var bestNoMissStreak: Int = 0

    // Stage ladder
    var highestStageCleared: Int = 0
    var currentStage: Int = 1

    // Mode bests
    var endlessBest: Int = 0
    var bestTapCount: Int = 0
    var blitzBest: Int = 0
    /// Fewest attempts to hit Perfect in Perfect Hunt (lower is better; 0 = none yet).
    var perfectHuntBest: Int = 0

    // Cosmetics & achievements
    var ownedCosmeticIDs: [String] = []
    /// CosmeticType.rawValue -> equipped item id.
    var equippedCosmetics: [String: String] = [:]
    var earnedAchievementIDs: [String] = []

    init() {}

    // MARK: Computed (never stored)

    var averageError: Double {
        lifetimeAttempts > 0 ? totalAbsoluteError / Double(lifetimeAttempts) : 0
    }

    var playerLevel: Int { xp / Constants.xpPerLevel + 1 }
    var xpIntoLevel: Int { xp % Constants.xpPerLevel }
    var levelProgress: Double { Double(xpIntoLevel) / Double(Constants.xpPerLevel) }

    /// The highest stage the player is allowed to attempt.
    var highestUnlockedStage: Int { highestStageCleared + 1 }

    /// Composite leaderboard rating (higher = better): stage progression, plus a
    /// precision bonus from best error, plus a little from perfect/legendary count.
    var leaderboardRating: Int {
        let stagePts = highestStageCleared * 120
        let precisionPts = bestError.map { Int(max(0, 500 - $0 * 1000)) } ?? 0
        let perfectPts = (perfectCount + legendaryCount) * 3
        return stagePts + precisionPts + perfectPts
    }

    var rank: String {
        guard lifetimeAttempts >= 5 else { return "Unranked" }
        let precise = legendaryCount + perfectCount
        switch (averageError, precise) {
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

    // MARK: Forward-compatible Codable

    enum CodingKeys: String, CodingKey {
        case xp, coins, currentCombo, longestCombo, lifetimeAttempts, bestError, totalAbsoluteError
        case legendaryCount, perfectCount, excellentCount, greatCount, goodCount, closeCount, missCount
        case currentPerfectStreak, bestPerfectStreak, currentNoMissStreak, bestNoMissStreak
        case highestStageCleared, currentStage, endlessBest, bestTapCount, blitzBest, perfectHuntBest
        case ownedCosmeticIDs, equippedCosmetics, earnedAchievementIDs
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func i(_ k: CodingKeys) -> Int { (try? c.decodeIfPresent(Int.self, forKey: k)) ?? 0 }
        xp = i(.xp); coins = i(.coins); currentCombo = i(.currentCombo); longestCombo = i(.longestCombo)
        lifetimeAttempts = i(.lifetimeAttempts)
        bestError = (try? c.decodeIfPresent(Double.self, forKey: .bestError)) ?? nil
        totalAbsoluteError = (try? c.decodeIfPresent(Double.self, forKey: .totalAbsoluteError)) ?? 0
        legendaryCount = i(.legendaryCount); perfectCount = i(.perfectCount); excellentCount = i(.excellentCount)
        greatCount = i(.greatCount); goodCount = i(.goodCount); closeCount = i(.closeCount); missCount = i(.missCount)
        currentPerfectStreak = i(.currentPerfectStreak); bestPerfectStreak = i(.bestPerfectStreak)
        currentNoMissStreak = i(.currentNoMissStreak); bestNoMissStreak = i(.bestNoMissStreak)
        highestStageCleared = i(.highestStageCleared)
        currentStage = max(1, i(.currentStage))
        endlessBest = i(.endlessBest)
        bestTapCount = i(.bestTapCount)
        blitzBest = i(.blitzBest)
        perfectHuntBest = i(.perfectHuntBest)
        ownedCosmeticIDs = (try? c.decodeIfPresent([String].self, forKey: .ownedCosmeticIDs)) ?? []
        equippedCosmetics = (try? c.decodeIfPresent([String: String].self, forKey: .equippedCosmetics)) ?? [:]
        earnedAchievementIDs = (try? c.decodeIfPresent([String].self, forKey: .earnedAchievementIDs)) ?? []
    }
}

import Foundation

/// User-facing preferences. Codable, persisted locally via `SettingsViewModel`.
struct GameSettings: Codable, Equatable {
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
    var reducedMotion: Bool = false

    static let `default` = GameSettings()
}

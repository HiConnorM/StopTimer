import UIKit

/// Isolated haptic feedback, gated by the user's settings. Uses UIKit's generators
/// (notification + impact) — Core Haptics can be layered in later behind this API
/// without touching call sites.
final class HapticsManager {

    /// Read at call time so a settings change takes effect immediately.
    var settingsProvider: () -> GameSettings = { .default }

    private var hapticsEnabled: Bool { settingsProvider().hapticsEnabled }

    // MARK: Button feedback

    func startTapped() {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func stopTapped() {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // MARK: Grade feedback

    func play(for grade: AccuracyGrade) {
        guard hapticsEnabled else { return }

        switch grade {
        case .legendary:
            // Strong double-success pattern for the top tier.
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                gen.notificationOccurred(.success)
            }
        case .perfect:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .excellent:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .great, .good:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .close:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .miss:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

import Foundation

/// Monotonic, high-precision timer used for scoring.
///
/// Backed by `DispatchTime.uptimeNanoseconds` (which wraps `mach_absolute_time`),
/// so it is unaffected by wall-clock changes, NTP corrections, or the user moving
/// the device clock. **Never** drive scoring from a SwiftUI/animation `Timer` —
/// those can drift; this cannot.
final class PrecisionTimer {

    private var startNanos: UInt64?

    var isRunning: Bool { startNanos != nil }

    /// Live elapsed seconds. For debug overlays only — the authoritative value is
    /// the one returned by `stop()`.
    var elapsedSeconds: Double {
        guard let startNanos else { return 0 }
        let now = DispatchTime.now().uptimeNanoseconds
        return Double(now - startNanos) / 1_000_000_000
    }

    /// Starts timing. No-op safeguards live in the caller (GameViewModel guards state).
    func start() {
        startNanos = DispatchTime.now().uptimeNanoseconds
    }

    /// Stops and returns elapsed seconds, or `nil` if it wasn't running (double-stop guard).
    func stop() -> Double? {
        guard let startNanos else { return nil }
        let now = DispatchTime.now().uptimeNanoseconds
        self.startNanos = nil
        return Double(now - startNanos) / 1_000_000_000
    }

    func reset() {
        startNanos = nil
    }
}

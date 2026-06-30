import Foundation

/// Formats `Double` second values for display. All gameplay time is in seconds.
enum TimeFormatting {

    /// "10.000" — three decimal places, the canonical target/actual display.
    static func seconds(_ value: Double) -> String {
        String(format: "%.3f", value)
    }

    /// "+0.014" or "-0.004" — always shows the sign for signed differences.
    static func signed(_ value: Double) -> String {
        String(format: "%+.3f", value)
    }

    /// Clean target display: "10" for whole seconds, "6.5" for halves, trailing
    /// zeros trimmed otherwise. Used for the big readable target on screen.
    static func target(_ value: Double) -> String {
        if value == value.rounded() { return String(format: "%.0f", value) }
        var s = String(format: "%.3f", value)
        while s.hasSuffix("0") { s.removeLast() }
        if s.hasSuffix(".") { s.removeLast() }
        return s
    }
}

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
}

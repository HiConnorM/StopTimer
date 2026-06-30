import SwiftUI

/// The glowing orb shown while the timer is hidden. Pulses to give the running
/// state life without revealing any timing information. Honors reduced motion.
struct TimerOrbView: View {
    var tint: Color = Constants.Theme.accent
    var reducedMotion: Bool = false

    @State private var pulse = false

    var body: some View {
        ZStack {
            // Soft outer halo.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.35), tint.opacity(0.0)],
                        center: .center, startRadius: 10, endRadius: 150
                    )
                )
            // Glossy core.
            Circle()
                .fill(
                    LinearGradient(colors: [tint, Constants.Theme.accentDark],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(26)
                .overlay(
                    Circle()
                        .fill(LinearGradient(colors: [.white.opacity(0.5), .clear],
                                             startPoint: .top, endPoint: .center))
                        .padding(40)
                )
        }
        .frame(width: 230, height: 230)
        .shadow(color: tint.opacity(0.45), radius: 30, y: 8)
        .scaleEffect(pulse ? 1.07 : 0.93)
        .onAppear {
            guard !reducedMotion else { return }
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityLabel("Timer running, hidden")
    }
}

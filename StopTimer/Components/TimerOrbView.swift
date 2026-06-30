import SwiftUI

/// The glowing orb shown while the timer is hidden. Pulses to give the running
/// state life without revealing any timing information. Honors reduced motion.
struct TimerOrbView: View {
    var tint: Color = Constants.Theme.accent
    var reducedMotion: Bool = false

    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.45), tint.opacity(0.05)],
                        center: .center, startRadius: 4, endRadius: 130
                    )
                )
            Circle()
                .stroke(tint.opacity(0.9), lineWidth: 3)
            Circle()
                .fill(tint.opacity(0.18))
                .padding(28)
        }
        .frame(width: 220, height: 220)
        .shadow(color: tint.opacity(0.6), radius: 36)
        .scaleEffect(pulse ? 1.06 : 0.94)
        .onAppear {
            guard !reducedMotion else { return }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityLabel("Timer running, hidden")
    }
}

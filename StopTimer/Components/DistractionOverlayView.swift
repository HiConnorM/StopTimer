import SwiftUI

/// Escalating, purely decorative distractions for higher stages. Effects are
/// cumulative with `level` (0 = none, 8 = everything). Never blocks or moves the
/// Stop orb (`allowsHitTesting(false)`), and stays fully static under reduced motion.
struct DistractionOverlayView: View {
    let level: Int
    var reducedMotion: Bool = false

    @State private var animate = false

    private var speed: Double { level >= 8 ? 0.6 : 1.0 } // level 8 = faster/combo

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if level >= 1 { colorPulse }
                if level >= 2 { movingShapes(in: geo.size) }
                if level >= 5 { decoyNumbers(in: geo.size) }
                if level >= 3 { fakeFlicker(in: geo.size) }
                if level >= 7 { edgeGlow }
                if level >= 6 { inversionFlash }
            }
        }
        .allowsHitTesting(false)
        .onAppear { if !reducedMotion { animate = true } }
    }

    // 1: subtle color pulse
    private var colorPulse: some View {
        Constants.Theme.purple
            .opacity(animate ? 0.06 : 0.0)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.1 * speed).repeatForever(autoreverses: true), value: animate)
    }

    // 2: moving background shapes
    private func movingShapes(in size: CGSize) -> some View {
        ForEach(0..<6, id: \.self) { i in
            Circle()
                .fill([Constants.Theme.blue, Constants.Theme.pink, Constants.Theme.teal,
                       Constants.Theme.orange, Constants.Theme.purple, Constants.Theme.green][i % 6]
                        .opacity(0.10))
                .frame(width: 70 + CGFloat(i) * 14)
                .position(x: size.width * [0.15, 0.85, 0.5, 0.2, 0.8, 0.6][i],
                          y: (animate ? -0.1 : 1.1) * size.height + CGFloat(i) * 18)
                .animation(.easeInOut(duration: (3.5 + Double(i) * 0.4) * speed)
                    .repeatForever(autoreverses: true), value: animate)
        }
    }

    // 3: fake timer flicker (a misleading number that is NOT the real elapsed time)
    private func fakeFlicker(in size: CGSize) -> some View {
        Text("0.000")
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundStyle(Constants.Theme.textSecondary.opacity(animate ? 0.28 : 0.0))
            .position(x: size.width * 0.5, y: size.height * 0.24)
            .animation(.easeInOut(duration: 0.28 * speed).repeatForever(autoreverses: true), value: animate)
    }

    // 5: floating decoy numbers
    private func decoyNumbers(in size: CGSize) -> some View {
        ForEach(0..<5, id: \.self) { i in
            Text(["3.14", "9.81", "7.77", "1.62", "42.0"][i])
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle([Constants.Theme.pink, Constants.Theme.blue, Constants.Theme.orange,
                                  Constants.Theme.green, Constants.Theme.purple][i].opacity(0.18))
                .position(x: size.width * [0.2, 0.75, 0.4, 0.85, 0.3][i],
                          y: (animate ? -0.05 : 1.05) * size.height)
                .animation(.linear(duration: (4.0 + Double(i) * 0.6) * speed)
                    .repeatForever(autoreverses: false), value: animate)
        }
    }

    // 6: color inversion flash (brief, occasional)
    private var inversionFlash: some View {
        Color.white
            .blendMode(.difference)
            .opacity(animate ? 0.05 : 0.0)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true).delay(2.0), value: animate)
    }

    // 7: button/edge glow distraction (around the edges, not on the orb)
    private var edgeGlow: some View {
        RoundedRectangle(cornerRadius: 40)
            .stroke(Constants.Theme.accent.opacity(animate ? 0.35 : 0.05), lineWidth: 10)
            .blur(radius: 12)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.7 * speed).repeatForever(autoreverses: true), value: animate)
    }
}

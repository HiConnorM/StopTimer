import SwiftUI

/// A one-shot burst of colorful confetti falling down the screen. Celebrates wins
/// (stage clears, top grades, new bests, achievements). Skipped for reduced motion.
struct ConfettiView: View {
    var reducedMotion: Bool = false

    @State private var go = false
    private let pieces: [Piece] = (0..<48).map { _ in Piece.random() }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 0.55)
                        .rotationEffect(.degrees(go ? p.spin : 0))
                        .position(x: p.x * geo.size.width,
                                  y: go ? geo.size.height * 1.15 : -50)
                        .opacity(go ? 0 : 1)
                        .animation(.easeIn(duration: p.duration).delay(p.delay), value: go)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { if !reducedMotion { go = true } }
    }

    struct Piece: Identifiable {
        let id = UUID()
        let x, size, spin, duration, delay: Double
        let color: Color

        static func random() -> Piece {
            let palette: [Color] = [Constants.Theme.accent, Constants.Theme.blue, Constants.Theme.green,
                                    Constants.Theme.coin, Constants.Theme.pink, Constants.Theme.purple,
                                    Constants.Theme.orange, Constants.Theme.teal]
            return Piece(x: .random(in: 0.05...0.95), size: .random(in: 8...15),
                         spin: .random(in: 180...720), duration: .random(in: 1.1...2.0),
                         delay: .random(in: 0...0.5), color: palette.randomElement()!)
        }
    }
}

/// A quick red flash over the screen to punish a Miss / life lost. Fades out once.
struct LoseFlashView: View {
    var reducedMotion: Bool = false
    @State private var faded = false

    var body: some View {
        Constants.Theme.accent
            .opacity(faded ? 0 : 0.26)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .onAppear {
                if reducedMotion { faded = true }
                else { withAnimation(.easeOut(duration: 0.5)) { faded = true } }
            }
    }
}

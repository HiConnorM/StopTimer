import SwiftUI

/// A lightweight burst of sparks that radiates outward once, for celebrating a
/// top-tier grade (Perfect / Legendary). Skipped when reduced motion is on.
struct CelebrationView: View {
    var color: Color
    var reducedMotion: Bool = false

    @State private var go = false
    private let count = 12

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .offset(y: go ? -130 : -20)
                    .rotationEffect(.degrees(Double(i) / Double(count) * 360))
                    .opacity(go ? 0 : 1)
                    .scaleEffect(go ? 0.3 : 1)
            }
        }
        .onAppear {
            guard !reducedMotion else { return }
            withAnimation(.easeOut(duration: 0.7)) { go = true }
        }
        .allowsHitTesting(false)
    }
}

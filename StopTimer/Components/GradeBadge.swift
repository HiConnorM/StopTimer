import SwiftUI

/// Big grade reveal: symbol + title in the grade's color, with an overshoot pop,
/// a glow for top tiers, and a spark burst for Perfect/Legendary. A Miss shakes.
/// Honors reduced motion by skipping the animations.
struct GradeBadge: View {
    let grade: AccuracyGrade
    var reducedMotion: Bool = false

    @State private var shown = false
    @State private var shakeValue: CGFloat = 0

    private var isTopTier: Bool { grade == .perfect || grade == .legendary }

    var body: some View {
        ZStack {
            if isTopTier {
                CelebrationView(color: grade.color, reducedMotion: reducedMotion)
            }
            VStack(spacing: 8) {
                Image(systemName: grade.symbolName)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(grade.color)
                Text(grade.title)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(grade.color)
            }
            .shadow(color: grade.color.opacity(isTopTier ? 0.55 : 0.30),
                    radius: isTopTier ? 22 : 10)
            .scaleEffect(displayScale)
            .opacity(shown ? 1 : 0)
            .shake(shakeValue)
        }
        .onAppear { animateIn() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Grade: \(grade.title)")
    }

    private func animateIn() {
        if reducedMotion {
            shown = true
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) { shown = true }
        if grade == .miss {
            withAnimation(.linear(duration: 0.45).delay(0.1)) { shakeValue = 1 }
        }
    }

    private var displayScale: CGFloat {
        if reducedMotion { return 1 }
        return shown ? 1 : 0.5
    }
}

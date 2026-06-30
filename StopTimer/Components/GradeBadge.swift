import SwiftUI

/// Big grade reveal: symbol + title in the grade's color, with a scale-in pop.
/// Honors reduced motion by skipping the animation.
struct GradeBadge: View {
    let grade: AccuracyGrade
    var reducedMotion: Bool = false

    @State private var shown = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: grade.symbolName)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(grade.color)
            Text(grade.title)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(grade.color)
        }
        .shadow(color: grade.color.opacity(0.6), radius: 24)
        .scaleEffect(displayScale)
        .opacity(shown ? 1 : 0)
        .onAppear {
            if reducedMotion {
                shown = true
            } else {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) { shown = true }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Grade: \(grade.title)")
    }

    private var displayScale: CGFloat {
        if reducedMotion { return 1 }
        return shown ? 1 : 0.6
    }
}

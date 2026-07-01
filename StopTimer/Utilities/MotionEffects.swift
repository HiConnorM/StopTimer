import SwiftUI

/// Horizontal shake driven by an animatable value 0...1. Used to punish a Miss.
struct Shake: GeometryEffect {
    var amount: CGFloat = 9
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let dx = amount * sin(animatableData * .pi * shakes)
        return ProjectionTransform(CGAffineTransform(translationX: dx, y: 0))
    }
}

extension View {
    /// Apply with a @State value you animate 0 -> 1 to trigger the shake.
    func shake(_ value: CGFloat) -> some View {
        modifier(Shake(animatableData: value))
    }

    /// Staggered fade + slide-up entrance. Drive `shown` true once on appear.
    func appearSlide(_ shown: Bool, delay: Double = 0) -> some View {
        modifier(AppearSlide(shown: shown, delay: delay))
    }
}

struct AppearSlide: ViewModifier {
    let shown: Bool
    var delay: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(delay), value: shown)
    }
}

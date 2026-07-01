import SwiftUI

/// Glossy "casual mobile" pill button: saturated vertical gradient, bold dark
/// outline, a diagonal shine, and a springy press. Matches the UI-pack look.
struct PrimaryButton: View {
    let title: String
    var face: Color = Constants.Theme.accent
    var foreground: Color = .white
    var height: CGFloat = 62
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).font(.system(size: 20, weight: .black)) }
                Text(title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(1)
            }
        }
        .buttonStyle(GlossyPillStyle(face: face, foreground: foreground, height: height))
    }
}

/// The reusable glossy-pill press style.
struct GlossyPillStyle: ButtonStyle {
    var face: Color
    var foreground: Color = .white
    var height: CGFloat = 62

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let outline = face.darker

        return configuration.label
            .foregroundStyle(foreground)
            .shadow(color: outline.opacity(0.6), radius: 0, y: 1)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                ZStack {
                    Capsule().fill(
                        LinearGradient(colors: [face.lighter, face, face.darker],
                                       startPoint: .top, endPoint: .bottom))
                    // Diagonal shine across the upper half.
                    Capsule()
                        .fill(LinearGradient(
                            stops: [.init(color: .white.opacity(0.55), location: 0.0),
                                    .init(color: .white.opacity(0.12), location: 0.32),
                                    .init(color: .clear, location: 0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .padding(3)
                    Capsule().stroke(outline, lineWidth: 3)
                }
            )
            .shadow(color: outline.opacity(0.5), radius: pressed ? 2 : 7, y: pressed ? 1 : 5)
            .scaleEffect(pressed ? 0.95 : 1)
            .offset(y: pressed ? 3 : 0)
            .animation(.spring(response: 0.16, dampingFraction: 0.5), value: pressed)
    }
}

/// Simple springy scale-on-press. Used for the tappable orb and the Home cards.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

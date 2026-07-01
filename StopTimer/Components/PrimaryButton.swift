import SwiftUI

/// Big, glossy, "juicy" 3D button. A darker lip sits beneath the face; pressing
/// compresses the face down onto the lip for a satisfying physical click.
struct PrimaryButton: View {
    let title: String
    var face: Color = Constants.Theme.accent
    var lip: Color = Constants.Theme.accentDark
    var foreground: Color = .white
    var depth: CGFloat = 9
    var height: CGFloat = 66
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .tracking(1.5)
        }
        .buttonStyle(JuicyButtonStyle(face: face, lip: lip, foreground: foreground,
                                      depth: depth, height: height))
    }
}

/// The reusable juicy press style. Used for Start / Stop / Play / Retry / Next.
struct JuicyButtonStyle: ButtonStyle {
    var face: Color
    var lip: Color
    var foreground: Color
    var depth: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        ZStack(alignment: .top) {
            // Lip — the darker block the face presses onto.
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(lip)
                .frame(height: height)
                .offset(y: depth)

            // Face — glossy top, carries the label.
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(face)
                .frame(height: height)
                .overlay(
                    // Glossy highlight across the top third.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.40), Color.white.opacity(0.0)],
                                startPoint: .top, endPoint: .center
                            )
                        )
                        .padding(2)
                )
                .overlay(
                    configuration.label
                        .foregroundStyle(foreground)
                        .shadow(color: lip.opacity(0.5), radius: 0, y: 1)
                )
                .offset(y: pressed ? depth : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, depth)
        .animation(.spring(response: 0.16, dampingFraction: 0.45), value: pressed)
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

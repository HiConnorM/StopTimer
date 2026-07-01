import SwiftUI

/// A big physical "red buzzer" button: a glossy red dome raised inside a dark
/// housing. Pressing sinks the dome into the base with a springy click.
struct BigRedButton: View {
    let title: String
    var diameter: CGFloat = 188
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .tracking(2)
        }
        .buttonStyle(BigRedButtonStyle(diameter: diameter))
    }
}

struct BigRedButtonStyle: ButtonStyle {
    let diameter: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let raise: CGFloat = pressed ? 4 : 20   // how far the dome sits above the body

        ZStack {
            // Dark housing base + ground shadow.
            Circle()
                .fill(RadialGradient(colors: [Color(white: 0.30), Color(white: 0.16)],
                                     center: .center, startRadius: 2, endRadius: diameter * 0.75))
                .frame(width: diameter * 1.30, height: diameter * 1.30)
                .overlay(Circle().stroke(Color.black.opacity(0.30), lineWidth: 2))
                .shadow(color: .black.opacity(0.28), radius: 18, y: 14)
                .offset(y: 10)

            // Recessed inner well the button sits in.
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: diameter * 1.08, height: diameter * 1.08)
                .offset(y: 8)

            // Red cylinder body (the side you see when raised).
            Circle()
                .fill(LinearGradient(colors: [Constants.Theme.accentDark,
                                              Color(red: 0.55, green: 0.07, blue: 0.11)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: diameter, height: diameter)

            // Glossy red top dome, raised above the body.
            Circle()
                .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.38),
                                              Constants.Theme.accent,
                                              Color(red: 0.82, green: 0.15, blue: 0.19)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: diameter, height: diameter)
                .overlay(
                    Ellipse()
                        .fill(LinearGradient(colors: [.white.opacity(0.55), .clear],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: diameter * 0.62, height: diameter * 0.34)
                        .offset(y: -diameter * 0.22)
                        .blur(radius: 3)
                )
                .overlay(
                    configuration.label
                        .foregroundStyle(.white)
                        .shadow(color: Constants.Theme.accentDark.opacity(0.7), radius: 1, y: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 6, y: 6)
                .offset(y: -raise)
        }
        .frame(width: diameter * 1.30, height: diameter * 1.30 + 20)
        .animation(.spring(response: 0.17, dampingFraction: 0.5), value: pressed)
        .contentShape(Circle())
    }
}

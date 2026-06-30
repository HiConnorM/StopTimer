import SwiftUI

/// Large, tappable action button used for Start / Stop / result actions.
/// `filled` controls the high-emphasis (solid) vs low-emphasis (outlined) look.
struct PrimaryButton: View {
    let title: String
    var filled: Bool = true
    var tint: Color = Constants.Theme.accent
    var foreground: Color = .white
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3.weight(.bold))
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(filled ? Color.clear : tint.opacity(0.8), lineWidth: 1.5)
                )
                .shadow(color: filled ? tint.opacity(0.45) : .clear, radius: 18, y: 6)
                .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.12)) { pressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.18)) { pressed = false } }
        )
    }

    private var background: Color {
        filled ? tint : Constants.Theme.card
    }
}

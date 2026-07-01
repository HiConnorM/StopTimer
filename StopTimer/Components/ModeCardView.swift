import SwiftUI

/// A glossy tappable card for a game mode, with an icon, title, subtitle, and a
/// "best" line. Used in the Home modes grid.
struct ModeCardView: View {
    let mode: GameMode
    var bestText: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: mode.symbol)
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption.weight(.black)).foregroundStyle(.white.opacity(0.85))
                }
                Text(mode.title)
                    .font(.system(.title3, design: .rounded).weight(.black))
                    .foregroundStyle(.white)
                Text(mode.subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2, reservesSpace: true)
                if let bestText {
                    Text(bestText)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.white.opacity(0.22), in: Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [mode.color.lighter, mode.color, mode.color.darker],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(mode.color.darker, lineWidth: 2.5))
            .shadow(color: mode.color.darker.opacity(0.5), radius: 10, y: 6)
        }
        .buttonStyle(PressableStyle(scale: 0.96))
    }
}

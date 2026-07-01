import SwiftUI

/// A single store card: colour swatch, name, and a context-aware action
/// (Buy / Equip / Equipped / locked requirement).
struct CosmeticCardView: View {
    let item: CosmeticItem
    let owned: Bool
    let equipped: Bool
    let available: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onEquip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            swatch
            Text(item.name)
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
                .lineLimit(1)
            Text(item.description)
                .font(.caption2)
                .foregroundStyle(Constants.Theme.textSecondary)
                .lineLimit(2, reservesSpace: true)
            action
        }
        .padding(14)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(equipped ? Constants.Theme.accent : Constants.Theme.cardStroke,
                        lineWidth: equipped ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }

    private var swatch: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(LinearGradient(colors: item.colors.count > 1 ? item.colors : [item.colors.first ?? .gray, .white.opacity(0.4)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 64)
            .overlay(
                Group {
                    if item.type == .title {
                        Text("“\(item.name)”")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                }
            )
    }

    @ViewBuilder private var action: some View {
        if equipped {
            tag(text: "EQUIPPED", color: Constants.Theme.accent, filled: true)
        } else if owned {
            Button(action: onEquip) { tag(text: "EQUIP", color: Constants.Theme.accent, filled: false) }
                .buttonStyle(.plain)
        } else if !available {
            tag(text: requirementText, color: Constants.Theme.textSecondary, filled: false)
        } else {
            Button(action: onBuy) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("\(item.price)")
                }
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(canAfford ? Constants.Theme.coin : Color.gray.opacity(0.4), in: Capsule())
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(!canAfford)
        }
    }

    private var requirementText: String {
        if let lvl = item.requiredPlayerLevel { return "Reach Lv \(lvl)" }
        if let stg = item.requiredStage { return "Clear Stage \(stg)" }
        return "Locked"
    }

    private func tag(text: String, color: Color, filled: Bool) -> some View {
        Text(text)
            .font(.system(.caption, design: .rounded).weight(.heavy))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(filled ? color : color.opacity(0.12), in: Capsule())
            .foregroundStyle(filled ? .white : color)
    }
}

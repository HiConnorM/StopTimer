import SwiftUI

/// White rounded card with a soft drop shadow, showing a single labelled stat.
struct StatCard: View {
    let label: String
    let value: String
    var systemImage: String? = nil
    var tint: Color = Constants.Theme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption)
                        .foregroundStyle(tint)
                }
                Text(label.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Constants.Theme.cardStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 5)
    }
}

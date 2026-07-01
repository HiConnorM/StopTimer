import SwiftUI

/// A big "82% Accurate" readout with a bar that fills to the accuracy. Color
/// shifts from red (low) through orange to green (high) for instant feedback.
struct AccuracyMeterView: View {
    let accuracyPercent: Int
    var reducedMotion: Bool = false

    @State private var fill: CGFloat = 0

    private var tint: Color {
        switch accuracyPercent {
        case 85...:   return Constants.Theme.green
        case 65..<85: return Constants.Theme.mint
        case 45..<65: return Constants.Theme.yellow
        case 25..<45: return Constants.Theme.orange
        default:      return Constants.Theme.accent
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(accuracyPercent)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                Text("% Accurate")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(Constants.Theme.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.07))
                    Capsule()
                        .fill(LinearGradient(colors: [tint.opacity(0.7), tint],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * fill)
                }
            }
            .frame(height: 14)
        }
        .onAppear {
            let target = CGFloat(accuracyPercent) / 100
            if reducedMotion { fill = target }
            else { withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { fill = target } }
        }
    }
}

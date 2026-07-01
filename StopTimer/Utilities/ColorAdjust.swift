import SwiftUI
import UIKit

extension Color {
    /// Returns the color with brightness nudged by `delta` (−1…1). Used to build
    /// the glossy button gradients (lighter top, darker outline/base).
    func adjust(brightness delta: CGFloat) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: Double(h), saturation: Double(s),
                     brightness: Double(max(0, min(1, b + delta))), opacity: Double(a))
    }

    var lighter: Color { adjust(brightness: 0.13) }
    var darker: Color { adjust(brightness: -0.20) }
}

import SwiftUI

/// Colours for the PiP window. They match the Flutter subtitle window (`subtitle_colors.dart`).
/// Picked by hand because the PiP image is rendered outside the app's theme.
struct PipPalette {
    let isDark: Bool

    var body: Color { isDark ? Color(hex: 0x0A0F1E) : Color(hex: 0xEEF2F9) }
    var card: Color { isDark ? Color(hex: 0x151B2E) : Color.white }
    var border: Color { isDark ? Color(hex: 0xEEF2F9).opacity(0.16) : Color(hex: 0x0A0F1E).opacity(0.12) }
    var ink: Color { isDark ? Color(hex: 0xEEF2F9) : Color(hex: 0x0A0F1E) }
    var muted: Color { isDark ? Color(hex: 0x93A0BC) : Color(hex: 0x566079) }
    var accent: Color { isDark ? Color(hex: 0x5AA2FF) : Color(hex: 0x1A6CFF) }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

import SwiftUI

/// The view rendered into the PiP window. The window size is `pipSize`.
struct PipSubtitleView: View {
    @ObservedObject var model: PipSubtitleModel

    /// Phone-width, wide aspect so iOS opens the PiP window as wide as it allows.
    static var pipSize: CGSize { CGSize(width: UIScreen.main.bounds.width, height: 180) }

    /// Rows of cards that fit in the panel.
    static let maxRows = 2

    var body: some View {
        let palette = PipPalette(isDark: model.isDark)
        ZStack(alignment: .topLeading) {
            palette.body

            if model.lines.isEmpty {
                Text("Listening…")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SubtitleLineLayout(spacing: 8, maxRows: Self.maxRows) {
                    ForEach(model.lines) { line in
                        ForEach(line.tokens) { token in
                            PipWordCard(token: token, palette: palette)
                                .layoutValue(key: LineStartKey.self, value: token.id == 0)
                        }
                    }
                }
                .clipped()
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}

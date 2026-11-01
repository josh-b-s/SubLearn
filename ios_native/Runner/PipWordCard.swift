import SwiftUI

/// Compact word card sized for the small PiP window. Same look as `SubtitleWindowCard(compact: true)` in Flutter.
struct PipWordCard: View {
    let token: PipToken
    let palette: PipPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(token.text)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(palette.ink)
            if !token.pinyin.isEmpty && !token.hidePinyin {
                Text(token.pinyin)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(palette.accent)
            }
            if !token.meanings.isEmpty && !token.hideMeaning {
                Text(token.meanings.prefix(2).joined(separator: " · "))
                    .font(.system(size: 11))
                    .foregroundStyle(palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: 92, alignment: .leading)
        .background(palette.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.border, lineWidth: 1))
    }
}

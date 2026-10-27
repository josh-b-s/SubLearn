import Foundation

struct PipToken: Identifiable {
    /// Position in its line. Zero marks the first card of a line.
    let id: Int
    let text: String
    let pinyin: String
    let meanings: [String]
    let hidePinyin: Bool
    let hideMeaning: Bool

    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int, let text = json["text"] as? String else { return nil }
        self.id = id
        self.text = text
        pinyin = json["pinyin"] as? String ?? ""
        meanings = json["meanings"] as? [String] ?? []
        hidePinyin = json["hidePinyin"] as? Bool ?? false
        hideMeaning = json["hideMeaning"] as? Bool ?? false
    }
}

struct PipLine: Identifiable {
    let id: Int
    let tokens: [PipToken]

    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int, let tokens = json["tokens"] as? [[String: Any]] else { return nil }
        self.id = id
        self.tokens = tokens.compactMap(PipToken.init(json:))
    }
}

/// The lines shown in the PiP window. Dart decides what they are, this only holds them for the view.
final class PipSubtitleModel: ObservableObject {
    @Published var lines: [PipLine] = []

    func set(lines json: [[String: Any]]) {
        lines = json.compactMap(PipLine.init(json:))
    }
}

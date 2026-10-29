import '../word_token.dart';

/// One utterance, shown on its own line of the subtitle panel.
class PipLine {
  const PipLine({required this.id, required this.tokens});

  final int id;
  final List<WordToken> tokens;

  factory PipLine.fromJson(Map<String, Object?> json) => PipLine(
        id: json['id'] as int,
        tokens: [
          for (final raw in json['tokens'] as List)
            WordToken(
              id: (raw as Map)['id'] as int,
              text: raw['text'] as String,
              pinyin: raw['pinyin'] as String,
              meanings: List<String>.from(raw['meanings'] as List),
              hidePinyin: raw['hidePinyin'] as bool,
              hideMeaning: raw['hideMeaning'] as bool,
            ),
        ],
      );

  /// The shape the native PiP renderer and the Android overlay read.
  Map<String, Object> toJson() => {
        'id': id,
        'tokens': [
          for (final t in tokens)
            {
              'id': t.id,
              'text': t.text,
              'pinyin': t.pinyin,
              'meanings': t.meanings,
              'hidePinyin': t.hidePinyin,
              'hideMeaning': t.hideMeaning,
            },
        ],
      };
}

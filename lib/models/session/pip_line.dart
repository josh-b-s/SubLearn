import '../word_token.dart';

/// One utterance, shown on its own line of the subtitle panel.
class PipLine {
  const PipLine({required this.id, required this.tokens});

  final int id;
  final List<WordToken> tokens;

  /// The shape the native PiP renderer reads.
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

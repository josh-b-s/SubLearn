/// One word shown as a card: from a sentence, a saved word or a dictionary hit.
class WordToken {
  const WordToken({
    required this.id,
    required this.text,
    required this.pinyin,
    required this.meanings,
    this.hideMeaning = false,
    this.hidePinyin = false,
  });

  /// Position in the sentence, so repeated words still get unique ids.
  final int id;
  final String text;
  final String pinyin;
  final List<String> meanings;
  final bool hideMeaning;
  final bool hidePinyin;

  WordToken copyWith({int? id, bool? hideMeaning, bool? hidePinyin}) => WordToken(
        id: id ?? this.id,
        text: text,
        pinyin: pinyin,
        meanings: meanings,
        hideMeaning: hideMeaning ?? this.hideMeaning,
        hidePinyin: hidePinyin ?? this.hidePinyin,
      );
}

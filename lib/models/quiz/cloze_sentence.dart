/// One Gemini-written example sentence for a word, cached on device.
class ClozeSentence {
  const ClozeSentence({required this.word, required this.sentence, required this.translation});

  final String word;
  final String sentence;
  final String translation;

  /// Cheap checks before trusting Gemini: short, translated, word appears exactly once.
  bool get isUsable =>
      word.isNotEmpty &&
      translation.isNotEmpty &&
      sentence.runes.length <= 20 &&
      sentence.split(word).length == 2;

  factory ClozeSentence.fromJson(Map<String, dynamic> json) => ClozeSentence(
        word: json['word'] as String,
        sentence: json['sentence'] as String,
        translation: json['translation'] as String,
      );

  Map<String, dynamic> toJson() => {'word': word, 'sentence': sentence, 'translation': translation};

  @override
  bool operator ==(Object other) =>
      other is ClozeSentence &&
      other.word == word &&
      other.sentence == sentence &&
      other.translation == translation;

  @override
  int get hashCode => Object.hash(word, sentence, translation);
}

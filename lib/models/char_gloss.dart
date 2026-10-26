/// One character of a multi-character word with its own pinyin and meaning.
class CharGloss {
  const CharGloss({required this.id, required this.char, required this.pinyin, required this.meaning});

  final int id;
  final String char;
  final String pinyin;
  final String meaning;
}

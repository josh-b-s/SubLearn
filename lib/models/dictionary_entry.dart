class DictionaryEntry {
  const DictionaryEntry({required this.pinyin, required this.meanings});

  final String pinyin;
  final List<String> meanings;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) => DictionaryEntry(
        pinyin: json['pinyin'] as String,
        meanings: (json['meanings'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {'pinyin': pinyin, 'meanings': meanings};
}

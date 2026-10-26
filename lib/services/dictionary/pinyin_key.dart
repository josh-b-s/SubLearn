const _folds = {
  'a': 'āáǎàâ',
  'e': 'ēéěèê',
  'i': 'īíǐìî',
  'o': 'ōóǒòô',
  'u': 'ūúǔùûǖǘǚǜü',
  'n': 'ńňǹ',
  'm': 'ḿ',
};

final Map<int, String> _foldTable = {
  for (final e in _folds.entries)
    for (final r in e.value.runes) r: e.key,
};

/// Lowercase with tone marks removed.
String foldDiacritics(String s) {
  final out = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    out.write(_foldTable[r] ?? String.fromCharCode(r));
  }
  return out.toString();
}

extension PinyinKey on String {
  /// Lowercase, no tone marks, no spaces, so "xi huan", "xihuan" and "xǐhuan" compare equal.
  String get pinyinKey => foldDiacritics(this).replaceAll(RegExp(r'\s'), '');
}

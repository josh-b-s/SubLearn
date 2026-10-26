const maxMeanings = 3;

final _split = RegExp(r'\s*[/;|,·•]\s*|\s+-\s+');
final _parens = RegExp(r'\(.*?\)');
final _spaces = RegExp(r'\s+');

/// Splits a raw definition, lowercases, drops "to ", drops (notes), dedupes, keeps 3.
List<String> shortMeanings(String definition) {
  final seen = <String>{};
  final result = <String>[];
  for (final piece in definition.split(_split)) {
    var m = piece.trim().toLowerCase();
    if (m.startsWith('to ')) m = m.substring(3);
    m = m.replaceAll(_parens, '');
    m = m.split(_spaces).where((s) => s.isNotEmpty).join(' ');
    if (m == 'i') m = 'I';
    if (m.isEmpty || !seen.add(m)) continue;
    result.add(m);
    if (result.length == maxMeanings) break;
  }
  return result;
}

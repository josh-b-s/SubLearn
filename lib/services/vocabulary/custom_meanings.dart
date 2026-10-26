import '../dictionary/short_meanings.dart';

/// Splits on / ; , (also the Chinese ones), lowercases, keeps at most 3.
List<String> parseMeanings(String text) {
  return text
      .split(RegExp('[/;,，；、]'))
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty)
      .take(maxMeanings)
      .toList();
}

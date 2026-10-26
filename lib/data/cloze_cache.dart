import '../models/quiz/cloze_sentence.dart';
import 'json_store.dart';

/// Keeps Gemini sentences on device so each word costs one request, and level 3 works offline after.
class ClozeCache {
  const ClozeCache(this._store);

  static const _key = 'clozeSentences';
  final JsonStore _store;

  Map<String, List<ClozeSentence>> all() => {
        for (final e in _store.readMap(_key).entries)
          e.key: (e.value as List)
              .map((s) => ClozeSentence.fromJson(s as Map<String, dynamic>))
              .toList(),
      };

  Future<void> store(List<ClozeSentence> sentences) {
    final current = all();
    for (final s in sentences) {
      final list = current.putIfAbsent(s.word, () => []);
      if (!list.contains(s)) list.add(s);
    }
    return _store.writeMap(_key, {
      for (final e in current.entries) e.key: e.value.map((s) => s.toJson()).toList(),
    });
  }
}

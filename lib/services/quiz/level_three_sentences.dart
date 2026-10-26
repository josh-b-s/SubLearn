import '../../data/cloze_cache.dart';
import '../../models/quiz/cloze_sentence.dart';
import '../../models/saved_word.dart';
import '../gemini/gemini_client.dart';
import 'candidate.dart';
import 'cloze_sentence_fetcher.dart';

typedef LevelThreeSentences = ({Map<String, List<ClozeSentence>> sentences, String? note});

/// Cached sentences for level 3, fetching only for words at the cloze step that have none yet.
class LevelThreeSentenceSource {
  const LevelThreeSentenceSource({required this.cache, required this.apiKey});

  final ClozeCache cache;
  final String apiKey;

  Future<LevelThreeSentences> load(List<SavedWord> words) async {
    final needed = words.where((w) => w.level >= 3 && w.levelStreak > 0).toList();
    if (needed.isEmpty) return (sentences: const <String, List<ClozeSentence>>{}, note: null);

    final cached = cache.all();
    final missing = needed.where((w) => cached[w.word]?.isEmpty ?? true).toList();
    if (missing.isEmpty) return (sentences: cached, note: null);

    if (apiKey.isEmpty) {
      return (
        sentences: cached,
        note: 'Some level 3 words got easier questions. Add a Gemini API key in Settings for sentences.',
      );
    }
    try {
      final fetched = await ClozeSentenceFetcher(GeminiClient(apiKey: apiKey))
          .fetch(missing.map(Candidate.fromSaved).toList());
      await cache.store(fetched);
      return (sentences: cache.all(), note: null);
    } on Exception catch (e) {
      // Network, HTTP and parse failures all end up as a note on the quiz, not a crash.
      final text = e.toString();
      final message = text.length > 160 ? text.substring(0, 160) : text;
      return (sentences: cached, note: 'Some level 3 words got easier questions. $message');
    }
  }
}

import 'dart:convert';

import '../../models/quiz/cloze_sentence.dart';
import '../gemini/gemini_client.dart';
import 'candidate.dart';

const _perWord = 2;

const Map<String, Object> _schema = {
  'type': 'ARRAY',
  'items': {
    'type': 'OBJECT',
    'properties': {
      'word': {'type': 'STRING'},
      'sentence': {'type': 'STRING'},
      'translation': {'type': 'STRING'},
    },
    'required': ['word', 'sentence', 'translation'],
  },
};

/// The only Gemini call: short example sentences with an English translation.
/// Pinyin and word meanings come from the local dictionary, not from Gemini.
class ClozeSentenceFetcher {
  const ClozeSentenceFetcher(this._client);

  final GeminiClient _client;

  Future<List<ClozeSentence>> fetch(List<Candidate> words) async {
    if (words.isEmpty) return const [];

    final list = words.map((w) => '${w.word} (${w.pinyin}): ${w.meanings.join('; ')}').join('\n');
    final prompt = '''
Write example sentences for a beginner learning Mandarin Chinese.
For EACH word below write $_perWord different sentences. Rules:
- Use the word exactly once, spelled exactly as given, as a whole word.
- Use only very common words and simple grammar. Under 12 characters.
- Make the sentence clear enough that only this word fits the gap.
- Give a natural English translation.
- Set "word" to the target word exactly as given.

Words:
$list
''';

    final json = await _client.generateJson(prompt: prompt, schema: _schema);
    final decoded = (jsonDecode(json) as List)
        .map((e) => ClozeSentence.fromJson(e as Map<String, dynamic>))
        .toList();

    final known = words.map((w) => w.word).toSet();
    return decoded.where((s) => known.contains(s.word) && s.isUsable).toList();
  }
}

import '../../models/quiz/cloze_question.dart';
import '../../models/quiz/cloze_sentence.dart';
import '../../models/saved_word.dart';
import '../dictionary/chinese_dictionary.dart';
import '../learning/mastery_redactor.dart';
import 'candidate.dart';
import 'distractor_picker.dart';
import 'quiz_column_pinyin.dart';

/// Level 3: turns a cached sentence into a blank plus word tokens, with pinyin and meaning options.
ClozeQuestion? buildClozeQuestion({
  required SavedWord word,
  required ClozeSentence sentence,
  required DistractorPicker picker,
  required ChineseDictionary dictionary,
  required Map<String, int> levels,
}) {
  final start = sentence.sentence.indexOf(word.word);
  if (sentence.word != word.word || start < 0) return null;

  // The target must be a whole word here, not part of a longer one.
  if (dictionary.segment(sentence.sentence).where((w) => w == word.word).length != 1) return null;

  final target = Candidate.fromSaved(word);
  if (target.meanings.isEmpty || target.pinyin.isEmpty) return null;
  final wrong = picker.pick(target);
  final wrongPinyin = picker.pick(target);
  final wrongMeaning = picker.pick(target);
  if (wrong.length != 3 || wrongPinyin.length != 3 || wrongMeaning.length != 3) return null;

  // Neighbouring words show the hints their mastery level allows.
  final before = MasteryRedactor.apply(dictionary.tokens(sentence.sentence.substring(0, start)), levels);
  final after = MasteryRedactor.apply(
    dictionary.tokens(sentence.sentence.substring(start + word.word.length)),
    levels,
  ).map((t) => t.copyWith(id: t.id + before.length + 1)).toList();

  return ClozeQuestion(
    before: before,
    after: after,
    translation: sentence.translation,
    choices: [word.word, ...wrong.map((c) => c.word)]..shuffle(),
    answer: word.word,
    pinyin: pinyinColumn(target: target, wrong: wrongPinyin),
    meaning: meaningColumn(target: target, wrong: wrongMeaning),
  );
}

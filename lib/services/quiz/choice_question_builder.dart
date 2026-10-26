import '../../models/quiz/choice_question.dart';
import '../../models/saved_word.dart';
import 'candidate.dart';
import 'distractor_picker.dart';

/// Level 1, built locally.
ChoiceQuestion? buildChoiceQuestion(SavedWord word, ChoiceDirection direction, DistractorPicker picker) {
  final target = Candidate.fromSaved(word);
  if (target.meanings.isEmpty) return null;
  final wrong = picker.pick(target);
  if (wrong.length != 3) return null;
  final all = [target, ...wrong];

  if (direction == ChoiceDirection.chineseToEnglish) {
    return ChoiceQuestion(
      direction: direction,
      prompt: target.word,
      hint: target.pinyin,
      choices: all.map((c) => c.meaningText).toList()..shuffle(),
      answer: target.meaningText,
    );
  }
  return ChoiceQuestion(
    direction: direction,
    prompt: target.meaningText,
    hint: '',
    choices: all.map((c) => c.word).toList()..shuffle(),
    answer: target.word,
    choicePinyin: {for (final c in all.reversed) c.word: c.pinyin},
  );
}

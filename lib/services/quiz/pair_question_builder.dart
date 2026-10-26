import '../../models/quiz/pair_question.dart';
import '../../models/quiz/quiz_column.dart';
import '../../models/saved_word.dart';
import 'candidate.dart';
import 'distractor_picker.dart';
import 'quiz_column_pinyin.dart';

enum PairVariant { wordToMeaning, meaningToWord, audio }

/// Level 2 and the level 3 listening question, built locally. Each column uses its own wrong set.
PairQuestion? buildPairQuestion(SavedWord word, PairVariant variant, DistractorPicker picker) {
  final target = Candidate.fromSaved(word);
  if (target.meanings.isEmpty || target.pinyin.isEmpty) return null;
  final wrongFirst = picker.pick(target);
  final wrongSecond = picker.pick(target);
  if (wrongFirst.length != 3 || wrongSecond.length != 3) return null;

  final PairPrompt prompt;
  final QuizColumn first;
  final QuizColumn second;
  switch (variant) {
    case PairVariant.wordToMeaning:
      prompt = PairPrompt.word;
      first = pinyinColumn(target: target, wrong: wrongFirst);
      second = meaningColumn(target: target, wrong: wrongSecond);
    case PairVariant.meaningToWord:
      prompt = PairPrompt.meaning;
      first = pinyinColumn(target: target, wrong: wrongFirst);
      second = wordColumn(target: target, wrong: wrongSecond);
    case PairVariant.audio:
      // The word is played, so neither column speaks when tapped.
      prompt = PairPrompt.audio;
      first = wordColumn(target: target, wrong: wrongFirst);
      second = meaningColumn(target: target, wrong: wrongSecond);
  }
  return PairQuestion(
    prompt: prompt,
    word: target.word,
    pinyin: target.pinyin,
    meaning: target.meaningText,
    first: first,
    second: second,
  );
}

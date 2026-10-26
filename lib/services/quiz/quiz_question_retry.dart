import '../../models/quiz/choice_question.dart';
import '../../models/quiz/cloze_question.dart';
import '../../models/quiz/pair_question.dart';
import '../../models/quiz/quiz_question.dart';

extension QuizQuestionRetry on QuizQuestion {
  /// The same question again with options reordered, for the end-of-quiz re-ask.
  QuizQuestion asRetry() {
    final reordered = switch (kind) {
      ChoiceKind(:final question) => ChoiceKind(ChoiceQuestion(
          direction: question.direction,
          prompt: question.prompt,
          hint: question.hint,
          choices: [...question.choices]..shuffle(),
          answer: question.answer,
          choicePinyin: question.choicePinyin,
        )),
      PairKind(:final question) => PairKind(PairQuestion(
          prompt: question.prompt,
          word: question.word,
          pinyin: question.pinyin,
          meaning: question.meaning,
          first: question.first.shuffled(),
          second: question.second.shuffled(),
        )),
      ClozeKind(:final question) => ClozeKind(ClozeQuestion(
          before: question.before,
          after: question.after,
          translation: question.translation,
          choices: [...question.choices]..shuffle(),
          answer: question.answer,
          pinyin: question.pinyin.shuffled(),
          meaning: question.meaning.shuffled(),
        )),
    };
    return QuizQuestion(word: word, level: level, kind: reordered, isRetry: true);
  }
}

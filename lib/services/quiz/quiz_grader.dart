import '../../models/quiz/choice_question.dart';
import '../../models/quiz/pair_question.dart';
import '../../models/quiz/quiz_answer.dart';
import '../../models/quiz/quiz_question.dart';

/// All grading is local exact match.
abstract final class QuizGrader {
  static bool isCorrect(QuizQuestion question, QuizAnswer answer) {
    return switch ((question.kind, answer)) {
      (ChoiceKind(:final question), ChoiceAnswer(:final choice)) => choice == question.answer,
      (ClozeKind(:final question), ClozeAnswer a) =>
        a.word == question.answer &&
            a.pinyin == question.pinyin.answer &&
            a.meaning == question.meaning.answer,
      (PairKind(:final question), PairAnswer a) =>
        a.first == question.first.answer && a.second == question.second.answer,
      _ => false,
    };
  }

  /// The question as a short line for history, with the blank shown for cloze.
  static String promptText(QuizQuestion question) {
    return switch (question.kind) {
      ChoiceKind(:final question) => question.hint.isEmpty ? question.prompt : '${question.prompt} (${question.hint})',
      PairKind(:final question) => question.prompt == PairPrompt.meaning ? question.meaning : question.word,
      ClozeKind(:final question) =>
        '${question.before.map((t) => t.text).join()}___${question.after.map((t) => t.text).join()}',
    };
  }

  static String explanation(QuizQuestion question) {
    return switch (question.kind) {
      ChoiceKind(:final question) => question.direction == ChoiceDirection.chineseToEnglish
          ? '${question.prompt} means "${question.answer}"'
          : '${question.answer} means "${question.prompt}"',
      PairKind(:final question) => '${question.word} is ${question.pinyin}, "${question.meaning}"',
      ClozeKind(:final question) =>
        '${question.answer} fits the blank: ${question.pinyin.answer}, "${question.meaning.answer}"',
    };
  }

  static String answerText(QuizQuestion question) {
    return switch (question.kind) {
      ChoiceKind(:final question) => question.answer,
      PairKind(:final question) => '${question.first.answer} · ${question.second.answer}',
      ClozeKind(:final question) =>
        '${question.answer} · ${question.pinyin.answer} · ${question.meaning.answer}',
    };
  }
}

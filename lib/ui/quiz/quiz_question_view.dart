import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quiz/choice_question.dart';
import '../../models/quiz/quiz_question.dart';
import '../../state/quiz_controller.dart';
import '../../state/word_clip_provider.dart';
import '../components/replay_clip_button.dart';
import '../theme/app_colors.dart';
import 'choice_question_view.dart';
import 'cloze_question_view.dart';
import 'pair_question_view.dart';

/// Picks the right body for the question kind and shows its level.
class QuizQuestionView extends ConsumerWidget {
  const QuizQuestionView({super.key, required this.question, required this.isRevealed});

  final QuizQuestion question;
  final bool isRevealed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider);
    final quiz = ref.read(quizControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Semantics(
          header: true,
          container: true,
          child: Row(spacing: 8, children: [
            Text('LEVEL ${question.level}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.accent)),
            if (question.isRetry)
              Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.warningText)),
          ]),
        ),
        switch (question.kind) {
          ChoiceKind(:final question) => ChoiceQuestionView(
              question: question,
              selection: state.selectedChoice,
              onSelect: quiz.selectChoice,
              isRevealed: isRevealed,
            ),
          PairKind(:final question) => PairQuestionView(
              question: question,
              first: state.selectedFirst,
              second: state.selectedSecond,
              onFirst: quiz.selectFirst,
              onSecond: quiz.selectSecond,
              isRevealed: isRevealed,
            ),
          ClozeKind(:final question) => ClozeQuestionView(
              question: question,
              selection: state.selectedChoice,
              pinyin: state.selectedFirst,
              meaning: state.selectedSecond,
              onSelection: quiz.selectChoice,
              onPinyin: quiz.selectFirst,
              onMeaning: quiz.selectSecond,
              isRevealed: isRevealed,
            ),
        },
        if (_showsReplay(ref)) ReplayClipButton(word: question.word),
      ],
    );
  }

  /// Only level 1 words keep clips, and only when hearing the word doesn't give away the answer.
  bool _showsReplay(WidgetRef ref) {
    final kind = question.kind;
    if (question.level != 1 || kind is! ChoiceKind) return false;
    if (kind.question.direction != ChoiceDirection.chineseToEnglish) return false;
    return ref.watch(wordClipProvider(question.word)).valueOrNull ?? false;
  }
}

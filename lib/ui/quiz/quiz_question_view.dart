import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quiz/quiz_question.dart';
import '../../state/quiz_controller.dart';
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
        Row(spacing: 8, children: [
          Text('LEVEL ${question.level}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.accent)),
          if (question.isRetry)
            Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.warningText)),
        ]),
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
      ],
    );
  }
}

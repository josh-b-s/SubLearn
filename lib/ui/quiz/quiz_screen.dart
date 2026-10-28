import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/vocabulary/saved_word_mastery.dart';
import '../../services/vocabulary/saved_word_review.dart';
import '../../state/clock_provider.dart';
import '../../state/quiz_controller.dart';
import '../../state/words_provider.dart';
import '../components/icon_action.dart';
import '../components/alerts.dart';
import '../components/empty_state.dart';
import '../components/slow_speech_button.dart';
import '../stats/stats_screen.dart';
import '../theme/app_colors.dart';
import 'quiz_feedback_banner.dart';
import 'quiz_home.dart';
import 'quiz_progress_header.dart';
import 'quiz_question_view.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizControllerProvider);
    final quiz = ref.read(quizControllerProvider.notifier);
    final words = ref.watch(wordsProvider);
    final now = ref.read(clockProvider)();
    final active = words.where((w) => !w.isMastered);
    final dueCount = active.where((w) => w.isDue(now)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isInProgress ? '' : 'Quiz'),
        automaticallyImplyLeading: false,
        leading: state.isInProgress ? TextButton(onPressed: () => _confirmQuit(context, quiz), child: const Text('Quit')) : null,
        leadingWidth: state.isInProgress ? 80 : null,
        actions: [
          if (state.isInProgress)
            const SlowSpeechButton()
          else
            IconAction(
              label: 'Stats',
              icon: CupertinoIcons.chart_bar,
              onPressed: () => Navigator.push(context, CupertinoPageRoute<void>(builder: (_) => const StatsScreen())),
            ),
        ],
      ),
      body: switch (state.stage) {
        QuizStage.idle => QuizHome(dueCount: dueCount, activeCount: active.length, onStart: quiz.start),
        QuizStage.loading => const Center(
            child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
              CircularProgressIndicator.adaptive(),
              Text('Building quiz…'),
            ]),
          ),
        QuizStage.answering || QuizStage.feedback => _QuestionScreen(state: state),
        QuizStage.finished => EmptyState(
            icon: CupertinoIcons.checkmark_circle,
            title: 'Quiz complete',
            description: state.summary?.text,
            action: FilledButton(onPressed: quiz.reset, child: const Text('New Quiz')),
          ),
        QuizStage.error => EmptyState(
            icon: CupertinoIcons.exclamationmark_triangle,
            title: "Can't start quiz",
            description: state.error,
            action: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
              OutlinedButton(onPressed: quiz.reset, child: const Text('Back')),
              FilledButton(onPressed: quiz.start, child: const Text('Try Again')),
            ]),
          ),
      },
    );
  }

  Future<void> _confirmQuit(BuildContext context, QuizController quiz) async {
    final quit = await showConfirmAlert(
      context,
      title: 'Quit this quiz?',
      message: "Answers you've already submitted are saved.",
      confirmLabel: 'Quit Quiz',
      cancelLabel: 'Keep Going',
      destructive: true,
    );
    if (quit) quiz.reset();
  }
}

class _QuestionScreen extends ConsumerWidget {
  const _QuestionScreen({required this.state});

  final QuizState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.read(quizControllerProvider.notifier);
    final question = state.shownQuestion;
    final feedback = state.feedback;
    final title = feedback == null ? 'Submit' : (state.hasMoreQuestions ? 'Next Question' : 'Finish');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                QuizProgressHeader(index: state.progressIndex, total: state.total, fraction: state.progressFraction),
                if (state.note != null)
                  Text(state.note!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.warningText)),
                if (question != null)
                  QuizQuestionView(key: ValueKey(question.id), question: question, isRevealed: feedback != null),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                if (feedback != null) QuizFeedbackBanner(feedback: feedback),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: feedback != null ? quiz.next : (state.canSubmit ? quiz.submit : null),
                    child: Padding(padding: const EdgeInsets.all(8), child: Text(title)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

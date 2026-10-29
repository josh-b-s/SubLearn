import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/vocabulary/saved_word_mastery.dart';
import '../../services/vocabulary/saved_word_review.dart';
import '../../state/clock_provider.dart';
import '../../state/quiz_controller.dart';
import '../../state/words_provider.dart';
import '../components/alerts.dart';
import '../components/app_button.dart';
import '../components/empty_state.dart';
import '../components/icon_action.dart';
import '../components/large_title_page.dart';
import '../components/nav_text_button.dart';
import '../components/slow_speech_button.dart';
import '../stats/stats_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
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

    // A running quiz is its own task, so it gets a plain title bar with Quit instead of the tab's large title.
    if (state.isInProgress) {
      return CupertinoPageScaffold(
        backgroundColor: context.groupedBackground,
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: context.groupedBackground,
          leading: NavTextButton(label: 'Quit', onPressed: () => _confirmQuit(context, quiz)),
          trailing: const SlowSpeechButton(),
        ),
        child: _QuestionScreen(state: state),
      );
    }

    return LargeTitlePage(
      title: 'Quiz',
      trailing: IconAction(
        label: 'Stats',
        icon: CupertinoIcons.chart_bar_alt_fill,
        onPressed: () => Navigator.push(context, CupertinoPageRoute<void>(builder: (_) => const StatsScreen())),
      ),
      bottom: state.stage == QuizStage.idle ? QuizStartBar(onStart: quiz.start) : null,
      slivers: [
        switch (state.stage) {
          QuizStage.idle => QuizHome(dueCount: dueCount, activeCount: active.length),
          QuizStage.loading => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
                  CupertinoActivityIndicator(radius: 14),
                  Text('Building quiz…'),
                ]),
              ),
            ),
          QuizStage.answering || QuizStage.feedback => const SliverToBoxAdapter(),
          QuizStage.finished => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.checkmark_circle,
                title: 'Quiz Complete',
                description: state.summary?.text,
                action: AppButton(label: 'New Quiz', expand: false, onPressed: quiz.reset),
              ),
            ),
          QuizStage.error => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: "Can't Start Quiz",
                description: state.error,
                action: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
                  AppButton(label: 'Back', style: AppButtonStyle.tinted, expand: false, onPressed: quiz.reset),
                  AppButton(label: 'Try Again', expand: false, onPressed: quiz.start),
                ]),
              ),
            ),
        },
      ],
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
                  Text(state.note!, style: context.footnote.copyWith(color: context.warningText)),
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
                AppButton(
                  label: title,
                  onPressed: feedback != null ? quiz.next : (state.canSubmit ? quiz.submit : null),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

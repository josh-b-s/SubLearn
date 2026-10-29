import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session/session_summary.dart';
import '../../state/quiz_controller.dart';
import '../../state/screen_share_controller.dart';
import '../../state/tab_provider.dart';
import '../components/app_button.dart';
import '../components/nav_text_button.dart';
import '../components/pushed_page.dart';
import '../components/section_label.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';
import 'session_breakdown_bar.dart';
import 'session_top_word_row.dart';

/// Shown after a session ends: what was heard, and a shortcut into a review quiz.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key, required this.summary});

  final SessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxCount = summary.topWords.fold(1, (m, e) => math.max(m, e.count));
    final unsaved = summary.unsavedTopWords.length;
    final reviewCount = summary.topWords.length;

    return PushedPage(
      title: 'Session Complete',
      showsBackButton: false,
      safeBottom: false,
      trailing: NavTextButton(label: 'Done', bold: true, onPressed: () => Navigator.pop(context)),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${summary.total} unique word${summary.total == 1 ? '' : 's'} heard',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText),
                ),
                const SizedBox(height: 20),
                _Card(
                  title: 'WORD BREAKDOWN',
                  child: SessionBreakdownBar(
                    alreadyKnown: summary.alreadyKnown,
                    learning: summary.learning,
                    newWords: summary.newWords,
                  ),
                ),
                if (summary.topWords.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Card(
                    title: 'MOST HEARD',
                    child: Column(spacing: 10, children: [
                      for (final entry in summary.topWords) SessionTopWordRow(entry: entry, maxCount: maxCount),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          if (reviewCount > 0)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: cardRadius),
              child: ColoredBox(
                color: context.cardBackground,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
                        AppButton(
                          label: 'Review $reviewCount word${reviewCount == 1 ? '' : 's'}',
                          onPressed: () => _review(context, ref),
                        ),
                        if (unsaved > 0)
                          Text(
                            '$unsaved new word${unsaved == 1 ? '' : 's'} will be saved to your vocabulary.',
                            style: context.footnote.copyWith(color: context.mutedText),
                          ),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  /// Saves the new words, then opens a quiz on only the words that were heard.
  void _review(BuildContext context, WidgetRef ref) {
    final focus = ref.read(screenShareControllerProvider.notifier).prepareReview();
    Navigator.pop(context);
    final quiz = ref.read(quizControllerProvider.notifier);
    quiz.reset();
    ref.read(tabProvider.notifier).select(AppTab.quiz);
    unawaited(quiz.start(focus: focus));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: context.cardBackground, borderRadius: const BorderRadius.all(cardRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [
        SectionLabel(title),
        child,
      ]),
    );
  }
}

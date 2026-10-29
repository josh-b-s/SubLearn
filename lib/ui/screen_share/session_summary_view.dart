import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/quiz_controller.dart';
import '../../state/screen_share_controller.dart';
import '../../state/tab_provider.dart';
import '../components/empty_state.dart';
import '../components/section_label.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import 'session_breakdown_bar.dart';
import 'session_top_word_row.dart';
import 'transcript_screen.dart';

/// Shown after a session ends: what was heard, and a shortcut into a review quiz.
class SessionSummaryView extends ConsumerWidget {
  const SessionSummaryView({super.key, required this.state});

  final ScreenShareState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(screenShareControllerProvider.notifier);
    final summary = state.summary;

    if (summary == null) {
      return EmptyState(
        icon: Icons.hearing_disabled_outlined,
        title: 'No Mandarin heard',
        description: state.error ?? 'Nothing with a dictionary meaning was picked up in this session.',
        action: FilledButton(onPressed: controller.dismissSummary, child: const Text('Done')),
      );
    }

    final maxCount = summary.topWords.fold(1, (m, e) => math.max(m, e.count));
    final unsaved = summary.unsavedTopWords.length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('Stopped early: ${state.error}', style: TextStyle(color: context.errorText)),
                ),
              Text(
                '${summary.total} unique word${summary.total == 1 ? '' : 's'} heard',
                style: TextStyle(color: context.mutedText),
              ),
              const SizedBox(height: 16),
              _Card(title: 'WORD BREAKDOWN', child: SessionBreakdownBar(
                alreadyKnown: summary.alreadyKnown,
                learning: summary.learning,
                newWords: summary.newWords,
              )),
              if (summary.topWords.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Card(
                  title: 'MOST HEARD',
                  child: Column(spacing: 10, children: [
                    for (final entry in summary.topWords) SessionTopWordRow(entry: entry, maxCount: maxCount),
                  ]),
                ),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const TranscriptScreen()),
                ),
                icon: const Icon(Icons.subject),
                label: const Text('View transcript'),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
              if (summary.topWords.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _review(ref),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Review ${summary.topWords.length} word${summary.topWords.length == 1 ? '' : 's'}'),
                    ),
                  ),
                ),
                if (unsaved > 0)
                  Text(
                    '$unsaved new word${unsaved == 1 ? '' : 's'} will be saved to your vocabulary.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText),
                  ),
              ],
              TextButton(onPressed: controller.dismissSummary, child: const Text('Done')),
            ]),
          ),
        ),
      ],
    );
  }

  /// Saves the new words, then opens a quiz on only the words that were heard.
  void _review(WidgetRef ref) {
    final focus = ref.read(screenShareControllerProvider.notifier).prepareReview();
    ref.read(screenShareControllerProvider.notifier).dismissSummary();
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

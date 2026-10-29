import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/quiz_records_provider.dart';
import '../components/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'quiz_due_banner.dart';
import 'quiz_history_card.dart';
import 'quiz_history_detail_screen.dart';

/// Quiz start screen content, as slivers: words due and past quizzes.
class QuizHome extends ConsumerWidget {
  const QuizHome({super.key, required this.dueCount, required this.activeCount});

  final int dueCount;
  final int activeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(quizRecordsProvider);
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          QuizDueBanner(dueCount: dueCount, activeCount: activeCount),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text('History', style: context.title2.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            Text('Quizzes you take show up here.', style: TextStyle(color: context.mutedText))
          else
            for (final record in records)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuizHistoryCard(
                  record: record,
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute<void>(builder: (_) => QuizHistoryDetailScreen(record: record)),
                  ),
                ),
              ),
        ]),
      ),
    );
  }
}

/// Pinned button under the quiz home that starts a review.
class QuizStartBar extends StatelessWidget {
  const QuizStartBar({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Semantics(
        hint: 'Starts a quiz on the words that are due',
        child: AppButton(label: 'Start Review Session', onPressed: onStart),
      ),
    );
  }
}

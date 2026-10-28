import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/quiz_records_provider.dart';
import '../theme/app_colors.dart';
import 'quiz_due_banner.dart';
import 'quiz_history_card.dart';
import 'quiz_history_detail_screen.dart';

/// Quiz start screen: words due, past quizzes, and the button that starts a review.
class QuizHome extends ConsumerWidget {
  const QuizHome({super.key, required this.dueCount, required this.activeCount, required this.onStart});

  final int dueCount;
  final int activeCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(quizRecordsProvider);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              QuizDueBanner(dueCount: dueCount, activeCount: activeCount),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text('History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Semantics(
              hint: 'Starts a quiz on the words that are due',
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: const Padding(padding: EdgeInsets.all(8), child: Text('Start Review Session')),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

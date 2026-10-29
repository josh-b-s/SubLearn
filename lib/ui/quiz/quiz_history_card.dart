import 'package:flutter/cupertino.dart';

import '../../models/quiz_record.dart';
import '../components/pressable.dart';
import '../components/progress_ring.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';

/// One past quiz: score ring, how it went, and when.
class QuizHistoryCard extends StatelessWidget {
  const QuizHistoryCard({super.key, required this.record, required this.onTap});

  final QuizRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fraction = record.items.isEmpty ? 0.0 : record.correctCount / record.items.length;
    final missed = record.items.length - record.correctCount;
    final summary = missed == 0 ? '${record.correctCount} correct' : '${record.correctCount} correct, $missed to review again';
    final when = formatDayTime(record.date);
    return Semantics(
      label: when,
      value: '${(fraction * 100).round()} percent. $summary',
      hint: 'Shows every question from this quiz',
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: Pressable(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: context.cardBackground, borderRadius: const BorderRadius.all(cardRadius)),
            child: Row(
              spacing: 16,
              children: [
                ProgressRing(
                  value: fraction,
                  child: Text(
                    '${(fraction * 100).round()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.accent),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary),
                      Text(when, style: context.footnote.copyWith(color: context.mutedText)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_forward, size: 16, color: context.resolve(CupertinoColors.tertiaryLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../models/quiz_record.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';

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
      child: Material(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 16,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator.adaptive(
                        value: fraction,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: context.chipBackground,
                      ),
                      Text(
                        '${(fraction * 100).round()}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.accent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary),
                      Text(when, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_forward, color: context.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

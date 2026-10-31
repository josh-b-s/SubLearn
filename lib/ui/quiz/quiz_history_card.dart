import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/quiz_record.dart';
import '../components/pressable.dart';
import '../components/progress_ring.dart';
import '../format_date.dart';
import '../theme/wind_classes.dart';

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
          child: WDiv(
            className: 'flex flex-row items-center gap-4 w-full p-5 $cardClass',
            children: [
              ProgressRing(
                value: fraction,
                child: WText('${(fraction * 100).round()}%', className: 'text-xs font-bold text-brand-500 dark:text-brand-400'),
              ),
              WDiv(
                className: 'flex-1 flex flex-col items-start',
                children: [
                  WText(summary, className: inkTextClass),
                  WText(when, className: 'text-[13px] $mutedTextClass'),
                ],
              ),
              const WIcon(CupertinoIcons.chevron_forward, className: 'text-base text-night-400'),
            ],
          ),
        ),
      ),
    );
  }
}

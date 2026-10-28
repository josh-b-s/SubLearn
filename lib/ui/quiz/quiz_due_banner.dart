import 'package:flutter/material.dart';

/// Top card on the quiz home: how many words are due for review.
class QuizDueBanner extends StatelessWidget {
  const QuizDueBanner({super.key, required this.dueCount, required this.activeCount});

  final int dueCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = dueCount > 0 ? '$dueCount Word${dueCount == 1 ? '' : 's'} Due' : 'All caught up';
    final subtitle = dueCount > 0
        ? 'Ready for review today'
        : '$activeCount word${activeCount == 1 ? '' : 's'} still being learned';
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(22)),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ExcludeSemantics(child: Icon(Icons.calendar_today, size: 28, color: scheme.onPrimary)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: scheme.onPrimary)),
                  Text(subtitle, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Top card on the quiz home: how many words are due for review.
class QuizDueBanner extends StatelessWidget {
  const QuizDueBanner({super.key, required this.dueCount, required this.activeCount});

  final int dueCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    const onAccent = CupertinoColors.white;
    final title = dueCount > 0 ? '$dueCount Word${dueCount == 1 ? '' : 's'} Due' : 'All caught up';
    final subtitle = dueCount > 0
        ? 'Ready for review today'
        : '$activeCount word${activeCount == 1 ? '' : 's'} still being learned';
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.accent, borderRadius: BorderRadius.circular(22)),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: onAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const ExcludeSemantics(child: Icon(CupertinoIcons.calendar, size: 28, color: onAccent)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onAccent)),
                  Text(subtitle, style: TextStyle(color: onAccent.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

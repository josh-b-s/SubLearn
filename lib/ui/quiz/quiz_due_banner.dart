import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

/// Top card on the quiz home: how many words are due for review.
class QuizDueBanner extends StatelessWidget {
  const QuizDueBanner({super.key, required this.dueCount, required this.activeCount});

  final int dueCount;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final due = dueCount > 0;
    final title = due ? 'word${dueCount == 1 ? '' : 's'} due today' : 'All caught up';
    final subtitle = due ? 'Ready for review' : '$activeCount word${activeCount == 1 ? '' : 's'} still being learned';
    return MergeSemantics(
      child: WDiv(
        className: 'flex flex-row items-center gap-4 w-full px-[22px] py-5 rounded-card bg-gradient-to-br from-brand-500 to-iris-500 dark:from-brand-500 dark:to-brand-600',
        children: [
          if (due)
            WText('$dueCount', className: 'text-[56px] leading-none font-bold text-white')
          else
            const ExcludeSemantics(
              child: WIcon(CupertinoIcons.checkmark_circle_fill, className: 'text-[44px] text-white'),
            ),
          WDiv(
            className: 'flex-1 flex flex-col items-start',
            children: [
              WText(title, className: 'text-xl font-bold text-white'),
              WText(subtitle, className: 'text-white/85'),
            ],
          ),
        ],
      ),
    );
  }
}

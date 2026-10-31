import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../components/progress_bar.dart';
import '../theme/wind_classes.dart';

/// "4 / 10", percent complete and a bar, shown above each question.
class QuizProgressHeader extends StatelessWidget {
  const QuizProgressHeader({super.key, required this.index, required this.total, required this.fraction});

  final int index;
  final int total;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Quiz progress',
      value: 'Question $index of $total',
      excludeSemantics: true,
      child: WDiv(
        className: 'flex flex-col items-stretch gap-2',
        children: [
          WDiv(
            className: 'flex flex-row justify-between items-center w-full',
            children: [
              WText('$index / $total', className: 'text-[17px] font-semibold text-brand-500 dark:text-brand-400'),
              WText('${(fraction * 100).round()}% complete', className: 'text-[15px] $mutedTextClass'),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(end: fraction),
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            builder: (_, value, __) => ProgressBar(value: value),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../components/progress_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

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
      child: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$index / $total', style: context.body.copyWith(color: context.accent, fontWeight: FontWeight.w600)),
              Text('${(fraction * 100).round()}% Complete', style: context.subhead.copyWith(color: context.mutedText)),
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

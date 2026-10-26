import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "4 / 10", percent complete and a bar, shown above each question.
class QuizProgressHeader extends StatelessWidget {
  const QuizProgressHeader({super.key, required this.index, required this.total, required this.fraction});

  final int index;
  final int total;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$index / $total', style: text.titleMedium?.copyWith(color: context.accent, fontWeight: FontWeight.w600)),
            Text('${(fraction * 100).round()}% Complete', style: text.bodyMedium?.copyWith(color: context.mutedText)),
          ],
        ),
        LinearProgressIndicator(value: fraction, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}

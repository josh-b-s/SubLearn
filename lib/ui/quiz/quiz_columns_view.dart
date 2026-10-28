import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quiz/quiz_column.dart';
import '../../state/core_providers.dart';
import '../theme/app_colors.dart';
import 'option_button.dart';

/// Two columns of answer options side by side, stacked once text is too large for two narrow columns.
class QuizColumnsView extends ConsumerWidget {
  const QuizColumnsView({
    super.key,
    required this.first,
    required this.second,
    required this.firstSelection,
    required this.secondSelection,
    required this.onFirst,
    required this.onSecond,
    required this.isRevealed,
  });

  final QuizColumn first;
  final QuizColumn second;
  final String? firstSelection;
  final String? secondSelection;
  final ValueChanged<String> onFirst;
  final ValueChanged<String> onSecond;
  final bool isRevealed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = [
      _column(context, ref, first, firstSelection, onFirst),
      _column(context, ref, second, secondSelection, onSecond),
    ];
    // Stacked once text is too large for two narrow columns.
    final stacked = MediaQuery.textScalerOf(context).scale(14) >= 14 * 1.6;
    if (stacked) return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: columns);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [for (final column in columns) Expanded(child: column)],
    );
  }

  Widget _column(BuildContext context, WidgetRef ref, QuizColumn column, String? selection, ValueChanged<String> onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Semantics(
          header: true,
          child: Text(column.title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.mutedText, fontWeight: FontWeight.w600)),
        ),
        for (final choice in column.choices)
          OptionButton(
            text: choice,
            fontSize: 16,
            state: OptionState.resolve(choice: choice, answer: column.answer, selection: selection, revealed: isRevealed),
            isLocked: isRevealed,
            onTap: () {
              onPick(choice);
              final spoken = column.spoken[choice];
              if (spoken != null) ref.read(speakerProvider).speak(spoken, ignoringMuteSwitch: true);
            },
          ),
      ],
    );
  }
}

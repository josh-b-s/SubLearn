import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Stacked bar of known, learning and new words, with a legend.
class SessionBreakdownBar extends StatelessWidget {
  const SessionBreakdownBar({super.key, required this.alreadyKnown, required this.learning, required this.newWords});

  final int alreadyKnown;
  final int learning;
  final int newWords;

  int get _total => alreadyKnown + learning + newWords;

  @override
  Widget build(BuildContext context) {
    final segments = [
      (label: 'Known', count: alreadyKnown, color: context.successText),
      (label: 'Learning', count: learning, color: context.warningText),
      (label: 'New', count: newWords, color: context.accent),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(children: [
              for (final s in segments.where((s) => s.count > 0))
                Expanded(flex: s.count, child: ColoredBox(color: s.color)),
              if (_total == 0) Expanded(child: ColoredBox(color: context.chipBackground)),
            ]),
          ),
        ),
        Wrap(spacing: 16, runSpacing: 4, children: [
          for (final s in segments)
            Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              Text('${s.label} ${s.count}'),
            ]),
        ]),
      ],
    );
  }
}

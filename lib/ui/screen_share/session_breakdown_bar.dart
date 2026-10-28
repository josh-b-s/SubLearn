import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Stacked bar and legend splitting a session's words into known, learning and new.
class SessionBreakdownBar extends StatelessWidget {
  const SessionBreakdownBar({super.key, required this.alreadyKnown, required this.learning, required this.newWords});

  final int alreadyKnown;
  final int learning;
  final int newWords;

  static const knownColor = Colors.green;
  static const learningColor = Colors.orange;
  static const newColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 14 * 1.5;
    final legend = [
      _Legend(color: knownColor, label: 'Already known', count: alreadyKnown),
      _Legend(color: learningColor, label: 'Learning', count: learning),
      _Legend(color: newColor, label: 'New', count: newWords),
    ];

    return Semantics(
      label: 'Word breakdown',
      value: '$alreadyKnown already known, $learning learning, $newWords new',
      excludeSemantics: true,
      child: Column(
        spacing: 14,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 28,
              color: context.chipBackground,
              child: LayoutBuilder(
                builder: (_, constraints) => TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
                  duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  // Unmasks the full bar from the left, so segments keep their sizes while revealing.
                  builder: (_, revealed, __) => ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: revealed,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Row(children: [
                          for (final (count, color) in [(alreadyKnown, knownColor), (learning, learningColor), (newWords, newColor)])
                            if (count > 0) Expanded(flex: count, child: ColoredBox(color: color)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (largeText)
            Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: legend)
          else
            Row(children: [for (final item in legend) Expanded(child: Center(child: item))]),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.count});

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$count', style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: text.bodySmall?.copyWith(color: context.mutedText)),
      ]),
    ]);
  }
}

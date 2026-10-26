import 'package:flutter/material.dart';

import '../../services/dates.dart';
import '../../services/stats/stats_calculator.dart';
import '../theme/app_colors.dart';

/// GitHub-style grid of review counts for the last 90 days. One column per week, one row per weekday, Monday first.
class ReviewHeatmap extends StatelessWidget {
  const ReviewHeatmap({super.key, required this.counts, required this.today});

  final Map<DateTime, int> counts;
  final DateTime today;

  static const _levels = 4;
  static const _cell = 14.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    final firstDay = addDays(startOfDay(today), -(StatsCalculator.heatmapDays - 1));
    final origin = startOfWeek(firstDay);
    final columns = (startOfWeek(today).difference(origin).inDays ~/ 7) + 1;
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b);

    Color colorFor(int count) {
      if (count == 0) return context.chipBackground;
      final level = (count * _levels / (maxCount == 0 ? 1 : maxCount)).ceil().clamp(1, _levels);
      return Colors.blue.withValues(alpha: level / _levels);
    }

    final cells = <Widget>[];
    for (var column = 0; column < columns; column++) {
      cells.add(Column(
        children: [
          for (var row = 0; row < 7; row++)
            Builder(builder: (_) {
              final day = addDays(origin, column * 7 + row);
              final inRange = !day.isBefore(firstDay) && !day.isAfter(startOfDay(today));
              return Container(
                width: _cell,
                height: _cell,
                margin: const EdgeInsets.all(_gap / 2),
                decoration: BoxDecoration(
                  color: inRange ? colorFor(counts[day] ?? 0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text('Less', style: TextStyle(fontSize: 11, color: context.mutedText)),
            for (var i = 0; i <= _levels; i++)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i == 0 ? context.chipBackground : Colors.blue.withValues(alpha: i / _levels),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Text('More', style: TextStyle(fontSize: 11, color: context.mutedText)),
          ],
        ),
      ],
    );
  }
}

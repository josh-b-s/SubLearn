import 'package:flutter/cupertino.dart';

import '../../services/dates.dart';
import '../../services/stats/stats_calculator.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';

/// GitHub-style grid of review counts for the last 90 days. One column per week, one row per weekday, Monday first.
class ReviewHeatmap extends StatelessWidget {
  const ReviewHeatmap({super.key, required this.counts, required this.today});

  final Map<DateTime, int> counts;
  final DateTime today;

  static const _levels = 4;
  static const _gap = 3.0;
  static const _labelWidth = 30.0;
  static const _monthHeight = 12.0;
  static const _weekdayLabels = ['Mon', '', 'Wed', '', 'Fri', '', ''];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) => _grid(context, (constraints.maxWidth - _labelWidth) / _columns));
  }

  int get _columns {
    final firstDay = addDays(startOfDay(today), -(StatsCalculator.heatmapDays - 1));
    return daysBetween(startOfWeek(firstDay), startOfWeek(today)) ~/ 7 + 1;
  }

  /// [stride] is the width and height of one cell including its gap, sized so the columns fill the row.
  Widget _grid(BuildContext context, double stride) {
    final cell = stride - _gap;
    final firstDay = addDays(startOfDay(today), -(StatsCalculator.heatmapDays - 1));
    final origin = startOfWeek(firstDay);
    final columns = _columns;
    final maxCount = counts.values.fold(1, (a, b) => a > b ? a : b);
    final activeDays = counts.values.where((c) => c > 0).length;
    final totalReviews = counts.values.fold(0, (a, b) => a + b);
    final small = TextStyle(fontSize: 11, color: context.mutedText);

    Color colorFor(int count) {
      if (count == 0) return context.chipBackground;
      final level = (count * _levels / maxCount).ceil().clamp(1, _levels);
      return context.accent.withValues(alpha: level / _levels);
    }

    DateTime columnDate(int column) => addDays(origin, column * 7);

    /// Label the first column of each month. The partial first column only counts if the next one is the same month.
    bool showsMonth(int column) {
      final month = columnDate(column).month;
      if (column == 0) return columns > 1 && columnDate(1).month == month;
      return month != columnDate(column - 1).month;
    }

    final monthRow = SizedBox(
      height: _monthHeight,
      child: Row(children: [
        for (var column = 0; column < columns; column++)
          SizedBox(
            width: stride,
            child: showsMonth(column)
                ? OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: 40,
              child: Text(monthAbbreviation(columnDate(column).month), style: small),
            )
                : null,
          ),
      ]),
    );

    final cells = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var column = 0; column < columns; column++)
        Column(children: [
          for (var row = 0; row < 7; row++)
            _cellAt(addDays(origin, column * 7 + row), firstDay, cell, colorFor),
        ]),
    ]);

    final weekdayLabels = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: _monthHeight),
      for (final label in _weekdayLabels)
        SizedBox(width: _labelWidth, height: stride, child: Align(alignment: Alignment.centerLeft, child: Text(label, style: small))),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Semantics(
          label: 'Review activity, last ${StatsCalculator.heatmapDays} days',
          value: '$activeDays days with reviews, $totalReviews reviews in total',
          excludeSemantics: true,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            weekdayLabels,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [monthRow, cells])),
          ]),
        ),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4,
            children: [
              Text('Less', style: small),
              for (var i = 0; i <= _levels; i++)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == 0 ? context.chipBackground : context.accent.withValues(alpha: i / _levels),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Text('More', style: small),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cellAt(DateTime day, DateTime firstDay, double size, Color Function(int) colorFor) {
    final inRange = !day.isBefore(firstDay) && !day.isAfter(startOfDay(today));
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(_gap / 2),
      decoration: BoxDecoration(
        color: inRange ? colorFor(counts[day] ?? 0) : const Color(0x00000000),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
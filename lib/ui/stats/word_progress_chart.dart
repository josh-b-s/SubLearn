import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/progress_series.dart';
import '../../models/stats_snapshot.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';

/// Words learned, saved and mastered over the last 12 weeks. The menu narrows it to one line.
class WordProgressChart extends StatefulWidget {
  const WordProgressChart({super.key, required this.weeks, required this.gainedThisWeek});

  final List<WeeklyProgress> weeks;
  final int gainedThisWeek;

  @override
  State<WordProgressChart> createState() => _WordProgressChartState();
}

class _WordProgressChartState extends State<WordProgressChart> {
  static const _all = -1;

  /// Null shows every series.
  ProgressSeries? _only;

  List<ProgressSeries> get _shown => _only == null ? ProgressSeries.values : [_only!];

  int _latest(ProgressSeries series) => widget.weeks.isEmpty ? 0 : widget.weeks.last.value(series);

  /// Totals only grow, so the latest week holds each line's highest point.
  int get _peak => _shown.map(_latest).fold(0, (a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final hasData = widget.weeks.isNotEmpty && ProgressSeries.values.any((s) => _latest(s) > 0);
    if (!hasData) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text('Not enough data yet', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _totals(context)),
            _menu(context),
          ],
        ),
        if (_shown.contains(ProgressSeries.learned) && widget.gainedThisWeek > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(
              '+${widget.gainedThisWeek} learned this week',
              style: TextStyle(color: context.successText, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        Semantics(
          label: 'Words over the last 12 weeks',
          value: _shown.map((s) => '${s.label} ${_latest(s)}').join(', '),
          excludeSemantics: true,
          child: SizedBox(height: 180, child: LineChart(_data(context))),
        ),
        if (_shown.length > 1) _legend(context),
      ],
    );
  }

  Widget _totals(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final series in _shown)
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('${_latest(series)}', style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: series.color)),
            Text(series.label, style: text.bodySmall?.copyWith(color: context.mutedText)),
          ]),
      ],
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Show',
      onSelected: (index) => setState(() => _only = index == _all ? null : ProgressSeries.values[index]),
      itemBuilder: (_) => [
        const PopupMenuItem(value: _all, child: Text('All')),
        for (final (i, series) in ProgressSeries.values.indexed) PopupMenuItem(value: i, child: Text(series.label)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, spacing: 2, children: [
          Text(_only?.label ?? 'All', style: TextStyle(color: context.accent)),
          Icon(Icons.expand_more, size: 18, color: context.accent),
        ]),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    return Wrap(spacing: 16, children: [
      for (final series in _shown)
        Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: series.color, shape: BoxShape.circle)),
          Text(series.label, style: Theme.of(context).textTheme.bodySmall),
        ]),
    ]);
  }

  LineChartData _data(BuildContext context) {
    final weeks = widget.weeks;
    final labelStyle = TextStyle(fontSize: 10, color: context.mutedText);
    final lastIndex = weeks.length - 1;
    return LineChartData(
      minY: 0,
      maxY: (_peak < 1 ? 1 : _peak).toDouble(),
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (v, meta) => v == meta.max || v == meta.min && v != 0
                ? const SizedBox.shrink()
                : Text('${v.toInt()}', style: labelStyle),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 4,
            getTitlesWidget: (v, meta) {
              final week = weeks[v.toInt().clamp(0, lastIndex).toInt()].weekStart;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${monthAbbreviation(week.month)} ${week.day}', style: labelStyle),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        for (final series in _shown)
          LineChartBarData(
            color: series.color,
            barWidth: 2.5,
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, checkToShowDot: (spot, _) => spot.x == lastIndex),
            spots: [for (final (i, w) in weeks.indexed) FlSpot(i.toDouble(), w.value(series).toDouble())],
          ),
      ],
    );
  }
}

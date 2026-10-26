import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/progress_series.dart';
import '../../models/stats_snapshot.dart';
import '../theme/app_colors.dart';

/// Running totals per week, with a chip row to show one line or all three.
class WordProgressChart extends StatefulWidget {
  const WordProgressChart({super.key, required this.weeks, required this.gainedThisWeek});

  final List<WeeklyProgress> weeks;
  final int gainedThisWeek;

  @override
  State<WordProgressChart> createState() => _WordProgressChartState();
}

class _WordProgressChartState extends State<WordProgressChart> {
  /// Null shows every series.
  ProgressSeries? _only;

  List<ProgressSeries> get _shown => _only == null ? ProgressSeries.values : [_only!];

  @override
  Widget build(BuildContext context) {
    final weeks = widget.weeks;
    final hasData = weeks.any((w) => w.learned > 0 || w.saved > 0 || w.mastered > 0);
    if (!hasData) {
      return Text('Not enough data yet', style: TextStyle(color: context.mutedText));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        if (widget.gainedThisWeek > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('+${widget.gainedThisWeek} learned this week', style: TextStyle(color: context.successText, fontWeight: FontWeight.w600)),
          ),
        Wrap(
          spacing: 16,
          children: [
            for (final series in _shown)
              Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
                Text('${weeks.last.value(series)}', style: TextStyle(fontWeight: FontWeight.bold, color: series.color)),
                Text(series.label),
              ]),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(label: const Text('All'), selected: _only == null, onSelected: (_) => setState(() => _only = null)),
            for (final series in ProgressSeries.values)
              ChoiceChip(
                label: Text(series.label),
                selected: _only == series,
                onSelected: (_) => setState(() => _only = series),
              ),
          ],
        ),
        SizedBox(height: 180, child: LineChart(_data(context))),
      ],
    );
  }

  LineChartData _data(BuildContext context) {
    final weeks = widget.weeks;
    final labelStyle = TextStyle(fontSize: 10, color: context.mutedText);
    return LineChartData(
      minY: 0,
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (v, meta) =>
                v == meta.max || v == meta.min && v != 0 ? const SizedBox.shrink() : Text('${v.toInt()}', style: labelStyle),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 3,
            getTitlesWidget: (v, meta) {
              final week = weeks[v.toInt().clamp(0, weeks.length - 1).toInt()].weekStart;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${week.day}/${week.month}', style: labelStyle),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        for (final series in _shown)
          LineChartBarData(
            color: series.color,
            barWidth: 3,
            isCurved: false,
            dotData: const FlDotData(show: false),
            spots: [for (final (i, w) in weeks.indexed) FlSpot(i.toDouble(), w.value(series).toDouble())],
          ),
      ],
    );
  }
}

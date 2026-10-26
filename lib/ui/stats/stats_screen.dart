import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stats_period.dart';
import '../../state/clock_provider.dart';
import '../../state/stats_provider.dart';
import '../theme/app_colors.dart';
import 'review_heatmap.dart';
import 'stat_card.dart';
import 'stats_section_card.dart';
import 'streak_badge.dart';
import 'word_progress_chart.dart';

/// Progress screen: streak, review accuracy, word progress over time and activity.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsSnapshotProvider);
    final period = ref.watch(statsPeriodProvider);
    final accuracy = stats.accuracy;

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              StreakBadge(days: stats.streak),
            ],
          ),
          const SizedBox(height: 20),
          SegmentedButton<StatsPeriod>(
            segments: [for (final p in StatsPeriod.values) ButtonSegment(value: p, label: Text(p.label))],
            selected: {period},
            onSelectionChanged: (s) => ref.read(statsPeriodProvider.notifier).select(s.first),
          ),
          const SizedBox(height: 20),
          StatsSectionCard(
            title: 'Words over time',
            child: WordProgressChart(weeks: stats.weekly, gainedThisWeek: stats.learnedThisWeek),
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Expanded(child: StatCard(value: '${stats.reviews}', label: 'Reviews')),
                Expanded(
                  child: StatCard(
                    value: accuracy == null ? 'n/a' : '${(accuracy * 100).round()}%',
                    label: 'Accuracy',
                    detail: stats.reviews == 0 ? null : '${stats.correct} of ${stats.reviews} correct',
                    accent: _accuracyColor(context, accuracy),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StatsSectionCard(
            title: 'Review activity (90 days)',
            child: ReviewHeatmap(counts: stats.dailyCounts, today: ref.read(clockProvider)()),
          ),
        ],
      ),
    );
  }

  Color? _accuracyColor(BuildContext context, double? accuracy) {
    if (accuracy == null) return null;
    if (accuracy >= 0.85) return context.successText;
    if (accuracy >= 0.70) return context.warningText;
    return context.errorText;
  }
}

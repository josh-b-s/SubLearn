import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stats_period.dart';
import '../../state/clock_provider.dart';
import '../../state/stats_provider.dart';
import '../components/pushed_page.dart';
import '../components/segmented_picker.dart';
import '../theme/wind_classes.dart';
import '../theme/app_text.dart';
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

    return PushedPage(
      title: 'Stats',
      backLabel: 'Quiz',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                header: true,
                child: Text('Progress', style: context.title2.copyWith(fontWeight: FontWeight.bold)),
              ),
              StreakBadge(days: stats.streak),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            hint: 'Changes the time range of the statistics',
            child: SegmentedPicker<StatsPeriod>(
              labels: {for (final p in StatsPeriod.values) p: p.label},
              selected: period,
              onChanged: ref.read(statsPeriodProvider.notifier).select,
            ),
          ),
          const SizedBox(height: 20),
          StatsSectionCard(
            title: 'Words over time',
            child: WordProgressChart(weeks: stats.weekly, gainedThisWeek: stats.learnedThisWeek),
          ),
          const SizedBox(height: 20),
          _StatCards(
            stacked: MediaQuery.textScalerOf(context).scale(14) >= 14 * 1.6,
            children: [
              StatCard(value: '${stats.reviews}', label: 'Reviews'),
              StatCard(
                value: accuracy == null ? 'n/a' : '${(accuracy * 100).round()}%',
                label: 'Accuracy',
                detail: stats.reviews == 0 ? null : '${stats.correct} of ${stats.reviews} correct',
                valueClass: _accuracyClass(accuracy),
              ),
            ],
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

  String _accuracyClass(double? accuracy) {
    if (accuracy == null) return inkTextClass;
    if (accuracy >= 0.85) return 'text-green-700 dark:text-green-400';
    if (accuracy >= 0.70) return 'text-orange-700 dark:text-orange-400';
    return 'text-red-700 dark:text-red-400';
  }
}

/// Cards side by side, stacked once text is too large for two narrow columns.
class _StatCards extends StatelessWidget {
  const _StatCards({required this.stacked, required this.children});

  final bool stacked;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (stacked) return Column(spacing: 12, crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    // IntrinsicHeight lets the shorter card stretch to match.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [for (final child in children) Expanded(child: child)],
      ),
    );
  }
}

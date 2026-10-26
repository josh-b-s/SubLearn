import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats_period.dart';
import '../models/stats_snapshot.dart';
import '../services/stats/stats_calculator.dart';
import 'clock_provider.dart';
import 'review_logs_provider.dart';
import 'words_provider.dart';

class StatsPeriodNotifier extends Notifier<StatsPeriod> {
  @override
  StatsPeriod build() => StatsPeriod.month;

  void select(StatsPeriod period) => state = period;
}

final statsPeriodProvider = NotifierProvider<StatsPeriodNotifier, StatsPeriod>(StatsPeriodNotifier.new);

final statsSnapshotProvider = Provider<StatsSnapshot>((ref) {
  return StatsCalculator.snapshot(
    logs: ref.watch(reviewLogsProvider),
    saved: ref.watch(wordsProvider),
    period: ref.watch(statsPeriodProvider),
    now: ref.read(clockProvider)(),
  );
});

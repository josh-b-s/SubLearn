import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reminders/reminder_planner.dart';
import '../services/vocabulary/saved_word_mastery.dart';
import 'clock_provider.dart';
import 'core_providers.dart';
import 'settings_provider.dart';
import 'words_provider.dart';

/// Rebuilds the pending reminders from the current words and reminder settings.
final reminderSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final settings = ref.read(settingsProvider);
    final scheduler = ref.read(reminderSchedulerProvider);
    if (!settings.reminderEnabled) return scheduler.replaceAll(const []);

    final plan = ReminderPlanner.plan(
      dueDates: ref.read(wordsProvider).where((w) => !w.isMastered).map((w) => w.dueDate).toList(),
      minutesAfterMidnight: settings.reminderMinutes,
      now: ref.read(clockProvider)(),
    );
    await scheduler.replaceAll(plan);
  };
});

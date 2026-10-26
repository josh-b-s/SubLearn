import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';
import '../../state/reminder_sync.dart';
import '../../state/settings_provider.dart';
import '../theme/app_colors.dart';

/// Settings section for the daily review reminder. Hidden where notifications aren't supported.
class ReminderSettingsSection extends ConsumerWidget {
  const ReminderSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final sync = ref.read(reminderSyncProvider);
    final minutes = settings.reminderMinutes;

    Future<void> toggled(bool enabled) async {
      if (enabled && !await ref.read(reminderSchedulerProvider).requestAuthorization()) {
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Notifications are off'),
              content: const Text('Allow notifications for Subtitle Learn in your device settings to get review reminders.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ),
          );
        }
        return;
      }
      notifier.setReminderEnabled(enabled);
      await sync();
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      );
      if (picked == null) return;
      notifier.setReminderMinutes(picked.hour * 60 + picked.minute);
      await sync();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Daily review reminder'),
          value: settings.reminderEnabled,
          onChanged: toggled,
        ),
        if (settings.reminderEnabled)
          ListTile(
            title: const Text('Time'),
            trailing: Text(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context)),
            onTap: pickTime,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Sends a notification at this time on days when words are due for review. Turning it on asks for permission to send notifications.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText),
          ),
        ),
      ],
    );
  }
}

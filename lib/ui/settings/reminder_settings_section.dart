import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker, CupertinoDatePickerMode, CupertinoButton, showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';
import '../../state/reminder_sync.dart';
import '../../state/settings_provider.dart';
import '../components/alerts.dart';
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
          final openSettings = await showConfirmAlert(
            context,
            title: 'Notifications are off',
            message: 'Allow notifications for Subtitle Learn in your device settings to get review reminders.',
            confirmLabel: 'Open Settings',
          );
          if (openSettings) AppSettings.openAppSettings(type: AppSettingsType.notification);
        }
        return;
      }
      notifier.setReminderEnabled(enabled);
      await sync();
    }

    Future<void> pickTime() async {
      var chosen = minutes;
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => Container(
          height: 280,
          color: context.cardBackground,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60),
                    onDateTimeChanged: (d) => chosen = d.hour * 60 + d.minute,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (chosen == minutes) return;
      notifier.setReminderMinutes(chosen);
      await sync();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          title: const Text('Daily review reminder'),
          value: settings.reminderEnabled,
          onChanged: toggled,
        ),
        if (settings.reminderEnabled) ...[
          const Divider(height: 1, thickness: 0.5, indent: 16),
          ListTile(
            title: const Text('Time'),
            trailing: Text(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context)),
            onTap: pickTime,
          ),
        ],
      ],
    );
  }
}

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';
import '../../state/reminder_sync.dart';
import '../../state/settings_provider.dart';
import '../components/alerts.dart';
import '../components/app_sheet.dart';
import '../components/grouped_row.dart';
import '../components/hairline.dart';
import '../components/nav_text_button.dart';
import '../format_date.dart';

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
      await showAppSheet<void>(
        context,
        builder: (context) => SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NavTextButton(label: 'Done', bold: true, onPressed: () => Navigator.pop(context)),
                ),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60),
                  onDateTimeChanged: (d) => chosen = d.hour * 60 + d.minute,
                ),
              ),
            ],
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
        GroupedRow(
          title: 'Daily review reminder',
          trailing: CupertinoSwitch(value: settings.reminderEnabled, onChanged: toggled),
        ),
        if (settings.reminderEnabled) ...[
          const Hairline(indent: 20),
          GroupedRow(title: 'Time', info: formatMinutes(minutes), onTap: pickTime),
        ],
      ],
    );
  }
}

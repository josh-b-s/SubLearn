import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_planner.dart';

/// Keeps the pending review reminders in step with the saved words and the reminder settings.
class ReviewReminderScheduler {
  ReviewReminderScheduler();

  static const _firstId = 1000;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Local notifications are only wired up for phones.
  static bool get supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    ));
    _initialized = true;
  }

  /// False when the user declines, or declined earlier (the system then skips the prompt).
  Future<bool> requestAuthorization() async {
    if (!supported) return false;
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  /// Replaces every pending reminder with [reminders], or just clears them when the list is empty.
  Future<void> replaceAll(List<Reminder> reminders) async {
    if (!supported) return;
    await _init();
    for (var i = 0; i < ReminderPlanner.horizonDays; i++) {
      await _plugin.cancel(_firstId + i);
    }
    for (var i = 0; i < reminders.length; i++) {
      final reminder = reminders[i];
      final count = reminder.dueCount;
      await _plugin.zonedSchedule(
        _firstId + i,
        'Time to review',
        '$count word${count == 1 ? '' : 's'} due for review.',
        // An absolute instant, so the zone only has to be consistent.
        tz.TZDateTime.from(reminder.fireDate, tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'review_reminders',
            'Review reminders',
            channelDescription: 'Daily reminder when words are due for review',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

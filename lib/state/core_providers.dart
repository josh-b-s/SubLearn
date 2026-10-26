import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cloze_cache.dart';
import '../data/json_store.dart';
import '../services/audio/speaker.dart';
import '../services/reminders/review_reminder_scheduler.dart';
import 'settings_provider.dart';

/// Overridden in main() once preferences are loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final jsonStoreProvider = Provider((ref) => JsonStore(ref.watch(sharedPreferencesProvider)));

final clozeCacheProvider = Provider((ref) => ClozeCache(ref.watch(jsonStoreProvider)));

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final speakerProvider = Provider(
  (ref) => Speaker(speakSlowly: () => ref.read(settingsProvider).speakSlowly),
);

final reminderSchedulerProvider = Provider((ref) => ReviewReminderScheduler());

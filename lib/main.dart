import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/core_providers.dart';
import 'ui/subtitle_window/subtitle_overlay_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const SubtitleLearnApp(),
  ));
}

/// Entry point of the Android overlay engine. Native code starts it by name.
@pragma('vm:entry-point')
void overlayMain() => runApp(const SubtitleOverlayApp());

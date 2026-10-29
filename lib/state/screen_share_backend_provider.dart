import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/platform_info.dart';
import '../services/screen_share/android_screen_share_backend.dart';
import '../services/screen_share/ios_screen_share_backend.dart';
import '../services/screen_share/screen_share_backend.dart';
import '../services/screen_share/screen_share_backend_api.dart';
import '../services/screen_share/unsupported_screen_share_backend.dart';

final screenShareBackendProvider = Provider<ScreenShareBackend>((ref) {
  if (isIos) return IosScreenShareBackend();
  if (isAndroid) return AndroidScreenShareBackend();
  return const UnsupportedScreenShareBackend();
});

final screenShareCapabilitiesProvider = FutureProvider<ScreenShareCapabilities>(
  (ref) => ref.watch(screenShareBackendProvider).capabilities(),
);

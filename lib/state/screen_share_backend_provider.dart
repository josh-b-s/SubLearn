import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/screen_share/ios_screen_share_backend.dart';
import '../services/screen_share/screen_share_backend.dart';
import '../services/screen_share/screen_share_backend_api.dart';
import '../services/screen_share/unsupported_screen_share_backend.dart';

final screenShareBackendProvider = Provider<ScreenShareBackend>((ref) {
  // kIsWeb first: mobile Safari reports iOS as the platform.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return IosScreenShareBackend();
  return const UnsupportedScreenShareBackend();
});

final screenShareCapabilitiesProvider = FutureProvider<ScreenShareCapabilities>(
  (ref) => ref.watch(screenShareBackendProvider).capabilities(),
);

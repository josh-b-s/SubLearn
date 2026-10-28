import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screen_share_backend_provider.dart';

/// Whether a clip of the word, as heard in a screen share, is stored on this device.
final wordClipProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, word) => ref.watch(screenShareBackendProvider).hasClip(word),
);

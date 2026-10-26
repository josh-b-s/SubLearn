import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// The Gemini API key, kept in secure storage (Keychain on iOS, Keystore on Android).
class GeminiKeyNotifier extends AsyncNotifier<String> {
  static const _key = 'geminiAPIKey';

  @override
  Future<String> build() async => await ref.read(secureStorageProvider).read(key: _key) ?? '';

  /// Trims pasted whitespace. An empty key removes the stored value.
  Future<void> save(String value) async {
    final trimmed = value.trim();
    final storage = ref.read(secureStorageProvider);
    if (trimmed.isEmpty) {
      await storage.delete(key: _key);
    } else {
      await storage.write(key: _key, value: trimmed);
    }
    state = AsyncData(trimmed);
  }
}

final geminiKeyProvider = AsyncNotifierProvider<GeminiKeyNotifier, String>(GeminiKeyNotifier.new);

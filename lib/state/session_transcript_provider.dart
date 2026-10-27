import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session/session_transcript.dart';
import 'core_providers.dart';

/// The latest session's transcript. Starting a new session replaces it.
class SessionTranscriptNotifier extends Notifier<SessionTranscript?> {
  static const _key = 'sessionTranscript';

  @override
  SessionTranscript? build() {
    final json = ref.read(jsonStoreProvider).readMap(_key);
    return json.isEmpty ? null : SessionTranscript.fromJson(json);
  }

  void begin(DateTime startedAt) => _set(SessionTranscript(startedAt: startedAt));

  void addLine(String line) {
    final current = state;
    if (current != null) _set(current.withLine(line));
  }

  void _set(SessionTranscript transcript) {
    state = transcript;
    unawaited(ref.read(jsonStoreProvider).writeMap(_key, transcript.toJson()));
  }
}

final sessionTranscriptProvider =
    NotifierProvider<SessionTranscriptNotifier, SessionTranscript?>(SessionTranscriptNotifier.new);

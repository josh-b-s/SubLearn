import '../../models/session/pip_line.dart';
import 'screen_share_backend.dart';

/// Platform side of Screen Share: audio capture, speech recognition and the PiP window.
abstract interface class ScreenShareBackend {
  Stream<ScreenShareEvent> get events;

  Future<ScreenShareCapabilities> capabilities();

  /// For [ScreenShareSource.screen] this only begins waiting for a broadcast. Call
  /// [showBroadcastPicker] next. For the microphone, recognition is running when this returns.
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice});

  Future<void> showBroadcastPicker();

  /// Ends the session, asks the broadcast to finish and closes the PiP window.
  Future<void> stop({required ScreenShareSource source});

  Future<void> updatePip(List<PipLine> lines);

  Future<void> presentPip();
}

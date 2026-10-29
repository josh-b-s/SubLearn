/// Where the subtitle audio comes from.
enum ScreenShareSource {
  screen('Screen audio'),
  microphone('Mic');

  const ScreenShareSource(this.label);
  final String label;
}

class ScreenShareCapabilities {
  const ScreenShareCapabilities({
    required this.isSupported,
    this.pipSupported = false,
    this.broadcastExtensionFound = false,
    this.unsupportedReason = '',
  });

  /// False on platforms without a backend, or when the native code isn't installed.
  final bool isSupported;
  final bool pipSupported;

  /// The native piece screen audio needs: the iOS broadcast extension, or the Android speech model.
  final bool broadcastExtensionFound;
  final String unsupportedReason;
}

class ScreenShareException implements Exception {
  const ScreenShareException(this.message);
  final String message;

  @override
  String toString() => message;
}

sealed class ScreenShareEvent {
  const ScreenShareEvent();
}

/// The system broadcast went live.
final class BroadcastStarted extends ScreenShareEvent {
  const BroadcastStarted();
}

/// The broadcast ended, for example from Control Center.
final class BroadcastEnded extends ScreenShareEvent {
  const BroadcastEnded();
}

/// The transcript of the current utterance so far, not a delta.
final class SpeechText extends ScreenShareEvent {
  const SpeechText(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

final class SpeechFailed extends ScreenShareEvent {
  const SpeechFailed(this.message);
  final String message;
}

final class PipStateChanged extends ScreenShareEvent {
  const PipStateChanged({required this.active});
  final bool active;
}

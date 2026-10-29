class SpeechInputException implements Exception {
  const SpeechInputException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Microphone transcription. [start]'s onText always gets the whole transcript so far, replacing the previous one.
abstract interface class MicTranscriber {
  bool get isActive;

  /// Throws [SpeechInputException] when it can't start. Failures after that go to [onFailure].
  Future<void> start({
    required void Function(String text) onText,
    required void Function(String message) onFailure,
  });

  Future<void> stop();
}

import 'mic_transcriber.dart';
import 'sherpa/sherpa_mic_transcriber.dart';
import 'sherpa/sherpa_model_store.dart';
import 'speech_input.dart';

/// Uses the Sherpa model when it is downloaded, and the platform recognizer when it isn't or can't start.
class SherpaFirstMicTranscriber implements MicTranscriber {
  SherpaFirstMicTranscriber({required SherpaModelStore store, required bool onDevice})
      : _store = store,
        _onDevice = onDevice;

  final SherpaModelStore _store;
  final bool _onDevice;
  MicTranscriber? _current;

  @override
  bool get isActive => _current?.isActive ?? false;

  @override
  Future<void> start({
    required void Function(String text) onText,
    required void Function(String message) onFailure,
  }) async {
    final model = await _store.installed();
    if (model != null) {
      final sherpa = SherpaMicTranscriber(model);
      try {
        await sherpa.start(onText: onText, onFailure: onFailure);
        _current = sherpa;
        return;
      } on SpeechInputException {
        // Fall back below. If the microphone was the problem, the platform recognizer reports it too.
      }
    }
    final platform = PlatformMicTranscriber(onDevice: _onDevice);
    await platform.start(onText: onText, onFailure: onFailure);
    _current = platform;
  }

  @override
  Future<void> stop() async {
    await _current?.stop();
    _current = null;
  }
}

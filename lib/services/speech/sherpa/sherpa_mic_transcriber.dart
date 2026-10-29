import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import '../mic_transcriber.dart';
import '../transcript_join.dart';
import 'sherpa_model_store.dart';
import 'sherpa_recognizer.dart';

/// Microphone transcription with the downloaded Sherpa model.
class SherpaMicTranscriber implements MicTranscriber {
  SherpaMicTranscriber(this._model);

  final SherpaModelFiles _model;
  final _recorder = AudioRecorder();
  SherpaRecognizer? _recognizer;
  StreamSubscription<Uint8List>? _audio;
  StreamSubscription<SherpaResult>? _results;
  String _committed = '';
  bool _active = false;
  bool _released = false;

  @override
  bool get isActive => _active;

  @override
  Future<void> start({
    required void Function(String text) onText,
    required void Function(String message) onFailure,
  }) async {
    try {
      if (!await _recorder.hasPermission()) {
        throw const SpeechInputException('Microphone access is needed. Allow it in Settings and try again.');
      }
      final recognizer = await SherpaRecognizer.start(_model);
      _recognizer = recognizer;
      _committed = '';
      _results = recognizer.results.listen(
        (result) {
          if (!_active) return;
          onText(joinTranscript(_committed, result.text));
          if (result.utteranceEnded) _committed = joinTranscript(_committed, result.text);
        },
        onError: (Object error) => _fail(onFailure, error.toString()),
      );
      final pcm = await _recorder.startStream(
        const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: SherpaRecognizer.sampleRate, numChannels: 1),
      );
      _audio = pcm.listen(recognizer.feed, onError: (Object error) => _fail(onFailure, error.toString()));
      _active = true;
    } on SherpaException catch (e) {
      await _release();
      throw SpeechInputException(e.message);
    } on SpeechInputException {
      await _release();
      rethrow;
    } on Object catch (e) {
      await _release();
      throw SpeechInputException("Couldn't start the microphone: $e");
    }
  }

  @override
  Future<void> stop() async {
    _active = false;
    await _release();
  }

  void _fail(void Function(String message) onFailure, String message) {
    if (!_active) return;
    _active = false;
    onFailure('Speech recognition stopped: $message');
    unawaited(_release());
  }

  Future<void> _release() async {
    if (_released) return;
    _released = true;
    await _audio?.cancel();
    await _results?.cancel();
    _audio = null;
    _results = null;
    if (await _recorder.isRecording()) await _recorder.stop();
    await _recorder.dispose();
    await _recognizer?.dispose();
    _recognizer = null;
  }
}

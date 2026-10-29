import 'dart:async';

import 'package:flutter/services.dart';

import '../speech/sherpa/sherpa_model_store.dart';
import '../speech/sherpa/sherpa_recognizer.dart';
import 'channel_screen_share_backend.dart';
import 'screen_share_backend.dart';

/// The Kotlin code in android/app/src/main/kotlin/.../screenshare captures the audio. Recognition runs
/// here in Dart with the Sherpa model, the same engine as the Translate microphone. Audio clips are not ported.
class AndroidScreenShareBackend extends ChannelScreenShareBackend {
  AndroidScreenShareBackend({SherpaModelStore? store})
      : _store = store ?? SherpaModelStore(),
        super(missingNativeMessage: 'The Android Screen Share code is not part of this build.');

  static const _audioChannel = EventChannel('subtitle_learn/screen_share/audio');

  final SherpaModelStore _store;
  final _events = StreamController<ScreenShareEvent>.broadcast();
  StreamSubscription<ScreenShareEvent>? _nativeEvents;
  StreamSubscription<SherpaResult>? _results;
  StreamSubscription<dynamic>? _audio;
  SherpaRecognizer? _recognizer;

  @override
  Stream<ScreenShareEvent> get events {
    _nativeEvents ??= super.events.listen(_events.add, onError: _events.addError);
    return _events.stream;
  }

  @override
  Future<ScreenShareCapabilities> capabilities() async {
    final native = await super.capabilities();
    if (!native.isSupported) return native;
    return ScreenShareCapabilities(
      isSupported: true,
      pipSupported: native.pipSupported,
      broadcastExtensionFound: await _store.installed() != null,
    );
  }

  @override
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice}) async {
    final model = await _store.installed();
    if (model == null) throw const ScreenShareException('Download the offline speech model in Settings first.');
    await _stopRecognition();
    try {
      // Load the model before any audio flows, so the first words aren't lost.
      final recognizer = await SherpaRecognizer.start(model);
      _recognizer = recognizer;
      _results = recognizer.results.listen(_onResult, onError: (Object e) => _events.add(SpeechFailed(e.toString())));
      _audio = _audioChannel.receiveBroadcastStream().listen((chunk) => recognizer.feed(chunk as Uint8List));
      await super.start(source: source, preferOnDevice: preferOnDevice);
    } on SherpaException catch (e) {
      await _stopRecognition();
      throw ScreenShareException(e.message);
    } on Object {
      await _stopRecognition();
      rethrow;
    }
  }

  @override
  Future<void> stop({required ScreenShareSource source, Set<String>? keepClipsFor}) async {
    try {
      await super.stop(source: source);
    } finally {
      await _stopRecognition();
    }
  }

  @override
  Future<bool> hasClip(String word) async => false;

  @override
  Future<void> playClip(String word, {required bool slow}) async {}

  void _onResult(SherpaResult result) {
    if (result.text.trim().isEmpty) return;
    _events.add(SpeechText(result.text, isFinal: result.utteranceEnded));
  }

  Future<void> _stopRecognition() async {
    await _audio?.cancel();
    await _results?.cancel();
    _audio = null;
    _results = null;
    await _recognizer?.dispose();
    _recognizer = null;
  }
}

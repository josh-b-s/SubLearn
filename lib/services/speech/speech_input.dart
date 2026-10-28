import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechInputException implements Exception {
  const SpeechInputException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Microphone transcription that keeps going across the platform's per-session time limit.
class SpeechInput {
  static const _maxFailures = 3;
  static const _onDeviceUnavailable =
      "On-device recognition isn't available here (the Simulator doesn't support it). Turn it off in Settings > Speech.";
  static const _benignErrors = {'error_no_match', 'error_speech_timeout'};

  final _speech = SpeechToText();
  bool _active = false;
  bool _accepting = false;
  bool _restarting = false;
  bool _onDevice = true;
  int _failures = 0;
  String _committed = '';
  String? _locale;
  void Function(String text)? _onText;
  void Function(String message)? _onFailure;

  bool get isActive => _active;

  /// [onText] gets the whole transcript so far, replacing the previous one.
  Future<void> start({
    required bool onDevice,
    required void Function(String text) onText,
    required void Function(String message) onFailure,
  }) async {
    final available = await _speech.initialize(onError: _handleError, onStatus: _handleStatus);
    if (!available) {
      throw const SpeechInputException(
        'Speech recognition is not available. Check that microphone and speech permissions are allowed.',
      );
    }
    _locale = await _chineseLocale();
    _onDevice = onDevice;
    _onText = onText;
    _onFailure = onFailure;
    _committed = '';
    _failures = 0;
    _active = true;
    _accepting = true;
    await _listen();
  }

  Future<void> stop() async {
    _active = false;
    await _speech.stop();
  }

  Future<String?> _chineseLocale() async {
    final locales = await _speech.locales();
    final chinese = locales.where((l) => l.localeId.toLowerCase().startsWith('zh')).toList();
    for (final l in chinese) {
      final id = l.localeId.toLowerCase().replaceAll('_', '-');
      if (id == 'zh-cn') return l.localeId;
    }
    return chinese.isEmpty ? null : chinese.first.localeId;
  }

  Future<void> _listen() async {
    await _speech.listen(
      onResult: _handleResult,
      listenOptions: SpeechListenOptions(
        localeId: _locale,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        onDevice: _onDevice,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  void _handleResult(SpeechRecognitionResult result) {
    if (!_accepting) return;
    _failures = 0;
    _onText?.call(_committed + result.recognizedWords);
    if (result.finalResult) _committed += result.recognizedWords;
  }

  void _handleStatus(String status) {
    if (status != 'done' && status != 'notListening') return;
    if (!_active) {
      _accepting = false;
      return;
    }
    unawaited(_restart());
  }

  Future<void> _restart() async {
    if (_restarting) return;
    _restarting = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _restarting = false;
    if (_active && !_speech.isListening) await _listen();
  }

  void _handleError(SpeechRecognitionError error) {
    if (!_active || _benignErrors.contains(error.errorMsg)) return;
    _failures++;
    if (_failures >= _maxFailures) {
      _active = false;
      _accepting = false;
      _onFailure?.call(_onDevice && error.errorMsg.contains('1101') ? _onDeviceUnavailable : 'Speech recognition stopped: ${error.errorMsg}');
    }
  }
}

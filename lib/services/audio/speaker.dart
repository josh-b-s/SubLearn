import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks Chinese text with the system voice. One shared engine so taps never overlap.
class Speaker {
  Speaker({required bool Function() speakSlowly}) : _speakSlowly = speakSlowly;

  static const _normalRate = 0.5;
  static const _slowRate = 0.35;

  final bool Function() _speakSlowly;
  final _tts = FlutterTts();
  bool _ready = false;

  /// A tap should always be heard. Autoplay passes false so it stays quiet when an iPhone is on silent.
  Future<void> speak(String text, {required bool ignoringMuteSwitch}) async {
    if (!_ready) {
      await _tts.setLanguage('zh-CN');
      _ready = true;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setIosAudioCategory(
        ignoringMuteSwitch ? IosTextToSpeechAudioCategory.playback : IosTextToSpeechAudioCategory.ambient,
        [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
      );
    }
    await _tts.setSpeechRate(_speakSlowly() ? _slowRate : _normalRate);
    await _tts.stop();
    await _tts.speak(text);
  }
}

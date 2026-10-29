import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/word_token.dart';
import '../services/learning/mastery_redactor.dart';
import '../services/speech/mic_transcriber.dart';
import '../services/speech/sherpa_first_mic_transcriber.dart';
import 'dictionary_provider.dart';
import 'settings_provider.dart';
import 'speech_model_provider.dart';
import 'words_provider.dart';

class TranslateState {
  const TranslateState({this.inputText = '', this.isListening = false, this.speechError});

  final String inputText;
  final bool isListening;
  final String? speechError;

  TranslateState copyWith({String? inputText, bool? isListening, String? speechError, bool clearError = false}) =>
      TranslateState(
        inputText: inputText ?? this.inputText,
        isListening: isListening ?? this.isListening,
        speechError: clearError ? null : (speechError ?? this.speechError),
      );
}

class TranslateController extends Notifier<TranslateState> {
  MicTranscriber? _mic;
  String _textBeforeListening = '';

  @override
  TranslateState build() {
    ref.onDispose(() => _mic?.stop());
    return const TranslateState();
  }

  void setInput(String text) => state = state.copyWith(inputText: text);

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> startListening() async {
    if (state.isListening) return;
    _textBeforeListening = state.inputText.trim();
    final mic = SherpaFirstMicTranscriber(
      store: ref.read(sherpaModelStoreProvider),
      onDevice: ref.read(settingsProvider).preferOnDeviceSpeech,
    );
    try {
      await mic.start(
        // The recognizer returns the whole transcript so far, so replace rather than append.
        onText: (transcript) => state = state.copyWith(inputText: _textBeforeListening + transcript),
        onFailure: (message) => state = state.copyWith(isListening: false, speechError: message),
      );
      _mic = mic;
      state = state.copyWith(isListening: true, clearError: true);
    } on SpeechInputException catch (e) {
      state = state.copyWith(speechError: e.message);
    }
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;
    state = state.copyWith(isListening: false);
    await _mic?.stop();
  }
}

final translateControllerProvider =
    NotifierProvider<TranslateController, TranslateState>(TranslateController.new);

/// Word cards for the current input. Learned words lose their hints when the toggle is on.
final translateTokensProvider = Provider<List<WordToken>>((ref) {
  final text = ref.watch(translateControllerProvider.select((s) => s.inputText));
  final dictionary = ref.watch(dictionaryProvider).valueOrNull;
  if (dictionary == null || text.trim().isEmpty) return const [];

  final tokens = dictionary.tokens(text);
  final hideLearned = ref.watch(settingsProvider.select((s) => s.hideLearnedInTranslate));
  return hideLearned ? MasteryRedactor.apply(tokens, ref.watch(levelsByWordProvider)) : tokens;
});

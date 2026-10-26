import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/word_token.dart';
import '../services/learning/mastery_redactor.dart';
import '../services/speech/speech_input.dart';
import 'dictionary_provider.dart';
import 'settings_provider.dart';
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
  final _speech = SpeechInput();
  String _textBeforeListening = '';

  @override
  TranslateState build() {
    ref.onDispose(() {
      if (_speech.isActive) _speech.stop();
    });
    return const TranslateState();
  }

  void setInput(String text) => state = state.copyWith(inputText: text);

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> startListening() async {
    if (state.isListening) return;
    _textBeforeListening = state.inputText.trim();
    try {
      await _speech.start(
        onDevice: ref.read(settingsProvider).preferOnDeviceSpeech,
        // The recognizer returns the whole transcript so far, so replace rather than append.
        onText: (transcript) => state = state.copyWith(inputText: _textBeforeListening + transcript),
        onFailure: (message) => state = state.copyWith(isListening: false, speechError: message),
      );
      state = state.copyWith(isListening: true, clearError: true);
    } on SpeechInputException catch (e) {
      state = state.copyWith(speechError: e.message);
    }
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;
    state = state.copyWith(isListening: false);
    await _speech.stop();
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

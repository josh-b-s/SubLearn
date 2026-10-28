import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appearance_mode.dart';
import '../models/vocabulary_sort.dart';
import 'core_providers.dart';

class AppSettingsState {
  const AppSettingsState({
    this.appearance = AppearanceMode.system,
    this.preferOnDeviceSpeech = true,
    this.speakSlowly = false,
    this.hideLearnedInTranslate = false,
    this.hideLearnedInSubtitles = true,
    this.reminderEnabled = false,
    this.reminderMinutes = 19 * 60,
    this.questionsPerQuiz = 8,
    this.vocabularySort = VocabularySort.newest,
    this.hasSeenOnboarding = false,
  });

  final AppearanceMode appearance;
  final bool preferOnDeviceSpeech;
  final bool speakSlowly;
  final bool hideLearnedInTranslate;
  final bool hideLearnedInSubtitles;
  final bool reminderEnabled;

  /// Minutes after midnight.
  final int reminderMinutes;
  final int questionsPerQuiz;
  final VocabularySort vocabularySort;
  final bool hasSeenOnboarding;
}

class SettingsNotifier extends Notifier<AppSettingsState> {
  static const _appearance = 'appearance';
  static const _onDevice = 'preferOnDeviceSpeech';
  static const _slow = 'speakSlowly';
  static const _hideTranslate = 'hideLearnedInTranslate';
  static const _hideSubtitles = 'hideLearnedInSubtitles';
  static const _reminderOn = 'reminderEnabled';
  static const _reminderMinutes = 'reminderMinutes';
  static const _questions = 'questionsPerQuiz';
  static const _sort = 'vocabularySort';
  static const _onboarding = 'hasSeenOnboarding';

  @override
  AppSettingsState build() {
    final p = ref.read(sharedPreferencesProvider);
    const defaults = AppSettingsState();
    return AppSettingsState(
      appearance: AppearanceMode.values.asNameMap()[p.getString(_appearance)] ?? defaults.appearance,
      preferOnDeviceSpeech: p.getBool(_onDevice) ?? defaults.preferOnDeviceSpeech,
      speakSlowly: p.getBool(_slow) ?? defaults.speakSlowly,
      hideLearnedInTranslate: p.getBool(_hideTranslate) ?? defaults.hideLearnedInTranslate,
      hideLearnedInSubtitles: p.getBool(_hideSubtitles) ?? defaults.hideLearnedInSubtitles,
      reminderEnabled: p.getBool(_reminderOn) ?? defaults.reminderEnabled,
      reminderMinutes: p.getInt(_reminderMinutes) ?? defaults.reminderMinutes,
      questionsPerQuiz: p.getInt(_questions) ?? defaults.questionsPerQuiz,
      vocabularySort: VocabularySort.values.asNameMap()[p.getString(_sort)] ?? defaults.vocabularySort,
      hasSeenOnboarding: p.getBool(_onboarding) ?? defaults.hasSeenOnboarding,
    );
  }

  void setAppearance(AppearanceMode v) => _write(_appearance, v.name, _copy(appearance: v));
  void setPreferOnDeviceSpeech(bool v) => _write(_onDevice, v, _copy(preferOnDeviceSpeech: v));
  void setSpeakSlowly(bool v) => _write(_slow, v, _copy(speakSlowly: v));
  void setHideLearnedInTranslate(bool v) => _write(_hideTranslate, v, _copy(hideLearnedInTranslate: v));
  void setHideLearnedInSubtitles(bool v) => _write(_hideSubtitles, v, _copy(hideLearnedInSubtitles: v));
  void setReminderEnabled(bool v) => _write(_reminderOn, v, _copy(reminderEnabled: v));
  void setReminderMinutes(int v) => _write(_reminderMinutes, v, _copy(reminderMinutes: v));
  void setQuestionsPerQuiz(int v) => _write(_questions, v, _copy(questionsPerQuiz: v));
  void setVocabularySort(VocabularySort v) => _write(_sort, v.name, _copy(vocabularySort: v));
  void setHasSeenOnboarding(bool v) => _write(_onboarding, v, _copy(hasSeenOnboarding: v));

  AppSettingsState _copy({
    AppearanceMode? appearance,
    bool? preferOnDeviceSpeech,
    bool? speakSlowly,
    bool? hideLearnedInTranslate,
    bool? hideLearnedInSubtitles,
    bool? reminderEnabled,
    int? reminderMinutes,
    int? questionsPerQuiz,
    VocabularySort? vocabularySort,
    bool? hasSeenOnboarding,
  }) =>
      AppSettingsState(
        appearance: appearance ?? state.appearance,
        preferOnDeviceSpeech: preferOnDeviceSpeech ?? state.preferOnDeviceSpeech,
        speakSlowly: speakSlowly ?? state.speakSlowly,
        hideLearnedInTranslate: hideLearnedInTranslate ?? state.hideLearnedInTranslate,
        hideLearnedInSubtitles: hideLearnedInSubtitles ?? state.hideLearnedInSubtitles,
        reminderEnabled: reminderEnabled ?? state.reminderEnabled,
        reminderMinutes: reminderMinutes ?? state.reminderMinutes,
        questionsPerQuiz: questionsPerQuiz ?? state.questionsPerQuiz,
        vocabularySort: vocabularySort ?? state.vocabularySort,
        hasSeenOnboarding: hasSeenOnboarding ?? state.hasSeenOnboarding,
      );

  void _write(String key, Object value, AppSettingsState next) {
    final p = ref.read(sharedPreferencesProvider);
    switch (value) {
      case final bool b:
        p.setBool(key, b);
      case final int i:
        p.setInt(key, i);
      case final String s:
        p.setString(key, s);
    }
    state = next;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettingsState>(SettingsNotifier.new);

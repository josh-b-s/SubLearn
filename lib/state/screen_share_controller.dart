import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session/pip_line.dart';
import '../models/session/session_summary.dart';
import '../services/dictionary/chinese_dictionary.dart';
import '../services/screen_share/pip_subtitle_model.dart';
import '../services/screen_share/screen_share_backend.dart';
import '../services/screen_share/session_summary_builder.dart';
import '../services/screen_share/session_word_tracker.dart';
import 'clock_provider.dart';
import 'dictionary_provider.dart';
import 'screen_share_backend_provider.dart';
import 'session_transcript_provider.dart';
import 'settings_provider.dart';
import 'words_provider.dart';

enum ScreenSharePhase { idle, starting, waitingForBroadcast, live, finished }

class ScreenShareState {
  const ScreenShareState({
    this.phase = ScreenSharePhase.idle,
    this.source = ScreenShareSource.screen,
    this.lines = const [],
    this.summary,
    this.error,
    this.notice,
    this.pipActive = false,
  });

  final ScreenSharePhase phase;
  final ScreenShareSource source;
  final List<PipLine> lines;
  final SessionSummary? summary;

  /// Why a session couldn't start or had to stop.
  final String? error;

  /// A problem that doesn't stop the session, such as the PiP window failing to open.
  final String? notice;
  final bool pipActive;

  bool get isRunning =>
      phase == ScreenSharePhase.starting || phase == ScreenSharePhase.waitingForBroadcast || phase == ScreenSharePhase.live;

  ScreenShareState copyWith({
    ScreenSharePhase? phase,
    ScreenShareSource? source,
    List<PipLine>? lines,
    SessionSummary? summary,
    String? error,
    String? notice,
    bool? pipActive,
    bool clearError = false,
    bool clearNotice = false,
  }) =>
      ScreenShareState(
        phase: phase ?? this.phase,
        source: source ?? this.source,
        lines: lines ?? this.lines,
        summary: summary ?? this.summary,
        error: clearError ? null : (error ?? this.error),
        notice: clearNotice ? null : (notice ?? this.notice),
        pipActive: pipActive ?? this.pipActive,
      );
}

class ScreenShareController extends Notifier<ScreenShareState> {
  final _tracker = SessionWordTracker();
  final _pip = PipSubtitleModel();
  StreamSubscription<ScreenShareEvent>? _events;
  ChineseDictionary? _dictionary;

  @override
  ScreenShareState build() {
    ref.onDispose(() => _events?.cancel());
    return const ScreenShareState();
  }

  void setSource(ScreenShareSource source) {
    if (!state.isRunning) state = state.copyWith(source: source);
  }

  Future<void> start() async {
    if (state.isRunning) return;
    final source = state.source;
    _tracker.reset();
    _pip.clear();
    state = ScreenShareState(phase: ScreenSharePhase.starting, source: source);

    final backend = ref.read(screenShareBackendProvider);
    _dictionary = await ref.read(dictionaryProvider.future).then<ChineseDictionary?>((d) => d, onError: (_) => null);
    if (_dictionary == null) return _stopWithError("The dictionary couldn't be loaded.");

    try {
      await _events?.cancel();
      _events = backend.events.listen(_onEvent, onError: (Object e) {
        unawaited(_stopWithError('$e'));
      });
      await backend.start(source: source, preferOnDevice: ref.read(settingsProvider).preferOnDeviceSpeech);
      if (source == ScreenShareSource.screen) {
        state = state.copyWith(phase: ScreenSharePhase.waitingForBroadcast);
        await backend.showBroadcastPicker();
      } else {
        await _goLive();
      }
    } on ScreenShareException catch (e) {
      await _stopWithError(e.message);
    }
  }

  /// Stops the session and shows its summary.
  Future<void> stop() async {
    if (!state.isRunning) return;
    final source = state.source;
    final wasLive = state.phase == ScreenSharePhase.live;
    await _events?.cancel();
    _events = null;
    state = state.copyWith(phase: ScreenSharePhase.finished);
    try {
      await ref.read(screenShareBackendProvider).stop(source: source);
    } on ScreenShareException catch (e) {
      state = state.copyWith(notice: e.message);
    }

    if (!wasLive) return dismissSummary();
    _tracker.flush();
    state = state.copyWith(
      summary: SessionSummaryBuilder.build(_tracker.entries, ref.read(wordsProvider)),
      pipActive: false,
    );
  }

  /// Back to the start screen.
  void dismissSummary() {
    _tracker.reset();
    _pip.clear();
    state = ScreenShareState(source: state.source);
  }

  /// Saves the most heard words that aren't saved yet. Returns the words to quiz on.
  Set<String> prepareReview() {
    final summary = state.summary;
    if (summary == null) return const {};
    final words = ref.read(wordsProvider.notifier);
    for (final entry in summary.topWords) {
      if (summary.unsavedTopWords.contains(entry.token.text)) words.toggleSaved(entry.token);
    }
    return {for (final e in summary.topWords) e.token.text};
  }

  Future<void> showBroadcastPicker() => _run(ref.read(screenShareBackendProvider).showBroadcastPicker);

  Future<void> presentPip() => _run(ref.read(screenShareBackendProvider).presentPip);

  Future<void> _goLive() async {
    ref.read(sessionTranscriptProvider.notifier).begin(ref.read(clockProvider)());
    state = state.copyWith(phase: ScreenSharePhase.live);
    await presentPip();
  }

  void _onEvent(ScreenShareEvent event) {
    switch (event) {
      case BroadcastStarted():
        if (state.phase == ScreenSharePhase.waitingForBroadcast) unawaited(_goLive());
      case BroadcastEnded():
        unawaited(stop());
      case SpeechText(:final text, :final isFinal):
        _onSpeech(text, isFinal);
      case SpeechFailed(:final message):
        unawaited(_stopWithError(message));
      case PipStateChanged(:final active):
        state = state.copyWith(pipActive: active);
    }
  }

  void _onSpeech(String text, bool isFinal) {
    final dictionary = _dictionary;
    if (dictionary == null || state.phase != ScreenSharePhase.live) return;

    final tokens = dictionary.tokens(text);
    _tracker.update(tokens, isFinal: isFinal);
    _pip.update(
      tokens,
      isFinal: isFinal,
      levels: ref.read(levelsByWordProvider),
      hideLearned: ref.read(settingsProvider).hideLearnedInSubtitles,
    );
    if (isFinal && tokens.isNotEmpty) ref.read(sessionTranscriptProvider.notifier).addLine(text);

    state = state.copyWith(lines: _pip.lines);
    unawaited(_run(() => ref.read(screenShareBackendProvider).updatePip(_pip.lines)));
  }

  /// Ends the session after a failure. The summary still shows if anything was heard.
  Future<void> _stopWithError(String message) async {
    final hadSession = state.phase == ScreenSharePhase.live;
    await stop();
    state = hadSession ? state.copyWith(error: message) : ScreenShareState(source: state.source, error: message);
  }

  /// Runs a backend call whose failure should show a notice instead of stopping the session.
  Future<void> _run(Future<void> Function() call) async {
    try {
      await call();
    } on ScreenShareException catch (e) {
      state = state.copyWith(notice: e.message);
    }
  }
}

final screenShareControllerProvider =
    NotifierProvider<ScreenShareController, ScreenShareState>(ScreenShareController.new);

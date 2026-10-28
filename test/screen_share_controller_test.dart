import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle_learn/models/dictionary_entry.dart';
import 'package:subtitle_learn/models/session/pip_line.dart';
import 'package:subtitle_learn/services/dictionary/chinese_dictionary.dart';
import 'package:subtitle_learn/services/screen_share/screen_share_backend.dart';
import 'package:subtitle_learn/services/screen_share/screen_share_backend_api.dart';
import 'package:subtitle_learn/state/core_providers.dart';
import 'package:subtitle_learn/state/dictionary_provider.dart';
import 'package:subtitle_learn/state/screen_share_backend_provider.dart';
import 'package:subtitle_learn/state/screen_share_controller.dart';
import 'package:subtitle_learn/state/session_transcript_provider.dart';
import 'package:subtitle_learn/state/settings_provider.dart';

class FakeBackend implements ScreenShareBackend {
  final controller = StreamController<ScreenShareEvent>.broadcast();

  @override
  Stream<ScreenShareEvent> get events => controller.stream;

  @override
  Future<ScreenShareCapabilities> capabilities() async =>
      const ScreenShareCapabilities(isSupported: true, pipSupported: true, broadcastExtensionFound: true);

  @override
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice}) async {}

  @override
  Future<void> showBroadcastPicker() async {}

  Set<String>? lastKeptClips;

  @override
  Future<void> stop({required ScreenShareSource source, Set<String>? keepClipsFor}) async {
    lastKeptClips = keepClipsFor;
  }

  @override
  Future<bool> hasClip(String word) async => false;

  @override
  Future<void> playClip(String word, {required bool slow}) async {}

  @override
  Future<void> updatePip(List<PipLine> lines) async {}

  @override
  Future<void> presentPip() async {}
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeBackend backend;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    backend = FakeBackend();
    final dictionary = ChineseDictionary(entries: {
      '你好': const DictionaryEntry(pinyin: 'nǐhǎo', meanings: ['hello']),
      '谢谢': const DictionaryEntry(pinyin: 'xièxie', meanings: ['thanks']),
    });
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      screenShareBackendProvider.overrideWithValue(backend),
      dictionaryProvider.overrideWith((ref) async => dictionary),
    ]);
    addTearDown(container.dispose);
    addTearDown(backend.controller.close);
  });

  ScreenShareController controller() => container.read(screenShareControllerProvider.notifier);
  ScreenShareState state() => container.read(screenShareControllerProvider);
  List<String> transcript() => container.read(sessionTranscriptProvider)?.lines ?? const [];

  Future<void> startMic() async {
    controller().setSource(ScreenShareSource.microphone);
    await controller().start();
  }

  test('hides hints for learned words by default', () {
    expect(container.read(settingsProvider).hideLearnedInSubtitles, isTrue);
  });

  test('stopping with nothing heard returns to the start screen without a summary', () async {
    await startMic();
    expect(state().phase, ScreenSharePhase.live);
    await controller().stop();
    expect(state().phase, ScreenSharePhase.idle);
    expect(state().summary, isNull);
  });

  test('a session that heard words ends with a summary', () async {
    await startMic();
    backend.controller.add(const SpeechText('你好', isFinal: true));
    await settle();
    await controller().stop();
    expect(state().phase, ScreenSharePhase.idle);
    expect(state().summary?.total, 1);
  });

  test('transcript lines are trimmed and blank ones are skipped', () async {
    await startMic();
    backend.controller.add(const SpeechText('  你好  ', isFinal: true));
    backend.controller.add(const SpeechText('   ', isFinal: true));
    await settle();
    expect(transcript(), ['你好']);
  });

  test('lines with no dictionary words are still kept', () async {
    await startMic();
    backend.controller.add(const SpeechText('嗯', isFinal: true));
    await settle();
    expect(transcript(), ['嗯']);
  });

  test('stopping saves the unfinished last line', () async {
    await startMic();
    backend.controller.add(const SpeechText('谢谢', isFinal: false));
    await settle();
    expect(transcript(), isEmpty);
    await controller().stop();
    expect(transcript(), ['谢谢']);
  });

  test('stopping keeps clips for the session\'s unsaved top words', () async {
    await startMic();
    backend.controller.add(const SpeechText('你好', isFinal: true));
    await settle();
    await controller().stop();
    expect(backend.lastKeptClips, {'你好'});
  });

  test('stopping with nothing heard leaves stored clips alone', () async {
    await startMic();
    await controller().stop();
    expect(backend.lastKeptClips, isNull);
  });

  test('a speech failure stops the session and reports why', () async {
    await startMic();
    backend.controller.add(const SpeechFailed('no network'));
    await settle();
    expect(state().phase, ScreenSharePhase.idle);
    expect(state().error, 'Speech recognition stopped: no network');
  });

  test('starting a new session replaces the previous transcript', () async {
    await startMic();
    backend.controller.add(const SpeechText('你好', isFinal: true));
    await settle();
    await controller().stop();
    controller().dismissSummary();
    await startMic();
    expect(transcript(), isEmpty);
  });
}

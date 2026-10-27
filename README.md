# Subtitle Learn (Flutter)

Flutter port of the iOS app. Look up Chinese text by typing, pasting or speaking, tap a word for pinyin, meanings and a per-character breakdown, save it, and review it with a spaced repetition quiz.

Targets: Android first. iOS, web and desktop share the same code, with the platform notes below.

## What was ported

- Translate: type, paste or speak. Word cards, character breakdown, save and remove, hide learned.
- Vocabulary: search, filter by level, due today, sort, multi-select delete, mastery slider.
- Dictionary: offline search by characters, pinyin or English. Custom words. Add a word you already know at a chosen level.
- Quiz: four mastery levels, SM-2 scheduling, missed questions return at the end, quiz history. Level 3 sentences come from Gemini and are cached.
- Stats: streak, accuracy by period, weekly progress chart, 90 day heatmap.
- Settings: theme, on-device speech, speak slowly, daily reminder (Android and iOS), Gemini key in secure storage, questions per quiz, onboarding, about.
- Screen Share (iOS): live Mandarin subtitles from system audio or the mic, word cards in a Picture in Picture window, session summary with a review shortcut, transcript. The native Swift code is in `ios_native/`, see its README for the Xcode steps. Android, web and desktop show a "not available" screen.
- Tests ported from the Swift suite: mastery, SM-2, dictionary, search, segmentation, stats, reminders, sorting, session word tracking.

## Differences from the Swift app

Each item is something to check and maybe fix. "Verified" means I compared it against the Swift source. "Unchecked" means I am going from memory or a rough count and you should compare it yourself.

### Screen Share: UI

- [ ] Tab order. Swift: Screen Share, Translate, Vocabulary, Quiz, Settings (Translate selected at launch). Flutter: Translate, Screen Share, Vocabulary, Quiz, Settings. Tab icons also differ (`airplayvideo` against a PiP icon). Verified.
- [ ] No preview panel. Swift shows a 420 pt "Preview" panel with the same view the PiP window renders, and the cards in it are not tappable. Flutter shows a scrolling list of the same word cards, and tapping one opens the word sheet. The PiP window itself matches Swift. Verified.
- [ ] One button against several. Swift uses a single large button that reads "Share screen audio", "Start live subtitles", "Waiting for broadcast (tap to cancel)" or "Stop", red while active. Flutter has a Start button, a separate Cancel and "Open sheet again" pair while waiting, and a Stop button on the live screen. Verified.
- [ ] Source picker. Swift keeps it on screen and locked while running. Flutter hides it once a session starts. Verified.
- [ ] Start is not disabled. Swift disables the button when PiP is unsupported or, for screen audio, when the extension is missing. Flutter leaves it enabled, warns in text when the extension is missing, and fails with an error on start. Verified.
- [ ] Help text. Swift has different text per source and for "PiP not supported". Flutter has shorter text and no PiP-unsupported text on the setup screen. Verified.
- [ ] Errors. Swift shows an alert titled "Screen Share". Flutter shows red text on the setup screen, or "Stopped early: ..." on the summary. Verified.
- [ ] Transcript button. Swift shows it in the toolbar whenever the saved transcript has lines, including when idle. Flutter shows it only on the live screen and on the summary. Verified.
- [ ] Summary and transcript are sheets in Swift (summary with a Done toolbar button). Flutter shows the summary in place of the tab content and pushes the transcript as a page. The summary has an extra "View transcript" button that Swift does not have. Verified.
- [ ] Hide-learned control. Swift has it only in Settings. Flutter also has a "Hide learned" chip on the live screen. Verified.
- [ ] "Show PiP" button. Swift shows it only while running and PiP is closed. Flutter's PiP icon is always visible while live and changes shape when PiP is open. Verified.
- [ ] Haptics on saving a word in the transcript. Not in Flutter. Verified.

### Screen Share: behaviour

- [ ] "Hide learned" default. Swift defaults `hideLearnedInPip` to on. Flutter defaults `hideLearnedInSubtitles` to off. Verified.
- [ ] Setting label and footer. Swift: "Hide hints for learned words", footer explains that past level 1 the meaning goes and past level 2 the pinyin too. Flutter: "Hide learned words" with a shorter footer. Verified.
- [ ] Transcript lines. Swift trims each line, keeps any non-empty line, and on stop also saves the unfinished last line. Flutter saves only finished lines that contain at least one Chinese word, untrimmed, and drops an unfinished last line (the word counts still include it). Verified.
- [ ] Nothing heard. Swift shows no summary and returns to the start screen. Flutter shows a "No Mandarin heard" screen. Verified.
- [ ] Transcript data. Flutter stores `startedAt` as well as the lines, in SharedPreferences (the whole JSON is rewritten on each line). Swift stores lines in a JSON file in Application Support. Verified.
- [ ] Audio clips. Swift saves a short clip per word during a session and the word sheet can replay it (`ReplayClipButton`, `SessionClipSaver`). Not ported, so the word sheet has no replay button. Verified.
- [ ] Mock source (debug builds only) not ported. Verified.
- [ ] Where the logic runs. Swift handles every speech result in-process. Flutter sends each partial result over the event channel, tokenizes it in Dart, then sends the lines back over the method channel for the PiP window. Fast speech may be heavier than Swift. Unchecked on a device.
- [ ] After a failed review start ("Try Again" on the quiz error screen), Flutter restarts a normal quiz and loses the review words. Swift unchecked.
- [ ] Error text points to `ios_native/README.md` instead of `SETUP.md`.
- [ ] Minimum iOS. Swift targets 18.5. The native code needs 17 (`AVAudioApplication`, `MainActor.assumeIsolated`).

### Other UI

- [ ] Platform look. Swift uses native iOS pieces: `TabView`, `Form`, `.searchable`, segmented pickers, `ContentUnavailableView`, sheets. Flutter uses Material 3 equivalents (NavigationBar, ListView, SegmentedButton, pushed pages), so spacing, fonts and icons differ everywhere. Verified.
- [ ] Onboarding. Swift shows it as a full-screen cover over the app. Flutter replaces the home screen with it. The page wording was written by me and may not match the Swift pages. Unchecked.
- [ ] Questions per quiz. Swift uses a `Stepper` (3 to 20). Flutter uses minus and plus buttons with the same range. Verified.
- [ ] Settings wording. The Speech footer is shorter in Flutter and drops the Simulator note. The Gemini key footer says "secure storage" instead of "Keychain". Verified.
- [ ] Gemini key saving. Swift saves on every change. Flutter trims and saves on submit or when the field loses focus. Verified.
- [ ] Animation and feedback. Swift has press animations (`PressableButtonStyle`), selection haptics on quiz options and on saving words in Translate, and reduce-motion handling in 12 places. Flutter has none of these. Verified by search.
- [ ] Accessibility. Swift has roughly 126 `accessibility*` modifiers (labels, hints, values). Flutter has about 10 `Semantics` widgets. Rough count, unchecked per screen.
- [ ] Home screen widget, widget refresh, and the debug review-log seed menu on Stats. Not ported. Verified.
- [ ] Privacy manifest. Swift ships one. The generated Flutter `ios/` project does not, and you would need to add one before an App Store build. Unchecked.

### Other behaviour

- [ ] Storage is JSON in SharedPreferences, not SwiftData. Fine for hundreds of words. Move to SQLite if the review log gets large.
- [ ] Deleting a word also deletes its review log entries, so the stats chart can't count removed words. (Swift's delete alert says the same.)
- [ ] Weeks on the stats chart start on Monday.
- [ ] Pinyin for words missing from the dictionary, and for custom words with blank pinyin, is joined from each character's entry. Apple's transliterator has no equivalent here, so characters missing from the dictionary add nothing.
- [ ] Speech on Translate uses the `speech_to_text` plugin, not `SFSpeechRecognizer` directly. It restarts itself when the platform ends a session. Some Android devices play a short sound on each restart.
- [ ] Gemini key lives in `flutter_secure_storage`. The Swift Keychain migration from UserDefaults is not needed and not ported.
- [ ] Reminders use `flutter_local_notifications` with a fixed set of scheduled notifications. Same planner logic as Swift, but delivery is plugin-specific. Unchecked on a device.

### Tests

- [ ] Ported: mastery, spaced repetition, dictionary and search, segmentation, stats, reminders, sorting, session word tracker (plus new tests for the summary builder and PiP line model).
- [ ] Not ported: `KeychainStoreTests`, `WidgetSnapshotTests`, both UI test targets, and `SubtitleLearnTests.swift`. I did not re-check `MasteryFilterTests`, `ShortMeaningsTests` and `SavedWordRecordTests` file by file, so compare them against `test/`.
- [ ] Nothing in Dart or Swift has been compiled or run yet. The Flutter widget code has no widget tests.

## Setup

Platform folders are not included. From this directory:

```
flutter create --project-name subtitle_learn --platforms=android,ios,web,windows,macos,linux .
flutter pub get
flutter test
flutter run
```

Needs Flutter 3.27 or newer.

Then add the permissions the plugins need.

Android, `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<queries>
  <intent><action android:name="android.speech.RecognitionService"/></intent>
  <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>
</queries>
```

`flutter_local_notifications` also needs core library desugaring on Android. Follow its README for `android/app/build.gradle`.

iOS, `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key><string>Used to turn your speech into text.</string>
<key>NSSpeechRecognitionUsageDescription</key><string>Used to transcribe Mandarin you speak.</string>
```

## Layout

- `lib/models`: plain data classes and enums. Quiz types are in `models/quiz`.
- `lib/services`: pure logic and platform wrappers, grouped by area.
- `lib/data`: JSON persistence helpers.
- `ios_native`: Swift for Screen Share. Copied into the Xcode project by hand, not built by Flutter.
- `lib/state`: Riverpod providers and controllers.
- `lib/ui`: screens, one widget per file, grouped by screen. `components` holds shared widgets.
- `assets/zh-en.tsv`: bundled dictionary.

## Credits

Dictionary data: CedPane by ssb22. Pinyin from CC-CEDICT (CC BY-SA) and pypinyin. Level 3 sentences from the Google Gemini API.

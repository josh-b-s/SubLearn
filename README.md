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
- Screen Share (iOS 17 or later, Android 10 or later): live Mandarin subtitles from system audio or the mic, word cards in a floating window, session summary with a review shortcut, transcript. On iOS the window is Picture in Picture, with native Swift in `ios_native/` (see its README). On Android it is an overlay drawn by Flutter, see Screen Share on Android below. Web and desktop show a "not available" screen.
- Tests ported from the Swift suite: mastery, SM-2, dictionary, search, segmentation, stats, reminders, sorting, session word tracking.

## Differences from the Swift app

`[x]` means fixed to match Swift. `[ ]` means still different, either because it is not done yet or because the difference is deliberate (the note says which). Add anything new you find to the end of the matching list.

### Screen Share: UI

- [x] Tab order is now Screen Share, Translate, Vocabulary, Quiz, Settings, with Translate selected at launch. The Screen Share icon is `airplay`.
- [x] The tab has a 420 pt preview panel that draws the same cards as the PiP window (two visible rows, not tappable).
- [x] One large button reads "Share screen audio", "Start live subtitles", "Waiting for broadcast (tap to cancel)" or "Stop", and is red while active.
- [x] The source picker stays on screen and is locked while a session is active.
- [x] Start is disabled when PiP is unsupported or, for screen audio, when the broadcast extension is missing.
- [x] Help text matches Swift for each source and for "PiP not supported". The extension hint points to `ios_native/README.md`, because `SETUP.md` does not exist in this repo.
- [x] Errors show in an alert titled "Screen Share".
- [x] The transcript button sits in the app bar whenever the saved transcript has lines, including when idle.
- [x] The summary and the transcript open as full-screen dialogs with a Done button. The extra "View transcript" button is gone.
- [x] The "Hide learned" chip on the live screen is gone. The setting lives only in Settings.
- [x] "Show PiP" shows only while live and the PiP window is closed.
- [x] Saving or removing a word in the transcript gives a selection haptic.

### Screen Share: Android

- [x] The floating window is Flutter (`lib/ui/subtitle_window/`), run by a second engine inside a system overlay. Title bar: left corner resizes, the middle moves, the right button opens the app. The body scrolls. The window keeps its size and place between sessions.
- [x] Speech comes from the downloaded Sherpa-ONNX model, run from Dart. Kotlin only captures audio and streams it over `subtitle_learn/screen_share/audio`. Android has no platform fallback for screen audio, so it needs the model. The "on-device speech" setting has no effect here.
- [ ] Audio clips are not ported. "Replay from video" never shows on Android.
- [ ] Apps can opt out of audio capture, and then screen audio is silent. Use the microphone source for those.
- [ ] Scrollback is capped by `PipSubtitleModel.maxTokens` (40 cards), shared with iOS.

### Speech engine order

- [x] The Translate microphone uses the downloaded Sherpa model first and falls back to `speech_to_text` when the model is missing or won't start. The same Dart engine runs Screen Share on Android.
- [ ] Screen Share on iOS still uses the platform recognizer for both sources. The broadcast extension has a memory limit of roughly 50 MB, too small for this model, and the iOS microphone path records clips natively. Moving it needs a look at the Swift side.
- [ ] Recognition runs in a background isolate, so the UI stays smooth, but nothing has been timed on a real device.

### Screen Share: behaviour

- [x] "Hide hints for learned words" defaults to on. Phones that already stored the old default keep their saved value.
- [x] Setting label and footer match Swift.
- [x] Transcript lines are trimmed, any non-empty line is kept, and stopping saves the unfinished last line.
- [x] A session that heard nothing returns to the start screen with no summary.
- [x] Speech failures read "Speech recognition stopped: ...".
- [x] "Try Again" on the quiz error screen restarts a normal quiz in Swift too, so Flutter matches.
- [x] Minimum iOS is 17 on purpose. The Xcode project target is set to 17.0 and the native code needs it.
- [ ] Transcript storage. Swift writes a JSON file in Application Support, Flutter rewrites the whole JSON in SharedPreferences on each line. Deliberate for now.
- [x] Audio clips. The Swift recorder, store and player are copied into `ios_native/Runner/`. The word sheet and level 1 Chinese-to-English quiz questions show "Replay from video" when a clip exists. Saved words keep their clips, others are dropped when the session ends.
- [ ] Mock source (debug builds only). Not ported on purpose.
- [ ] Where the logic runs. Swift handles every speech result in-process. Flutter sends each partial result over the event channel, tokenizes it in Dart, then sends the lines back for the PiP window. Fast speech may be heavier than Swift. Unchecked on a device.

### Other UI

- [x] Onboarding pages use the Swift order, titles, text and notes, the same colours and a scrolling page. It covers the app as an overlay. On non-iOS platforms the first page note says Screen Share is iOS only.
- [x] Settings: section order, "Hide hints for learned words" footer, Speech footer (with the Simulator note on iOS), Keychain wording on iOS, no headers on the stepper and "more" groups.
- [x] The Gemini key saves on every change.
- [x] About text, author line, the frameworks credit and the AI note match Swift (the frameworks credit is rewritten for Flutter).
- [x] Session breakdown bar: 28 pt capsule that unmasks left to right, legend with count and label, spoken summary.
- [x] Quiz option buttons: press animation, selection haptic, spoken label, value and hint, selected trait, idle shadow, letter and subtitle colours.
- [x] Quiz progress header: spoken value and animated bar.
- [x] Press animation, reduce motion in the quiz header, breakdown bar, onboarding paging and press style, haptics on quiz options, Translate saves and transcript saves.
- [x] iOS privacy manifest copied to `ios/Runner/PrivacyInfo.xcprivacy`. Add it to the Runner target in Xcode (step 6 in `ios_native/README.md`).
- [x] Word sheet and vocabulary row have the same spoken hints as Swift.
- [x] iOS look first pass: theme platform is iOS (swipe-back, bounce scrolling), the tab bar is a `CupertinoTabBar` with SF-style icons, and alerts, switches and spinners use the `.adaptive` constructors so they render as Cupertino on iOS.
- [x] iOS look: Cupertino tab bar, alerts, action sheet for sort, search fields, segmented controls, text fields, time picker, page routes, chevrons and icon buttons (`components/icon_action.dart`), capsule filter pills (`components/pill_chip.dart`), 12 pt rounded buttons and sheets, inset grouped Settings. Fonts follow the iOS platform default (SF).
- [ ] Still Material underneath: `AppBar`, `Scaffold`, list tiles, `Divider`, and the `FilledButton`/`OutlinedButton` styling (rounded to match). Deliberate, since they follow the iOS theme.
- [ ] Questions per quiz. Swift uses a `Stepper`, Flutter uses minus and plus buttons with the same 3 to 20 range. Deliberate.
- [x] Translate listening bar: pulsing waveform and stop icon (static with reduce motion), 18 pt rounded red stop button, spoken hint on stop, live-region status.
- [x] Translate shows the Swift message when on-device recognition is unavailable (error 1101), if the plugin reports that code in its error text. Unchecked on a device.
- [x] Accessibility labels, values, hints and headers added for Stats (cards, heatmap, streak, chart), Dictionary, Add known word, custom word form, mastery picker, and all quiz views.
- [x] Stats heatmap has Mon/Wed/Fri and month labels, 14 pt cells and a right-aligned legend. The word chart has a totals column, a series menu, curved lines, a legend and a 4-week x axis.
- [x] Mastery picker captions read "Subtitles show/hide ...".
- [x] Cloze blank is a dashed border until answered. Quiz columns and stat cards stack at large text sizes.
- [ ] Home screen widget, widget refresh and the debug review-log seed menu on Stats. Not ported.
- [x] Reminder permission alert offers "Open Settings" and "Cancel" (adds the `app_settings` package).
- [ ] Quiz error screen keeps an extra "Back" button next to "Try Again". Deliberate.
- [ ] Reminder time. Swift uses an inline `DatePicker`, Flutter opens a time dialog.
- [ ] Translate debug buttons ("Test speech with sample audio", "Simulate live transcript"). Debug only, not ported.
- [x] Stats, Dictionary, Add known word, the quiz views, Translate and the word sheet were read against Swift in this pass.

### Other behaviour

- [ ] Storage is JSON in SharedPreferences, not SwiftData. Fine for hundreds of words. Move to SQLite if the review log gets large.
- [ ] Deleting a word also deletes its review log entries, so the stats chart can't count removed words. Swift's delete alert says the same.
- [ ] Weeks on the stats chart start on Monday.
- [ ] Pinyin for words missing from the dictionary, and for custom words with blank pinyin, is joined from each character's entry. Apple's transliterator has no equivalent here, so characters missing from the dictionary add nothing.
- [ ] Speech on Translate uses the `speech_to_text` plugin, not `SFSpeechRecognizer` directly. It restarts itself when the platform ends a session. Some Android devices play a short sound on each restart.
- [ ] Gemini key lives in `flutter_secure_storage`. The Swift Keychain migration from UserDefaults is not needed and not ported.
- [ ] Reminders use `flutter_local_notifications` with a fixed set of scheduled notifications. Same planner logic as Swift, but delivery is plugin-specific. Unchecked on a device.

### Tests

- [x] `MasteryFilterTests`, `ShortMeaningsTests` and `SavedWordRecordTests` are covered by `test/mastery_test.dart`, `test/dictionary_test.dart` and `test/saved_word_test.dart`.
- [x] New `test/screen_share_controller_test.dart` covers the transcript rules, the no-summary case, failure text and the default for hiding learned words, using a fake backend.
- [ ] Not ported: `KeychainStoreTests` (needs a secure storage mock), `WidgetSnapshotTests` (no widget), both UI test targets and the empty `SubtitleLearnTests.swift`.
- [ ] Nothing in Dart or Swift has been compiled or run. The Flutter widget code has no widget tests. Run `flutter pub get`, `flutter analyze` and `flutter test` first, since every round of edits was made without an SDK.

## Setup

Platform folders are included. If one is missing, regenerate it. From this directory:

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

## Screen Share on Android

Needs Android 10 or later. Speech recognition uses the Sherpa-ONNX streaming Paraformer model (Mandarin and English), run from Dart with the `sherpa_onnx` package. Nothing is bundled. Open Settings > Speech > Offline speech model and tap Download once, on Wi-Fi. The files go into the app's support folder.

The first time you start, the app asks for the microphone, then sends you to the "Display over other apps" screen. Allow it and start again. Screen audio then shows the system capture prompt.

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

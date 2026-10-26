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
- Tests ported from the Swift suite: mastery, SM-2, dictionary, search, segmentation, stats, reminders, sorting.

## Not ported

- Screen Share (ReplayKit broadcast, picture in picture subtitles) and everything that only served it: session summary, transcript, audio clips, the hide-hints-in-subtitles setting.
- The home screen widget and the debug seed menu.

## Behaviour that differs

- Storage is JSON in SharedPreferences, not SwiftData. Fine for hundreds of words. Move to SQLite if the review log gets large.
- Deleting a word also deletes its review log entries, so the stats chart can't count removed words.
- Weeks on the stats chart start on Monday.
- Pinyin for words missing from the dictionary (and for custom words with blank pinyin) is joined from each character's entry. Apple's transliterator has no equivalent here, so characters missing from the dictionary add nothing.
- Speech uses the `speech_to_text` plugin. It restarts itself when the platform ends a session. Some Android devices play a short sound on each restart.
- The Gemini key is trimmed and saved on submit or when the field loses focus.

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
- `lib/state`: Riverpod providers and controllers.
- `lib/ui`: screens, one widget per file, grouped by screen. `components` holds shared widgets.
- `assets/zh-en.tsv`: bundled dictionary.

## Credits

Dictionary data: CedPane by ssb22. Pinyin from CC-CEDICT (CC BY-SA) and pypinyin. Level 3 sentences from the Google Gemini API.

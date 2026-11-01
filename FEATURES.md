# SubLearn: features

What the app does today, what is planned, and what is known to be incomplete. Written from the code as it stands. Effort is rough: S is hours, M is a day or two, L is a week or more. The README covers setup, architecture and the differences from the Swift app.

## Current features

### Capture

- **Screen Share.** Live Mandarin subtitles from system audio or the microphone, shown in a floating window. On iOS 17 or later the window is Picture in Picture. On Android 10 or later it is an overlay drawn by Flutter that you can move and resize, and it keeps its size and place between sessions.
- **Speech engines.** Android uses the downloaded Sherpa-ONNX model for Screen Share and tries it first on Translate, falling back to the platform recognizer. iOS uses the platform recognizer, on the device or through Apple's servers depending on the on-device setting.
- **Session summary.** After each share: new, known and due words, the most heard words, and a shortcut into a review quiz. The transcript of the saved session is kept.
- **Audio clips (iOS).** A short clip is kept per heard word and replayed from the word sheet and in level 1 questions. Saved words keep their clips, the rest are dropped when the session ends.
- **Translate.** Type, paste or speak, then tap a word for pinyin, meanings and a per-character breakdown.

### Vocabulary

- **Save and remove.** Save words from Translate, the transcript or dictionary search. Delete one or many.
- **Custom words.** Add your own, or add a word you already know at a chosen level.
- **Find and sort.** Search, sort, and filter by mastery level or due today. Change a level by hand with the mastery slider.
- **Offline dictionary.** Search by characters, pinyin or English across about 105,000 entries.
- **Word sheet.** Pronunciation, clip replay, slow speech and the mastery picker.

### Quiz

- **Levels.** Levels 1 to 3 are quizzed. Level 4 is mastered and never quizzed again. Each level has two question types, and the answer streak picks which one comes up.
  - Level 1: multiple choice, Chinese to English and English to Chinese.
  - Level 2: match a word to its pinyin and meaning, in both directions.
  - Level 3: hear the word and pick its characters and meaning, or fill in the blank in a sentence.
- **Progress rule.** A word moves up a level after two correct answers in a row. A miss undoes one pass.
- **Scheduling.** SM-2. Missed questions come back at the end of the quiz.
- **History.** Quiz history with a detail view for each quiz.
- **Gemini sentences.** Fill-in-the-blank sentences come from Gemini and are cached on the device. Without a key, levels 1 and 2 and the listening question still work.

### Stats

- **Streak and accuracy.** A streak badge, and accuracy by period (7 days, 30 days, all time).
- **Words over time.** A chart of learned, saved and mastered words with a series menu.
- **Heatmap.** Reviews per day for the last 90 days, Monday first.

### Settings

- **Preferences.** Theme, on-device speech, speak slowly, hide hints for learned words, questions per quiz (3 to 20).
- **Reminder.** A daily review notification with a time picker, on Android and iOS. It only fires on days that have words due.
- **Gemini key.** Kept in secure storage. The Quiz section says what is sent: the words being quizzed with their pinyin and meanings.
- **Onboarding.** Shown on first launch and available again from Settings.

## Planned

In rough priority order.

| Feature | What it adds | Notes | Effort |
| --- | --- | --- | --- |
| Vocabulary export and import | JSON for a full backup, CSV for Anki and spreadsheets | Data lives in SharedPreferences, so a reinstall or a new phone loses everything | M |
| Cloze without Gemini | Store the sentence each saved word was heard in and build level 3 questions from those | The quiz then works without a key and stays tied to the user's own audio | M |
| Widget tests and date tests | Cover `ReviewHeatmap`, `daysBetween` and the stats calculator across a DST change | The heatmap column bug came from exactly that case | S |
| Move storage to SQLite | Faster transcript writes, room for history | The transcript rewrites its whole JSON on every line and the review log only grows. Do this before transcript history | M to L |
| Keep review logs on delete | Stats stop shrinking when a word is removed | Keep the logs and hide removed words from the lists instead | S |
| Sentence translation | Whole-sentence translation under the word breakdown on Translate and in the transcript | Uses the Gemini client. Hidden when no key is set | M |

## Ideas

Not scheduled.

### Learning

- Listening quiz from the clips heard during Screen Share. Level 3 already plays a saved word and asks for its characters and meaning.
- Typed recall: type the pinyin or characters from the English meaning.
- Leech list: flag words missed several times in a row and offer a short drill on them.
- Source sentence and clip shown on each saved word.
- Tone colours on pinyin and characters.
- HSK level tags, with a filter and a goal.
- Hide very common words (的, 了, 是) from the overlay by default, based on HSK or frequency.
- Traditional character toggle.
- Daily review goal and a streak freeze.

### Capture

- Import an SRT or text file for content without live audio.
- Transcript history across sessions.
- Save a whole transcript line as a card.
- Paste or share-sheet input from other apps.
- Audio clips on Android.

### Stats and platform

- Forecast of reviews due over the next 7 days.
- Android home screen widget with the due count and streak.
- Other source languages. The dictionary format would need a language field, and segmentation currently assumes Chinese (greedy longest-match on characters).

## Known limits

### Speech and Screen Share

- Screen Share on iOS still uses the platform recognizer for both sources. The broadcast extension has a memory limit of roughly 50 MB, too small for the Sherpa model, and the iOS microphone path records clips natively.
- Apps can opt out of audio capture, and then screen audio is silent. Use the microphone source for those.
- Recognition runs in a background isolate, but nothing has been timed on a real device during a long session.
- Scrollback is capped at 40 cards (`PipSubtitleModel.maxTokens`), shared with iOS.
- Some Android devices play a short sound each time the platform speech service restarts on Translate.
- Android has no audio clips, so "Replay from video" never shows there.

### Data

- Storage is JSON in SharedPreferences. That is fine for hundreds of words and is the reason for the SQLite item above.
- Deleting a word also deletes its review log entries, so the stats chart cannot count removed words.
- Pinyin for words missing from the dictionary, and for custom words with blank pinyin, is joined from each character's entry. Characters missing from the dictionary add nothing.

### Quality and release

- The app has had a full run on Android only. The Swift code, Picture in Picture, the iOS broadcast flow and iOS reminders have not been compiled or tried.
- Confirm that speaking a word during a screen share does not pause the source app's audio on iOS. The audio session category may need to mix with other audio.
- Detect a killed broadcast extension on iOS. A heartbeat timestamp the extension refreshes, treated as stale after a few seconds, would end a stuck "live" state.
- Show clear messages when the on-device Mandarin model is missing or recognition hits its time limit.
- Review the App Privacy answers. Words go to Gemini and speech can go to Apple's servers, while the manifest declares no collected data.
- Read the CC BY-SA terms for CC-CEDICT before any commercial release.

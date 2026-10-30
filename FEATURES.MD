# Subtitle Learn: features

What the app does today, what is planned, and ideas that are not scheduled. The README covers setup and the differences from the Swift app.

## Current features

### Capture
- Screen Share: live Mandarin subtitles from system audio or the mic, shown in a floating window. On iOS it is Picture in Picture, on Android it is an overlay drawn by Flutter.
- Speech runs on the device. Android uses the downloaded Sherpa-ONNX model. iOS uses the platform recognizer.
- Session summary after each share (new, known and due words, most heard words), with a shortcut into a review quiz. Transcript of the saved session.
- Audio clips per word on iOS, replayed from the word sheet and in level 1 questions.
- Translate: type, paste or speak, then tap a word for pinyin, meanings and a per-character breakdown.

### Vocabulary
- Save words from Translate, the transcript or dictionary search. Delete one or many.
- Add custom words, or add a word you already know at a chosen level.
- Search, sort and filter by mastery level or due today. Change a level by hand.
- Offline dictionary search by characters, pinyin or English.
- Word sheet with pronunciation, clip replay, slow speech and the mastery picker.

### Quiz
- Four mastery levels: multiple choice, pinyin and meaning match, fill in the blank, learned.
- SM-2 scheduling. Missed questions come back at the end.
- Quiz history with a detail view for each quiz.
- Level 3 sentences come from Gemini and are cached on the device.

### Stats
- Streak badge, accuracy by period (7 days, 30 days, all time).
- Words over time chart (learned, saved, mastered) with a pull-down series filter.
- Review heatmap for the last 90 days.

### Settings
- Theme, on-device speech, speak slowly, hide hints for learned words, questions per quiz.
- Daily review reminder with a time picker. It only fires on days that have words due.
- Gemini API key in secure storage.
- First-launch onboarding.

## Planned

In rough priority order.

1. **Vocabulary export and import.** JSON for a full backup, CSV for Anki and spreadsheets. Data lives in SharedPreferences today, so a reinstall or a new phone loses everything.
2. **Cloze without Gemini.** Store the sentence each saved word was heard in, and build level 3 questions from those. The quiz then works without a key and stays tied to the user's own audio.
3. **Widget tests and date tests.** Cover `ReviewHeatmap`, `daysBetween` and the stats calculator on dates that cross a DST change. The heatmap column bug came from exactly that case.
4. **Move storage to SQLite.** The transcript rewrites its whole JSON on every line, and the review log only grows. Do this before adding transcript history.
5. **Keep review logs when a word is deleted.** Stats currently shrink because deleting a word deletes its history. Keep the logs and hide removed words from the lists instead.
6. **Sentence translation.** Optional whole-sentence translation under the word breakdown on Translate and in the transcript, using the Gemini client. Hidden when no key is set.

## Ideas

### Learning
- Listening quiz: hear a word or clip and pick the meaning.
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

### Stats
- Forecast of reviews due over the next 7 days.

### Platform
- Android home screen widget with the due count and streak.
- Other source languages. The dictionary format would need a language field, and segmentation currently assumes Chinese (greedy character matching).

### Quality
- Time the Sherpa recognizer on a real device during a long session.
- Confirm that speaking a word during a screen share does not pause the source app's audio on iOS. The audio session category may need to mix with other audio.
- Detect a killed broadcast extension on iOS. A heartbeat timestamp the extension refreshes, treated as stale after a few seconds, would end a stuck "live" state.
- Clear messages when the on-device Mandarin model is missing or recognition hits its time limit.
- Review the App Privacy answers. Words go to Gemini and speech can go to Apple's servers, while the manifest declares no collected data.
- Read the CC BY-SA terms for CC-CEDICT before any commercial release.
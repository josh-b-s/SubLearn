import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/appearance_mode.dart';
import '../../services/platform_info.dart';
import '../../services/reminders/review_reminder_scheduler.dart';
import '../../state/settings_provider.dart';
import '../components/grouped_row.dart';
import '../components/grouped_section.dart';
import '../components/large_title_page.dart';
import '../components/segmented_picker.dart';
import '../components/stepper_control.dart';
import 'about_screen.dart';
import 'gemini_key_field.dart';
import 'reminder_settings_section.dart';
import 'speech_model_tile.dart';

const _modelFooter =
    'The downloaded model is used first, for the Translate microphone and for Screen Share on Android. The switch below only matters when it is missing.';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return LargeTitlePage(
      title: 'Settings',
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GroupedSection(
                title: 'Appearance',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SegmentedPicker<AppearanceMode>(
                      labels: {for (final m in AppearanceMode.values) m: m.title},
                      selected: settings.appearance,
                      onChanged: notifier.setAppearance,
                    ),
                  ),
                ],
              ),
              GroupedSection(
                title: 'Speech',
                footer: '$_modelFooter ${isIos
                    ? "On: works offline with no time limit, but needs the Mandarin model and is less accurate. Off: Apple's servers, more accurate but needs internet. The Simulator doesn't support on-device, so turn this off there."
                    : 'On: works offline, but needs the Mandarin speech model on the device and may be less accurate. Off: uses the platform speech service, which is more accurate but needs internet.'}',
                children: [
                  const SpeechModelTile(),
                  GroupedRow(
                    title: 'On-device recognition',
                    trailing: CupertinoSwitch(value: settings.preferOnDeviceSpeech, onChanged: notifier.setPreferOnDeviceSpeech),
                  ),
                ],
              ),
              GroupedSection(
                title: 'Pronunciation',
                footer: 'Slows the voice for word details and quizzes.',
                children: [
                  GroupedRow(
                    title: 'Speak slowly',
                    trailing: CupertinoSwitch(value: settings.speakSlowly, onChanged: notifier.setSpeakSlowly),
                  ),
                ],
              ),
              GroupedSection(
                title: 'Subtitles',
                footer:
                    'Words past level 1 lose their meaning in the subtitles, and past level 2 their pinyin too. Look them up in the app if you need a reminder.',
                children: [
                  GroupedRow(
                    title: 'Hide hints for learned words',
                    trailing: CupertinoSwitch(
                      value: settings.hideLearnedInSubtitles,
                      onChanged: notifier.setHideLearnedInSubtitles,
                    ),
                  ),
                ],
              ),
              if (ReviewReminderScheduler.supported)
                const GroupedSection(
                  title: 'Reminders',
                  footer:
                      'Sends a notification at this time on days when words are due for review. Turning it on asks for permission to send notifications.',
                  children: [ReminderSettingsSection()],
                ),
              GroupedSection(
                title: 'Quiz',
                footer:
                    "Only used to write example sentences for level 3 questions, then cached. Each request sends the words being quizzed, with their pinyin and meanings, to Google's Gemini API. Nothing else leaves your device. Levels 1 and 2 work without a key. Get a key at aistudio.google.com/apikey. The key is kept in ${isIos ? 'the Keychain' : 'secure storage'} on this device.",
                children: const [GeminiKeyField()],
              ),
              GroupedSection(
                children: [
                  GroupedRow(
                    title: '${settings.questionsPerQuiz} questions per quiz',
                    trailing: StepperControl(
                      decrementLabel: 'Fewer questions',
                      incrementLabel: 'More questions',
                      onDecrement: settings.questionsPerQuiz > 3
                          ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz - 1)
                          : null,
                      onIncrement: settings.questionsPerQuiz < 20
                          ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz + 1)
                          : null,
                    ),
                  ),
                ],
              ),
              GroupedSection(
                children: [
                  GroupedRow(title: 'Show App Introduction', onTap: () => notifier.setHasSeenOnboarding(false)),
                  GroupedRow(
                    title: 'About',
                    chevron: true,
                    onTap: () => Navigator.push(context, CupertinoPageRoute<void>(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

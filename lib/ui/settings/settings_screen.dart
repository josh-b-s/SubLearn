import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/appearance_mode.dart';
import '../../services/platform_info.dart';
import '../../services/reminders/review_reminder_scheduler.dart';
import '../../state/settings_provider.dart';
import '../components/icon_action.dart';
import '../components/segmented_picker.dart';
import '../theme/app_colors.dart';
import 'about_screen.dart';
import 'gemini_key_field.dart';
import 'reminder_settings_section.dart';
import 'settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: context.groupedBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedPicker<AppearanceMode>(
                  labels: {for (final m in AppearanceMode.values) m: m.title},
                  selected: settings.appearance,
                  onChanged: notifier.setAppearance,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Speech',
            footer: isIos
                ? "On: works offline with no time limit, but needs the Mandarin model and is less accurate. Off: Apple's servers, more accurate but needs internet. The Simulator doesn't support on-device, so turn this off there."
                : 'On: works offline, but needs the Mandarin speech model on the device and may be less accurate. Off: uses the platform speech service, which is more accurate but needs internet.',
            children: [
              SwitchListTile.adaptive(
                title: const Text('On-device recognition'),
                value: settings.preferOnDeviceSpeech,
                onChanged: notifier.setPreferOnDeviceSpeech,
              ),
            ],
          ),
          SettingsSection(
            title: 'Pronunciation',
            footer: 'Slows the voice for word details and quizzes.',
            children: [
              SwitchListTile.adaptive(
                title: const Text('Speak slowly'),
                value: settings.speakSlowly,
                onChanged: notifier.setSpeakSlowly,
              ),
            ],
          ),
          SettingsSection(
            title: 'Subtitles',
            footer:
                'Words past level 1 lose their meaning in the subtitles, and past level 2 their pinyin too. Look them up in the app if you need a reminder.',
            children: [
              SwitchListTile.adaptive(
                title: const Text('Hide hints for learned words'),
                value: settings.hideLearnedInSubtitles,
                onChanged: notifier.setHideLearnedInSubtitles,
              ),
            ],
          ),
          if (ReviewReminderScheduler.supported)
            SettingsSection(
              title: 'Reminders',
              footer:
                  'Sends a notification at this time on days when words are due for review. Turning it on asks for permission to send notifications.',
              children: [ReminderSettingsSection()],
            ),
          SettingsSection(
            title: 'Quiz',
            footer:
                "Only used to write example sentences for level 3 questions, then cached. Each request sends the words being quizzed, with their pinyin and meanings, to Google's Gemini API. Nothing else leaves your device. Levels 1 and 2 work without a key. Get a key at aistudio.google.com/apikey. The key is kept in ${isIos ? 'the Keychain' : 'secure storage'} on this device.",
            children: const [GeminiKeyField()],
          ),
          SettingsSection(
            children: [
              ListTile(
                title: Text('${settings.questionsPerQuiz} questions per quiz'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconAction(
                    label: 'Fewer questions',
                    icon: CupertinoIcons.minus_circle,
                    onPressed: settings.questionsPerQuiz > 3
                        ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz - 1)
                        : null,
                  ),
                  IconAction(
                    label: 'More questions',
                    icon: CupertinoIcons.plus_circle,
                    onPressed: settings.questionsPerQuiz < 20
                        ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz + 1)
                        : null,
                  ),
                ]),
              ),
            ],
          ),
          SettingsSection(
            children: [
              ListTile(title: const Text('Show app introduction'), onTap: () => notifier.setHasSeenOnboarding(false)),
              ListTile(
                title: const Text('About'),
                trailing: const Icon(CupertinoIcons.chevron_forward),
                onTap: () => Navigator.push(context, CupertinoPageRoute<void>(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

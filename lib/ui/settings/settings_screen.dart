import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/appearance_mode.dart';
import '../../services/reminders/review_reminder_scheduler.dart';
import '../../state/settings_provider.dart';
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<AppearanceMode>(
                  segments: [for (final m in AppearanceMode.values) ButtonSegment(value: m, label: Text(m.title))],
                  selected: {settings.appearance},
                  onSelectionChanged: (s) => notifier.setAppearance(s.first),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Speech',
            footer:
                'On: works offline, but needs the Mandarin speech model on the device and may be less accurate. Off: uses the platform speech service, which is more accurate but needs internet.',
            children: [
              SwitchListTile(
                title: const Text('On-device recognition'),
                value: settings.preferOnDeviceSpeech,
                onChanged: notifier.setPreferOnDeviceSpeech,
              ),
            ],
          ),
          SettingsSection(
            title: 'Subtitles',
            footer: 'Screen Share cards for words you already know show only the characters.',
            children: [
              SwitchListTile(
                title: const Text('Hide learned words'),
                value: settings.hideLearnedInSubtitles,
                onChanged: notifier.setHideLearnedInSubtitles,
              ),
            ],
          ),
          SettingsSection(
            title: 'Pronunciation',
            footer: 'Slows the voice for word details and quizzes.',
            children: [
              SwitchListTile(
                title: const Text('Speak slowly'),
                value: settings.speakSlowly,
                onChanged: notifier.setSpeakSlowly,
              ),
            ],
          ),
          if (ReviewReminderScheduler.supported)
            const SettingsSection(title: 'Reminders', children: [ReminderSettingsSection()]),
          const SettingsSection(
            title: 'Quiz',
            footer:
                "Only used to write example sentences for level 3 questions, then cached. Each request sends the words being quizzed, with their pinyin and meanings, to Google's Gemini API. Nothing else leaves your device. Levels 1 and 2 work without a key. Get a key at aistudio.google.com/apikey. The key is kept in secure storage on this device.",
            children: [GeminiKeyField()],
          ),
          SettingsSection(
            title: 'Questions',
            children: [
              ListTile(
                title: Text('${settings.questionsPerQuiz} questions per quiz'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Fewer questions',
                    icon: const Icon(Icons.remove),
                    onPressed: settings.questionsPerQuiz > 3
                        ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz - 1)
                        : null,
                  ),
                  IconButton(
                    tooltip: 'More questions',
                    icon: const Icon(Icons.add),
                    onPressed: settings.questionsPerQuiz < 20
                        ? () => notifier.setQuestionsPerQuiz(settings.questionsPerQuiz + 1)
                        : null,
                  ),
                ]),
              ),
            ],
          ),
          SettingsSection(
            title: 'More',
            children: [
              ListTile(title: const Text('Show app introduction'), onTap: () => notifier.setHasSeenOnboarding(false)),
              ListTile(
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

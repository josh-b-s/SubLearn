import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/quiz_controller.dart';
import 'state/reminder_sync.dart';
import 'state/settings_provider.dart';
import 'state/tab_provider.dart';
import 'state/translate_controller.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/quiz/quiz_screen.dart';
import 'ui/screen_share/screen_share_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/translate/translate_screen.dart';
import 'ui/vocabulary/vocabulary_screen.dart';

class SubtitleLearnApp extends ConsumerWidget {
  const SubtitleLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(settingsProvider.select((s) => s.appearance));
    final seen = ref.watch(settingsProvider.select((s) => s.hasSeenOnboarding));
    return MaterialApp(
      title: 'Subtitle Learn',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: appearance.themeMode,
      home: seen
          ? const _Shell()
          : OnboardingScreen(onFinish: () => ref.read(settingsProvider.notifier).setHasSeenOnboarding(true)),
    );
  }
}

class _Shell extends ConsumerStatefulWidget {
  const _Shell();

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> with WidgetsBindingObserver {
  static const _screens = [
    TranslateScreen(),
    ScreenShareScreen(),
    VocabularyScreen(),
    QuizScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshReminders();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Rebuilds the reminders on launch and each time the app comes forward or goes away,
  /// so the counts follow the latest quiz results.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || state == AppLifecycleState.paused) _refreshReminders();
  }

  void _refreshReminders() => ref.read(reminderSyncProvider)();

  void _select(int index) {
    if (index != AppTab.translate.index) ref.read(translateControllerProvider.notifier).stopListening();
    ref.read(tabProvider.notifier).select(AppTab.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final inQuiz = ref.watch(quizControllerProvider.select((s) => s.isInProgress));
    final tab = ref.watch(tabProvider);
    return Scaffold(
      body: IndexedStack(index: tab.index, children: _screens),
      bottomNavigationBar: inQuiz && tab == AppTab.quiz
          ? null
          : NavigationBar(
              selectedIndex: tab.index,
              onDestinationSelected: _select,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Translate'),
                NavigationDestination(
                  icon: Icon(Icons.picture_in_picture_alt_outlined),
                  selectedIcon: Icon(Icons.picture_in_picture_alt),
                  label: 'Screen Share',
                ),
                NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Vocabulary'),
                NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'Quiz'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
    );
  }
}

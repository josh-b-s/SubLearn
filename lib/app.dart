import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoTabBar;
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
      // Onboarding covers the app instead of replacing it, so the tabs keep their state underneath.
      home: Stack(
        children: [
          const _Shell(),
          if (!seen)
            Positioned.fill(
              child: OnboardingScreen(onFinish: () => ref.read(settingsProvider.notifier).setHasSeenOnboarding(true)),
            ),
        ],
      ),
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
    ScreenShareScreen(),
    TranslateScreen(),
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
          : CupertinoTabBar(
              currentIndex: tab.index,
              onTap: _select,
              activeColor: Theme.of(context).colorScheme.primary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.airplay), label: 'Screen Share'),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.arrow_right_arrow_left), label: 'Translate'),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.bookmark), activeIcon: Icon(CupertinoIcons.bookmark_fill), label: 'Vocabulary'),
                BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'Quiz'),
                BottomNavigationBarItem(icon: Icon(CupertinoIcons.gear), activeIcon: Icon(CupertinoIcons.gear_solid), label: 'Settings'),
              ],
            ),
    );
  }
}

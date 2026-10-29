import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
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
import 'ui/theme/app_colors.dart';
import 'ui/theme/app_theme.dart';
import 'ui/translate/translate_screen.dart';
import 'ui/vocabulary/vocabulary_screen.dart';

class SubtitleLearnApp extends ConsumerWidget {
  const SubtitleLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(settingsProvider.select((s) => s.appearance));
    final seen = ref.watch(settingsProvider.select((s) => s.hasSeenOnboarding));
    return CupertinoApp(
      title: 'Subtitle Learn',
      theme: AppTheme.of(appearance.brightness),
      // The text selection toolbar on Android looks up Material strings.
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
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

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.tv),
      activeIcon: Icon(CupertinoIcons.tv_fill),
      label: 'Screen Share',
    ),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.arrow_right_arrow_left), label: 'Translate'),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.bookmark),
      activeIcon: Icon(CupertinoIcons.bookmark_fill),
      label: 'Vocabulary',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.question_circle),
      activeIcon: Icon(CupertinoIcons.question_circle_fill),
      label: 'Quiz',
    ),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.gear),
      activeIcon: Icon(CupertinoIcons.gear_solid),
      label: 'Settings',
    ),
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
    final showBar = !(inQuiz && tab == AppTab.quiz);

    final bar = CupertinoTabBar(currentIndex: tab.index, onTap: _select, items: _items);
    Widget body = IndexedStack(index: tab.index, children: _screens);
    if (showBar) {
      // The tab bar takes the home indicator inset and sits under the keyboard, so the pages above it
      // see neither the inset nor the part of the keyboard that overlaps the bar.
      final media = MediaQuery.of(context);
      final barHeight = bar.preferredSize.height + media.padding.bottom;
      body = MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(bottom: 0),
          viewInsets: media.viewInsets.copyWith(bottom: math.max(0, media.viewInsets.bottom - barHeight)),
        ),
        child: body,
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      resizeToAvoidBottomInset: false,
      child: Column(children: [Expanded(child: body), if (showBar) bar]),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../../services/platform_info.dart';

/// One screen of the first launch tour.
class OnboardingPage {
  const OnboardingPage({required this.icon, required this.title, required this.text, this.note});

  final IconData icon;
  final String title;
  final String text;
  final String? note;

  /// Same order and icons as the tab bar.
  static List<OnboardingPage> get all => [
        OnboardingPage(
          icon: CupertinoIcons.captions_bubble,
          title: 'Subtitles for what you watch',
          text:
              'Play a video or podcast in Chinese. The app listens and shows each word with its pinyin and meaning in a floating window. Words you hear are collected so you can review them afterwards.',
          note: isIos
              ? 'Needs a real device. In Settings you can hide hints for words you know and choose on-device or server speech recognition.'
              : 'Only available on iOS. Other platforms show a message on that tab instead.',
        ),
        const OnboardingPage(
          icon: CupertinoIcons.arrow_right_arrow_left,
          title: 'Look up any Chinese text',
          text:
              'Speak into the microphone or paste text. Tap a word to see its meaning, pinyin and each character, then save it to your vocabulary.',
          note: 'In Settings you can choose on-device or server speech recognition.',
        ),
        const OnboardingPage(
          icon: CupertinoIcons.bookmark,
          title: 'Keep the words you save',
          text:
              'Search and filter your words by mastery level, or set a level yourself. You can also search the whole dictionary and add words you already know.',
        ),
        const OnboardingPage(
          icon: CupertinoIcons.rectangle_stack,
          title: 'Review with spaced repetition',
          text:
              'Questions get harder as a word moves up a level. Words you miss come back at the end of the quiz. The stats screen tracks your streak and progress.',
          note: 'In Settings you can set how many questions a quiz has and add a Gemini key for level 3.',
        ),
      ];
}

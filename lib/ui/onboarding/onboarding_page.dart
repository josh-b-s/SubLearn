import 'package:flutter/material.dart';

/// One screen of the first launch tour.
class OnboardingPage {
  const OnboardingPage({required this.icon, required this.title, required this.text, this.note});

  final IconData icon;
  final String title;
  final String text;
  final String? note;

  /// Same order and icons as the tab bar.
  static const all = [
    OnboardingPage(
      icon: Icons.swap_horiz,
      title: 'Look up any Chinese text',
      text:
          'Speak into the microphone or paste text. Tap a word to see its meaning, pinyin and each character, then save it to your vocabulary.',
      note: 'In Settings you can choose on-device or server speech recognition.',
    ),
    OnboardingPage(
      icon: Icons.picture_in_picture_alt_outlined,
      title: 'Subtitles over any video',
      text:
          'Start a screen share to get live Mandarin subtitles for audio playing on your phone. Word cards float in a small window above other apps, and a summary afterwards shows the words you heard most.',
      note: 'Available on iOS. Other platforms show a message instead.',
    ),
    OnboardingPage(
      icon: Icons.bookmark_border,
      title: 'Keep the words you save',
      text:
          'Search and filter your words by mastery level, or set a level yourself. You can also search the whole dictionary and add words you already know.',
    ),
    OnboardingPage(
      icon: Icons.psychology_outlined,
      title: 'Review with spaced repetition',
      text:
          'Questions get harder as a word moves up a level. Words you miss come back at the end of the quiz. The stats screen tracks your streak and progress.',
      note: 'In Settings you can set how many questions a quiz has and add a Gemini key for level 3.',
    ),
  ];
}

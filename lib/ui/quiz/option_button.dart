import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../components/pressable.dart';
import '../theme/wind_classes.dart';

enum OptionState {
  idle,
  selected,
  correct,
  wrong;

  /// Before the answer is revealed only the pick is marked. After, the right one is green and a wrong pick red.
  static OptionState resolve({
    required String choice,
    required String answer,
    required String? selection,
    required bool revealed,
  }) {
    if (revealed) {
      if (choice == answer) return correct;
      return choice == selection ? wrong : idle;
    }
    return choice == selection ? selected : idle;
  }

  static String letter(int index) => String.fromCharCode(65 + index);
}

/// Answer row shared by every question type.
class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
    this.letter,
    this.subtitle,
    this.fontSize = 18,
    this.isLocked = false,
  });

  final String text;
  final String? letter;
  final String? subtitle;
  final OptionState state;
  final double fontSize;
  final bool isLocked;
  final VoidCallback onTap;

  static const _idle = 'bg-white dark:bg-night-900 border border-night-950/10 dark:border-night-50/15';
  static const _selected = 'bg-brand-500/15 dark:bg-brand-400/20 border-2 border-brand-500 dark:border-brand-400';
  static const _correct = 'bg-green-600/10 dark:bg-green-400/15 border-2 border-green-600 dark:border-green-400';
  static const _wrong = 'bg-red-600/10 dark:bg-red-400/15 border-2 border-red-600 dark:border-red-400';

  @override
  Widget build(BuildContext context) {
    final (surface, icon, textClass, accentClass) = switch (state) {
      OptionState.idle => (_idle, null, inkTextClass, mutedTextClass),
      OptionState.selected => (
          _selected,
          CupertinoIcons.checkmark_circle_fill,
          inkTextClass,
          'text-brand-500 dark:text-brand-400',
        ),
      OptionState.correct => (
          _correct,
          CupertinoIcons.checkmark_circle_fill,
          'text-green-700 dark:text-green-400',
          'text-green-700 dark:text-green-400',
        ),
      OptionState.wrong => (
          _wrong,
          CupertinoIcons.xmark_circle_fill,
          'text-red-700 dark:text-red-400',
          'text-red-700 dark:text-red-400',
        ),
    };
    final stateLabel = switch (state) {
      OptionState.idle => '',
      OptionState.selected => 'Selected',
      OptionState.correct => 'Correct answer',
      OptionState.wrong => 'Wrong answer',
    };
    final resolved = state == OptionState.correct || state == OptionState.wrong;
    return Semantics(
      button: true,
      selected: state != OptionState.idle,
      label: [letter, text, subtitle].whereType<String>().where((p) => p.isNotEmpty).join(', '),
      value: stateLabel,
      hint: isLocked ? '' : 'Double tap to choose this answer',
      excludeSemantics: true,
      onTap: isLocked ? null : _choose,
      child: Pressable(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isLocked ? null : _choose,
          child: WDiv(
            className: 'flex flex-row items-center gap-3 w-full p-[14px] rounded-control $surface',
            children: [
              if (letter != null) WText(letter!, className: 'font-bold $accentClass'),
              WDiv(
                className: 'flex-1 flex flex-col items-start',
                children: [
                  WText(text, className: 'text-[${fontSize.round()}px] $textClass'),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    WText(subtitle!, className: resolved ? textClass : mutedTextClass),
                ],
              ),
              if (icon != null) WIcon(icon, className: 'text-[24px] $accentClass'),
            ],
          ),
        ),
      ),
    );
  }

  void _choose() {
    HapticFeedback.selectionClick();
    onTap();
  }
}

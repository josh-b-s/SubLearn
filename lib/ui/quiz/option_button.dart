import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../components/pressable.dart';
import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final green = context.resolve(CupertinoColors.systemGreen);
    final red = context.resolve(CupertinoColors.systemRed);
    final label = context.resolve(CupertinoColors.label);
    final (border, fill, icon, textColor) = switch (state) {
      OptionState.idle => (context.hairline, context.cardBackground, null, label),
      OptionState.selected => (context.accent, context.accent.withValues(alpha: 0.15), CupertinoIcons.checkmark_circle_fill, label),
      OptionState.correct => (green, green.withValues(alpha: 0.12), CupertinoIcons.checkmark_circle_fill, context.successText),
      OptionState.wrong => (red, red.withValues(alpha: 0.12), CupertinoIcons.xmark_circle_fill, context.errorText),
    };
    final stateLabel = switch (state) {
      OptionState.idle => '',
      OptionState.selected => 'Selected',
      OptionState.correct => 'Correct answer',
      OptionState.wrong => 'Wrong answer',
    };
    final resolved = state == OptionState.correct || state == OptionState.wrong;
    final letterColor = switch (state) {
      OptionState.idle => context.mutedText,
      OptionState.selected => border,
      _ => textColor,
    };
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: state == OptionState.idle ? 1 : 2),
            ),
            child: Row(
              children: [
                if (letter != null) ...[
                  Text(letter!, style: TextStyle(fontWeight: FontWeight.bold, color: letterColor)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(subtitle!, style: TextStyle(color: resolved ? textColor : context.mutedText)),
                    ],
                  ),
                ),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
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

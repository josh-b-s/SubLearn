import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final (border, fill, icon, textColor) = switch (state) {
      OptionState.idle => (scheme.outlineVariant, context.cardBackground, null, scheme.onSurface),
      OptionState.selected => (scheme.primary, scheme.primary.withValues(alpha: 0.15), Icons.check_circle, scheme.onSurface),
      OptionState.correct => (Colors.green, Colors.green.withValues(alpha: 0.12), Icons.check_circle, context.successText),
      OptionState.wrong => (Colors.red, Colors.red.withValues(alpha: 0.12), Icons.cancel, context.errorText),
    };
    final stateLabel = switch (state) {
      OptionState.idle => '',
      OptionState.selected => 'Selected',
      OptionState.correct => 'Correct answer',
      OptionState.wrong => 'Wrong answer',
    };
    return Semantics(
      button: true,
      selected: state == OptionState.selected,
      value: stateLabel,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: state == OptionState.idle ? 1 : 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLocked ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                if (letter != null) ...[
                  Text(letter!, style: TextStyle(fontWeight: FontWeight.bold, color: context.mutedText)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(subtitle!, style: TextStyle(color: context.mutedText)),
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
}

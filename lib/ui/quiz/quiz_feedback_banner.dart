import 'package:flutter/cupertino.dart';

import '../../models/quiz/quiz_feedback.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Result of the answer just given, shown above the Next button.
class QuizFeedbackBanner extends StatelessWidget {
  const QuizFeedbackBanner({super.key, required this.feedback});

  final QuizFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final tint = context.resolve(feedback.correct ? CupertinoColors.systemGreen : CupertinoColors.systemRed);
    final textTint = feedback.correct ? context.successText : context.errorText;
    final message = feedback.correct ? 'Correct! ${feedback.explanation}' : 'Not quite. Answer: ${feedback.answerText}';
    final small = context.footnote;
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Row(
              spacing: 8,
              children: [
                Icon(feedback.correct ? CupertinoIcons.checkmark : CupertinoIcons.xmark, color: textTint, size: 18),
                Expanded(child: Text(message, style: TextStyle(color: textTint, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          if (!feedback.correct) Text("You'll see this one again at the end.", style: small.copyWith(color: context.mutedText)),
          if (feedback.levelNote != null)
            Text(feedback.levelNote!, style: small.copyWith(color: context.accent, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/quiz/quiz_feedback.dart';
import '../theme/wind_classes.dart';

/// Result of the answer just given, shown above the Next button.
class QuizFeedbackBanner extends StatelessWidget {
  const QuizFeedbackBanner({super.key, required this.feedback});

  final QuizFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final correct = feedback.correct;
    final surface = correct ? 'bg-green-600/10 dark:bg-green-400/15' : 'bg-red-600/10 dark:bg-red-400/15';
    final text = correct ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400';
    final message = correct ? 'Correct! ${feedback.explanation}' : 'Not quite. Answer: ${feedback.answerText}';
    return Semantics(
      liveRegion: true,
      child: WDiv(
        className: 'flex flex-col items-start gap-[6px]',
        children: [
          WDiv(
            className: 'flex flex-row items-center gap-2 w-full p-[14px] rounded-control $surface',
            children: [
              WIcon(correct ? CupertinoIcons.checkmark : CupertinoIcons.xmark, className: 'text-lg $text'),
              WDiv(className: 'flex-1', child: WText(message, className: 'font-semibold $text')),
            ],
          ),
          if (!correct) const WText("You'll see this one again at the end.", className: 'text-[13px] $mutedTextClass'),
          if (feedback.levelNote != null)
            WText(feedback.levelNote!, className: 'text-[13px] font-medium text-brand-500 dark:text-brand-400'),
        ],
      ),
    );
  }
}

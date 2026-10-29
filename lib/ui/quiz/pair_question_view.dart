import 'package:flutter/cupertino.dart';

import '../../models/quiz/pair_question.dart';
import '../components/speak_button.dart';
import '../theme/app_text.dart';
import 'auto_speak.dart';
import 'quiz_columns_view.dart';
import 'quiz_prompt_card.dart';

/// Level 2 and listening body: two columns of options, one pick from each.
class PairQuestionView extends StatelessWidget {
  const PairQuestionView({
    super.key,
    required this.question,
    required this.first,
    required this.second,
    required this.onFirst,
    required this.onSecond,
    required this.isRevealed,
  });

  final PairQuestion question;
  final String? first;
  final String? second;
  final ValueChanged<String> onFirst;
  final ValueChanged<String> onSecond;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        QuizPromptCard(children: [
          switch (question.prompt) {
            PairPrompt.word => Text(question.word, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold)),
            PairPrompt.meaning => Text(
                question.meaning,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            PairPrompt.audio => AutoSpeak(word: question.word, child: SpeakButton(word: question.word)),
          },
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Pick the ${question.first.title.toLowerCase()} and the ${question.second.title.toLowerCase()}',
              style: context.body,
            ),
          ),
        ]),
        QuizColumnsView(
          first: question.first,
          second: question.second,
          firstSelection: first,
          secondSelection: second,
          onFirst: onFirst,
          onSecond: onSecond,
          isRevealed: isRevealed,
        ),
      ],
    );
  }
}

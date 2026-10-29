import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/quiz/choice_question.dart';
import '../../state/core_providers.dart';
import '../components/speak_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'auto_speak.dart';
import 'option_button.dart';
import 'quiz_prompt_card.dart';

/// Level 1 body.
class ChoiceQuestionView extends ConsumerWidget {
  const ChoiceQuestionView({
    super.key,
    required this.question,
    required this.selection,
    required this.onSelect,
    required this.isRevealed,
  });

  final ChoiceQuestion question;
  final String? selection;
  final ValueChanged<String> onSelect;
  final bool isRevealed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chinese = question.direction == ChoiceDirection.chineseToEnglish;
    return Column(
      spacing: 20,
      children: [
        QuizPromptCard(children: [
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: chinese ? 48 : 28, fontWeight: FontWeight.bold),
          ),
          if (question.hint.isNotEmpty)
            Text(question.hint, style: context.body.copyWith(color: context.mutedText)),
          if (chinese) AutoSpeak(word: question.prompt, child: SpeakButton(word: question.prompt)),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              chinese ? 'What does this mean?' : 'Which word means this?',
              style: context.body,
            ),
          ),
        ]),
        Column(
          spacing: 10,
          children: [
            for (final (i, choice) in question.choices.indexed)
              OptionButton(
                text: choice,
                letter: OptionState.letter(i),
                subtitle: question.choicePinyin[choice],
                state: OptionState.resolve(choice: choice, answer: question.answer, selection: selection, revealed: isRevealed),
                isLocked: isRevealed,
                onTap: () {
                  onSelect(choice);
                  // Only where the pinyin is on screen too, so hearing it gives nothing away.
                  if (question.choicePinyin[choice] != null) {
                    ref.read(speakerProvider).speak(choice, ignoringMuteSwitch: true);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/quiz/choice_question.dart';
import '../../state/core_providers.dart';
import '../components/speak_button.dart';
import '../theme/wind_classes.dart';
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
          WText(
            question.prompt,
            className: 'text-[${chinese ? 48 : 28}px] font-bold text-center $inkTextClass',
          ),
          if (question.hint.isNotEmpty) WText(question.hint, className: 'text-[17px] $mutedTextClass'),
          if (chinese) AutoSpeak(word: question.prompt, child: SpeakButton(word: question.prompt)),
          WDiv(
            className: 'pt-1',
            child: WText(chinese ? 'What does this mean?' : 'Which word means this?', className: 'text-[17px] $inkTextClass'),
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

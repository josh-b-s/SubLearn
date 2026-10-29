import 'package:flutter/cupertino.dart';

import '../../models/quiz/cloze_question.dart';
import '../../models/word_token.dart';
import '../../services/dictionary/han.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'cloze_word_card.dart';
import 'dashed_border_painter.dart';
import 'option_button.dart';
import 'quiz_columns_view.dart';
import 'quiz_prompt_card.dart';

/// Level 3 body: the English sentence, its words as cards around a blank, a word bank, then pinyin and meaning options.
class ClozeQuestionView extends StatefulWidget {
  const ClozeQuestionView({
    super.key,
    required this.question,
    required this.selection,
    required this.pinyin,
    required this.meaning,
    required this.onSelection,
    required this.onPinyin,
    required this.onMeaning,
    required this.isRevealed,
  });

  final ClozeQuestion question;
  final String? selection;
  final String? pinyin;
  final String? meaning;
  final ValueChanged<String> onSelection;
  final ValueChanged<String> onPinyin;
  final ValueChanged<String> onMeaning;
  final bool isRevealed;

  @override
  State<ClozeQuestionView> createState() => _ClozeQuestionViewState();
}

class _ClozeQuestionViewState extends State<ClozeQuestionView> {
  /// Cards the learner tapped to see their hidden hints.
  final _showingHidden = <int>{};

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Column(
      spacing: 20,
      children: [
        QuizPromptCard(alignment: CrossAxisAlignment.start, children: [
          Text(
            'Fill in the blank, then pick its pinyin and meaning',
            style: context.subhead.copyWith(color: context.mutedText),
          ),
          Text(q.translation, style: context.body.copyWith(fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final t in q.before) _card(t),
                _blank(context),
                for (final t in q.after) _card(t),
              ],
            ),
          ),
        ]),
        Column(
          spacing: 10,
          children: [
            for (final (i, choice) in q.choices.indexed)
              OptionButton(
                text: choice,
                letter: OptionState.letter(i),
                state: OptionState.resolve(
                  choice: choice,
                  answer: q.answer,
                  selection: widget.selection,
                  revealed: widget.isRevealed,
                ),
                isLocked: widget.isRevealed,
                onTap: () => widget.onSelection(choice),
              ),
          ],
        ),
        QuizColumnsView(
          first: q.pinyin,
          second: q.meaning,
          firstSelection: widget.pinyin,
          secondSelection: widget.meaning,
          onFirst: widget.onPinyin,
          onSecond: widget.onMeaning,
          isRevealed: widget.isRevealed,
        ),
      ],
    );
  }

  Widget _blank(BuildContext context) {
    final selection = widget.selection;
    final revealed = widget.isRevealed;
    final isOpen = selection == null && !revealed;
    final color = revealed ? context.successText : (selection == null ? context.mutedText : context.accent);
    return Semantics(
      label: 'Blank in the sentence',
      value: revealed ? widget.question.answer : (selection ?? 'Empty'),
      excludeSemantics: true,
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: revealed ? context.resolve(CupertinoColors.systemGreen) : context.accent,
          radius: ClozeWordCard.cornerRadius,
          dash: isOpen ? 5 : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            revealed ? widget.question.answer : (selection ?? '＿＿'),
            style: TextStyle(fontSize: ClozeWordCard.wordSize, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }

  /// Words get a card. Punctuation stays plain text.
  Widget _card(WordToken token) {
    if (!token.text.runes.any(isHanRune)) {
      return Text(token.text, style: const TextStyle(fontSize: ClozeWordCard.wordSize, fontWeight: FontWeight.w500));
    }
    return ClozeWordCard(
      token: token,
      showsHidden: _showingHidden.contains(token.id),
      onTap: () => setState(() {
        if (!_showingHidden.remove(token.id)) _showingHidden.add(token.id);
      }),
    );
  }
}

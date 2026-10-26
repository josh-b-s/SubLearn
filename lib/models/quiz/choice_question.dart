enum ChoiceDirection { chineseToEnglish, englishToChinese }

/// Level 1: pick the meaning of a word, or the word for a meaning.
class ChoiceQuestion {
  const ChoiceQuestion({
    required this.direction,
    required this.prompt,
    required this.hint,
    required this.choices,
    required this.answer,
    this.choicePinyin = const {},
  });

  final ChoiceDirection direction;

  /// The word or the meaning being asked about.
  final String prompt;

  /// Pinyin under a Chinese prompt, empty otherwise.
  final String hint;
  final List<String> choices;
  final String answer;

  /// Pinyin per choice, set when the choices are Chinese.
  final Map<String, String> choicePinyin;
}

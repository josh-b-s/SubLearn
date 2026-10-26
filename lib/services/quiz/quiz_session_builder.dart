import 'dart:math';

import '../../models/quiz/choice_question.dart';
import '../../models/quiz/cloze_sentence.dart';
import '../../models/quiz/quiz_question.dart';
import '../../models/saved_word.dart';
import '../dictionary/chinese_dictionary.dart';
import '../vocabulary/saved_word_mastery.dart';
import '../vocabulary/saved_word_review.dart';
import 'candidate.dart';
import 'choice_question_builder.dart';
import 'cloze_question_builder.dart';
import 'distractor_picker.dart';
import 'level_three_sentences.dart';
import 'pair_question_builder.dart';

typedef QuizBuild = ({List<QuizQuestion> questions, String? note});

/// Picks the words for a quiz and builds one question each at the word's level.
/// Falls back to an easier question type when a harder one can't be built.
class QuizSessionBuilder {
  QuizSessionBuilder({
    required this.allWords,
    required this.count,
    required this.dictionary,
    required this.sentenceSource,
    required this.now,
    Random? random,
  }) : _random = random ?? Random();

  final List<SavedWord> allWords;
  final int count;
  final ChineseDictionary? dictionary;
  final LevelThreeSentenceSource sentenceSource;
  final DateTime now;

  final Random _random;

  Future<QuizBuild> build() async {
    // Mastered words are never quizzed. Due words first, otherwise any active word.
    final pool = allWords.where((w) => !w.isMastered).toList();
    final due = pool.where((w) => w.isDue(now)).toList();
    final source = due.isEmpty ? pool : due;
    final chosen = (source.toList()..shuffle(_random)).take(count).toList();

    final picker = DistractorPicker(
      saved: allWords.map(Candidate.fromSaved).where((c) => c.meanings.isNotEmpty).toList(),
      dictionary: dictionary,
      random: _random,
    );
    final loaded = await sentenceSource.load(chosen);
    final levels = {for (final w in allWords.reversed) w.word: w.level};

    final questions = <QuizQuestion>[];
    for (final word in chosen) {
      final q = _question(word, picker, levels, loaded.sentences[word.word] ?? const []);
      if (q != null) questions.add(q);
    }
    return (questions: questions, note: loaded.note);
  }

  QuizQuestion? _question(
    SavedWord word,
    DistractorPicker picker,
    Map<String, int> levels,
    List<ClozeSentence> sentences,
  ) {
    // Each level asks two question types. The streak says which: 0 is the first, 1 the second.
    final second = word.levelStreak > 0;
    final dict = dictionary;
    if (word.level >= 3) {
      if (second && dict != null) {
        for (final sentence in sentences.toList()..shuffle(_random)) {
          final cloze = buildClozeQuestion(
            word: word,
            sentence: sentence,
            picker: picker,
            dictionary: dict,
            levels: levels,
          );
          if (cloze != null) return QuizQuestion(word: word.word, level: 3, kind: ClozeKind(cloze));
        }
      }
      if (!second) {
        final listening = buildPairQuestion(word, PairVariant.audio, picker);
        if (listening != null) return QuizQuestion(word: word.word, level: 3, kind: PairKind(listening));
      }
    }
    if (word.level >= 2) {
      final pair = buildPairQuestion(
        word,
        second ? PairVariant.meaningToWord : PairVariant.wordToMeaning,
        picker,
      );
      if (pair != null) return QuizQuestion(word: word.word, level: 2, kind: PairKind(pair));
    }
    final direction = second ? ChoiceDirection.englishToChinese : ChoiceDirection.chineseToEnglish;
    final choice = buildChoiceQuestion(word, direction, picker);
    return choice == null ? null : QuizQuestion(word: word.word, level: 1, kind: ChoiceKind(choice));
  }
}

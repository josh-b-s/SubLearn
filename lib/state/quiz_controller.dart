import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz/quiz_answer.dart';
import '../models/quiz/quiz_feedback.dart';
import '../models/quiz/quiz_question.dart';
import '../models/quiz/quiz_summary.dart';
import '../models/quiz_record.dart';
import '../models/review_log.dart';
import '../models/saved_word.dart';
import '../services/dictionary/chinese_dictionary.dart';
import '../services/learning/mastery.dart';
import '../services/quiz/level_three_sentences.dart';
import '../services/quiz/quiz_grader.dart';
import '../services/quiz/quiz_question_retry.dart';
import '../services/quiz/quiz_session_builder.dart';
import '../services/vocabulary/saved_word_mastery.dart';
import 'clock_provider.dart';
import 'core_providers.dart';
import 'dictionary_provider.dart';
import 'gemini_key_provider.dart';
import 'quiz_records_provider.dart';
import 'review_logs_provider.dart';
import 'settings_provider.dart';
import 'words_provider.dart';

enum QuizStage { idle, loading, answering, feedback, finished, error }

class QuizState {
  const QuizState({
    this.stage = QuizStage.idle,
    this.queue = const [],
    this.answered,
    this.total = 0,
    this.completed = 0,
    this.feedback,
    this.summary,
    this.error,
    this.note,
    this.selectedChoice,
    this.selectedFirst,
    this.selectedSecond,
    this.attempted = 0,
    this.correctFirstTry = 0,
    this.leveledUp = 0,
    this.mastered = 0,
  });

  final QuizStage stage;
  final List<QuizQuestion> queue;

  /// Stays on screen while its feedback shows.
  final QuizQuestion? answered;
  final int total;
  final int completed;
  final QuizFeedback? feedback;
  final QuizSummary? summary;
  final String? error;
  final String? note;
  final String? selectedChoice;
  final String? selectedFirst;
  final String? selectedSecond;

  // First-attempt tallies for the summary.
  final int attempted;
  final int correctFirstTry;
  final int leveledUp;
  final int mastered;

  QuizQuestion? get currentQuestion => queue.isEmpty ? null : queue.first;

  /// The question on screen: the one just answered while feedback shows, otherwise the next one.
  QuizQuestion? get shownQuestion => feedback == null ? currentQuestion : answered;

  bool get hasMoreQuestions => queue.isNotEmpty;

  /// True while a quiz is underway (question or feedback showing).
  bool get isInProgress => stage == QuizStage.answering || stage == QuizStage.feedback;

  /// Total stays constant: a miss moves a question to the back, it doesn't add one.
  int get progressIndex {
    final fb = feedback;
    final index = fb == null ? completed + 1 : (fb.correct ? completed : completed + 1);
    return min(max(index, 1), max(total, 1));
  }

  double get progressFraction => total == 0 ? 0 : completed / total;

  QuizAnswer? get currentAnswer {
    final question = currentQuestion;
    if (question == null) return null;
    return switch (question.kind) {
      PairKind() => selectedFirst != null && selectedSecond != null
          ? PairAnswer(first: selectedFirst!, second: selectedSecond!)
          : null,
      ClozeKind() => selectedChoice != null && selectedFirst != null && selectedSecond != null
          ? ClozeAnswer(word: selectedChoice!, pinyin: selectedFirst!, meaning: selectedSecond!)
          : null,
      ChoiceKind() => selectedChoice == null ? null : ChoiceAnswer(selectedChoice!),
    };
  }

  bool get canSubmit => currentAnswer != null;
}

class QuizController extends Notifier<QuizState> {
  QuizStage _stage = QuizStage.idle;
  List<QuizQuestion> _queue = [];
  QuizQuestion? _answered;
  int _total = 0;
  int _completed = 0;
  QuizFeedback? _feedback;
  QuizSummary? _summary;
  String? _error;
  String? _note;
  String? _choice;
  String? _first;
  String? _second;

  /// Start time of this run, which identifies its history entry.
  DateTime? _runDate;

  int _attempted = 0;
  int _correctFirstTry = 0;
  int _leveledUp = 0;
  int _mastered = 0;

  @override
  QuizState build() => const QuizState();

  DateTime get _now => ref.read(clockProvider)();

  Future<void> start() async {
    final words = ref.read(wordsProvider);
    if (words.isEmpty) return _fail('Save some words on the Translate tab first.');
    if (words.every((w) => w.isMastered)) {
      return _fail('Every saved word is mastered. Save more words to keep learning.');
    }

    _stage = QuizStage.loading;
    _publish();

    // The dictionary only supplies extra wrong options, so a failed load still allows a quiz.
    final dictionary =
        await ref.read(dictionaryProvider.future).then<ChineseDictionary?>((d) => d, onError: (_) => null);
    final apiKey = await ref.read(geminiKeyProvider.future);
    final built = await QuizSessionBuilder(
      allWords: words,
      count: ref.read(settingsProvider).questionsPerQuiz,
      dictionary: dictionary,
      sentenceSource: LevelThreeSentenceSource(cache: ref.read(clozeCacheProvider), apiKey: apiKey),
      now: _now,
    ).build();

    if (built.questions.isEmpty) return _fail("Couldn't build any questions. Try saving a few more words.");

    _resetRun();
    _queue = built.questions;
    _total = built.questions.length;
    _note = built.note;
    _stage = QuizStage.answering;
    _publish();
  }

  void selectChoice(String value) {
    _choice = value;
    _publish();
  }

  void selectFirst(String value) {
    _first = value;
    _publish();
  }

  void selectSecond(String value) {
    _second = value;
    _publish();
  }

  void submit() {
    final question = state.currentQuestion;
    final answer = state.currentAnswer;
    if (_stage != QuizStage.answering || question == null || answer == null) return;
    final correct = QuizGrader.isCorrect(question, answer);

    // Only the first attempt counts. Retries just have to be answered.
    String? levelNote;
    if (!question.isRetry) {
      final change = ref
          .read(wordsProvider.notifier)
          .recordAnswer(question.word, correct: correct, questionLevel: question.level);
      if (change != null) {
        final now = _now;
        ref.read(reviewLogsProvider.notifier).add(ReviewLog(word: question.word, correct: correct, date: now));
        levelNote = _levelNote(change.before, change.after);
        _tally(correct, change.before.level, change.after.level);
        _runDate ??= now;
        ref.read(quizRecordsProvider.notifier).append(
              _runDate!,
              QuizRecordItem(
                prompt: QuizGrader.promptText(question),
                answer: QuizGrader.answerText(question),
                correct: correct,
              ),
            );
      }
    }

    final asked = _queue.removeAt(0);
    _answered = asked;
    if (correct) {
      _completed++;
    } else {
      _queue.add(asked.asRetry());
    }
    _feedback = QuizFeedback(
      correct: correct,
      answerText: QuizGrader.answerText(asked),
      explanation: QuizGrader.explanation(asked),
      levelNote: levelNote,
    );
    _stage = QuizStage.feedback;
    _publish();
  }

  void next() {
    _choice = null;
    _first = null;
    _second = null;
    _feedback = null;
    if (_queue.isEmpty) {
      _summary = QuizSummary(
        attempted: _attempted,
        correctFirstTry: _correctFirstTry,
        leveledUp: _leveledUp,
        mastered: _mastered,
      );
      _stage = QuizStage.finished;
    } else {
      _stage = QuizStage.answering;
    }
    _publish();
  }

  void reset() {
    _queue = [];
    _answered = null;
    _total = 0;
    _choice = null;
    _first = null;
    _second = null;
    _note = null;
    _error = null;
    _summary = null;
    _feedback = null;
    _resetRun();
    _stage = QuizStage.idle;
    _publish();
  }

  void _fail(String message) {
    _error = message;
    _stage = QuizStage.error;
    _publish();
  }

  void _resetRun() {
    _runDate = null;
    _completed = 0;
    _attempted = 0;
    _correctFirstTry = 0;
    _leveledUp = 0;
    _mastered = 0;
    _summary = null;
    _feedback = null;
  }

  void _tally(bool correct, int before, int after) {
    _attempted++;
    if (correct) _correctFirstTry++;
    if (after > before) _leveledUp++;
    if (Mastery.isMastered(after) && !Mastery.isMastered(before)) _mastered++;
  }

  static String? _levelNote(SavedWord before, SavedWord after) {
    if (after.masteryScore < before.masteryScore) return 'Down to ${after.masteryLabel}.';
    if (after.level <= before.level) return null;
    return switch (after.level) {
      2 => 'Level 2. Cards will now hide its meaning.',
      3 => 'Level 3. Cards will now hide its pinyin too.',
      _ => "Mastered! It won't be quizzed again.",
    };
  }

  void _publish() {
    state = QuizState(
      stage: _stage,
      queue: List.unmodifiable(_queue),
      answered: _answered,
      total: _total,
      completed: _completed,
      feedback: _feedback,
      summary: _summary,
      error: _error,
      note: _note,
      selectedChoice: _choice,
      selectedFirst: _first,
      selectedSecond: _second,
      attempted: _attempted,
      correctFirstTry: _correctFirstTry,
      leveledUp: _leveledUp,
      mastered: _mastered,
    );
  }
}

final quizControllerProvider = NotifierProvider<QuizController, QuizState>(QuizController.new);

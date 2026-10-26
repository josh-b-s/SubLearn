import 'word_token.dart';

/// A vocabulary word the user saved.
class SavedWord {
  const SavedWord({
    required this.word,
    required this.pinyin,
    required this.meanings,
    required this.dateAdded,
    required this.dueDate,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.level = 1,
    this.levelStreak = 0,
    this.masteredDate,
  });

  factory SavedWord.fresh({
    required String word,
    required String pinyin,
    required List<String> meanings,
    required DateTime now,
  }) =>
      SavedWord(word: word, pinyin: pinyin, meanings: meanings, dateAdded: now, dueDate: now);

  final String word;
  final String pinyin;
  final List<String> meanings;
  final DateTime dateAdded;

  // SM-2 schedule
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime dueDate;

  /// Levels 1 to 3 are quizzed, 4 is mastered.
  final int level;
  final int levelStreak;

  /// Null if not mastered, or mastered before this was tracked.
  final DateTime? masteredDate;

  WordToken get token => WordToken(id: 0, text: word, pinyin: pinyin, meanings: meanings);

  SavedWord copyWith({
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    DateTime? dueDate,
    int? level,
    int? levelStreak,
    DateTime? masteredDate,
    bool clearMasteredDate = false,
  }) =>
      SavedWord(
        word: word,
        pinyin: pinyin,
        meanings: meanings,
        dateAdded: dateAdded,
        repetitions: repetitions ?? this.repetitions,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        dueDate: dueDate ?? this.dueDate,
        level: level ?? this.level,
        levelStreak: levelStreak ?? this.levelStreak,
        masteredDate: clearMasteredDate ? null : (masteredDate ?? this.masteredDate),
      );

  factory SavedWord.fromJson(Map<String, dynamic> json) => SavedWord(
        word: json['word'] as String,
        pinyin: json['pinyin'] as String,
        meanings: (json['meanings'] as List).cast<String>(),
        dateAdded: DateTime.parse(json['dateAdded'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        repetitions: json['repetitions'] as int,
        easeFactor: (json['easeFactor'] as num).toDouble(),
        intervalDays: json['intervalDays'] as int,
        level: json['level'] as int,
        levelStreak: json['levelStreak'] as int,
        masteredDate:
            json['masteredDate'] == null ? null : DateTime.parse(json['masteredDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'word': word,
        'pinyin': pinyin,
        'meanings': meanings,
        'dateAdded': dateAdded.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'repetitions': repetitions,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'level': level,
        'levelStreak': levelStreak,
        'masteredDate': masteredDate?.toIso8601String(),
      };
}

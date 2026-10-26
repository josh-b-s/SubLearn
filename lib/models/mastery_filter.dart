import '../services/learning/mastery.dart';

/// Vocabulary filter chips. Unlike MasteryStatus, levels 2 and 3 are separate.
enum MasteryFilter {
  newWord('New'),
  level2('Level 2'),
  level3('Level 3'),
  mastered('Mastered');

  const MasteryFilter(this.label);
  final String label;

  bool matches(int level) => switch (this) {
        newWord => level <= 1,
        level2 => level == 2,
        level3 => level == 3,
        mastered => Mastery.isMastered(level),
      };
}

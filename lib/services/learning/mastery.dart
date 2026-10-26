import 'dart:math' as math;

/// Pure level rules. Levels 1 to 3 are quizzed, level 4 is mastered and never quizzed again.
class MasteryState {
  const MasteryState(this.level, this.streak);

  final int level;
  final int streak;

  @override
  bool operator ==(Object other) =>
      other is MasteryState && other.level == level && other.streak == streak;

  @override
  int get hashCode => Object.hash(level, streak);

  @override
  String toString() => 'MasteryState($level, $streak)';
}

abstract final class Mastery {
  static const masteredLevel = 4;
  static const passesNeeded = 2;

  /// Steps lost on a miss. One step is one correct answer, so 1 means a miss undoes the last pass.
  static const missPenalty = 1;

  /// Distance between neighbouring scores: one pass.
  static const scoreStep = 1 / passesNeeded;

  /// Promote after [passesNeeded] correct answers in a row, lose [missPenalty] steps on a miss.
  static MasteryState next(MasteryState state, {required bool correct}) {
    if (state.level >= masteredLevel) return state;
    if (!correct) return _stateAtStep(_step(state) - missPenalty);

    final streak = state.streak + 1;
    if (streak >= passesNeeded) return MasteryState(state.level + 1, 0);
    return MasteryState(state.level, streak);
  }

  /// Level plus progress through it: level 2 with one pass is 2.5.
  static double score(int level, int streak) => level + streak * scoreStep;

  /// The level and streak a score stands for, snapped to the nearest step.
  static MasteryState stateForScore(double score) =>
      _stateAtStep(((score - 1) / scoreStep).round());

  /// "Level 2.5", or "Mastered" at the top.
  static String summaryForScore(double score) {
    final state = stateForScore(score);
    return isMastered(state.level) ? 'Mastered' : 'Level ${label(state.level, state.streak)}';
  }

  static String label(int level, int streak) {
    final value = score(level, streak);
    return value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  static int _step(MasteryState s) => (s.level - 1) * passesNeeded + s.streak;

  static MasteryState _stateAtStep(int step) {
    final clamped = math.min(math.max(step, 0), (masteredLevel - 1) * passesNeeded);
    return MasteryState(clamped ~/ passesNeeded + 1, clamped % passesNeeded);
  }

  /// SM-2 quality. Easier levels earn less so a lucky guess can't stretch the interval.
  static int quality(int level, {required bool correct}) {
    if (!correct) return 1;
    return switch (level) {
      1 => 3,
      2 => 4,
      _ => 5,
    };
  }

  static bool isMastered(int level) => level >= masteredLevel;

  /// Hints shown on word cards: meaning goes after level 1, pinyin after level 2.
  static bool showsMeaning(int level) => level < 2;
  static bool showsPinyin(int level) => level < 3;
}

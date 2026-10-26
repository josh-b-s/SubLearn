import 'dart:math' as math;

/// SM-2 spaced repetition. Quality: 1 = no idea, 3 = roughly right, 5 = got it.
class SrsState {
  const SrsState({required this.repetitions, required this.easeFactor, required this.intervalDays});

  final int repetitions;
  final double easeFactor;
  final int intervalDays;
}

abstract final class SpacedRepetition {
  static SrsState next(SrsState state, int quality) {
    var reps = state.repetitions;
    var interval = state.intervalDays;

    if (quality < 3) {
      reps = 0;
      interval = 1;
    } else {
      interval = switch (reps) {
        0 => 1,
        1 => 6,
        _ => math.max(1, (interval * state.easeFactor).round()),
      };
      reps += 1;
    }
    final q = quality.toDouble();
    final ef = math.max(1.3, state.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)));

    return SrsState(repetitions: reps, easeFactor: ef, intervalDays: interval);
  }
}

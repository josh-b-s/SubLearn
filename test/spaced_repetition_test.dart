import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/services/learning/spaced_repetition.dart';

void main() {
  const fresh = SrsState(repetitions: 0, easeFactor: 2.5, intervalDays: 0);

  test('first success is due tomorrow', () {
    final next = SpacedRepetition.next(fresh, 5);
    expect(next.repetitions, 1);
    expect(next.intervalDays, 1);
  });
  test('second success waits six days', () {
    expect(SpacedRepetition.next(SpacedRepetition.next(fresh, 5), 5).intervalDays, 6);
  });
  test('later intervals scale by ease factor', () {
    const state = SrsState(repetitions: 2, easeFactor: 2.6, intervalDays: 6);
    expect(SpacedRepetition.next(state, 5).intervalDays, 16);
  });
  test('failure resets repetitions and reviews tomorrow', () {
    const state = SrsState(repetitions: 5, easeFactor: 2.5, intervalDays: 30);
    final next = SpacedRepetition.next(state, 1);
    expect(next.repetitions, 0);
    expect(next.intervalDays, 1);
  });
  test('ease factor follows quality', () {
    expect(SpacedRepetition.next(fresh, 5).easeFactor, closeTo(2.6, 0.0001));
    expect(SpacedRepetition.next(fresh, 3).easeFactor, closeTo(2.36, 0.0001));
  });
  test('ease factor never drops below the floor', () {
    const state = SrsState(repetitions: 0, easeFactor: 1.3, intervalDays: 0);
    expect(SpacedRepetition.next(state, 1).easeFactor, 1.3);
  });
}

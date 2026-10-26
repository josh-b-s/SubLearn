import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_record.dart';
import 'core_providers.dart';

/// Quiz history, newest first.
class QuizRecordsNotifier extends Notifier<List<QuizRecord>> {
  static const _key = 'quizRecords';

  @override
  List<QuizRecord> build() => ref.read(jsonStoreProvider).readList(_key, QuizRecord.fromJson);

  /// Adds [item] to the run that started at [runDate], creating the run on its first answer.
  void append(DateTime runDate, QuizRecordItem item) {
    final index = state.indexWhere((r) => r.date == runDate);
    final next = [...state];
    if (index < 0) {
      next.insert(0, QuizRecord(date: runDate, items: [item]));
    } else {
      next[index] = next[index].withItem(item);
    }
    state = next;
    unawaited(ref.read(jsonStoreProvider).writeList(_key, next, (r) => r.toJson()));
  }
}

final quizRecordsProvider = NotifierProvider<QuizRecordsNotifier, List<QuizRecord>>(QuizRecordsNotifier.new);

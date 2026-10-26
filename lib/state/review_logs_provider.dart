import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_log.dart';
import 'core_providers.dart';

class ReviewLogsNotifier extends Notifier<List<ReviewLog>> {
  static const _key = 'reviewLogs';

  @override
  List<ReviewLog> build() => ref.read(jsonStoreProvider).readList(_key, ReviewLog.fromJson);

  void add(ReviewLog log) => _save([...state, log]);

  /// Deleting a word deletes its history too, so stats never count words that are gone.
  void removeWords(Set<String> words) => _save(state.where((l) => !words.contains(l.word)).toList());

  void _save(List<ReviewLog> logs) {
    state = logs;
    unawaited(ref.read(jsonStoreProvider).writeList(_key, logs, (l) => l.toJson()));
  }
}

final reviewLogsProvider = NotifierProvider<ReviewLogsNotifier, List<ReviewLog>>(ReviewLogsNotifier.new);

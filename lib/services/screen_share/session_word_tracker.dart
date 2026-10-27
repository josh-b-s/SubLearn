import '../../models/session/session_entry.dart';
import '../../models/word_token.dart';

/// Counts the words heard during one session.
class SessionWordTracker {
  final _counts = <String, SessionEntry>{};
  List<WordToken> _pending = [];

  List<SessionEntry> get entries => _counts.values.toList();

  /// Each partial replaces the last, so only a final result is counted.
  void update(List<WordToken> tokens, {required bool isFinal}) {
    _pending = tokens;
    if (isFinal) _commitPending();
  }

  /// Counts an unfinished last utterance. Call when the session ends.
  void flush() => _commitPending();

  void reset() {
    _counts.clear();
    _pending = [];
  }

  /// Words with no dictionary meaning are skipped, they can't be quizzed.
  void _commitPending() {
    for (final token in _pending.where((t) => t.meanings.isNotEmpty)) {
      final current = _counts[token.text] ?? SessionEntry(token: token, count: 0);
      _counts[token.text] = current.withCount(current.count + 1);
    }
    _pending = [];
  }
}

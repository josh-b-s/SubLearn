import 'session_entry.dart';

/// What the summary screen shows after a session.
class SessionSummary {
  const SessionSummary({
    required this.alreadyKnown,
    required this.learning,
    required this.newWords,
    required this.topWords,
    required this.unsavedTopWords,
  });

  final int alreadyKnown;
  final int learning;
  final int newWords;

  /// Most heard words that are not mastered, most heard first.
  final List<SessionEntry> topWords;

  /// Subset of [topWords] not saved yet. Saved before the review starts.
  final Set<String> unsavedTopWords;

  int get total => alreadyKnown + learning + newWords;
}

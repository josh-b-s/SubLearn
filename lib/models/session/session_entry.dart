import '../word_token.dart';

/// A word heard during a screen share session and how many times.
class SessionEntry {
  const SessionEntry({required this.token, required this.count});

  final WordToken token;
  final int count;

  SessionEntry withCount(int count) => SessionEntry(token: token, count: count);
}

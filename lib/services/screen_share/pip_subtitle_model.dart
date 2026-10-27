import '../../models/session/pip_line.dart';
import '../../models/word_token.dart';
import '../learning/mastery_redactor.dart';

/// Holds the lines shown in the subtitle panel and the PiP window.
class PipSubtitleModel {
  /// Cap on cards kept. The oldest whole lines are dropped past it.
  static const maxTokens = 40;

  List<PipLine> _committed = [];
  List<PipLine> _lines = [];
  int _nextId = 0;

  List<PipLine> get lines => _lines;

  /// [segment] is the current (possibly partial) utterance. When [isFinal], it becomes a finished
  /// line and the next utterance starts a new one.
  void update(
    List<WordToken> segment, {
    required bool isFinal,
    required Map<String, int> levels,
    required bool hideLearned,
  }) {
    if (segment.isEmpty) {
      _lines = _committed;
      return;
    }
    final shown = hideLearned ? MasteryRedactor.apply(segment, levels) : segment;
    final indexed = [for (final (i, t) in shown.indexed) t.copyWith(id: i)];
    _lines = [..._committed, PipLine(id: _nextId, tokens: indexed)];
    if (isFinal) {
      _committed = _trimmed(_lines);
      _lines = _committed;
      _nextId++;
    }
  }

  void clear() {
    _committed = [];
    _lines = [];
  }

  List<PipLine> _trimmed(List<PipLine> all) {
    final result = [...all];
    int count() => result.fold(0, (sum, line) => sum + line.tokens.length);
    while (result.length > 1 && count() > maxTokens) {
      result.removeAt(0);
    }
    return result;
  }
}

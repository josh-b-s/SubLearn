/// Appends [next] to [committed], adding a space only where two Latin words would run together.
String joinTranscript(String committed, String next) {
  if (committed.isEmpty || next.isEmpty) return committed + next;
  final needsSpace = _isLatinWordChar(committed.codeUnitAt(committed.length - 1)) && _isLatinWordChar(next.codeUnitAt(0));
  return needsSpace ? '$committed $next' : committed + next;
}

bool _isLatinWordChar(int unit) =>
    (unit >= 0x30 && unit <= 0x39) || (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);

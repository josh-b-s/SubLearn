/// The Chinese text heard in one session, one entry per finished utterance.
class SessionTranscript {
  const SessionTranscript({required this.startedAt, this.lines = const []});

  final DateTime startedAt;
  final List<String> lines;

  SessionTranscript withLine(String line) => SessionTranscript(startedAt: startedAt, lines: [...lines, line]);

  factory SessionTranscript.fromJson(Map<String, dynamic> json) => SessionTranscript(
        startedAt: DateTime.parse(json['startedAt'] as String),
        lines: (json['lines'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() => {'startedAt': startedAt.toIso8601String(), 'lines': lines};
}

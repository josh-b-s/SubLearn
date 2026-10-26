import '../../models/saved_word.dart';

/// A word as quiz material: a saved word or a dictionary entry used as a wrong option.
class Candidate {
  const Candidate({required this.word, required this.pinyin, required this.meanings});

  factory Candidate.fromSaved(SavedWord saved) =>
      Candidate(word: saved.word, pinyin: saved.pinyin, meanings: saved.meanings);

  final String word;
  final String pinyin;
  final List<String> meanings;

  /// Meaning as shown on answer buttons.
  String get meaningText => meanings.take(2).join(' · ');
}

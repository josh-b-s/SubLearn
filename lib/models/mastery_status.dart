/// Three-way grouping of levels used by the Vocabulary row badge.
enum MasteryStatus {
  newWord('New'),
  learning('Learning'),
  mastered('Mastered');

  const MasteryStatus(this.label);
  final String label;

  static MasteryStatus ofLevel(int level) {
    if (level <= 1) return newWord;
    if (level <= 3) return learning;
    return mastered;
  }
}

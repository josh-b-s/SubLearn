enum Tone { first, second, third, fourth }

const _marks = {
  Tone.first: 'āēīōūǖ',
  Tone.second: 'áéíóúǘ',
  Tone.third: 'ǎěǐǒǔǚ',
  Tone.fourth: 'àèìòùǜ',
};

/// The tone and position of the marked vowel in one pinyin syllable, or null when it has no mark.
({Tone tone, int index})? toneMark(String syllable) {
  final lower = syllable.toLowerCase();
  for (var i = 0; i < lower.length; i++) {
    for (final entry in _marks.entries) {
      if (entry.value.contains(lower[i])) return (tone: entry.key, index: i);
    }
  }
  return null;
}

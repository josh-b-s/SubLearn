import 'dart:ui' show Brightness, Color;

import '../../services/pinyin/pinyin_tone.dart';

/// Colour of the tone mark in pinyin. Only the marked vowel gets it, so the rest stays accent blue.
Color toneColor(Tone tone, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return switch (tone) {
    Tone.first => dark ? const Color(0xFF3FD0C9) : const Color(0xFF0E7F7A),
    Tone.second => dark ? const Color(0xFFFFA23A) : const Color(0xFFB35F00),
    Tone.third => dark ? const Color(0xFFFF7AA8) : const Color(0xFFC2255C),
    Tone.fourth => dark ? const Color(0xFFB79BFF) : const Color(0xFF7B44F6),
  };
}

import 'package:flutter/cupertino.dart';

/// The app's colours as light and dark pairs. Resolve them with `context.resolve`.
abstract final class AppPalette {
  static const background = CupertinoDynamicColor.withBrightness(color: Color(0xFFEEF2F9), darkColor: Color(0xFF0A0F1E));
  static const card = CupertinoDynamicColor.withBrightness(color: Color(0xFFFFFFFF), darkColor: Color(0xFF151B2E));
  static const chip = CupertinoDynamicColor.withBrightness(color: Color(0xFFE0E6F2), darkColor: Color(0xFF232B45));
  static const hairline = CupertinoDynamicColor.withBrightness(color: Color(0x1F0A0F1E), darkColor: Color(0x29EEF2F9));
  static const muted = CupertinoDynamicColor.withBrightness(color: Color(0xFF566079), darkColor: Color(0xFF93A0BC));
  /// The icon's blue. Dark mode uses a lighter blue so it stays readable on navy.
  static const accent = CupertinoDynamicColor.withBrightness(color: Color(0xFF1A6CFF), darkColor: Color(0xFF5AA2FF));

  /// The subtitle yellow, used to mark saved words.
  static const highlight = CupertinoDynamicColor.withBrightness(color: Color(0xFFFFC43D), darkColor: Color(0xFFFFD25E));
}

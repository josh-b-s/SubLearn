import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF0A84FF);

  static ThemeData light() => _build(Brightness.light, const Color(0xFFF2F2F7));
  static ThemeData dark() => _build(Brightness.dark, Colors.black);

  static ThemeData _build(Brightness brightness, Color background) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surfaceContainer),
    );
  }
}

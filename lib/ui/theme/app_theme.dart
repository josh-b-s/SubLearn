import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final _rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  static const _seed = Color(0xFF0A84FF);

  static ThemeData light() => _build(Brightness.light, const Color(0xFFF2F2F7));
  static ThemeData dark() => _build(Brightness.dark, Colors.black);

  static ThemeData _build(Brightness brightness, Color background) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      platform: TargetPlatform.iOS,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: _rounded, minimumSize: const Size(64, 48))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: _rounded, minimumSize: const Size(64, 48))),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Grouped-list surfaces and status colours that stay readable as text in light and dark.
extension AppColors on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get groupedBackground => _isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get cardBackground => _isDark ? const Color(0xFF1C1C1E) : Colors.white;
  Color get chipBackground => _isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
  Color get mutedText => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get accent => Theme.of(this).colorScheme.primary;

  Color get successText => _isDark ? const Color(0xFF30D158) : const Color(0xFF008033);
  Color get warningText => _isDark ? const Color(0xFFFF9F0A) : const Color(0xFFB35900);
  Color get errorText => _isDark ? const Color(0xFFFF453A) : const Color(0xFFCC1A1A);
}

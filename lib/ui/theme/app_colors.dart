import 'package:flutter/cupertino.dart';

/// iOS system colours, resolved for the current light or dark appearance.
extension AppColors on BuildContext {
  bool get _isDark => CupertinoTheme.brightnessOf(this) == Brightness.dark;

  /// Resolves a dynamic system colour such as [CupertinoColors.systemRed] for this context.
  Color resolve(Color color) => CupertinoDynamicColor.resolve(color, this);

  Color get groupedBackground => resolve(CupertinoColors.systemGroupedBackground);
  Color get cardBackground => resolve(CupertinoColors.secondarySystemGroupedBackground);
  Color get chipBackground => resolve(CupertinoColors.systemGrey5);
  Color get hairline => resolve(CupertinoColors.separator);
  Color get mutedText => resolve(CupertinoColors.secondaryLabel);
  Color get accent => CupertinoTheme.of(this).primaryColor;
  Color get destructive => resolve(CupertinoColors.systemRed);

  // Text-safe variants of the system colours, tuned for contrast on the grouped backgrounds.
  Color get successText => _isDark ? const Color(0xFF30D158) : const Color(0xFF008033);
  Color get warningText => _isDark ? const Color(0xFFFF9F0A) : const Color(0xFFB35900);
  Color get errorText => _isDark ? const Color(0xFFFF453A) : const Color(0xFFCC1A1A);
}

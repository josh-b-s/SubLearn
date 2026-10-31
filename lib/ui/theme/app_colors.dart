import 'package:flutter/cupertino.dart';

import 'app_palette.dart';

/// App colours, resolved for the current light or dark appearance.
extension AppColors on BuildContext {
  bool get _isDark => CupertinoTheme.brightnessOf(this) == Brightness.dark;

  /// Resolves a dynamic colour such as [CupertinoColors.systemRed] for this context.
  Color resolve(Color color) => CupertinoDynamicColor.resolve(color, this);

  Color get groupedBackground => resolve(AppPalette.background);
  Color get cardBackground => resolve(AppPalette.card);
  Color get chipBackground => resolve(AppPalette.chip);
  Color get hairline => resolve(AppPalette.hairline);
  Color get mutedText => resolve(AppPalette.muted);
  Color get accent => resolve(CupertinoTheme.of(this).primaryColor);
  Color get highlight => resolve(AppPalette.highlight);
  Color get destructive => resolve(CupertinoColors.systemRed);

  // Text-safe variants of the system colours, tuned for contrast on the card backgrounds.
  Color get successText => _isDark ? const Color(0xFF4ADE80) : const Color(0xFF1A7F45);
  Color get warningText => _isDark ? const Color(0xFFFFA23A) : const Color(0xFFA35500);
  Color get errorText => _isDark ? const Color(0xFFFF7A73) : const Color(0xFFCC1A1A);
}

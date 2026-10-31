import 'package:flutter/cupertino.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  /// A null [brightness] follows the system setting.
  static CupertinoThemeData of(Brightness? brightness) => CupertinoThemeData(
        brightness: brightness,
        primaryColor: AppPalette.accent,
        scaffoldBackgroundColor: AppPalette.background,
      );
}

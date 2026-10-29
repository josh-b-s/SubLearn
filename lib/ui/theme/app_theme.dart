import 'package:flutter/cupertino.dart';

abstract final class AppTheme {
  /// A null [brightness] follows the system setting.
  static CupertinoThemeData of(Brightness? brightness) => CupertinoThemeData(
        brightness: brightness,
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      );
}

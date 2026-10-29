import 'dart:ui' show Brightness;

enum AppearanceMode {
  system('System', null),
  light('Light', Brightness.light),
  dark('Dark', Brightness.dark);

  const AppearanceMode(this.title, this.brightness);
  final String title;

  /// Null follows the system setting.
  final Brightness? brightness;
}

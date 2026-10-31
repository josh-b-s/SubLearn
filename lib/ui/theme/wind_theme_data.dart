import 'dart:ui' show Brightness, Color;

import 'package:flutter/material.dart' show MaterialColor;
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

// Keep these hexes in step with app_palette.dart, which colours the Cupertino widgets.

/// The icon's blue. The primary colour.
const _brand = MaterialColor(0xFF1A6CFF, {
  50: Color(0xFFEAF2FF),
  100: Color(0xFFD6E6FF),
  300: Color(0xFF9CC4FF),
  400: Color(0xFF5AA2FF),
  500: Color(0xFF1A6CFF),
  600: Color(0xFF1257D6),
});

/// The icon's violet. The secondary colour, used in light mode only.
const _iris = MaterialColor(0xFF7B44F6, {
  400: Color(0xFF9B72FA),
  500: Color(0xFF7B44F6),
  600: Color(0xFF6A33E0),
});

/// Cool slate: paper and card in light mode, ink and deep navy in dark mode.
const _night = MaterialColor(0xFF566079, {
  50: Color(0xFFEEF2F9),
  100: Color(0xFFE0E6F2),
  400: Color(0xFF93A0BC),
  500: Color(0xFF566079),
  800: Color(0xFF232B45),
  900: Color(0xFF151B2E),
  950: Color(0xFF0A0F1E),
});

/// The subtitle yellow, used to mark saved words.
const _gold = MaterialColor(0xFFFFC43D, {
  300: Color(0xFFFFD25E),
  400: Color(0xFFFFC43D),
  700: Color(0xFFA35500),
});

final _colors = {'brand': _brand, 'iris': _iris, 'night': _night, 'gold': _gold};

// Wind only reads radii from this map, so these back `rounded-card` and the rest.
const _radii = {'card': 22.0, 'tile': 18.0, 'control': 14.0, 'chip': 10.0};

// One instance per mode, so WindTheme sees the same data until the appearance changes.
final _system = WindThemeData(colors: _colors, borderRadius: _radii);
final _light = WindThemeData(colors: _colors, borderRadius: _radii, brightness: Brightness.light, syncWithSystem: false);
final _dark = WindThemeData(colors: _colors, borderRadius: _radii, brightness: Brightness.dark, syncWithSystem: false);

/// A null [brightness] follows the system setting.
WindThemeData appWindTheme(Brightness? brightness) => switch (brightness) {
      null => _system,
      Brightness.light => _light,
      Brightness.dark => _dark,
    };

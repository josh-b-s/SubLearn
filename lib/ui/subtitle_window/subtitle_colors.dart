import 'package:flutter/cupertino.dart';

import '../theme/app_palette.dart';

/// Colours for the subtitle window and the in-app preview. Both follow the same light or dark look,
/// and they can't use `context.resolve` because the overlay runs outside the app's theme.
class SubtitleColors {
  const SubtitleColors._(this.brightness);

  factory SubtitleColors.of(Brightness brightness) => SubtitleColors._(brightness);

  final Brightness brightness;

  bool get _dark => brightness == Brightness.dark;

  Color _pick(CupertinoDynamicColor color) => _dark ? color.darkColor : color.color;

  Color get body => _pick(AppPalette.background);
  Color get bar => _pick(AppPalette.chip);
  Color get card => _pick(AppPalette.card);
  Color get border => _pick(AppPalette.hairline);
  Color get ink => _dark ? const Color(0xFFEEF2F9) : const Color(0xFF0A0F1E);
  Color get muted => _pick(AppPalette.muted);
}

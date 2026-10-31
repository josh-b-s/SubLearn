import 'package:flutter/cupertino.dart';

import '../theme/app_palette.dart';

/// Pinyin in the accent blue, like the line on the app icon's word card. Pass [brightness] where the surface ignores the app theme.
class Pinyin extends StatelessWidget {
  const Pinyin(this.text, {super.key, this.style, this.brightness});

  final String text;
  final TextStyle? style;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final dark = (brightness ?? CupertinoTheme.brightnessOf(context)) == Brightness.dark;
    final color = dark ? AppPalette.accent.darkColor : AppPalette.accent.color;
    return Text(text, style: (style ?? const TextStyle()).copyWith(color: color));
  }
}

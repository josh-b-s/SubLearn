import 'package:flutter/cupertino.dart';

/// iOS text styles at the default content size. They scale with the system text size setting.
extension AppText on BuildContext {
  TextStyle get _label => CupertinoTheme.of(this).textTheme.textStyle;

  TextStyle get title1 => _label.copyWith(fontSize: 28, letterSpacing: 0.36);
  TextStyle get title2 => _label.copyWith(fontSize: 22, letterSpacing: 0.35);
  TextStyle get title3 => _label.copyWith(fontSize: 20, letterSpacing: 0.38);
  TextStyle get headline => _label.copyWith(fontWeight: FontWeight.w600);
  TextStyle get body => _label;
  TextStyle get callout => _label.copyWith(fontSize: 16, letterSpacing: -0.32);
  TextStyle get subhead => _label.copyWith(fontSize: 15, letterSpacing: -0.24);
  TextStyle get footnote => _label.copyWith(fontSize: 13, letterSpacing: -0.08);
  TextStyle get caption1 => _label.copyWith(fontSize: 12, letterSpacing: 0);
  TextStyle get caption2 => _label.copyWith(fontSize: 11, letterSpacing: 0.07);
}

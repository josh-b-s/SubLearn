import 'package:flutter/material.dart';

enum AppearanceMode {
  system('System', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  const AppearanceMode(this.title, this.themeMode);
  final String title;
  final ThemeMode themeMode;
}

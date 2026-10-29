import 'package:flutter/cupertino.dart';

/// The lines on the progress chart. Colours are dynamic, so resolve them with `context.resolve`.
enum ProgressSeries {
  learned('Learned', CupertinoColors.systemBlue),
  saved('Saved', CupertinoColors.systemOrange),
  mastered('Mastered', CupertinoColors.systemGreen);

  const ProgressSeries(this.label, this.color);
  final String label;
  final CupertinoDynamicColor color;
}

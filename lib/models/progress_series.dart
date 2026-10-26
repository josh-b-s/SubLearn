import 'package:flutter/material.dart';

/// The lines on the progress chart.
enum ProgressSeries {
  learned('Learned', Colors.blue),
  saved('Saved', Colors.orange),
  mastered('Mastered', Colors.green);

  const ProgressSeries(this.label, this.color);
  final String label;
  final Color color;
}

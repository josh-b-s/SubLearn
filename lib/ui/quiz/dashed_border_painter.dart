import 'package:flutter/material.dart';

/// Rounded rectangle outline, optionally dashed.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 2,
    this.dash,
    this.gap = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  /// Dash length. Null draws a solid line.
  final double? dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final inset = strokeWidth / 2;
    final outline = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth),
        Radius.circular(radius),
      ));
    final dashLength = dash;
    if (dashLength == null) return canvas.drawPath(outline, paint);

    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += dashLength + gap) {
        canvas.drawPath(metric.extractPath(start, (start + dashLength).clamp(0, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      color != old.color || radius != old.radius || strokeWidth != old.strokeWidth || dash != old.dash || gap != old.gap;
}

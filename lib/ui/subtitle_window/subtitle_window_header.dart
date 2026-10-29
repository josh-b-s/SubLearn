import 'package:flutter/material.dart';

/// What a drag on the title bar does. The host decides how to move or resize its window.
enum SubtitleWindowGesture { move, resize }

/// Title bar of the floating window. Left: resize. Middle: move. Right: back to the app.
class SubtitleWindowHeader extends StatelessWidget {
  const SubtitleWindowHeader({
    super.key,
    required this.onGestureStart,
    required this.onGestureUpdate,
    required this.onGestureEnd,
    required this.onOpenApp,
  });

  final ValueChanged<SubtitleWindowGesture> onGestureStart;

  /// Finger movement since the last update, in the window's own coordinates. A host that moves
  /// the window under the finger can't use it and tracks the pointer itself.
  final void Function(SubtitleWindowGesture gesture, Offset delta) onGestureUpdate;
  final VoidCallback onGestureEnd;
  final VoidCallback onOpenApp;

  static const height = 36.0;
  static const _background = Color(0xFFD9D9D9);
  static const _ink = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: _background,
      child: Row(
        children: [
          _dragArea(
            SubtitleWindowGesture.resize,
            label: 'Resize subtitle window',
            width: 44,
            child: const CustomPaint(size: Size(18, 18), painter: _ResizeGlyphPainter(_ink)),
          ),
          Expanded(
            child: _dragArea(
              SubtitleWindowGesture.move,
              label: 'Move subtitle window',
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0x33000000), borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Open Subtitle Learn',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onOpenApp,
              child: const SizedBox(width: 44, height: height, child: Icon(Icons.open_in_new, size: 20, color: _ink)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dragArea(SubtitleWindowGesture gesture, {required String label, required Widget child, double? width}) {
    return Semantics(
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => onGestureStart(gesture),
        onPanUpdate: (details) => onGestureUpdate(gesture, details.delta),
        onPanEnd: (_) => onGestureEnd(),
        onPanCancel: onGestureEnd,
        child: SizedBox(width: width, height: height, child: Center(child: child)),
      ),
    );
  }
}

/// Two parallel diagonal strokes, the resize mark in the design.
class _ResizeGlyphPainter extends CustomPainter {
  const _ResizeGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.55), Offset(size.width * 0.55, size.height * 0.15), paint);
    canvas.drawLine(Offset(size.width * 0.45, size.height * 0.85), Offset(size.width * 0.85, size.height * 0.45), paint);
  }

  @override
  bool shouldRepaint(_ResizeGlyphPainter old) => old.color != color;
}

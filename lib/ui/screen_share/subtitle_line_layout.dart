import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Flows cards left to right and starts a new row at each subtitle line.
/// Only the last [maxRows] rows are visible, so a full panel scrolls a whole row at a time.
class SubtitleLineLayout extends StatelessWidget {
  const SubtitleLineLayout({
    super.key,
    required this.children,
    required this.lineStarts,
    this.spacing = 8,
    this.maxRows = 2,
  });

  final List<Widget> children;

  /// One flag per child: true when that card begins a new subtitle line.
  final List<bool> lineStarts;
  final double spacing;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomMultiChildLayout(
        delegate: _Delegate(lineStarts: lineStarts, spacing: spacing, maxRows: maxRows),
        children: [for (final (i, child) in children.indexed) LayoutId(id: i, child: child)],
      ),
    );
  }
}

class _Delegate extends MultiChildLayoutDelegate {
  _Delegate({required this.lineStarts, required this.spacing, required this.maxRows});

  final List<bool> lineStarts;
  final double spacing;
  final int maxRows;

  @override
  void performLayout(Size size) {
    final rows = <_Row>[];
    var current = _Row(y: 0);
    var x = 0.0;

    for (var i = 0; i < lineStarts.length; i++) {
      final childSize = layoutChild(i, BoxConstraints.loose(Size(size.width, double.infinity)));
      final breaks = lineStarts[i] || x + childSize.width > size.width;
      if (current.items.isNotEmpty && breaks) {
        rows.add(current);
        current = _Row(y: current.y + current.height + spacing);
        x = 0;
      }
      current.items.add((index: i, x: x));
      current.height = current.height > childSize.height ? current.height : childSize.height;
      x += childSize.width + spacing;
    }
    if (current.items.isNotEmpty) rows.add(current);

    // Hidden rows sit above the top edge.
    final visibleFrom = rows.length > maxRows ? rows.length - maxRows : 0;
    final shift = rows.isEmpty ? 0.0 : rows[visibleFrom].y;
    for (final row in rows) {
      for (final item in row.items) {
        positionChild(item.index, Offset(item.x, row.y - shift));
      }
    }
  }

  @override
  bool shouldRelayout(_Delegate old) =>
      spacing != old.spacing || maxRows != old.maxRows || !listEquals(lineStarts, old.lineStarts);
}

class _Row {
  _Row({required this.y});

  final double y;
  double height = 0;
  final items = <({int index, double x})>[];
}

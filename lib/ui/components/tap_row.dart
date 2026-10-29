import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// List row that highlights while pressed, like a table view cell.
class TapRow extends StatefulWidget {
  const TapRow({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<TapRow> createState() => _TapRowState();
}

class _TapRowState extends State<TapRow> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: ColoredBox(
        color: _pressed ? context.resolve(CupertinoColors.systemGrey4) : context.cardBackground,
        child: widget.child,
      ),
    );
  }
}

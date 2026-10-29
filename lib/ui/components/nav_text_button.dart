import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Text button for a navigation bar, such as Done or Cancel. A null [onPressed] greys it out.
class NavTextButton extends StatelessWidget {
  const NavTextButton({super.key, required this.label, required this.onPressed, this.bold = false, this.destructive = false});

  final String label;
  final VoidCallback? onPressed;
  final bool bold;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: destructive && onPressed != null ? context.destructive : null,
        ),
      ),
    );
  }
}

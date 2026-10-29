import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Borderless icon button in the iOS style. A null [onPressed] greys it out.
class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 24,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  /// Tinted circle behind the icon, for a standalone action such as playing a word.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final tint = context.accent;
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      excludeSemantics: true,
      onTap: onPressed,
      child: CupertinoButton(
        padding: EdgeInsets.all(filled ? 10 : 8),
        color: filled ? tint.withValues(alpha: 0.14) : null,
        borderRadius: BorderRadius.circular(size * 2),
        onPressed: onPressed,
        child: Icon(icon, size: size, color: onPressed == null ? null : tint),
      ),
    );
  }
}

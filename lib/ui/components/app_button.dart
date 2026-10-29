import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

enum AppButtonStyle { filled, destructive, tinted }

/// iOS button with a rounded fill. A null [onPressed] greys it out.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.filled,
    this.expand = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonStyle style;

  /// Stretches to the full width of the parent.
  final bool expand;

  /// Shows a spinner in place of the icon.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final base = style == AppButtonStyle.destructive ? context.destructive : context.accent;
    final tinted = style == AppButtonStyle.tinted;
    final enabled = onPressed != null;
    final foreground = !enabled
        ? context.resolve(CupertinoColors.tertiaryLabel)
        : (tinted ? base : CupertinoColors.white);

    final button = CupertinoButton(
      color: tinted ? base.withValues(alpha: 0.15) : base,
      disabledColor: context.resolve(CupertinoColors.tertiarySystemFill),
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      onPressed: onPressed,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (busy) CupertinoActivityIndicator(color: foreground) else if (icon != null) icon!,
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

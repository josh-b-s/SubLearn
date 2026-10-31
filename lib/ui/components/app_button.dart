import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

enum AppButtonStyle { filled, destructive, tinted }

/// Rounded button. A null [onPressed] greys it out.
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
  final IconData? icon;
  final AppButtonStyle style;

  /// Stretches to the full width of the parent.
  final bool expand;

  /// Shows a spinner in place of the icon.
  final bool busy;

  static const _disabled = 'disabled:bg-night-100 dark:disabled:bg-night-800';
  static const _disabledText = 'disabled:text-night-400';

  @override
  Widget build(BuildContext context) {
    final (surface, text) = switch (style) {
      AppButtonStyle.filled => ('bg-brand-500 dark:bg-brand-400', 'text-white dark:text-night-950'),
      AppButtonStyle.destructive => ('bg-red-600 dark:bg-red-500', 'text-white'),
      AppButtonStyle.tinted => ('bg-brand-500/15 dark:bg-brand-400/20', 'text-brand-500 dark:text-brand-400'),
    };
    final textClass = '$text $_disabledText';
    return WButton(
      onTap: onPressed,
      disabled: onPressed == null,
      semanticLabel: label,
      className:
          'flex flex-row items-center justify-center gap-2 px-5 py-[14px] rounded-control ${expand ? 'w-full' : ''} $surface $_disabled',
      child: WDiv(
        className: 'flex flex-row items-center justify-center gap-2',
        children: [
          if (busy) const CupertinoActivityIndicator() else if (icon != null) WIcon(icon!, className: 'text-xl $textClass'),
          WText(label, className: 'text-[17px] font-semibold text-center $textClass'),
        ],
      ),
    );
  }
}

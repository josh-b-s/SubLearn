import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// Capsule toggle used for filters. Reads as a selectable button to screen readers.
class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.selected, required this.onTap, this.hint, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? hint;
  final IconData? icon;

  static const _on = 'bg-brand-500 dark:bg-brand-400';
  static const _onText = 'text-white dark:text-night-950';
  static const _off = 'bg-night-100 dark:bg-night-800';

  @override
  Widget build(BuildContext context) {
    final text = selected ? _onText : inkTextClass;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      hint: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: WDiv(
          className: 'flex flex-row items-center justify-center gap-[6px] min-h-[36px] px-[14px] rounded-full ${selected ? _on : _off}',
          children: [
            if (icon != null) WIcon(icon!, className: 'text-base $text'),
            WText(label, className: 'text-[15px] font-medium $text'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Capsule toggle used for filters. Reads as a selectable button to screen readers.
class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.selected, required this.onTap, this.hint, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : context.chipBackground,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
            if (icon != null) Icon(icon, size: 16, color: selected ? scheme.onPrimary : scheme.onSurface),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: selected ? scheme.onPrimary : scheme.onSurface),
            ),
          ]),
        ),
      ),
    );
  }
}

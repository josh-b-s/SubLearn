import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A small number with a label underneath.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label, this.detail, this.accent});

  final String value;
  final String label;
  final String? detail;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: label,
      value: [value, detail].whereType<String>().join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: context.cardBackground, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, maxLines: 1, style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: accent)),
            ),
            Text(label, style: text.bodySmall?.copyWith(color: context.mutedText)),
            if (detail != null) Text(detail!, style: text.labelSmall?.copyWith(color: context.mutedText)),
          ],
        ),
      ),
    );
  }
}

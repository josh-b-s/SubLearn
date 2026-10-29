import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// A small number with a label underneath.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label, this.detail, this.accent});

  final String value;
  final String label;
  final String? detail;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: [value, detail].whereType<String>().join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.cardBackground, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, maxLines: 1, style: context.title2.copyWith(fontWeight: FontWeight.bold, color: accent)),
            ),
            Text(label, style: context.footnote.copyWith(color: context.mutedText)),
            if (detail != null) Text(detail!, style: context.caption2.copyWith(color: context.mutedText)),
          ],
        ),
      ),
    );
  }
}

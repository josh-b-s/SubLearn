import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Inset grouped list: optional small-caps title, rounded card of rows, optional footnote.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, this.title, required this.children, this.footer});

  final String? title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 6),
              child: Text(title!.toUpperCase(), style: text.bodySmall?.copyWith(color: context.mutedText)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const Divider(height: 1, thickness: 0.5, indent: 16),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 32, 0),
              child: Text(footer!, style: text.bodySmall?.copyWith(color: context.mutedText)),
            ),
        ],
      ),
    );
  }
}

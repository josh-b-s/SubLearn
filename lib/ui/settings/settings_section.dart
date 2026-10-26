import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Titled group of settings with an optional footnote.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(title.toUpperCase(), style: text.labelMedium?.copyWith(color: context.mutedText, fontWeight: FontWeight.w600)),
        ),
        ...children,
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(footer!, style: text.bodySmall?.copyWith(color: context.mutedText)),
          ),
      ],
    );
  }
}

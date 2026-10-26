import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small uppercase heading used above groups of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.mutedText,
            ),
      ),
    );
  }
}

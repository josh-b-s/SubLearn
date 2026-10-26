import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded card that holds the question prompt.
class QuizPromptCard extends StatelessWidget {
  const QuizPromptCard({super.key, required this.children, this.alignment = CrossAxisAlignment.center});

  final List<Widget> children;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: alignment, spacing: 8, children: children),
    );
  }
}

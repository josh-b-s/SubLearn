import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Centered icon, title and explanation, with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.description, this.action});

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.mutedText),
            const SizedBox(height: 12),
            Text(title, style: context.title2.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(description!, style: context.subhead.copyWith(color: context.mutedText), textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

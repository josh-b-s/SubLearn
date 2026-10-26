import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'onboarding_page.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Icon(page.icon, size: 72, color: context.accent),
          Text(page.title, textAlign: TextAlign.center, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(page.text, textAlign: TextAlign.center, style: text.bodyLarge),
          if (page.note != null)
            Text(page.note!, textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: context.mutedText)),
        ],
      ),
    );
  }
}

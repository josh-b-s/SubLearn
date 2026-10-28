import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'onboarding_page.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Scrolls so large font sizes still fit.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        spacing: 20,
        children: [
          ExcludeSemantics(child: Icon(page.icon, size: 72, color: context.accent)),
          Semantics(
            header: true,
            child: Text(page.title, textAlign: TextAlign.center, style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Text(page.text, textAlign: TextAlign.center, style: text.bodyLarge?.copyWith(color: context.mutedText)),
          if (page.note != null)
            Text(
              page.note!,
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: context.accent, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
}

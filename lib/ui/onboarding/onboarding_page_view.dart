import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';
import 'onboarding_page.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    // Scrolls so large font sizes still fit.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: WDiv(
        className: 'flex flex-col items-center gap-5',
        children: [
          ExcludeSemantics(
            child: WDiv(
              className: 'flex items-center justify-center size-28 rounded-card bg-iris-500/10 dark:bg-brand-400/15',
              child: WIcon(page.icon, className: 'text-[56px] text-iris-500 dark:text-brand-400'),
            ),
          ),
          Semantics(
            header: true,
            child: WText(page.title, className: 'text-[28px] font-bold text-center $inkTextClass'),
          ),
          WText(page.text, className: 'text-[17px] text-center $mutedTextClass'),
          if (page.note != null)
            WText(page.note!, className: 'text-[13px] font-medium text-center text-brand-500 dark:text-brand-400'),
        ],
      ),
    );
  }
}

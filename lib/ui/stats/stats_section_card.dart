import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';

/// Titled card used for each section of the stats screen.
class StatsSectionCard extends StatelessWidget {
  const StatsSectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: context.cardBackground, borderRadius: BorderRadius.all(cardRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.subhead.copyWith(fontWeight: FontWeight.w600)),
          ),
          child,
        ],
      ),
    );
  }
}

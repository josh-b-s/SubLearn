import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';
import 'hairline.dart';

/// Inset grouped list: optional small-caps title, rounded card of rows, optional footnote.
class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, this.title, required this.children, this.footer, this.dividerIndent = 24});

  final String? title;
  final List<Widget> children;
  final String? footer;

  /// Where the divider between rows starts. Increase it for rows with a leading icon.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 32, 6),
              child: Text(title!.toUpperCase(), style: context.footnote.copyWith(color: context.mutedText)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(cardRadius),
              child: ColoredBox(
                color: context.cardBackground,
                child: Column(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) Hairline(indent: dividerIndent),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 6, 32, 0),
              child: Text(footer!, style: context.footnote.copyWith(color: context.mutedText)),
            ),
        ],
      ),
    );
  }
}

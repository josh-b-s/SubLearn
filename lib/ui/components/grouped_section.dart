import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';
import 'hairline.dart';

/// Inset grouped list: optional title, rounded card of rows, optional footnote.
class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, this.title, required this.children, this.footer, this.dividerIndent = 24});

  final String? title;
  final List<Widget> children;
  final String? footer;

  /// Where the divider between rows starts. Increase it for rows with a leading icon.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return WDiv(
      className: 'flex flex-col items-stretch pt-5',
      children: [
        if (title != null)
          WDiv(
            className: 'pl-10 pr-8 pb-[6px]',
            child: WText(title!, className: 'text-[13px] font-semibold $mutedTextClass'),
          ),
        WDiv(
          className: 'mx-4 overflow-hidden $cardClass',
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Hairline(indent: dividerIndent),
              children[i],
            ],
          ],
        ),
        if (footer != null)
          WDiv(
            className: 'pl-10 pr-8 pt-[6px]',
            child: WText(footer!, className: 'text-[13px] $mutedTextClass'),
          ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Root tab page: a large title that collapses as the content scrolls. [bottom] stays pinned under the scroll view.
class LargeTitlePage extends StatelessWidget {
  const LargeTitlePage({
    super.key,
    required this.title,
    required this.slivers,
    this.leading,
    this.trailing,
    this.bottom,
    this.controller,
  });

  final String title;
  final List<Widget> slivers;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: controller,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: Text(title),
                  leading: leading,
                  trailing: trailing,
                  automaticallyImplyLeading: false,
                  // All tabs stay in the tree at once, so their bars can't share one hero.
                  transitionBetweenRoutes: false,
                  backgroundColor: context.groupedBackground.withValues(alpha: 0.85),
                ),
                ...slivers,
              ],
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}

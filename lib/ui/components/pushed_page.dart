import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Page pushed from a tab: small centred title, back button labelled with the previous page.
class PushedPage extends StatelessWidget {
  const PushedPage({
    super.key,
    required this.title,
    required this.child,
    this.backLabel,
    this.leading,
    this.trailing,
    this.showsBackButton = true,
    this.safeBottom = true,
  });

  final String title;
  final Widget child;

  /// Title of the page this one was opened from.
  final String? backLabel;
  final Widget? leading;
  final Widget? trailing;
  final bool showsBackButton;

  /// Keeps [child] clear of the home indicator. Turn off when the child pads itself.
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        previousPageTitle: backLabel,
        leading: leading,
        trailing: trailing,
        automaticallyImplyLeading: showsBackButton,
        // Opaque, so the page is laid out below the bar and needs no top inset of its own.
        backgroundColor: context.groupedBackground,
      ),
      child: safeBottom ? SafeArea(top: false, child: child) : child,
    );
  }
}

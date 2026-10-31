import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

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
      child: WDiv(
        className: 'flex flex-col items-center gap-2 p-8',
        children: [
          WIcon(icon, className: 'text-[48px] $mutedTextClass'),
          WText(title, className: 'text-[22px] font-bold text-center'),
          if (description != null) WText(description!, className: 'text-[15px] text-center $mutedTextClass'),
          if (action != null) action!,
        ],
      ),
    );
  }
}

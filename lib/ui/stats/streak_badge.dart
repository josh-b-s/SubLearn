import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// Flame and day count. Grey when there is no streak.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    final surface = active ? 'bg-gold-400 dark:bg-gold-300' : 'bg-night-100 dark:bg-night-800';
    final text = active ? 'text-night-950' : mutedTextClass;
    final label = '$days day${days == 1 ? '' : 's'}';
    return Semantics(
      label: 'Streak',
      value: label,
      excludeSemantics: true,
      child: WDiv(
        className: 'flex flex-row items-center gap-[6px] px-3 py-[6px] rounded-full $surface',
        children: [
          WIcon(CupertinoIcons.flame_fill, className: 'text-lg $text'),
          WText(label, className: 'font-bold $text'),
        ],
      ),
    );
  }
}

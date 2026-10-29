import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Flame and day count. Grey when there is no streak.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final active = days > 0;
    final color = active ? CupertinoColors.black : context.mutedText;
    final label = '$days day${days == 1 ? '' : 's'}';
    return Semantics(
      label: 'Streak',
      value: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? context.resolve(CupertinoColors.systemOrange) : context.chipBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(CupertinoIcons.flame_fill, size: 18, color: color),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

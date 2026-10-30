import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Thin rounded progress bar, like UIProgressView.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 4, this.color});

  /// 0 to 1.
  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ColoredBox(
          color: context.chipBackground,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: color ?? context.accent),
          ),
        ),
      ),
    );
  }
}
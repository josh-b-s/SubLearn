import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

/// Thin rounded progress bar, like UIProgressView. Pass a [fillClass] to colour the fill.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.fillClass = 'bg-brand-500 dark:bg-brand-400',
  });

  /// 0 to 1.
  final double value;
  final double height;
  final String fillClass;

  @override
  Widget build(BuildContext context) {
    return WDiv(
      className: 'w-full h-[${height.round()}px] rounded-full overflow-hidden bg-night-100 dark:bg-night-800',
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: WDiv(className: 'h-full $fillClass'),
      ),
    );
  }
}

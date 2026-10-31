import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// One-pixel separator line, the way iOS draws list dividers.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0});

  /// Space left of the line, so it lines up with the text instead of the row edge.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent),
      child: const WDiv(className: 'w-full h-px $hairlineClass'),
    );
  }
}

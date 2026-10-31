import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// Small heading used above groups of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: WText(text, className: 'text-[13px] font-semibold $mutedTextClass'),
    );
  }
}

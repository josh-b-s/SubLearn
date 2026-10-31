import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// Titled card used for each section of the stats screen.
class StatsSectionCard extends StatelessWidget {
  const StatsSectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WDiv(
      className: 'flex flex-col items-start gap-3 w-full p-5 $cardClass',
      children: [
        Semantics(
          header: true,
          child: WText(title, className: 'text-[15px] font-semibold $inkTextClass'),
        ),
        child,
      ],
    );
  }
}

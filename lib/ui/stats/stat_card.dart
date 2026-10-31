import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// A small number with a label underneath. Pass [valueClass] to colour the number.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label, this.detail, this.valueClass = inkTextClass});

  final String value;
  final String label;
  final String? detail;
  final String valueClass;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: [value, detail].whereType<String>().join(', '),
      excludeSemantics: true,
      child: WDiv(
        className: 'flex flex-col items-start p-[18px] $cardClass',
        children: [
          WText(value, className: 'text-[28px] font-bold truncate $valueClass'),
          WText(label, className: 'text-[13px] $mutedTextClass'),
          if (detail != null) WText(detail!, className: 'text-[11px] $mutedTextClass'),
        ],
      ),
    );
  }
}

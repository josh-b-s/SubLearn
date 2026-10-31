import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../theme/wind_classes.dart';

/// Rounded card that holds the question prompt.
class QuizPromptCard extends StatelessWidget {
  const QuizPromptCard({super.key, required this.children, this.alignment = CrossAxisAlignment.center});

  final List<Widget> children;

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final items = alignment == CrossAxisAlignment.start ? 'items-start' : 'items-center';
    return WDiv(className: 'flex flex-col $items gap-2 w-full p-6 $cardClass', children: children);
  }
}

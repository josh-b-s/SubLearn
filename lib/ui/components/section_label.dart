import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Small uppercase heading used above groups of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: context.footnote.copyWith(color: context.mutedText)),
    );
  }
}

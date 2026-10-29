import 'package:flutter/cupertino.dart';

import '../../models/char_gloss.dart';
import '../theme/app_colors.dart';
import 'section_label.dart';

/// Per-character meanings for the word detail sheet.
class CharacterBreakdown extends StatelessWidget {
  const CharacterBreakdown({super.key, required this.glosses});

  final List<CharGloss> glosses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('CHARACTERS'),
        const SizedBox(height: 8),
        for (final gloss in glosses)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(gloss.char, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Text(gloss.pinyin, style: TextStyle(color: context.accent)),
                const SizedBox(width: 10),
                Expanded(child: Text(gloss.meaning, style: TextStyle(color: context.mutedText))),
              ],
            ),
          ),
      ],
    );
  }
}

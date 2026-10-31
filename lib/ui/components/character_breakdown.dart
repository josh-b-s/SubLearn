import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/char_gloss.dart';
import '../theme/wind_classes.dart';
import 'section_label.dart';
import 'pinyin.dart';

/// Per-character meanings for the word detail sheet.
class CharacterBreakdown extends StatelessWidget {
  const CharacterBreakdown({super.key, required this.glosses});

  final List<CharGloss> glosses;

  @override
  Widget build(BuildContext context) {
    return WDiv(
      className: 'flex flex-col items-start gap-2',
      children: [
        const SectionLabel('Characters'),
        for (final gloss in glosses)
          WDiv(
            className: 'flex flex-row items-baseline gap-[10px]',
            children: [
              WText(gloss.char, className: 'text-[22px] font-semibold $inkTextClass'),
              Pinyin(gloss.pinyin),
              WDiv(className: 'flex-1', child: WText(gloss.meaning, className: mutedTextClass)),
            ],
          ),
      ],
    );
  }
}

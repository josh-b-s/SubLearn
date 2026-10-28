import 'package:flutter/material.dart';

import '../../models/dictionary_match.dart';
import '../theme/app_colors.dart';

/// One dictionary hit: word, pinyin, meanings, with badges for custom and saved words.
class DictionaryResultRow extends StatelessWidget {
  const DictionaryResultRow({super.key, required this.match, required this.isSaved, this.isSelected = false});

  final DictionaryMatch match;
  final bool isSaved;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      value: [if (isSaved) 'Saved', if (isSelected) 'Selected'].join(', '),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(match.word, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(match.entry.pinyin, style: text.bodyMedium?.copyWith(color: context.mutedText)),
                      if (match.isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Custom', style: text.labelSmall?.copyWith(color: context.accent, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  Text(
                    match.entry.meanings.join(' · '),
                    style: text.bodyMedium?.copyWith(color: context.mutedText),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.accent)
            else if (isSaved)
              Icon(Icons.bookmark, size: 16, color: context.accent),
          ],
        ),
      ),
    );
  }
}

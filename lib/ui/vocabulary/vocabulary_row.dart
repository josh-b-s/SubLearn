import 'package:flutter/material.dart';

import '../../models/mastery_status.dart';
import '../../models/saved_word.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../theme/app_colors.dart';
import 'mastery_status_color.dart';

/// One saved word: mastery badge, word, pinyin, meanings.
class VocabularyRow extends StatelessWidget {
  const VocabularyRow({super.key, required this.word, this.isPicked});

  final SavedWord word;

  /// Set while choosing words to delete, null otherwise.
  final bool? isPicked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = MasteryStatus.ofLevel(word.level);
    final picked = isPicked;
    return Semantics(
      value: status == MasteryStatus.mastered ? status.label : '${status.label}, level ${word.masteryLabel}',
      selected: picked == true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (picked != null) ...[
              Icon(picked ? Icons.check_circle : Icons.circle_outlined, color: picked ? context.accent : context.mutedText),
              const SizedBox(width: 12),
            ],
            _Badge(status: status, label: word.masteryLabel),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: word.word, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    TextSpan(text: '  ${word.pinyin}', style: text.bodyMedium?.copyWith(color: context.mutedText)),
                  ])),
                  Text(
                    word.meanings.isEmpty ? 'No definition' : word.meanings.join(' · '),
                    style: text.bodyMedium?.copyWith(color: context.mutedText),
                  ),
                ],
              ),
            ),
            if (picked == null) Icon(Icons.chevron_right, color: context.mutedText),
          ],
        ),
      ),
    );
  }
}

/// The number is the level plus progress through it, such as 2.5. Mastered words show a check instead.
class _Badge extends StatelessWidget {
  const _Badge({required this.status, required this.label});

  final MasteryStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: status.color, width: 2)),
      child: status == MasteryStatus.mastered
          ? Icon(Icons.check, size: 16, color: context.successText)
          : FittedBox(
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
    );
  }
}

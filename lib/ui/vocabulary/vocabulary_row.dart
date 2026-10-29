import 'package:flutter/cupertino.dart';

import '../../models/mastery_status.dart';
import '../../models/saved_word.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'mastery_status_color.dart';

/// One saved word: mastery badge, word, pinyin, meanings.
class VocabularyRow extends StatelessWidget {
  const VocabularyRow({super.key, required this.word, this.isPicked});

  final SavedWord word;

  /// Set while choosing words to delete, null otherwise.
  final bool? isPicked;

  @override
  Widget build(BuildContext context) {
    final status = MasteryStatus.ofLevel(word.level);
    final picked = isPicked;
    return Semantics(
      value: status == MasteryStatus.mastered ? status.label : '${status.label}, level ${word.masteryLabel}',
      selected: picked == true,
      hint: picked == null ? 'Opens the word details' : 'Selects this word for deletion',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (picked != null) ...[
              Icon(picked ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, color: picked ? context.accent : context.mutedText),
              const SizedBox(width: 12),
            ],
            _Badge(status: status, label: word.masteryLabel),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: word.word, style: context.body.copyWith(fontWeight: FontWeight.w600)),
                    TextSpan(text: '  ${word.pinyin}', style: context.subhead.copyWith(color: context.mutedText)),
                  ])),
                  Text(
                    word.meanings.isEmpty ? 'No definition' : word.meanings.join(' · '),
                    style: context.subhead.copyWith(color: context.mutedText),
                  ),
                ],
              ),
            ),
            if (picked == null) Icon(CupertinoIcons.chevron_forward, size: 16, color: context.resolve(CupertinoColors.tertiaryLabel)),
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
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.resolve(status.color), width: 2)),
      child: status == MasteryStatus.mastered
          ? Icon(CupertinoIcons.checkmark, size: 16, color: context.successText)
          : FittedBox(
              child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/mastery_status.dart';
import '../../models/saved_word.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../components/pinyin.dart';
import '../theme/wind_classes.dart';

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
      child: WDiv(
        className: 'flex flex-row items-center gap-3 px-4 py-[10px]',
        children: [
          if (picked != null)
            WIcon(
              picked ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              className: 'text-2xl ${picked ? 'text-brand-500 dark:text-brand-400' : mutedTextClass}',
            ),
          _Badge(status: status, label: word.masteryLabel),
          WDiv(
            className: 'flex-1 flex flex-col items-start',
            children: [
              WDiv(
                className: 'flex flex-row items-baseline gap-2',
                children: [
                  WText(word.word, className: 'text-[20px] font-semibold $inkTextClass'),
                  Pinyin(word.pinyin, style: const TextStyle(fontSize: 15)),
                ],
              ),
              WText(word.meanings.isEmpty ? 'No definition' : word.meanings.join(' · '), className: 'text-[15px] $mutedTextClass'),
            ],
          ),
          if (picked == null) const WIcon(CupertinoIcons.chevron_forward, className: 'text-base text-night-400'),
        ],
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
    final ring = switch (status) {
      MasteryStatus.newWord => 'border-night-400',
      MasteryStatus.learning => 'border-orange-500',
      MasteryStatus.mastered => 'border-green-600 dark:border-green-400',
    };
    return WDiv(
      className: 'flex items-center justify-center size-[34px] rounded-full border-2 $ring',
      child: status == MasteryStatus.mastered
          ? const WIcon(CupertinoIcons.checkmark, className: 'text-base text-green-700 dark:text-green-400')
          : WText(label, className: 'text-xs font-bold $inkTextClass'),
    );
  }
}

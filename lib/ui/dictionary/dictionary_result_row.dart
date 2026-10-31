import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/dictionary_match.dart';
import '../components/pinyin.dart';
import '../theme/wind_classes.dart';

/// One dictionary hit: word, pinyin, meanings, with badges for custom and saved words.
class DictionaryResultRow extends StatelessWidget {
  const DictionaryResultRow({super.key, required this.match, required this.isSaved, this.isSelected = false});

  final DictionaryMatch match;
  final bool isSaved;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: [if (isSaved) 'Saved', if (isSelected) 'Selected'].join(', '),
      child: WDiv(
        className: 'flex flex-row items-center px-4 py-[10px]',
        children: [
          WDiv(
            className: 'flex-1 flex flex-col items-start',
            children: [
              WDiv(
                className: 'wrap items-center gap-2',
                children: [
                  WText(match.word, className: 'text-[20px] font-semibold $inkTextClass'),
                  Pinyin(match.entry.pinyin, style: const TextStyle(fontSize: 15)),
                  if (match.isCustom)
                    const WDiv(
                      className: 'px-[6px] py-[2px] rounded-chip bg-iris-500/15 dark:bg-brand-400/20',
                      child: WText('Custom', className: 'text-[11px] font-semibold text-iris-500 dark:text-brand-400'),
                    ),
                ],
              ),
              WText(match.entry.meanings.join(' · '), className: 'text-[15px] $mutedTextClass'),
            ],
          ),
          if (isSelected)
            const WIcon(CupertinoIcons.checkmark_circle_fill, className: 'text-2xl text-brand-500 dark:text-brand-400')
          else if (isSaved)
            const WIcon(CupertinoIcons.bookmark_fill, className: 'text-base text-brand-500 dark:text-brand-400'),
        ],
      ),
    );
  }
}

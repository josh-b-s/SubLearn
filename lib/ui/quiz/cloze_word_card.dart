import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/word_token.dart';
import '../components/pressable.dart';
import '../components/pinyin.dart';
import '../theme/wind_classes.dart';

/// One word of the cloze sentence. Pinyin and meaning follow the word's mastery level, and a tap shows the hidden ones.
class ClozeWordCard extends StatelessWidget {
  const ClozeWordCard({super.key, required this.token, required this.showsHidden, required this.onTap});

  static const wordSize = 26.0;
  static const cornerRadius = 14.0;

  final WordToken token;
  final bool showsHidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pinyin = token.pinyin.isEmpty || (token.hidePinyin && !showsHidden) ? null : token.pinyin;
    final meaning = token.meanings.isEmpty || (token.hideMeaning && !showsHidden) ? null : token.meanings.join(' · ');
    final hasHiddenHints = (token.hidePinyin && token.pinyin.isNotEmpty) || (token.hideMeaning && token.meanings.isNotEmpty);
    return Semantics(
      button: true,
      hint: hasHiddenHints && !showsHidden ? 'Shows its pinyin and meaning' : '',
      child: Pressable(
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: WDiv(
              className: 'flex flex-col items-center px-[10px] py-[6px] rounded-control bg-night-950/5 dark:bg-night-50/10',
              children: [
                WText(token.text, className: 'text-[26px] font-semibold $inkTextClass'),
                if (pinyin != null) Pinyin(pinyin, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                if (meaning != null) WText(meaning, className: 'text-xs truncate $mutedTextClass'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

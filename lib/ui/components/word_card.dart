import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/word_token.dart';
import '../theme/wind_classes.dart';
import 'pressable.dart';
import 'pinyin.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.token, required this.isSaved, required this.onTap});

  final WordToken token;
  final bool isSaved;
  final VoidCallback onTap;

  static const _plain = 'bg-white dark:bg-night-900 border border-night-950/10 dark:border-night-50/15';
  static const _saved = 'bg-gold-400/15 border-2 border-gold-400 dark:border-gold-300';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      value: isSaved ? 'Saved' : 'Not saved',
      hint: 'Double tap for details and to save',
      child: Pressable(
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Stack(
              children: [
                WDiv(
                  className: 'flex flex-col items-start p-4 rounded-tile ${isSaved ? _saved : _plain}',
                  children: [
                    WText(token.text, className: 'text-[34px] font-semibold leading-tight $inkTextClass'),
                    if (token.pinyin.isNotEmpty && !token.hidePinyin)
                      Pinyin(token.pinyin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (!token.hideMeaning)
                      WText(
                        token.meanings.isEmpty ? 'No definition' : token.meanings.join(' · '),
                        className: 'text-[17px] line-clamp-2 $mutedTextClass',
                      ),
                  ],
                ),
                if (isSaved)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: WIcon(CupertinoIcons.bookmark_fill, className: 'text-[14px] text-gold-700 dark:text-gold-300'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

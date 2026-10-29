import 'package:flutter/cupertino.dart';

import '../../models/word_token.dart';
import '../components/pressable.dart';
import '../theme/app_colors.dart';

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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.resolve(CupertinoColors.tertiarySystemFill),
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(token.text, style: const TextStyle(fontSize: wordSize, fontWeight: FontWeight.w600)),
                    if (pinyin != null) Text(pinyin, style: TextStyle(fontSize: 13, color: context.accent)),
                    if (meaning != null)
                      Text(meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: context.mutedText)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

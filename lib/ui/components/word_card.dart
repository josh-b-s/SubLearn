import 'package:flutter/cupertino.dart';

import '../../models/word_token.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'pressable.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.token, required this.isSaved, required this.onTap});

  final WordToken token;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return Semantics(
      button: true,
      value: isSaved ? 'Saved' : 'Not saved',
      hint: 'Double tap for details and to save',
      child: Pressable(
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSaved ? accent : const Color(0x00000000), width: 2),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(token.text, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        if (token.pinyin.isNotEmpty && !token.hidePinyin)
                          Text(token.pinyin, style: context.callout.copyWith(color: accent)),
                        if (!token.hideMeaning)
                          Text(
                            token.meanings.isEmpty ? 'No definition' : token.meanings.join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.body.copyWith(color: context.mutedText),
                          ),
                      ],
                    ),
                  ),
                  if (isSaved)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(CupertinoIcons.bookmark_fill, size: 14, color: accent),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

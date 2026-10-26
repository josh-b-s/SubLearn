import 'package:flutter/material.dart';

import '../../models/word_token.dart';
import '../theme/app_colors.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.token, required this.isSaved, required this.onTap});

  final WordToken token;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = context.accent;
    return Semantics(
      button: true,
      value: isSaved ? 'Saved' : 'Not saved',
      hint: 'Double tap for details and to save',
      child: Material(
        color: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSaved ? accent : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
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
                        Text(token.pinyin, style: text.titleMedium?.copyWith(color: accent)),
                      if (!token.hideMeaning)
                        Text(
                          token.meanings.isEmpty ? 'No definition' : token.meanings.join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge?.copyWith(color: context.mutedText),
                        ),
                    ],
                  ),
                ),
                if (isSaved)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.bookmark, size: 14, color: accent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

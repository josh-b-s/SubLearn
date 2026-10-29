import 'package:flutter/material.dart';

import '../../models/word_token.dart';

/// One word in the floating window. Colours are fixed because the window is drawn outside the app's theme.
class SubtitleWindowCard extends StatelessWidget {
  const SubtitleWindowCard({super.key, required this.token});

  final WordToken token;

  static const _ink = Color(0xFF1A1A1A);
  static const _blue = Color(0xFF007AFF);
  static const _grey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Text(token.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink)),
          if (token.pinyin.isNotEmpty && !token.hidePinyin)
            Text(token.pinyin, style: const TextStyle(fontSize: 13, color: _blue)),
          if (token.meanings.isNotEmpty && !token.hideMeaning)
            Text(
              token.meanings.take(2).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: _grey),
            ),
        ],
      ),
    );
  }
}

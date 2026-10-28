import 'package:flutter/material.dart';

import '../../models/word_token.dart';

/// Compact word card sized like the one in the PiP window.
/// Colours are fixed because the PiP image is drawn outside the app's theme.
class PipPreviewCard extends StatelessWidget {
  const PipPreviewCard({super.key, required this.token});

  final WordToken token;

  static const _blue = Color(0xFF0059D9);
  static const _grey = Color(0xFF595959);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 1,
        children: [
          Text(token.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          if (token.pinyin.isNotEmpty && !token.hidePinyin)
            Text(token.pinyin, style: const TextStyle(fontSize: 12, color: _blue)),
          if (token.meanings.isNotEmpty && !token.hideMeaning)
            Text(
              token.meanings.take(2).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _grey),
            ),
        ],
      ),
    );
  }
}

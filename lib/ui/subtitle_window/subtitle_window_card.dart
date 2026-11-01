import 'package:flutter/material.dart';

import '../../models/word_token.dart';
import '../components/pinyin.dart';
import 'subtitle_colors.dart';

/// One word in the floating window and in the in-app preview. [compact] is the smaller size the preview
/// panel uses. Colours come in as [colors] because the overlay is drawn outside the app's theme.
class SubtitleWindowCard extends StatelessWidget {
  const SubtitleWindowCard({super.key, required this.token, required this.colors, this.compact = false});

  final WordToken token;
  final SubtitleColors colors;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 92 : 180),
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Text(token.text, style: TextStyle(fontSize: compact ? 22 : 20, fontWeight: FontWeight.w600, color: colors.ink)),
          if (token.pinyin.isNotEmpty && !token.hidePinyin)
            Pinyin(
              token.pinyin,
              brightness: colors.brightness,
              style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600),
            ),
          if (token.meanings.isNotEmpty && !token.hideMeaning)
            Text(
              token.meanings.take(2).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 11 : 12, color: colors.muted),
            ),
        ],
      ),
    );
  }
}

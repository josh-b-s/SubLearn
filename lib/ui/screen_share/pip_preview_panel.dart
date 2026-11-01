import 'package:flutter/cupertino.dart';

import '../../models/session/pip_line.dart';
import '../subtitle_window/subtitle_colors.dart';
import '../subtitle_window/subtitle_window_card.dart';
import 'subtitle_line_layout.dart';

/// What the subtitle window shows, minus its title bar, drawn in the app. The cards are not tappable.
class PipPreviewPanel extends StatelessWidget {
  const PipPreviewPanel({super.key, required this.lines});

  final List<PipLine> lines;

  static const height = 180.0;
  static const maxRows = 2;

  @override
  Widget build(BuildContext context) {
    final colors = SubtitleColors.of(CupertinoTheme.brightnessOf(context));
    return Container(
      height: height,
      color: colors.body,
      child: lines.isEmpty
          ? Center(child: Text('Listening…', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.muted)))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: SubtitleLineLayout(
                  maxRows: maxRows,
                  lineStarts: [
                    for (final line in lines)
                      for (final token in line.tokens) token.id == 0,
                  ],
                  children: [
                    for (final line in lines)
                      for (final token in line.tokens)
                        SubtitleWindowCard(key: ValueKey('${line.id}-${token.id}'), token: token, colors: colors, compact: true),
                  ],
                ),
              ),
            ),
    );
  }
}

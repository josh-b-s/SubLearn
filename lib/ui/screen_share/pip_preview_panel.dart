import 'package:flutter/material.dart';

import '../../models/session/pip_line.dart';
import 'pip_preview_card.dart';
import 'subtitle_line_layout.dart';

/// What the PiP window shows, drawn in the app. The cards are not tappable, same as the window.
class PipPreviewPanel extends StatelessWidget {
  const PipPreviewPanel({super.key, required this.lines});

  final List<PipLine> lines;

  static const height = 180.0;
  static const maxRows = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBEBEB), Color(0xFFD1D1D1)],
        ),
      ),
      child: lines.isEmpty
          ? const Center(
              child: Text(
                'Listening…',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF4D4D4D)),
              ),
            )
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
                      for (final token in line.tokens) PipPreviewCard(key: ValueKey('${line.id}-${token.id}'), token: token),
                  ],
                ),
              ),
            ),
    );
  }
}

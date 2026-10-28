import 'package:flutter/material.dart';

import '../../models/session/pip_line.dart';
import 'pip_preview_panel.dart';

/// Stand-in for the media being watched, with the same panel the PiP window shows.
class MockMediaPreview extends StatelessWidget {
  const MockMediaPreview({super.key, required this.lines});

  final List<PipLine> lines;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Live subtitles preview',
      child: Container(
        height: 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1A33), Colors.black, Color(0xFF73401A)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: ExcludeSemantics(
                child: Text('Preview', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0x80FFFFFF))),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: ClipRRect(borderRadius: BorderRadius.circular(24), child: PipPreviewPanel(lines: lines)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/session/pip_line.dart';
import 'subtitle_colors.dart';
import 'subtitle_window_card.dart';
import 'subtitle_window_header.dart';

export 'subtitle_window_header.dart' show SubtitleWindowGesture;

/// The floating subtitle window: title bar on top, word cards below that scroll.
/// Plain Flutter with no platform code, so any host that can give it a floating surface can show it.
class SubtitleWindow extends StatelessWidget {
  const SubtitleWindow({
    super.key,
    required this.lines,
    required this.onGestureStart,
    required this.onGestureUpdate,
    required this.onGestureEnd,
    required this.onOpenApp,
  });

  final List<PipLine> lines;
  final ValueChanged<SubtitleWindowGesture> onGestureStart;
  final void Function(SubtitleWindowGesture gesture, Offset delta) onGestureUpdate;
  final VoidCallback onGestureEnd;
  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    final colors = SubtitleColors.of(MediaQuery.platformBrightnessOf(context));
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          SubtitleWindowHeader(
            colors: colors,
            onGestureStart: onGestureStart,
            onGestureUpdate: onGestureUpdate,
            onGestureEnd: onGestureEnd,
            onOpenApp: onOpenApp,
          ),
          Expanded(
            child: ColoredBox(
              color: colors.body,
              child: SizedBox.expand(
                child: lines.isEmpty
                    ? Center(child: Text('Listening…', style: TextStyle(fontSize: 14, color: colors.muted)))
                    : _Lines(lines: lines, colors: colors),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.lines, required this.colors});

  final List<PipLine> lines;
  final SubtitleColors colors;

  @override
  Widget build(BuildContext context) {
    // reverse keeps the newest line at the bottom as lines arrive, and the list scrolls up to older ones.
    return ListView(
      reverse: true,
      padding: const EdgeInsets.all(10),
      children: [
        for (final line in lines.reversed)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final token in line.tokens) SubtitleWindowCard(key: ValueKey('${line.id}-${token.id}'), token: token, colors: colors),
              ],
            ),
          ),
      ],
    );
  }
}

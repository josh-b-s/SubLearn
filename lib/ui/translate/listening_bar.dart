import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pinned bar shown while recording: status, the hide-learned toggle, and a one-tap stop.
class ListeningBar extends StatelessWidget {
  const ListeningBar({
    super.key,
    required this.hasTranscript,
    required this.hideLearned,
    required this.onHideLearnedChanged,
    required this.onStop,
  });

  final bool hasTranscript;
  final bool hideLearned;
  final ValueChanged<bool> onHideLearnedChanged;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        hasTranscript ? 'Listening…' : 'Listening, start speaking…',
                        style: TextStyle(color: context.mutedText),
                      ),
                    ),
                  ),
                  if (hasTranscript)
                    FilterChip(
                      avatar: const Icon(Icons.visibility_off, size: 18),
                      label: const Text('Hide learned'),
                      selected: hideLearned,
                      onSelected: onHideLearnedChanged,
                      tooltip: 'Hides the pinyin and meaning of words you already know',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(14)),
                  onPressed: onStop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop recording'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';

/// Speaks a word on tap.
class SpeakButton extends ConsumerWidget {
  const SpeakButton({super.key, required this.word, this.iconSize = 32});

  final String word;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.outlined(
      iconSize: iconSize,
      tooltip: 'Play pronunciation',
      onPressed: () => ref.read(speakerProvider).speak(word, ignoringMuteSwitch: true),
      icon: const Icon(Icons.volume_up),
    );
  }
}

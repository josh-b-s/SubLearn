import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';
import 'icon_action.dart';

/// Speaks a word on tap.
class SpeakButton extends ConsumerWidget {
  const SpeakButton({super.key, required this.word, this.iconSize = 32});

  final String word;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconAction(
      label: 'Play pronunciation',
      icon: CupertinoIcons.speaker_2_fill,
      size: iconSize,
      filled: true,
      onPressed: () => ref.read(speakerProvider).speak(word, ignoringMuteSwitch: true),
    );
  }
}

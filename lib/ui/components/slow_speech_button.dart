import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/settings_provider.dart';

/// Toolbar button that turns slow speech on or off.
class SlowSpeechButton extends ConsumerWidget {
  const SlowSpeechButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slow = ref.watch(settingsProvider.select((s) => s.speakSlowly));
    return IconButton(
      tooltip: slow ? 'Speak slowly: on' : 'Speak slowly: off',
      isSelected: slow,
      icon: const Icon(Icons.slow_motion_video_outlined),
      selectedIcon: const Icon(Icons.slow_motion_video),
      onPressed: () => ref.read(settingsProvider.notifier).setSpeakSlowly(!slow),
    );
  }
}

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/settings_provider.dart';
import 'icon_action.dart';

/// Toolbar button that turns slow speech on or off.
class SlowSpeechButton extends ConsumerWidget {
  const SlowSpeechButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slow = ref.watch(settingsProvider.select((s) => s.speakSlowly));
    return IconAction(
      label: slow ? 'Speak slowly: on' : 'Speak slowly: off',
      icon: slow ? CupertinoIcons.tortoise_fill : CupertinoIcons.tortoise,
      onPressed: () => ref.read(settingsProvider.notifier).setSpeakSlowly(!slow),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/speech_model_provider.dart';
import '../theme/app_colors.dart';

/// Download or delete the offline speech model.
class SpeechModelTile extends ConsumerWidget {
  const SpeechModelTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(speechModelProvider);
    final controller = ref.read(speechModelProvider.notifier);
    final progress = model.progress;

    final subtitle = switch (model.status) {
      SpeechModelStatus.checking => 'Checking…',
      SpeechModelStatus.missing => model.error ?? 'Not downloaded. It is a large file, so use Wi-Fi.',
      SpeechModelStatus.downloading => progress == null ? 'Downloading…' : 'Downloading ${(progress * 100).round()}%',
      SpeechModelStatus.installed => 'Downloaded',
    };

    return ListTile(
      title: const Text('Offline speech model'),
      subtitle: Text(subtitle, style: TextStyle(color: model.error == null ? context.mutedText : Theme.of(context).colorScheme.error)),
      trailing: switch (model.status) {
        SpeechModelStatus.checking => null,
        SpeechModelStatus.missing => TextButton(onPressed: controller.download, child: const Text('Download')),
        SpeechModelStatus.downloading => SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: progress, strokeWidth: 3)),
        SpeechModelStatus.installed => TextButton(onPressed: controller.remove, child: const Text('Delete')),
      },
    );
  }
}

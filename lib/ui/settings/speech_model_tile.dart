import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/speech_model_provider.dart';
import '../components/grouped_row.dart';

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

    return GroupedRow(
      title: 'Offline speech model',
      subtitle: subtitle,
      trailing: switch (model.status) {
        SpeechModelStatus.checking => null,
        SpeechModelStatus.missing => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: controller.download,
            child: const Text('Download'),
          ),
        SpeechModelStatus.downloading => const CupertinoActivityIndicator(),
        SpeechModelStatus.installed => CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: controller.remove,
            child: const Text('Delete'),
          ),
      },
    );
  }
}

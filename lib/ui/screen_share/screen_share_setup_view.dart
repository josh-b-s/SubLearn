import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/screen_share/screen_share_backend.dart';
import '../../state/screen_share_controller.dart';
import '../theme/app_colors.dart';

/// Source choice and the start button, also shown while waiting for the system broadcast.
class ScreenShareSetupView extends ConsumerWidget {
  const ScreenShareSetupView({super.key, required this.state, required this.capabilities});

  final ScreenShareState state;
  final ScreenShareCapabilities capabilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(screenShareControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final waiting = state.phase == ScreenSharePhase.waitingForBroadcast;
    final starting = state.phase == ScreenSharePhase.starting;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Live Mandarin subtitles for whatever you are watching, in a floating window over other apps.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 20),
        SegmentedButton<ScreenShareSource>(
          segments: [for (final s in ScreenShareSource.values) ButtonSegment(value: s, label: Text(s.label))],
          selected: {state.source},
          onSelectionChanged: state.isRunning ? null : (s) => controller.setSource(s.first),
        ),
        const SizedBox(height: 8),
        Text(
          state.source == ScreenShareSource.screen
              ? 'Captures audio playing on this device through a system broadcast. Nothing is recorded or sent anywhere, the audio is transcribed on the device or by the iOS speech service.'
              : 'Listens through the microphone, for speech in the room.',
          style: text.bodySmall?.copyWith(color: context.mutedText),
        ),
        if (state.source == ScreenShareSource.screen && !capabilities.broadcastExtensionFound) ...[
          const SizedBox(height: 12),
          Text(
            'The broadcast extension was not found in this build, so screen audio will not work. Follow ios_native/README.md to add it, or use the microphone.',
            style: text.bodySmall?.copyWith(color: context.warningText),
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: 16),
          Text(state.error!, style: TextStyle(color: context.errorText)),
        ],
        if (state.notice != null) ...[
          const SizedBox(height: 16),
          Text(state.notice!, style: TextStyle(color: context.warningText)),
        ],
        const SizedBox(height: 24),
        if (waiting) ...[
          Text(
            'In the sheet that opened, choose Subtitle Learn and tap Start Broadcast.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(spacing: 12, children: [
            Expanded(child: OutlinedButton(onPressed: controller.stop, child: const Text('Cancel'))),
            Expanded(child: FilledButton(onPressed: controller.showBroadcastPicker, child: const Text('Open sheet again'))),
          ]),
        ] else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: starting ? null : controller.start,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: starting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Start'),
              ),
            ),
          ),
      ],
    );
  }
}

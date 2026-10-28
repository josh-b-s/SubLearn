import 'package:flutter/cupertino.dart' show CupertinoPageRoute, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session/session_summary.dart';
import '../../services/screen_share/screen_share_backend.dart';
import '../../state/screen_share_backend_provider.dart';
import '../../state/screen_share_controller.dart';
import '../../state/session_transcript_provider.dart';
import '../components/icon_action.dart';
import '../components/alerts.dart';
import '../components/empty_state.dart';
import '../components/segmented_picker.dart';
import '../theme/app_colors.dart';
import 'mock_media_preview.dart';
import 'screen_share_button.dart';
import 'screen_share_help_text.dart';
import 'session_summary_screen.dart';
import 'transcript_screen.dart';

/// Screen Share tab: live subtitles from audio, shown in a Picture in Picture window.
class ScreenShareScreen extends ConsumerWidget {
  const ScreenShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(screenShareCapabilitiesProvider);
    final controller = ref.read(screenShareControllerProvider.notifier);

    ref.listen(screenShareControllerProvider.select((s) => s.summary), (_, summary) {
      if (summary != null) _showSummary(context, controller, summary);
    });
    ref.listen(screenShareControllerProvider.select((s) => s.error), (_, error) {
      if (error != null) _showError(context, controller, error);
    });

    final hasTranscript = ref.watch(sessionTranscriptProvider.select((t) => t?.lines.isNotEmpty ?? false));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Share'),
        actions: [
          if (hasTranscript)
            IconAction(
              label: 'Transcript',
              icon: CupertinoIcons.doc_text,
              onPressed: () => _showTranscript(context),
            ),
        ],
      ),
      body: capabilities.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => EmptyState(icon: Icons.warning_amber, title: "Can't check Screen Share", description: '$e'),
        data: (caps) {
          if (!caps.isSupported) {
            return EmptyState(
              icon: Icons.picture_in_picture_alt_outlined,
              title: 'Not available here',
              description: caps.unsupportedReason,
            );
          }
          return _Content(capabilities: caps);
        },
      ),
    );
  }

  Future<void> _showSummary(BuildContext context, ScreenShareController controller, SessionSummary summary) {
    return Navigator.of(context)
        .push(CupertinoPageRoute<void>(fullscreenDialog: true, builder: (_) => SessionSummaryScreen(summary: summary)))
        .whenComplete(controller.dismissSummary);
  }

  Future<void> _showTranscript(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute<void>(fullscreenDialog: true, builder: (_) => const TranscriptScreen()),
    );
  }

  Future<void> _showError(BuildContext context, ScreenShareController controller, String message) {
    return showMessageAlert(context, title: 'Screen Share', message: message).whenComplete(controller.clearError);
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.capabilities});

  final ScreenShareCapabilities capabilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenShareControllerProvider);
    final controller = ref.read(screenShareControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        MockMediaPreview(lines: state.lines),
        const SizedBox(height: 20),
        SegmentedPicker<ScreenShareSource>(
          labels: {for (final s in ScreenShareSource.values) s: s.label},
          selected: state.source,
          onChanged: state.isActive ? null : controller.setSource,
        ),
        const SizedBox(height: 20),
        ScreenShareButton(state: state, capabilities: capabilities, onStart: controller.start, onStop: controller.stop),
        if (state.phase == ScreenSharePhase.live && !state.pipActive) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.presentPip,
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              icon: const Icon(Icons.picture_in_picture_alt),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Show PiP')),
            ),
          ),
        ],
        if (state.notice != null) ...[
          const SizedBox(height: 12),
          Text(state.notice!, style: TextStyle(color: context.warningText)),
        ],
        const SizedBox(height: 20),
        Text(
          screenShareHelpText(state.source, capabilities),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText),
        ),
      ],
    );
  }
}

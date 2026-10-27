import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/screen_share_backend_provider.dart';
import '../../state/screen_share_controller.dart';
import '../components/empty_state.dart';
import 'live_subtitles_view.dart';
import 'screen_share_setup_view.dart';
import 'session_summary_view.dart';

/// Screen Share tab: pick a source, watch live subtitles, then see what was heard.
class ScreenShareScreen extends ConsumerWidget {
  const ScreenShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(screenShareCapabilitiesProvider);
    final state = ref.watch(screenShareControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Screen Share')),
      body: capabilities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(icon: Icons.warning_amber, title: "Can't check Screen Share", description: '$e'),
        data: (caps) {
          if (!caps.isSupported) {
            return EmptyState(
              icon: Icons.picture_in_picture_alt_outlined,
              title: 'Not available here',
              description: caps.unsupportedReason,
            );
          }
          return switch (state.phase) {
            ScreenSharePhase.idle || ScreenSharePhase.starting || ScreenSharePhase.waitingForBroadcast =>
              ScreenShareSetupView(state: state, capabilities: caps),
            ScreenSharePhase.live => LiveSubtitlesView(state: state),
            ScreenSharePhase.finished => SessionSummaryView(state: state),
          };
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/screen_share/screen_share_backend.dart';
import '../../state/screen_share_controller.dart';

/// The one big button: starts, cancels the wait for the broadcast, or stops.
class ScreenShareButton extends StatelessWidget {
  const ScreenShareButton({
    super.key,
    required this.state,
    required this.capabilities,
    required this.onStart,
    required this.onStop,
  });

  final ScreenShareState state;
  final ScreenShareCapabilities capabilities;
  final VoidCallback onStart;
  final VoidCallback onStop;

  bool get _canStart {
    if (!capabilities.pipSupported) return false;
    return state.isActive || state.source != ScreenShareSource.screen || capabilities.broadcastExtensionFound;
  }

  String get _title {
    if (state.phase == ScreenSharePhase.waitingForBroadcast) return 'Waiting for broadcast (tap to cancel)';
    if (state.phase == ScreenSharePhase.live) return 'Stop';
    return state.source == ScreenShareSource.screen ? 'Share screen audio' : 'Start live subtitles';
  }

  @override
  Widget build(BuildContext context) {
    final active = state.isActive;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _canStart ? (active ? onStop : onStart) : null,
        style: FilledButton.styleFrom(
          backgroundColor: active ? Colors.red.shade700 : null,
          foregroundColor: active ? Colors.white : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(active ? Icons.stop : Icons.picture_in_picture_alt),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(_title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../../services/screen_share/screen_share_backend.dart';
import '../../state/screen_share_controller.dart';
import '../components/app_button.dart';

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
    return AppButton(
      label: _title,
      style: active ? AppButtonStyle.destructive : AppButtonStyle.filled,
      icon: Icon(active ? CupertinoIcons.stop_fill : CupertinoIcons.rectangle_on_rectangle),
      onPressed: _canStart ? (active ? onStop : onStart) : null,
    );
  }
}

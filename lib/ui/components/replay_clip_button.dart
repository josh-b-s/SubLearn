import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/screen_share_backend_provider.dart';
import '../../state/settings_provider.dart';
import 'app_button.dart';

/// Plays the clip of the word as it was heard in a screen share.
class ReplayClipButton extends ConsumerStatefulWidget {
  const ReplayClipButton({super.key, required this.word});

  final String word;

  @override
  ConsumerState<ReplayClipButton> createState() => _ReplayClipButtonState();
}

class _ReplayClipButtonState extends ConsumerState<ReplayClipButton> {
  bool _playing = false;
  bool _failed = false;

  Future<void> _play() async {
    setState(() {
      _playing = true;
      _failed = false;
    });
    try {
      await ref.read(screenShareBackendProvider).playClip(
            widget.word,
            slow: ref.read(settingsProvider).speakSlowly,
          );
    } on Exception {
      _failed = true;
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _failed ? "Can't play clip" : (_playing ? 'Playing…' : 'Replay from video');
    return Semantics(
      hint: 'Plays the audio of this word from the video you watched',
      child: AppButton(
        label: label,
        style: AppButtonStyle.tinted,
        expand: false,
        onPressed: _playing ? null : _play,
        icon: Icon(_playing ? CupertinoIcons.volume_up : CupertinoIcons.play_fill),
      ),
    );
  }
}

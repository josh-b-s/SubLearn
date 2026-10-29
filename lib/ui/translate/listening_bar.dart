import 'package:flutter/cupertino.dart';

import '../components/app_button.dart';
import '../components/pill_chip.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';

/// Pinned bar shown while recording: status, the hide-learned toggle, and a one-tap stop.
class ListeningBar extends StatelessWidget {
  const ListeningBar({
    super.key,
    required this.hasTranscript,
    required this.hideLearned,
    required this.onHideLearnedChanged,
    required this.onStop,
  });

  final bool hasTranscript;
  final bool hideLearned;
  final ValueChanged<bool> onHideLearnedChanged;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: cardRadius),
      child: ColoredBox(
        color: context.cardBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _Pulse(child: Icon(CupertinoIcons.waveform, color: context.destructive)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Semantics(
                            liveRegion: true,
                            container: true,
                            child: Text(
                              hasTranscript ? 'Listening…' : 'Listening, start speaking…',
                              style: TextStyle(color: context.mutedText),
                            ),
                          ),
                        ),
                        if (hasTranscript)
                          PillChip(
                            icon: CupertinoIcons.eye_slash,
                            label: 'Hide learned',
                            selected: hideLearned,
                            onTap: () => onHideLearnedChanged(!hideLearned),
                            hint: 'Hides the pinyin and meaning of words you already know',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      hint: 'Stops listening and keeps the transcript',
                      child: AppButton(
                        label: 'Stop Recording',
                        style: AppButtonStyle.destructive,
                        icon: const _Pulse(child: Icon(CupertinoIcons.stop_fill)),
                        onPressed: onStop,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slow fade in and out; static when the system asks for reduced motion.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: FadeTransition(opacity: Tween(begin: 0.4, end: 1.0).animate(_controller), child: widget.child),
      );
}

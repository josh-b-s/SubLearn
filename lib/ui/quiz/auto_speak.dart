import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/core_providers.dart';

/// Speaks [word] once when it first appears, staying quiet on a silenced iPhone.
class AutoSpeak extends ConsumerStatefulWidget {
  const AutoSpeak({super.key, required this.word, required this.child});

  final String word;
  final Widget child;

  @override
  ConsumerState<AutoSpeak> createState() => _AutoSpeakState();
}

class _AutoSpeakState extends ConsumerState<AutoSpeak> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(speakerProvider).speak(widget.word, ignoringMuteSwitch: false);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

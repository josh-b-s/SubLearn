import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/session/pip_line.dart';
import 'subtitle_window.dart';

/// Runs inside the Android overlay engine. Lines come from the main engine through native code,
/// and window gestures go back to native code, which owns the window.
class SubtitleOverlayApp extends StatefulWidget {
  const SubtitleOverlayApp({super.key});

  @override
  State<SubtitleOverlayApp> createState() => _SubtitleOverlayAppState();
}

class _SubtitleOverlayAppState extends State<SubtitleOverlayApp> {
  static const _channel = MethodChannel('subtitle_learn/overlay');

  List<PipLine> _lines = const [];

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_onCall);
    // Native code can't know when the handler above is ready, so it waits for this.
    _channel.invokeMethod<void>('ready');
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method != 'lines') return;
    final lines = [
      for (final raw in call.arguments as List) PipLine.fromJson(Map<String, Object?>.from(raw as Map)),
    ];
    setState(() => _lines = lines);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: Material(
        type: MaterialType.transparency,
        child: SubtitleWindow(
          lines: _lines,
          onGestureStart: (gesture) => _channel.invokeMethod<void>('beginGesture', gesture.name),
          // Native code tracks the finger in screen coordinates, so the deltas aren't needed here.
          onGestureUpdate: (_, __) {},
          onGestureEnd: () => _channel.invokeMethod<void>('endGesture'),
          onOpenApp: () => _channel.invokeMethod<void>('openApp'),
        ),
      ),
    );
  }
}

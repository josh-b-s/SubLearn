import 'package:flutter/services.dart';

import '../../models/session/pip_line.dart';
import 'screen_share_backend.dart';
import 'screen_share_backend_api.dart';

/// Talks to the Swift code in ios_native/ over a method channel and an event channel.
class IosScreenShareBackend implements ScreenShareBackend {
  static const _methods = MethodChannel('subtitle_learn/screen_share');
  static const _eventChannel = EventChannel('subtitle_learn/screen_share/events');

  static const _missingNative =
      'The iOS Screen Share code is not part of this build. Follow ios_native/README.md to add it.';

  @override
  Stream<ScreenShareEvent> get events => _eventChannel.receiveBroadcastStream().map(_decode);

  @override
  Future<ScreenShareCapabilities> capabilities() async {
    try {
      final map = await _methods.invokeMapMethod<String, Object?>('capabilities') ?? const {};
      return ScreenShareCapabilities(
        isSupported: true,
        pipSupported: map['pip'] == true,
        broadcastExtensionFound: map['broadcastExtension'] == true,
      );
    } on MissingPluginException {
      return const ScreenShareCapabilities(isSupported: false, unsupportedReason: _missingNative);
    }
  }

  @override
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice}) =>
      _invoke('start', {'source': source.name, 'preferOnDevice': preferOnDevice});

  @override
  Future<void> showBroadcastPicker() => _invoke('showBroadcastPicker');

  @override
  Future<void> stop({required ScreenShareSource source}) => _invoke('stop', {'source': source.name});

  @override
  Future<void> updatePip(List<PipLine> lines) => _invoke('updatePip', {'lines': [for (final l in lines) l.toJson()]});

  @override
  Future<void> presentPip() => _invoke('presentPip');

  Future<void> _invoke(String method, [Object? arguments]) async {
    try {
      await _methods.invokeMethod<void>(method, arguments);
    } on PlatformException catch (e) {
      throw ScreenShareException(e.message ?? e.code);
    } on MissingPluginException {
      throw const ScreenShareException(_missingNative);
    }
  }

  static ScreenShareEvent _decode(dynamic raw) {
    final map = Map<String, Object?>.from(raw as Map);
    return switch (map['type']) {
      'started' => const BroadcastStarted(),
      'ended' => const BroadcastEnded(),
      'text' => SpeechText(map['text'] as String, isFinal: map['isFinal'] == true),
      'error' => SpeechFailed(map['message'] as String? ?? 'unknown error'),
      'pip' => PipStateChanged(active: map['active'] == true),
      final other => throw FormatException('Unknown screen share event: $other'),
    };
  }
}


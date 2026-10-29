import 'package:flutter/services.dart';

import '../../models/session/pip_line.dart';
import 'screen_share_backend.dart';
import 'screen_share_backend_api.dart';

/// Talks to the native Screen Share code over a method channel and an event channel.
/// iOS and Android use the same channel names and messages.
class ChannelScreenShareBackend implements ScreenShareBackend {
  ChannelScreenShareBackend({required this.missingNativeMessage});

  static const _methods = MethodChannel('subtitle_learn/screen_share');
  static const _eventChannel = EventChannel('subtitle_learn/screen_share/events');

  final String missingNativeMessage;

  @override
  Stream<ScreenShareEvent> get events => _eventChannel.receiveBroadcastStream().map(_decode);

  /// The native side answers with `pip` and `broadcastExtension` flags, or with `unsupportedReason`.
  @override
  Future<ScreenShareCapabilities> capabilities() async {
    try {
      final map = await _methods.invokeMapMethod<String, Object?>('capabilities') ?? const {};
      final reason = map['unsupportedReason'] as String?;
      return ScreenShareCapabilities(
        isSupported: reason == null,
        pipSupported: map['pip'] == true,
        broadcastExtensionFound: map['broadcastExtension'] == true,
        unsupportedReason: reason ?? '',
      );
    } on MissingPluginException {
      return ScreenShareCapabilities(isSupported: false, unsupportedReason: missingNativeMessage);
    }
  }

  @override
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice}) =>
      _invoke('start', {'source': source.name, 'preferOnDevice': preferOnDevice});

  @override
  Future<void> showBroadcastPicker() => _invoke('showBroadcastPicker');

  @override
  Future<void> stop({required ScreenShareSource source, Set<String>? keepClipsFor}) =>
      _invoke('stop', {'source': source.name, 'keepClipsFor': keepClipsFor?.toList()});

  @override
  Future<bool> hasClip(String word) async {
    try {
      return await _methods.invokeMethod<bool>('hasClip', {'word': word}) ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> playClip(String word, {required bool slow}) => _invoke('playClip', {'word': word, 'slow': slow});

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
      throw ScreenShareException(missingNativeMessage);
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

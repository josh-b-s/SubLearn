import '../../models/session/pip_line.dart';
import 'screen_share_backend.dart';
import 'screen_share_backend_api.dart';

/// Stand-in for platforms without a native Screen Share implementation.
class UnsupportedScreenShareBackend implements ScreenShareBackend {
  const UnsupportedScreenShareBackend({this.reason = _defaultReason});

  static const _defaultReason =
      'Screen Share needs system audio capture and a floating subtitle window. '
      'That is only implemented on iOS so far.';

  final String reason;

  @override
  Stream<ScreenShareEvent> get events => const Stream.empty();

  @override
  Future<ScreenShareCapabilities> capabilities() async =>
      ScreenShareCapabilities(isSupported: false, unsupportedReason: reason);

  @override
  Future<void> start({required ScreenShareSource source, required bool preferOnDevice}) =>
      Future.error(ScreenShareException(reason));

  @override
  Future<void> showBroadcastPicker() async {}

  @override
  Future<void> stop({required ScreenShareSource source}) async {}

  @override
  Future<void> updatePip(List<PipLine> lines) async {}

  @override
  Future<void> presentPip() async {}
}

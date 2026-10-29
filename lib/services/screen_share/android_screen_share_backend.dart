import 'channel_screen_share_backend.dart';

/// The Kotlin code in android/app/src/main/kotlin/.../screenshare. Audio clips are not ported.
class AndroidScreenShareBackend extends ChannelScreenShareBackend {
  AndroidScreenShareBackend()
      : super(missingNativeMessage: 'The Android Screen Share code is not part of this build.');

  @override
  Future<bool> hasClip(String word) async => false;

  @override
  Future<void> playClip(String word, {required bool slow}) async {}
}

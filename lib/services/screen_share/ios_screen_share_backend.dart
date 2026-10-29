import 'channel_screen_share_backend.dart';

/// The Swift code in ios_native/.
class IosScreenShareBackend extends ChannelScreenShareBackend {
  IosScreenShareBackend()
      : super(
          missingNativeMessage:
              'The iOS Screen Share code is not part of this build. Follow ios_native/README.md to add it.',
        );
}

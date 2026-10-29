import '../../services/platform_info.dart';
import '../../services/screen_share/screen_share_backend.dart';

/// The footnote under the start button, per source.
String screenShareHelpText(ScreenShareSource source, ScreenShareCapabilities capabilities) {
  if (!capabilities.pipSupported) return "Picture in Picture isn't supported on this device or simulator.";
  return switch (source) {
    ScreenShareSource.screen when isAndroid => capabilities.broadcastExtensionFound
        ? 'Tap the button and allow screen capture. Subtitles appear in a floating window over other apps, for audio from any app that allows capture, such as a video you play.'
        : "The speech model isn't in this build yet. See Screen Share on Android in README.md.",
    ScreenShareSource.screen => capabilities.broadcastExtensionFound
        ? 'Tap the button, then "Start Broadcast" in the system sheet. Subtitles appear in a floating window for audio from any app, such as a video you play.'
        : "The broadcast extension isn't in this build yet. See ios_native/README.md.",
    ScreenShareSource.microphone =>
      'Listens through the microphone, so it hears media playing out loud (not through headphones). Start it, then press Home and play something in Chinese.',
  };
}

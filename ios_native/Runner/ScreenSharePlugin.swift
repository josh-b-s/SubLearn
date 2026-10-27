import Flutter
import UIKit

/// Entry point. Call `ScreenSharePlugin.register(with:)` from AppDelegate, see ios_native/README.md.
public final class ScreenSharePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Flutter registers plugins on the main thread.
        MainActor.assumeIsolated { ScreenShareBridge.install(with: registrar) }
    }
}

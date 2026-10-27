import AVFoundation
import AVKit
import Combine
import Flutter
import ReplayKit
import SwiftUI
import UIKit

/// Runs the audio source, speech recognition and PiP window for the Dart side.
/// Dart owns segmentation, word tracking and what the PiP window shows. This side only
/// turns audio into transcript text and draws the lines it is given.
@MainActor
final class ScreenShareBridge {
    private static let channelName = "subtitle_learn/screen_share"
    private static let eventsName = "subtitle_learn/screen_share/events"
    private static let broadcastExtensionPoint = "com.apple.broadcast-services-upload"

    /// Longest unbroken speech kept in one subtitle. Longer is closed off and a new one starts.
    private static let maxSegmentCharacters = 40

    private let events = ScreenShareEventStream()
    private let transcriber = SpeechTranscriber()
    private let receiver = BroadcastAudioReceiver()
    private let subtitles = PipSubtitleModel()
    private lazy var pip = makePip()

    private var runID = UUID()
    private var layerHost: UIView?
    private var picker: RPSystemBroadcastPickerView?
    private var pipObserver: AnyCancellable?

    static func install(with registrar: FlutterPluginRegistrar) {
        let bridge = ScreenShareBridge()
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        // The channel keeps the closure, and the closure keeps the bridge alive.
        channel.setMethodCallHandler { call, result in
            MainActor.assumeIsolated { bridge.handle(call, result: result) }
        }
        FlutterEventChannel(name: eventsName, binaryMessenger: registrar.messenger()).setStreamHandler(bridge.events)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "capabilities":
            result([
                "pip": AVPictureInPictureController.isPictureInPictureSupported(),
                "broadcastExtension": Self.embeddedExtensionBundleID != nil && BroadcastShared.containerURL != nil,
            ])
        case "start":
            // Creating the PiP controller sets the audio category, so it has to come before the
            // microphone session sets its own.
            _ = pip
            let preferOnDevice = args["preferOnDevice"] as? Bool ?? true
            switch args["source"] as? String {
            case "microphone": Task { result(await startMicrophone(preferOnDevice: preferOnDevice)) }
            case "screen": Task { result(await waitForBroadcast(preferOnDevice: preferOnDevice)) }
            default: result(Self.error("bad_source", "Unknown audio source."))
            }
        case "showBroadcastPicker":
            result(showBroadcastPicker())
        case "stop":
            stop(requestBroadcastEnd: args["source"] as? String == "screen")
            result(nil)
        case "updatePip":
            subtitles.set(lines: args["lines"] as? [[String: Any]] ?? [])
            result(nil)
        case "presentPip":
            result(presentPip())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Microphone

    private func startMicrophone(preferOnDevice: Bool) async -> FlutterError? {
        do {
            try await SpeechTranscriber.requestPermissions()
            let run = beginRun(preferOnDevice: preferOnDevice)
            // Keep the media's audio playing normally while we listen to it.
            transcriber.sessionMode = .default
            transcriber.sessionOptions = [.mixWithOthers, .defaultToSpeaker]
            try await transcriber.start(
                continuous: true,
                onUpdate: { [weak self] text, isFinal in self?.forward(text, isFinal: isFinal, run: run) },
                onFailure: { [weak self] error in self?.fail(error, run: run) }
            )
            return nil
        } catch {
            return Self.error("start_failed", error.localizedDescription)
        }
    }

    // MARK: - Screen audio (broadcast extension)

    private func waitForBroadcast(preferOnDevice: Bool) async -> FlutterError? {
        guard BroadcastShared.containerURL != nil else {
            return Self.error("no_app_group", "The App Group isn't set up. See ios_native/README.md, step 4.")
        }
        do {
            try await SpeechTranscriber.requestSpeechPermission()
        } catch {
            return Self.error("start_failed", error.localizedDescription)
        }

        receiver.resetSharedFolder()
        receiver.start(
            onStarted: { [weak self] in self?.broadcastDidStart(preferOnDevice: preferOnDevice) },
            onBuffer: { [weak self] buffer in self?.transcriber.appendExternal(buffer) },
            onEnded: { [weak self] in self?.events.send("ended") }
        )
        return nil
    }

    private func broadcastDidStart(preferOnDevice: Bool) {
        let run = beginRun(preferOnDevice: preferOnDevice)
        do {
            try transcriber.startExternal(
                continuous: true,
                onUpdate: { [weak self] text, isFinal in self?.forward(text, isFinal: isFinal, run: run) },
                onFailure: { [weak self] error in self?.fail(error, run: run) }
            )
            events.send("started")
        } catch {
            events.send("error", ["message": error.localizedDescription])
        }
    }

    private func showBroadcastPicker() -> FlutterError? {
        guard let host = Self.rootView() else { return Self.error("no_view", "No window to show the broadcast sheet in.") }
        let picker = self.picker ?? RPSystemBroadcastPickerView(frame: CGRect(x: -4000, y: -4000, width: 44, height: 44))
        if picker.superview == nil {
            picker.alpha = 0
            picker.showsMicrophoneButton = false
            host.addSubview(picker)
        }
        picker.preferredExtension = Self.embeddedExtensionBundleID
        self.picker = picker
        picker.subviews.compactMap { $0 as? UIButton }.first?.sendActions(for: .touchUpInside)
        return nil
    }

    // MARK: - Session

    /// Starts a new run. Callbacks from an older run are ignored.
    private func beginRun(preferOnDevice: Bool) -> UUID {
        let run = UUID()
        runID = run
        transcriber.preferOnDevice = preferOnDevice
        transcriber.maxSegmentCharacters = Self.maxSegmentCharacters
        return run
    }

    private func stop(requestBroadcastEnd: Bool) {
        runID = UUID()
        transcriber.cancel()
        receiver.stop(requestBroadcastEnd: requestBroadcastEnd)
        subtitles.set(lines: [])
        pip.stop()
    }

    /// The recognizer calls back on its own queue.
    private nonisolated func forward(_ text: String, isFinal: Bool, run: UUID) {
        Task { @MainActor in
            guard run == self.runID else { return }
            self.events.send("text", ["text": text, "isFinal": isFinal])
        }
    }

    private nonisolated func fail(_ error: Error, run: UUID) {
        Task { @MainActor in
            guard run == self.runID else { return }
            self.events.send("error", ["message": "Speech recognition stopped: \(error.localizedDescription)"])
        }
    }

    // MARK: - Picture in Picture

    private func makePip() -> PipController {
        let controller = PipController()
        controller.setContent(
            PipSubtitleView(model: subtitles)
                .frame(width: PipSubtitleView.pipSize.width, height: PipSubtitleView.pipSize.height)
        )
        pipObserver = controller.$isActive.removeDuplicates().sink { [weak self] active in
            self?.events.send("pip", ["active": active])
        }
        return controller
    }

    private func presentPip() -> FlutterError? {
        guard PipController.isSupported else {
            return Self.error("pip_unsupported", "Picture in Picture isn't supported on this device.")
        }
        guard let host = Self.rootView() else { return Self.error("no_view", "No window to start Picture in Picture from.") }
        if layerHost == nil {
            // iOS only starts PiP while the layer is in the view tree, so park it invisibly off screen.
            let view = UIView(frame: CGRect(x: -4000, y: -4000, width: 300, height: 100))
            view.alpha = 0
            view.isUserInteractionEnabled = false
            view.layer.addSublayer(pip.displayLayer)
            host.addSubview(view)
            layerHost = view
        }
        pip.present()
        return nil
    }

    // MARK: - Helpers

    private static func rootView() -> UIView? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController?.view
    }

    /// Finds the broadcast extension embedded in this app, whatever it was named.
    private static var embeddedExtensionBundleID: String? {
        guard let plugins = Bundle.main.builtInPlugInsURL,
              let urls = try? FileManager.default.contentsOfDirectory(at: plugins, includingPropertiesForKeys: nil)
        else { return nil }

        for url in urls where url.pathExtension == "appex" {
            guard let bundle = Bundle(url: url),
                  let ext = bundle.infoDictionary?["NSExtension"] as? [String: Any],
                  ext["NSExtensionPointIdentifier"] as? String == broadcastExtensionPoint
            else { continue }
            return bundle.bundleIdentifier
        }
        return nil
    }

    private static func error(_ code: String, _ message: String) -> FlutterError {
        FlutterError(code: code, message: message, details: nil)
    }
}

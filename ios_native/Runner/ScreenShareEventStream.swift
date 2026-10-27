import Flutter

/// Holds the Dart listener for the event channel and sends events to it.
/// Events are sent from the main thread only, which is what Flutter requires.
final class ScreenShareEventStream: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    func send(_ type: String, _ fields: [String: Any] = [:]) {
        sink?(fields.merging(["type": type]) { _, new in new })
    }
}

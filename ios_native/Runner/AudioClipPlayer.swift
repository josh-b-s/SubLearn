import AVFoundation
import Flutter

/// Plays a stored word clip and reports back when it ends.
@MainActor
final class AudioClipPlayer: NSObject, AVAudioPlayerDelegate {
    private static let slowRate: Float = 0.7

    private var player: AVAudioPlayer?
    private var completion: FlutterResult?

    /// Calls `completion` with nil when playback ends, or a FlutterError if it can't play.
    /// A second request while a clip is playing is ignored.
    func play(word: String, slow: Bool, completion: @escaping FlutterResult) {
        guard self.completion == nil else { return completion(nil) }
        guard let url = AudioClipStore.url(for: word) else {
            return completion(FlutterError(code: "no_clip", message: "No clip stored for this word.", details: nil))
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.enableRate = true
            newPlayer.rate = slow ? Self.slowRate : 1
            player = newPlayer
            self.completion = completion
            if !newPlayer.play() { finish(FlutterError(code: "play_failed", message: "The clip didn't start.", details: nil)) }
        } catch {
            completion(FlutterError(code: "play_failed", message: error.localizedDescription, details: nil))
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.finish(nil) }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            self.finish(FlutterError(code: "play_failed", message: error?.localizedDescription, details: nil))
        }
    }

    private func finish(_ result: Any?) {
        let done = completion
        completion = nil
        player = nil
        done?(result)
    }
}

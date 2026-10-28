# Screen Share on iOS

Flutter does not build these files. Copy them into the Xcode project once. This is the same design as the SwiftUI app: a Broadcast Upload Extension captures system audio and writes it to an App Group folder, the app reads it and runs Mandarin speech recognition, and the word cards are drawn into a Picture in Picture window.

Needs iOS 17 or later (`AVAudioApplication`, `ImageRenderer`, `MainActor.assumeIsolated`). Test on a real device. The Simulator has no broadcast sheet and no PiP.

Nothing here has been compiled. Expect to fix small things on the first build.

## Steps

Run `flutter create --platforms=ios .` first if there is no `ios/` folder, then open `ios/Runner.xcworkspace`.

1. **Deployment target.** Set the iOS deployment target to 17.0 on the Runner target. Also set `platform :ios, '17.0'` in `ios/Podfile`.

2. **Add the app files.** Drag everything in `ios_native/Runner/` and `ios_native/Shared/BroadcastShared.swift` into the Runner group. Tick "Copy items if needed" and the Runner target.

3. **Register the plugin.** In `ios/Runner/AppDelegate.swift`, after `GeneratedPluginRegistrant.register(with: self)`:

   ```swift
   ScreenSharePlugin.register(with: self.registrar(forPlugin: "ScreenSharePlugin")!)
   ```

   If your template uses `didInitializeImplicitFlutterEngine(_ engineBridge:)`, call `ScreenSharePlugin.register(with: engineBridge.pluginRegistry.registrar(forPlugin: "ScreenSharePlugin")!)` there instead.

4. **App Group.** On the Runner target, Signing & Capabilities, add App Groups and a group named `group.<Runner bundle id>`. For bundle id `com.example.subtitleLearn` that is `group.com.example.subtitleLearn`. The extension's bundle id must be the Runner id plus a suffix, and the shared code takes the group name from that.

5. **Extension target.** File > New > Target > Broadcast Upload Extension. Name it `SubtitleBroadcast`, untick "Include UI Extension", bundle id `<Runner bundle id>.SubtitleBroadcast`. Then:
   - Delete the `SampleHandler.swift` Xcode generated.
   - Add `SubtitleBroadcast/SampleHandler.swift`, `SubtitleBroadcast/BroadcastAudioWriter.swift` and `Shared/BroadcastShared.swift` to the extension target. `BroadcastShared.swift` must belong to both targets.
   - Replace the extension's `Info.plist` contents with `SubtitleBroadcast/Info.plist`.
   - Replace its entitlements with `SubtitleBroadcast/SubtitleBroadcast.entitlements` and put your group name in it.
   - Set the extension's deployment target to 17.0 and add the same App Group under Signing & Capabilities.

6. **Privacy manifest.** Drag `ios/Runner/PrivacyInfo.xcprivacy` into the Runner group and tick the Runner target. It declares the UserDefaults access that `shared_preferences` makes, the same as the Swift app's manifest.

7. **Runner Info.plist** (`ios/Runner/Info.plist`):

   ```xml
   <key>UIBackgroundModes</key>
   <array><string>audio</string></array>
   <key>NSMicrophoneUsageDescription</key>
   <string>Used to turn your speech into text.</string>
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>Used to transcribe Mandarin you hear.</string>
   ```

   The first two keys are already there if you followed the main README.

8. **Build phase order.** If the build fails with "Cycle inside Runner", open Runner > Build Phases and drag "Embed Foundation Extensions" (or "Embed App Extensions") above "Thin Binary". This is a known Flutter and extension clash.

## Trying it

- Screen Share tab, pick Screen audio, tap Start, choose Subtitle Learn in the sheet, tap Start Broadcast. Open a video with Mandarin speech. The PiP window opens by itself, retrying for a few seconds while the sheet closes.
- Mic mode skips the extension and listens through the microphone.
- If the tab says the broadcast extension was not found, step 5 or the App Group in step 4 is wrong.

## How it fits together

- `Runner/ScreenSharePlugin.swift`, `ScreenShareBridge.swift`, `ScreenShareEventStream.swift`: channel handlers and events. Channel names are `subtitle_learn/screen_share` and `subtitle_learn/screen_share/events`.
- `Runner/SpeechTranscriber.swift`: `SFSpeechRecognizer` for zh-CN. Restarts after each result, gives up after three failures in a row.
- `Runner/BroadcastAudioReceiver.swift`: polls the shared folder every 150 ms for 16 kHz chunks.
- `Runner/PipController.swift`, `PipFrameRenderer.swift`, `PipSubtitleView.swift`, `PipWordCard.swift`, `SubtitleLineLayout.swift`: the PiP window.
- `Runner/AudioClipRecorder.swift`, `AudioClipStore.swift`, `AudioClipPlayer.swift`, `WavEncoder.swift`: keep a short clip per heard word. Clips are dropped at session end except for saved words, and replayed from the word sheet.
- `SubtitleBroadcast/`: the extension. Only system audio is used, video frames are ignored.

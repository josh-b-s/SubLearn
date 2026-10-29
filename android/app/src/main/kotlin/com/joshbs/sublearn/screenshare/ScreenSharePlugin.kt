package com.joshbs.sublearn.screenshare

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.joshbs.sublearn.audio.SharedRecognizer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** Dart side of Screen Share on Android. Same channel names as the iOS plugin. */
class ScreenSharePlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var events: EventChannel
    private var binding: ActivityPluginBinding? = null
    private var overlay: OverlayWindow? = null

    /** Waits for the microphone permission prompt to finish. */
    private var pendingStart: Pair<CaptureService.Source, MethodChannel.Result>? = null

    override fun onAttachedToEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        context = flutter.applicationContext
        methods = MethodChannel(flutter.binaryMessenger, "subtitle_learn/screen_share").also { it.setMethodCallHandler(this) }
        events = EventChannel(flutter.binaryMessenger, "subtitle_learn/screen_share/events").also { it.setStreamHandler(this) }
    }

    override fun onDetachedFromEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        endSession()
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        binding?.removeActivityResultListener(this)
        binding?.removeRequestPermissionsResultListener(this)
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        ScreenShareEvents.sink = sink
    }

    override fun onCancel(arguments: Any?) {
        ScreenShareEvents.sink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "capabilities" -> result.success(capabilities())
            "start" -> start(sourceOf(call), result)
            "showBroadcastPicker" -> askForProjection(result)
            "stop" -> {
                endSession()
                result.success(null)
            }
            "updatePip" -> {
                overlay?.update(call.argument<List<*>>("lines") ?: emptyList<Any>())
                result.success(null)
            }
            "presentPip" -> presentPip(result)
            else -> result.notImplemented()
        }
    }

    private fun capabilities(): Map<String, Any> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return mapOf("unsupportedReason" to "Screen Share on Android needs Android 10 or later.")
        }
        // The shared channel reads these two keys: the window can be shown, and the speech model is bundled.
        return mapOf("pip" to true, "broadcastExtension" to SharedRecognizer.isBundled(context.assets))
    }

    private fun sourceOf(call: MethodCall) =
        if (call.argument<String>("source") == "microphone") CaptureService.Source.MIC else CaptureService.Source.SCREEN

    /** Checks everything a session needs. The microphone starts right away, screen audio waits for [askForProjection]. */
    private fun start(source: CaptureService.Source, result: MethodChannel.Result) {
        val activity = binding?.activity ?: return result.error("no_activity", "The app is not in the foreground.", null)

        if (!SharedRecognizer.isBundled(context.assets)) {
            return result.error("no_model", "The speech model is not in this build. See Screen Share on Android in README.md.", null)
        }
        if (!Settings.canDrawOverlays(context)) {
            activity.startActivity(
                Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:${context.packageName}"))
            )
            return result.error("no_overlay", "Allow \"Display over other apps\" for Subtitle Learn, then start again.", null)
        }
        if (context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            pendingStart = source to result
            activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_AUDIO)
            return
        }
        begin(source, result)
    }

    private fun begin(source: CaptureService.Source, result: MethodChannel.Result) {
        if (source == CaptureService.Source.MIC) CaptureService.start(context, source)
        result.success(null)
    }

    private fun askForProjection(result: MethodChannel.Result) {
        val activity = binding?.activity ?: return result.error("no_activity", "The app is not in the foreground.", null)
        val manager = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        activity.startActivityForResult(manager.createScreenCaptureIntent(), REQUEST_PROJECTION)
        result.success(null)
    }

    private fun presentPip(result: MethodChannel.Result) {
        val window = overlay ?: OverlayWindow(context).also { overlay = it }
        window.show()
        result.success(null)
    }

    private fun endSession() {
        CaptureService.stop(context)
        overlay?.hide()
        overlay = null
        pendingStart = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_PROJECTION) return false
        if (resultCode == Activity.RESULT_OK && data != null) {
            CaptureService.start(context, CaptureService.Source.SCREEN, resultCode, data)
        } else {
            ScreenShareEvents.ended() // Cancelled in the system dialog.
        }
        return true
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode != REQUEST_AUDIO) return false
        val (source, result) = pendingStart ?: return true
        pendingStart = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            begin(source, result)
        } else {
            result.error("no_audio", "Microphone access is needed to hear the audio. Allow it in Settings and start again.", null)
        }
        return true
    }

    private companion object {
        const val REQUEST_PROJECTION = 4401
        const val REQUEST_AUDIO = 4402
    }
}

package com.joshbs.sublearn.screenshare

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

/**
 * The floating subtitle window: a second Flutter engine running `overlayMain` inside a system
 * overlay. Dart draws everything. Moving and resizing are done here with raw screen coordinates,
 * because the window moves under the finger and Dart only sees window-relative positions.
 */
class OverlayWindow(private val context: Context) {

    private enum class Gesture { MOVE, RESIZE }

    private class Anchor(val rawX: Float, val rawY: Float, val box: Box)

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private val density = context.resources.displayMetrics.density

    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null
    private var view: FlutterView? = null
    private var params: WindowManager.LayoutParams? = null

    private var gesture: Gesture? = null
    private var anchor: Anchor? = null
    private var lastLines: List<*> = emptyList<Any>()

    val isShowing: Boolean get() = view != null

    fun show() {
        if (view != null) return

        val engine = FlutterEngine(context)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(FlutterInjector.instance().flutterLoader().findAppBundlePath(), "overlayMain")
        )
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(::onCall)

        val flutterView = FlutterView(context, FlutterTextureView(context).apply { isOpaque = false })
        flutterView.setBackgroundColor(Color.TRANSPARENT)
        flutterView.attachToFlutterEngine(engine)
        flutterView.setOnTouchListener { _, event ->
            track(event)
            false // Dart still needs the touches to tell a drag from a tap.
        }
        engine.lifecycleChannel.appIsResumed()

        val layout = layoutParams(savedBox())
        windowManager.addView(flutterView, layout)

        this.engine = engine
        this.channel = channel
        this.view = flutterView
        this.params = layout
        ScreenShareEvents.pip(true)
    }

    fun hide() {
        val flutterView = view ?: return
        windowManager.removeView(flutterView)
        flutterView.detachFromFlutterEngine()
        channel?.setMethodCallHandler(null)
        engine?.destroy()
        view = null
        channel = null
        engine = null
        params = null
        gesture = null
        anchor = null
        ScreenShareEvents.pip(false)
    }

    /** [lines] is the list of maps made by Dart's `PipLine.toJson`. */
    fun update(lines: List<*>) {
        lastLines = lines
        channel?.invokeMethod("lines", lines)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Dart registers its handler a moment after the engine starts, so it asks for the lines.
            "ready" -> channel?.invokeMethod("lines", lastLines)
            "beginGesture" -> gesture = if (call.arguments == "resize") Gesture.RESIZE else Gesture.MOVE
            "endGesture" -> endGesture()
            "openApp" -> openApp()
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    private fun track(event: MotionEvent) {
        val layout = params ?: return
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> anchor = Anchor(event.rawX, event.rawY, boxOf(layout))
            MotionEvent.ACTION_MOVE -> applyGesture(event)
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> endGesture()
        }
    }

    private fun applyGesture(event: MotionEvent) {
        val layout = params ?: return
        val flutterView = view ?: return
        val start = anchor ?: return
        val dx = (event.rawX - start.rawX).roundToInt()
        val dy = (event.rawY - start.rawY).roundToInt()
        val screen = context.resources.displayMetrics

        val box = when (gesture) {
            Gesture.MOVE -> OverlayGeometry.moved(start.box, dx, dy, screen.widthPixels, screen.heightPixels, dp(REACH_DP))
            Gesture.RESIZE -> OverlayGeometry.resized(start.box, dx, dy, dp(MIN_WIDTH_DP), dp(MIN_HEIGHT_DP))
            null -> return
        }
        layout.x = box.x
        layout.y = box.y
        layout.width = box.width
        layout.height = box.height
        windowManager.updateViewLayout(flutterView, layout)
    }

    private fun endGesture() {
        if (gesture != null) params?.let { save(boxOf(it)) }
        gesture = null
        anchor = null
    }

    private fun openApp() {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return
        context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT))
    }

    private fun layoutParams(box: Box) = WindowManager.LayoutParams(
        box.width,
        box.height,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        // Not focusable so the video app keeps the keyboard and back button. Layout in screen so
        // x and y match the raw touch coordinates.
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
        PixelFormat.TRANSLUCENT
    ).apply {
        gravity = Gravity.TOP or Gravity.START
        x = box.x
        y = box.y
    }

    private fun boxOf(layout: WindowManager.LayoutParams) = Box(layout.x, layout.y, layout.width, layout.height)

    private fun savedBox(): Box {
        val screen = context.resources.displayMetrics
        val width = prefs.getInt(KEY_WIDTH, dp(DEFAULT_WIDTH_DP)).coerceAtMost(screen.widthPixels)
        val height = prefs.getInt(KEY_HEIGHT, dp(DEFAULT_HEIGHT_DP)).coerceAtMost(screen.heightPixels)
        return Box(
            x = prefs.getInt(KEY_X, (screen.widthPixels - width) / 2),
            y = prefs.getInt(KEY_Y, screen.heightPixels / 6),
            width = width,
            height = height,
        )
    }

    private fun save(box: Box) {
        prefs.edit()
            .putInt(KEY_X, box.x).putInt(KEY_Y, box.y)
            .putInt(KEY_WIDTH, box.width).putInt(KEY_HEIGHT, box.height)
            .apply()
    }

    private fun dp(value: Int) = (value * density).roundToInt()

    private companion object {
        const val CHANNEL = "subtitle_learn/overlay"
        const val PREFS = "subtitle_window"
        const val KEY_X = "x"
        const val KEY_Y = "y"
        const val KEY_WIDTH = "width"
        const val KEY_HEIGHT = "height"
        const val DEFAULT_WIDTH_DP = 320
        const val DEFAULT_HEIGHT_DP = 200
        const val MIN_WIDTH_DP = 180
        const val MIN_HEIGHT_DP = 110
        const val REACH_DP = 96
    }
}

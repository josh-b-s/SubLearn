package com.joshbs.sublearn.screenshare

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/** Carries events from the capture service and overlay to Dart. Dropped while Dart isn't listening. */
object ScreenShareEvents {
    @Volatile
    var sink: EventChannel.EventSink? = null

    private val main = Handler(Looper.getMainLooper())

    fun started() = send("type" to "started")

    fun ended() = send("type" to "ended")

    fun text(text: String, isFinal: Boolean) = send("type" to "text", "text" to text, "isFinal" to isFinal)

    fun error(message: String) = send("type" to "error", "message" to message)

    fun pip(active: Boolean) = send("type" to "pip", "active" to active)

    private fun send(vararg entries: Pair<String, Any>) {
        val event = mapOf(*entries)
        main.post { sink?.success(event) }
    }
}

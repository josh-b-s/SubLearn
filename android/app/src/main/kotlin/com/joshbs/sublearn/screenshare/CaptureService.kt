package com.joshbs.sublearn.screenshare

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import com.joshbs.sublearn.R
import com.joshbs.sublearn.audio.AudioRecordFactory
import com.joshbs.sublearn.audio.AudioTranscriptionLoop
import com.joshbs.sublearn.audio.SttEngine

/**
 * Foreground service that records system playback audio (or the mic), runs speech recognition
 * and reports the text to Dart through [ScreenShareEvents]. The overlay window is not owned here.
 */
class CaptureService : Service() {

    enum class Source { SCREEN, MIC }

    private var projection: MediaProjection? = null
    private var worker: Thread? = null

    @Volatile
    private var running = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (worker != null) return START_NOT_STICKY
        val source = Source.valueOf(intent?.getStringExtra(EXTRA_SOURCE) ?: Source.SCREEN.name)

        // Playback capture needs API 29. The plugin already refuses older devices.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return fail("Screen Share needs Android 10 or later.")

        startForeground(NOTIFICATION_ID, notification(), foregroundType(source))

        if (source == Source.SCREEN) {
            val resultCode = intent?.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
            val data = intent?.getParcelableExtra<Intent>(EXTRA_DATA)
            if (resultCode != Activity.RESULT_OK || data == null) return fail("Screen capture was not allowed.")
            val manager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            val granted = manager.getMediaProjection(resultCode, data) ?: return fail("Couldn't start screen capture.")
            watchForRevoke(granted)
            projection = granted
        }

        running = true
        worker = Thread({ capture(source) }, "screen-share-capture").also { it.start() }
        return START_NOT_STICKY
    }

    // Android 14 requires a callback to be registered before the projection is used.
    private fun watchForRevoke(p: MediaProjection) {
        p.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() {
                ScreenShareEvents.ended()
                stopSelf()
            }
        }, Handler(Looper.getMainLooper()))
    }

    private fun capture(source: Source) {
        var record: AudioRecord? = null
        var engine: SttEngine? = null
        try {
            // Loading the model takes seconds, so do it before the record starts filling its buffer.
            engine = SttEngine(assets)
            record = openRecord(source)
            if (record == null) {
                ScreenShareEvents.error("Couldn't open the audio input.")
                return
            }
            record.startRecording()
            ScreenShareEvents.started()

            AudioTranscriptionLoop(record, engine).run(
                isRunning = { running },
                onResult = { ScreenShareEvents.text(it, isFinal = false) },
                onEndpoint = { if (it.isNotBlank()) ScreenShareEvents.text(it, isFinal = true) },
                onReadError = { code -> ScreenShareEvents.error("audio read failed ($code)") },
                onProcessError = { Log.w(TAG, "Dropped a chunk: ${it.message}") }
            )
        } catch (e: Throwable) { // Throwable: a missing sherpa .so is an UnsatisfiedLinkError.
            Log.e(TAG, "Capture failed", e)
            ScreenShareEvents.error(e.message ?: e.javaClass.simpleName)
        } finally {
            record?.stop()
            record?.release()
            engine?.release()
            stopSelf()
        }
    }

    private fun openRecord(source: Source): AudioRecord? = when (source) {
        Source.MIC -> AudioRecordFactory.create(AudioRecordFactory.Source.Mic, minBufferFloor = MIC_BUFFER_FLOOR)
        Source.SCREEN -> projection?.let { AudioRecordFactory.create(AudioRecordFactory.Source.PlaybackCapture(it)) }
    }

    private fun fail(message: String): Int {
        ScreenShareEvents.error(message)
        stopSelf()
        return START_NOT_STICKY
    }

    private fun foregroundType(source: Source): Int = when (source) {
        Source.SCREEN -> ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
        Source.MIC -> ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
    }

    private fun notification(): Notification {
        getSystemService(NotificationManager::class.java).createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Screen Share", NotificationManager.IMPORTANCE_LOW)
        )
        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Live subtitles")
            .setContentText("Listening for Mandarin")
            .setSmallIcon(R.mipmap.ic_launcher)
            .build()
    }

    override fun onDestroy() {
        running = false
        worker?.join(JOIN_TIMEOUT_MS)
        worker = null
        projection?.stop()
        projection = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        private const val TAG = "CaptureService"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "screen_share"
        private const val EXTRA_SOURCE = "source"
        private const val EXTRA_RESULT_CODE = "resultCode"
        private const val EXTRA_DATA = "data"
        private const val JOIN_TIMEOUT_MS = 1500L

        // Some devices report a minimum buffer that is too small to keep up with the mic.
        private const val MIC_BUFFER_FLOOR = 4096

        fun start(context: Context, source: Source, resultCode: Int = Activity.RESULT_CANCELED, data: Intent? = null) {
            val intent = Intent(context, CaptureService::class.java)
                .putExtra(EXTRA_SOURCE, source.name)
                .putExtra(EXTRA_RESULT_CODE, resultCode)
                .putExtra(EXTRA_DATA, data)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CaptureService::class.java))
        }
    }
}

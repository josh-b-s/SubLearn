package com.joshbs.sublearn.audio

import android.content.res.AssetManager
import android.util.Log
import com.k2fsa.sherpa.onnx.OnlineStream

/** One STT session: an `OnlineStream` against the shared recognizer. */
class SttEngine(assets: AssetManager) {

    private val recognizer = SharedRecognizer.getOrCreate(assets)
    private val stream: OnlineStream = recognizer.createStream()

    init {
        Log.i(TAG, "Session started")
    }

    /** Feed PCM samples and return the current partial/final result text. */
    fun process(samples: FloatArray): String {
        stream.acceptWaveform(samples, SAMPLE_RATE)
        while (recognizer.isReady(stream)) recognizer.decode(stream)
        return recognizer.getResult(stream).text
    }

    fun isEndpoint(): Boolean = recognizer.isEndpoint(stream)

    fun reset() = recognizer.reset(stream)

    /** Releases this session's stream. The shared model itself stays loaded for other sessions. */
    fun release() {
        stream.release()
        Log.i(TAG, "Session released")
    }

    companion object {
        const val SAMPLE_RATE = SharedRecognizer.SAMPLE_RATE
        private const val TAG = "SttEngine"
    }
}

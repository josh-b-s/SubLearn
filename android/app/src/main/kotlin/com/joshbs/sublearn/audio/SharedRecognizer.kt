package com.joshbs.sublearn.audio

import android.content.res.AssetManager
import android.util.Log
import com.k2fsa.sherpa.onnx.OnlineModelConfig
import com.k2fsa.sherpa.onnx.OnlineParaformerModelConfig
import com.k2fsa.sherpa.onnx.OnlineRecognizer
import com.k2fsa.sherpa.onnx.OnlineRecognizerConfig
import com.k2fsa.sherpa.onnx.getEndpointConfig
import com.k2fsa.sherpa.onnx.getFeatureConfig

/** Loads the STT model once and keeps it for the life of the process, so a new session only pays for a stream. */
object SharedRecognizer {
    private const val TAG = "SharedRecognizer"
    const val SAMPLE_RATE = 16000
    private val MODEL_FILES = setOf("encoder.int8.onnx", "decoder.int8.onnx", "tokens.txt")

    @Volatile
    private var recognizer: OnlineRecognizer? = null

    /** Returns the shared recognizer, loading it on first call. Blocks the caller while loading. */
    @Synchronized
    fun getOrCreate(assets: AssetManager): OnlineRecognizer {
        recognizer?.let { return it }

        Log.i(TAG, "Loading STT model…")
        val loaded = OnlineRecognizer(
            assets,
            OnlineRecognizerConfig(
                featConfig = getFeatureConfig(sampleRate = SAMPLE_RATE, featureDim = 80),
                modelConfig = OnlineModelConfig(
                    paraformer = OnlineParaformerModelConfig(
                        encoder = "model/encoder.int8.onnx",
                        decoder = "model/decoder.int8.onnx"
                    ),
                    tokens = "model/tokens.txt",
                    numThreads = 2,
                    provider = "cpu"
                ),
                endpointConfig = getEndpointConfig(),
                enableEndpoint = true
            )
        )
        recognizer = loaded
        Log.i(TAG, "STT model loaded")
        return loaded
    }


    /** True when the three model files were copied into assets/model. */
    fun isBundled(assets: AssetManager): Boolean =
        (assets.list("model") ?: emptyArray()).toSet().containsAll(MODEL_FILES)
}

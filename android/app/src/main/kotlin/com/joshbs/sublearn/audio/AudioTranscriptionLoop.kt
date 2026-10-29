package com.joshbs.sublearn.audio

import android.media.AudioRecord

/** Reads 100 ms of PCM at a time from an [AudioRecord], feeds it to an [SttEngine] and reports the text. */
class AudioTranscriptionLoop(
    private val record: AudioRecord,
    private val engine: SttEngine
) {
    /**
     * Blocks the calling thread until [isRunning] turns false or a read error occurs.
     *
     * @param onResult called whenever the partial text of the current utterance changes.
     * @param onEndpoint called when the engine detects the end of an utterance, with its last text.
     *   The engine is reset right before this fires.
     * @param onReadError called when `AudioRecord.read` returns a negative code. Stops the loop.
     * @param onProcessError called when one chunk fails. The engine is reset and the loop goes on.
     */
    fun run(
        isRunning: () -> Boolean,
        onResult: (String) -> Unit,
        onEndpoint: (String) -> Unit,
        onReadError: (Int) -> Unit,
        onProcessError: (Exception) -> Unit
    ) {
        val buffer = ShortArray((0.1 * SttEngine.SAMPLE_RATE).toInt())
        var lastText = ""

        while (isRunning()) {
            val read = record.read(buffer, 0, buffer.size)
            if (read < 0) {
                onReadError(read)
                break
            }
            if (read == 0) continue

            try {
                val samples = FloatArray(read) { buffer[it] / 32768f }
                val text = engine.process(samples)

                if (text.isNotBlank() && text != lastText) {
                    lastText = text
                    onResult(text)
                }

                if (engine.isEndpoint()) {
                    val finalText = lastText
                    engine.reset()
                    lastText = ""
                    onEndpoint(finalText)
                }
            } catch (e: Exception) {
                onProcessError(e)
                try { engine.reset() } catch (_: Exception) { /* best effort */ }
                lastText = ""
            }
        }
    }
}

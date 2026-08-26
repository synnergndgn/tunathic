package dev.gundev.tunathic.audio

import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.Keep
import dev.gundev.tunathic.BuildConfig
import java.io.Closeable

internal data class NativeEngineInfo(
    val engineInstanceId: Long,
    val streamGeneration: Long,
    val lifecycleState: String,
    val audioApi: String,
    val sampleRate: Int,
    val framesPerBurst: Int,
    val bufferSizeFrames: Int,
)

internal data class NativeStartResult(
    val runId: Long,
    val streamGeneration: Long,
)

internal data class NativeStopReport(
    val framesRendered: Long,
    val xRunCount: Int,
)

internal interface NativeMetronomeEventListener {
    fun onBeat(
        runId: Long,
        streamGeneration: Long,
        sequence: Int,
        beatNumber: Int,
        accented: Boolean,
        audioFramePosition: Long,
        callbackTimeNanos: Long,
    )

    fun onError(
        runId: Long,
        streamGeneration: Long,
        code: String,
        message: String,
    )
}

@Keep
internal class NativeMetronomeEngine(
    private val listener: NativeMetronomeEventListener,
) : Closeable {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var nativeHandle: Long = nativeCreate()
    private var currentRunId: Long = 0
    private var currentStreamGeneration: Long = 0
    private var initialized = false
    private var running = false

    init {
        check(nativeHandle != 0L) { "Could not create native metronome engine" }
        debug("create handle=$nativeHandle")
    }

    fun initialize(
        regularWav: ByteArray,
        accentWav: ByteArray,
        bpm: Int,
        beatsPerMeasure: Int,
        beatUnit: Int,
        volume: Float,
        accentEnabled: Boolean,
    ): NativeEngineInfo {
        require(nativeHandle != 0L) { "Metronome engine is closed" }
        debug(
            "initialize handle=$nativeHandle bpm=$bpm " +
                "signature=$beatsPerMeasure/$beatUnit",
        )
        nativeInitialize(
            nativeHandle,
            regularWav,
            accentWav,
            bpm,
            beatsPerMeasure,
            beatUnit,
            volume,
            accentEnabled,
        )
        initialized = true
        running = false
        val info = readInfo()
        currentStreamGeneration = info.streamGeneration
        debug(
            "initialized engine=${info.engineInstanceId} " +
                "streamGeneration=${info.streamGeneration} " +
                "state=${info.lifecycleState} api=${info.audioApi} " +
                "sampleRate=${info.sampleRate} framesPerBurst=${info.framesPerBurst} " +
                "bufferFrames=${info.bufferSizeFrames}",
        )
        return info
    }

    fun getInfo(): NativeEngineInfo {
        check(initialized) { "Metronome engine is not initialized" }
        return readInfo()
    }

    fun start(): NativeStartResult {
        check(initialized) { "Metronome engine is not initialized" }
        debug(
            "start request handle=$nativeHandle state=${nativeGetLifecycleState(nativeHandle)} " +
                "streamGeneration=$currentStreamGeneration",
        )
        currentRunId = nativeStart(nativeHandle)
        currentStreamGeneration = nativeGetStreamGeneration(nativeHandle)
        running = true
        debug(
            "start result run=$currentRunId streamGeneration=$currentStreamGeneration " +
                "state=${nativeGetLifecycleState(nativeHandle)}",
        )
        return NativeStartResult(currentRunId, currentStreamGeneration)
    }

    fun stop(): NativeStopReport {
        if (!initialized) return NativeStopReport(0, 0)
        debug(
            "stop request run=$currentRunId streamGeneration=$currentStreamGeneration " +
                "state=${nativeGetLifecycleState(nativeHandle)}",
        )
        running = false
        val values = nativeStop(nativeHandle)
        return NativeStopReport(
            framesRendered = values.getOrElse(0) { 0L },
            xRunCount = values.getOrElse(1) { 0L }.toInt(),
        )
    }

    fun setBpm(bpm: Int) {
        check(initialized) { "Metronome engine is not initialized" }
        nativeSetBpm(nativeHandle, bpm)
    }

    fun setTimeSignature(beatsPerMeasure: Int, beatUnit: Int) {
        check(initialized) { "Metronome engine is not initialized" }
        nativeSetTimeSignature(nativeHandle, beatsPerMeasure, beatUnit)
    }

    fun setVolume(volume: Float) {
        check(initialized) { "Metronome engine is not initialized" }
        nativeSetVolume(nativeHandle, volume)
    }

    fun setAccentEnabled(enabled: Boolean) {
        check(initialized) { "Metronome engine is not initialized" }
        nativeSetAccentEnabled(nativeHandle, enabled)
    }

    fun dispose() {
        if (nativeHandle == 0L) return
        debug(
            "dispose handle=$nativeHandle run=$currentRunId " +
                "streamGeneration=$currentStreamGeneration",
        )
        running = false
        nativeDispose(nativeHandle)
        initialized = false
        currentRunId = 0
        currentStreamGeneration = 0
    }

    override fun close() {
        if (nativeHandle == 0L) return
        debug(
            "close handle=$nativeHandle run=$currentRunId " +
                "streamGeneration=$currentStreamGeneration",
        )
        running = false
        nativeDestroy(nativeHandle)
        nativeHandle = 0
        initialized = false
        currentRunId = 0
        currentStreamGeneration = 0
        mainHandler.removeCallbacksAndMessages(null)
    }

    @Keep
    @Suppress("unused")
    private fun onNativeBeat(
        runId: Long,
        streamGeneration: Long,
        sequence: Int,
        beatNumber: Int,
        accented: Boolean,
        audioFramePosition: Long,
        callbackTimeNanos: Long,
    ) {
        mainHandler.post {
            val accepted =
                nativeHandle != 0L &&
                    running &&
                    runId == currentRunId &&
                    streamGeneration == currentStreamGeneration
            if (sequence == 1 || !accepted) {
                debug(
                    "beat callback run=$runId streamGeneration=$streamGeneration " +
                        "sequence=$sequence accepted=$accepted currentRun=$currentRunId " +
                        "currentStreamGeneration=$currentStreamGeneration",
                )
            }
            if (accepted) {
                listener.onBeat(
                    runId,
                    streamGeneration,
                    sequence,
                    beatNumber,
                    accented,
                    audioFramePosition,
                    callbackTimeNanos,
                )
            }
        }
    }

    @Keep
    @Suppress("unused")
    private fun onNativeError(
        runId: Long,
        streamGeneration: Long,
        code: String,
        message: String,
    ) {
        mainHandler.post {
            val accepted =
                nativeHandle != 0L &&
                    runId == currentRunId &&
                    streamGeneration == currentStreamGeneration
            debug(
                "error callback run=$runId streamGeneration=$streamGeneration " +
                    "code=$code accepted=$accepted currentRun=$currentRunId " +
                    "currentStreamGeneration=$currentStreamGeneration message=$message",
            )
            if (accepted) {
                running = false
                listener.onError(
                    runId,
                    streamGeneration,
                    code,
                    message,
                )
            }
        }
    }

    private fun readInfo() = NativeEngineInfo(
        engineInstanceId = nativeGetEngineInstanceId(nativeHandle),
        streamGeneration = nativeGetStreamGeneration(nativeHandle),
        lifecycleState = nativeGetLifecycleState(nativeHandle),
        audioApi = nativeGetAudioApi(nativeHandle),
        sampleRate = nativeGetSampleRate(nativeHandle),
        framesPerBurst = nativeGetFramesPerBurst(nativeHandle),
        bufferSizeFrames = nativeGetBufferSizeFrames(nativeHandle),
    )

    private external fun nativeCreate(): Long

    private external fun nativeInitialize(
        handle: Long,
        regularWav: ByteArray,
        accentWav: ByteArray,
        bpm: Int,
        beatsPerMeasure: Int,
        beatUnit: Int,
        volume: Float,
        accentEnabled: Boolean,
    )

    private external fun nativeStart(handle: Long): Long
    private external fun nativeStop(handle: Long): LongArray
    private external fun nativeSetBpm(handle: Long, bpm: Int)
    private external fun nativeSetTimeSignature(
        handle: Long,
        beatsPerMeasure: Int,
        beatUnit: Int,
    )

    private external fun nativeSetVolume(handle: Long, volume: Float)
    private external fun nativeSetAccentEnabled(handle: Long, enabled: Boolean)
    private external fun nativeGetEngineInstanceId(handle: Long): Long
    private external fun nativeGetStreamGeneration(handle: Long): Long
    private external fun nativeGetLifecycleState(handle: Long): String
    private external fun nativeGetAudioApi(handle: Long): String
    private external fun nativeGetSampleRate(handle: Long): Int
    private external fun nativeGetFramesPerBurst(handle: Long): Int
    private external fun nativeGetBufferSizeFrames(handle: Long): Int
    private external fun nativeDispose(handle: Long)
    private external fun nativeDestroy(handle: Long)

    private fun debug(message: String) {
        if (BuildConfig.DEBUG) Log.d(LOG_TAG, message)
    }

    private companion object {
        const val LOG_TAG = "TunathicMetronome"

        init {
            System.loadLibrary("tunathic_metronome")
        }
    }
}

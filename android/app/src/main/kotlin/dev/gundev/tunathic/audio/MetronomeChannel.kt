package dev.gundev.tunathic.audio

import android.util.Log
import dev.gundev.tunathic.BuildConfig
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.Closeable

internal class MetronomeChannel(
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    NativeMetronomeEventListener,
    Closeable {
    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private val engine = NativeMetronomeEngine(this)
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (BuildConfig.DEBUG) {
            Log.d(LOG_TAG, "method call=${call.method}")
        }
        try {
            when (call.method) {
                "initialize" -> {
                    val info = engine.initialize(
                        regularWav = call.requiredBytes("regularWav"),
                        accentWav = call.requiredBytes("accentWav"),
                        bpm = call.requiredInt("bpm"),
                        beatsPerMeasure = call.requiredInt("beatsPerMeasure"),
                        beatUnit = call.requiredInt("beatUnit"),
                        volume = call.requiredDouble("volume").toFloat(),
                        accentEnabled = call.requiredBoolean("accentEnabled"),
                    )
                    result.success(info.toMap())
                }

                "getInfo" -> result.success(engine.getInfo().toMap())
                "start" -> result.success(engine.start().toMap())
                "stop" -> result.success(engine.stop().toMap())
                "setBpm" -> {
                    engine.setBpm(call.requiredInt("bpm"))
                    result.success(null)
                }

                "setTimeSignature" -> {
                    engine.setTimeSignature(
                        beatsPerMeasure = call.requiredInt("beatsPerMeasure"),
                        beatUnit = call.requiredInt("beatUnit"),
                    )
                    result.success(null)
                }

                "setVolume" -> {
                    engine.setVolume(call.requiredDouble("volume").toFloat())
                    result.success(null)
                }

                "setAccentEnabled" -> {
                    engine.setAccentEnabled(call.requiredBoolean("enabled"))
                    result.success(null)
                }

                "dispose" -> {
                    engine.dispose()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            result.error(
                "metronome_engine",
                error.message ?: error.javaClass.simpleName,
                null,
            )
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onBeat(
        runId: Long,
        streamGeneration: Long,
        sequence: Int,
        beatNumber: Int,
        accented: Boolean,
        audioFramePosition: Long,
        callbackTimeNanos: Long,
    ) {
        eventSink?.success(
            mapOf(
                "type" to "beat",
                "runId" to runId,
                "streamGeneration" to streamGeneration,
                "sequence" to sequence,
                "beatNumber" to beatNumber,
                "accented" to accented,
                "audioFramePosition" to audioFramePosition,
                "callbackTimeNanos" to callbackTimeNanos,
            ),
        )
    }

    override fun onError(
        runId: Long,
        streamGeneration: Long,
        code: String,
        message: String,
    ) {
        eventSink?.success(
            mapOf(
                "type" to "error",
                "runId" to runId,
                "streamGeneration" to streamGeneration,
                "code" to code,
                "message" to message,
            ),
        )
    }

    override fun close() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        engine.close()
    }

    private fun NativeEngineInfo.toMap(): Map<String, Any> = mapOf(
        "implementation" to "Oboe native audio callback",
        "engineInstanceId" to engineInstanceId,
        "streamGeneration" to streamGeneration,
        "lifecycleState" to lifecycleState,
        "audioApi" to audioApi,
        "sampleRate" to sampleRate,
        "framesPerBurst" to framesPerBurst,
        "bufferSizeFrames" to bufferSizeFrames,
    )

    private fun NativeStartResult.toMap(): Map<String, Any> = mapOf(
        "runId" to runId,
        "streamGeneration" to streamGeneration,
    )

    private fun NativeStopReport.toMap(): Map<String, Any> = mapOf(
        "framesRendered" to framesRendered,
        "xRunCount" to xRunCount,
    )

    private fun MethodCall.requiredBytes(name: String): ByteArray =
        argument<ByteArray>(name) ?: error("Missing $name")

    private fun MethodCall.requiredInt(name: String): Int =
        argument<Int>(name) ?: error("Missing $name")

    private fun MethodCall.requiredDouble(name: String): Double =
        (argument<Number>(name) ?: error("Missing $name")).toDouble()

    private fun MethodCall.requiredBoolean(name: String): Boolean =
        argument<Boolean>(name) ?: error("Missing $name")

    private companion object {
        const val METHOD_CHANNEL = "dev.gundev.tunathic/metronome_engine/methods"
        const val EVENT_CHANNEL = "dev.gundev.tunathic/metronome_engine/events"
        const val LOG_TAG = "TunathicMetronome"
    }
}

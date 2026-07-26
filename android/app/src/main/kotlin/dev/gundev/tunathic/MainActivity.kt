package dev.gundev.tunathic

import dev.gundev.tunathic.audio.MetronomeChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var metronomeChannel: MetronomeChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        metronomeChannel = MetronomeChannel(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        metronomeChannel?.close()
        metronomeChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

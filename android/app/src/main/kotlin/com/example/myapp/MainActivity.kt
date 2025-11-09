package com.example.myapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.example.myapp/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "moveToBackground") {
                moveTaskToBack(true)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}

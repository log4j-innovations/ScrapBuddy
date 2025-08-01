package com.example.scrapbuddy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "api_keys_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVertexAIKey" -> {
                    result.success(getVertexAIKey())
                }
                "getSarvamAIKey" -> {
                    result.success(getSarvamAIKey())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getVertexAIKey(): String {
        return resources.getString(R.string.vertex_ai_api_key)
    }

    private fun getSarvamAIKey(): String {
        return resources.getString(R.string.sarvam_ai_api_key)
    }
}

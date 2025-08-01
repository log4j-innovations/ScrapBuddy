package com.example.scrapbuddy

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "api_keys_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVertexAIKey" -> {
                    try {
                        val ai = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                        val vertexAIKey = ai.metaData.getString("vertex_ai_api_key")
                        result.success(vertexAIKey)
                    } catch (e: Exception) {
                        result.error("KEY_ERROR", "Could not get Vertex AI key", e.message)
                    }
                }
                "getSarvamAIKey" -> {
                    try {
                        val ai = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                        val sarvamAIKey = ai.metaData.getString("sarvam_ai_api_key")
                        result.success(sarvamAIKey)
                    } catch (e: Exception) {
                        result.error("KEY_ERROR", "Could not get Sarvam AI key", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

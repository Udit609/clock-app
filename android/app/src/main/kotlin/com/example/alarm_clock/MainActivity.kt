package com.example.alarm_clock

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.alarm_clock/is_screen_locked"
    private val BROADCAST_CHANNEL = "com.example.alarm_clock/trigger_broadcast"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "isScreenLocked") {
                    val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                    val isLocked = keyguardManager.isKeyguardLocked
                    result.success(isLocked)
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BROADCAST_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "triggerBroadcast") {
                    val broadcastIntent = Intent("com.example.alarm_clock.NOTIFICATION_ACTION")
                    sendBroadcast(broadcastIntent)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}

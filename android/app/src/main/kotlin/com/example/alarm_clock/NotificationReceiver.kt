package com.example.alarm_clock
import android.os.Build
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Create an Intent to launch the MainActivity
        val notificationIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // For Android O and above, use the notification manager to bring the app to the foreground
            context.startForegroundService(notificationIntent)
        } else {
            // For older versions, use the startActivity method
            context.startActivity(notificationIntent)
        }
    }
}

package com.example.icecream

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class RestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action || intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            val serviceIntent = Intent(context, LocationService::class.java)
            context.startForegroundService(serviceIntent)
        }
    }
}

package com.example.icecream
import android.content.Context
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val LOCATION_CHANNEL = "com.example.icecream/locationService"
    private val USERDATA_CHANNEL = "com.example.icecream/userdata"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USERDATA_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendUserId") {
                val userId = call.argument<String>("userId")
                if (userId != null) {
                    saveUserId(userId)
                    Log.d("MainActivity", "Received user ID: $userId")
                    result.success("User ID saved successfully")
                } else {
                    Log.d("MainActivity", "User ID is null")
                    result.error("ERROR", "User ID is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveUserId(userId: String?) {
        val sharedPref = getSharedPreferences("AppData", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("userId", userId)
            apply()
        }
    }
}

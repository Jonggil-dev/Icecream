package com.example.icecream

import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.icecream/foreground_service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "wakeUpScreen") {
                wakeUpScreen()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun wakeUpScreen() {
        // 화면 깨우기
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "MyApp::MyWakelockTag"
        )
        wakeLock.acquire(3000) // 3초 동안 화면을 켬

        // 진동 발생
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val vibrationEffect = VibrationEffect.createWaveform(longArrayOf(0, 500, 250, 500, 250, 500, 250, 500, 250, 500), -1)
            vibrator.vibrate(vibrationEffect)
        } else {
            // API 26 미만에서는 deprecated된 vibrate 메서드 사용
            vibrator.vibrate(longArrayOf(0, 500, 250, 500, 250, 500, 250, 500, 250, 500), -1)
        }

        // 소리 재생
        val mediaPlayer = MediaPlayer.create(this, R.raw.warning_sound)
        mediaPlayer.start()
    }
}

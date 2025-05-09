package com.example.clevertapflutterapp

import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.clevertap.android.sdk.CleverTapAPI
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Inform CleverTap of the notification click event
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cleverTapInstance = CleverTapAPI.getDefaultInstance(applicationContext)
            intent.extras?.let {
                cleverTapInstance?.pushNotificationClickedEvent(it)
            }
        }
    }
}
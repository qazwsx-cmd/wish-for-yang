package dev.bilisail.bilisail

import android.app.Activity
import android.database.ContentObserver
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.OrientationEventListener
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** Owns immersive bars and observes physical rotation independently of UI locks. */
class MobileWindowHandler(private val activity: Activity, messenger: BinaryMessenger) : EventChannel.StreamHandler {
    private val events = EventChannel(messenger, "bilisail/device_orientation")
    private val commands = MethodChannel(messenger, "bilisail/mobile_window")
    private val handler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var resumed = false
    private var fullScreen = false
    private var playbackNavigationHidden = false
    private var immersiveBarsApplied = false
    private var candidate: String? = null
    private var delivered: String? = null
    private var rotationAllowed = false
    private val rotationObserver = object : ContentObserver(handler) {
        override fun onChange(selfChange: Boolean) {
            updateRotationPolicy()
        }
    }
    private fun updateRotationPolicy() {
        val allowed = Settings.System.getInt(
            activity.contentResolver, Settings.System.ACCELEROMETER_ROTATION, 0
        ) == 1
        if (allowed == rotationAllowed) return
        rotationAllowed = allowed
        handler.removeCallbacks(publish)
        candidate = null
        delivered = null
        // A policy transition invalidates any queued Flutter rotation action.
        sink?.success("reset")
        listener.disable()
        if (allowed && resumed && sink != null && listener.canDetectOrientation()) listener.enable()
    }
    private val publish = Runnable {
        val value = candidate
        if (resumed && rotationAllowed && value != null && value != delivered &&
            Settings.System.getInt(activity.contentResolver, Settings.System.ACCELEROMETER_ROTATION, 0) == 1) {
            delivered = value
            sink?.success(value)
        }
    }
    private val listener = object : OrientationEventListener(activity) {
        override fun onOrientationChanged(angle: Int) {
            // Ignore flat/diagonal positions; require a stable cardinal posture.
            val value = when (angle) {
                in 0..25, in 155..205, in 335..359 -> "portrait"
                in 65..115, in 245..295 -> "landscape"
                else -> null
            }
            if (value == candidate) return
            candidate = value
            handler.removeCallbacks(publish)
            if (value != null) handler.postDelayed(publish, 250)
        }
    }

    init {
        events.setStreamHandler(this)
        commands.setMethodCallHandler { call, result ->
            if (call.method != "setFullScreen" && call.method != "setPlaybackNavigationHidden") {
                result.notImplemented()
            } else if (call.arguments !is Boolean) {
                result.error("invalid_argument", "Expected a system bar visibility flag", null)
            } else {
                val enabled = call.arguments as Boolean
                if (call.method == "setFullScreen") {
                    fullScreen = enabled
                } else {
                    playbackNavigationHidden = enabled
                }
                applySystemBars()
                result.success(null)
            }
        }
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        sink = eventSink
        delivered = null
        candidate = null
        rotationAllowed = false
        activity.contentResolver.registerContentObserver(
            Settings.System.getUriFor(Settings.System.ACCELEROMETER_ROTATION), false, rotationObserver
        )
        // Report a locked initial state even when no policy transition occurs.
        sink?.success("reset")
        updateRotationPolicy()
    }

    override fun onCancel(arguments: Any?) {
        activity.contentResolver.unregisterContentObserver(rotationObserver)
        listener.disable()
        handler.removeCallbacks(publish)
        candidate = null
        delivered = null
        sink = null
    }

    fun setResumed(value: Boolean) {
        resumed = value
        if (value) {
            candidate = null
            delivered = null
            if (sink != null) {
                rotationAllowed = false
                sink?.success("reset")
                updateRotationPolicy()
            }
            reapplySystemBars()
        } else {
            listener.disable()
            handler.removeCallbacks(publish)
            candidate = null
        }
    }

    @Suppress("DEPRECATION")
    private fun applySystemBars() {
        if (activity.isInPictureInPictureMode) return
        val immersive = fullScreen || playbackNavigationHidden
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity.window.insetsController?.let { controller ->
                controller.systemBarsBehavior = if (immersive) {
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                } else {
                    WindowInsetsController.BEHAVIOR_DEFAULT
                }
                when {
                    fullScreen -> controller.hide(WindowInsets.Type.systemBars())
                    playbackNavigationHidden -> {
                        controller.show(WindowInsets.Type.statusBars())
                        controller.hide(WindowInsets.Type.navigationBars())
                    }
                    else -> controller.show(WindowInsets.Type.systemBars())
                }
            }
        } else {
            val decor = activity.window.decorView
            val ownedFlags = View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            val layoutFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            val navigationFlags = if (immersive) {
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            } else 0
            val statusFlags = if (fullScreen) View.SYSTEM_UI_FLAG_FULLSCREEN else 0
            decor.systemUiVisibility = (decor.systemUiVisibility and ownedFlags.inv()) or
                layoutFlags or navigationFlags or statusFlags
        }
        immersiveBarsApplied = immersive
    }

    fun reapplySystemBars() {
        if (fullScreen || playbackNavigationHidden || immersiveBarsApplied) applySystemBars()
    }

    fun close() {
        onCancel(null)
        events.setStreamHandler(null)
        commands.setMethodCallHandler(null)
        fullScreen = false
        playbackNavigationHidden = false
        reapplySystemBars()
    }
}

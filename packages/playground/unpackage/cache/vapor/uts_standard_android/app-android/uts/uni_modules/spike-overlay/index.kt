@file:Suppress("UNCHECKED_CAST", "USELESS_CAST", "INAPPLICABLE_JVM_NAME", "UNUSED_ANONYMOUS_PARAMETER", "SENSELESS_COMPARISON", "NAME_SHADOWING", "UNNECESSARY_NOT_NULL_ASSERTION")
package uts.sdk.modules.spikeOverlay
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.WindowManager
import android.widget.TextView
import io.dcloud.uniapp.*
import io.dcloud.uniapp.extapi.*
import io.dcloud.uniappxv.runtime.*
import io.dcloud.unicloud.*
import io.dcloud.uts.*
import io.dcloud.uts.Map
import io.dcloud.uts.Set
import io.dcloud.uts.UTSAndroid
import io.dcloud.uts.autoregister.UTSAutoRegister
import kotlin.properties.Delegates
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
var androidOverlay: TextView? = null
var androidHideTimer: Number = 0
fun buildAndroidToastView(activity: Activity, title: String): TextView {
    val tv = TextView(activity)
    tv.setText(title)
    tv.setTextColor(Color.WHITE)
    val textSp: Number = 16.0
    tv.setTextSize(textSp.toFloat())
    tv.setGravity(Gravity.CENTER)
    val bg = GradientDrawable()
    bg.setColor(Color.parseColor("#D9000000"))
    val radiusPx: Number = 24.0
    bg.setCornerRadius(radiusPx.toFloat())
    tv.setBackground(bg)
    tv.setPadding(48, 28, 48, 28)
    return tv
}
fun showSpikeOverlay(title: String, duration: Number): Unit {
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        console.log("[spike-android] getUniActivity() 为 null，无法挂窗", " at uni_modules/spike-overlay/utssdk/app-android/index.uts:45")
        return
    }
    val activity = act as Activity
    activity.runOnUiThread(fun(){
        try {
            val existing = androidOverlay
            if (existing != null) {
                existing.setText(title)
                console.log("[spike-android] 复用已有窗口视图，更新文案", " at uni_modules/spike-overlay/utssdk/app-android/index.uts:55")
            } else {
                val view = buildAndroidToastView(activity, title)
                val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                val params = WindowManager.LayoutParams()
                params.type = WindowManager.LayoutParams.TYPE_APPLICATION_PANEL
                params.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                params.format = PixelFormat.TRANSLUCENT
                params.width = WindowManager.LayoutParams.WRAP_CONTENT
                params.height = WindowManager.LayoutParams.WRAP_CONTENT
                params.gravity = Gravity.CENTER
                params.token = activity.getWindow().getDecorView().getWindowToken()
                if (params.token == null) {
                    console.log("[spike-android] windowToken 为 null（页面未就绪），放弃挂载", " at uni_modules/spike-overlay/utssdk/app-android/index.uts:73")
                    return
                }
                wm.addView(view, params)
                androidOverlay = view
                val alpha0: Number = 0.0
                val alpha1: Number = 1.0
                view.setAlpha(alpha0.toFloat())
                view.animate().alpha(alpha1.toFloat()).setDuration(200).start()
                console.log("[spike-android] addView 成功 type=TYPE_APPLICATION_PANEL", " at uni_modules/spike-overlay/utssdk/app-android/index.uts:83")
            }
            if (androidHideTimer != 0) {
                clearTimeout(androidHideTimer)
            }
            androidHideTimer = setTimeout(fun(){
                androidHideTimer = 0
                hideSpikeOverlay()
            }
            , duration)
        }
         catch (e: Throwable) {
            console.log("[spike-android] 挂窗异常: " + e.message, " at uni_modules/spike-overlay/utssdk/app-android/index.uts:94")
        }
    }
    )
}
fun hideSpikeOverlay(): Unit {
    val view = androidOverlay
    if (view == null) {
        return
    }
    androidOverlay = null
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        return
    }
    val activity = act as Activity
    activity.runOnUiThread(fun(){
        try {
            val alphaOut: Number = 0.0
            view.animate().alpha(alphaOut.toFloat()).setDuration(200).start()
            setTimeout(fun(){
                try {
                    val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                    wm.removeView(view)
                    console.log("[spike-android] removeView 成功", " at uni_modules/spike-overlay/utssdk/app-android/index.uts:121")
                }
                 catch (e: Throwable) {
                    console.log("[spike-android] removeView 异常: " + e.message, " at uni_modules/spike-overlay/utssdk/app-android/index.uts:123")
                }
            }
            , 220)
        }
         catch (e: Throwable) {
            console.log("[spike-android] 隐藏异常: " + e.message, " at uni_modules/spike-overlay/utssdk/app-android/index.uts:127")
        }
    }
    )
}
open class UniUTSMethodRegister {
    companion object {
        @UTSAutoRegister
        fun registerUTSMethod(): Unit {
            UTSBridge.registerUTSMethod("spike-overlay", fun(methodId: Number, params: kotlin.Array<Any?>): Any? {
                when (methodId) {
                    0 -> 
                        {
                            when (params.size) {
                                2 -> 
                                    return showSpikeOverlay(params[0] as String, params[1] as Number)
                                else -> 
                                    throw UTSError("showSpikeOverlay parameters length error, got " + params.size + " parameters")
                            }
                        }
                    1 -> 
                        {
                            when (params.size) {
                                0 -> 
                                    return hideSpikeOverlay()
                                else -> 
                                    throw UTSError("hideSpikeOverlay parameters length error, got " + params.size + " parameters")
                            }
                        }
                    else -> 
                        throw UTSError("methodId " + methodId + " not found in module spike-overlay")
                }
            }
            )
        }
    }
}

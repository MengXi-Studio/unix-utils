@file:Suppress("UNCHECKED_CAST", "USELESS_CAST", "INAPPLICABLE_JVM_NAME", "UNUSED_ANONYMOUS_PARAMETER", "SENSELESS_COMPARISON", "NAME_SHADOWING", "UNNECESSARY_NOT_NULL_ASSERTION")
package uts.sdk.modules.unixWindow
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.IBinder
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
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
var toastRoot: View? = null
var maskRoot: View? = null
var iconText: TextView? = null
var titleText: TextView? = null
var lastMask: Boolean = false
var lastPosition: String = ""
var hideTimer: Number = 0
fun iconEmoji(icon: String): String {
    if (icon == "success") {
        return "✓"
    }
    if (icon == "error") {
        return "✕"
    }
    if (icon == "warning" || icon == "exception") {
        return "!"
    }
    if (icon == "loading") {
        return "◌"
    }
    return ""
}
fun positionGravity(position: String): Int {
    if (position == "top") {
        return Gravity.TOP or Gravity.CENTER_HORIZONTAL
    }
    if (position == "center") {
        return Gravity.CENTER
    }
    return Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
}
fun screenEdgeOffset(activity: Activity): Int {
    val h = UTSNumber.from(activity.getResources().getDisplayMetrics().heightPixels)
    return (h * 0.1).toInt()
}
fun dp2pxI(activity: Activity, dp: Number): Int {
    val density = UTSNumber.from(activity.getResources().getDisplayMetrics().density)
    return (dp * density).toInt()
}
fun dp2pxF(activity: Activity, dp: Number): Float {
    val density = UTSNumber.from(activity.getResources().getDisplayMetrics().density)
    return (dp * density).toFloat()
}
fun buildCard(activity: Activity, title: String, icon: String): LinearLayout {
    val card = LinearLayout(activity)
    card.setOrientation(LinearLayout.VERTICAL)
    card.setGravity(Gravity.CENTER)
    val bg = GradientDrawable()
    bg.setColor(Color.parseColor("#BF000000"))
    bg.setCornerRadius(dp2pxF(activity, 8.0))
    card.setBackground(bg)
    val pad = dp2pxI(activity, 16.0)
    card.setPadding(pad, pad, pad, pad)
    card.setMinimumWidth(dp2pxI(activity, 120.0))
    val emoji = iconEmoji(icon)
    if (emoji.length > 0) {
        val iv = TextView(activity)
        iv.setTextColor(Color.WHITE)
        iv.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 40.0f)
        iv.setGravity(Gravity.CENTER)
        iv.setText(emoji)
        iv.setPadding(0, 0, 0, dp2pxI(activity, 8.0))
        card.addView(iv)
        iconText = iv
    } else {
        iconText = null
    }
    val tv = TextView(activity)
    tv.setTextColor(Color.WHITE)
    tv.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 14.0f)
    tv.setGravity(Gravity.CENTER)
    tv.setMaxWidth(dp2pxI(activity, 240.0))
    tv.setText(title)
    card.addView(tv)
    titleText = tv
    return card
}
fun buildMask(activity: Activity): FrameLayout {
    val root = FrameLayout(activity)
    val dim = GradientDrawable()
    dim.setColor(Color.parseColor("#80000000"))
    root.setBackground(dim)
    return root
}
fun updateTexts(icon: String, title: String): Unit {
    val emoji = iconEmoji(icon)
    val it = iconText
    if (it != null) {
        it.setVisibility(if (emoji.length > 0) {
            View.VISIBLE
        } else {
            View.GONE
        }
        )
        it.setText(emoji)
    }
    val tt = titleText
    if (tt != null) {
        tt.setText(title)
    }
}
fun removeRootImmediate(view: View): Unit {
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        return
    }
    val activity = act as Activity
    activity.runOnUiThread(fun(){
        try {
            val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            wm.removeView(view)
        }
         catch (e: Throwable) {}
    }
    )
}
fun scheduleHide(duration: Number): Unit {
    if (hideTimer != 0) {
        clearTimeout(hideTimer)
    }
    hideTimer = setTimeout(fun(){
        hideTimer = 0
        hideWindowToast()
    }
    , duration)
}
fun buildCardParams(activity: Activity, position: String, token: IBinder): WindowManager.LayoutParams {
    val params = WindowManager.LayoutParams()
    params.type = WindowManager.LayoutParams.TYPE_APPLICATION_PANEL
    params.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
    params.format = PixelFormat.TRANSLUCENT
    params.width = WindowManager.LayoutParams.WRAP_CONTENT
    params.height = WindowManager.LayoutParams.WRAP_CONTENT
    params.gravity = positionGravity(position)
    if (position == "top") {
        params.y = screenEdgeOffset(activity)
    }
    if (position == "bottom") {
        params.y = screenEdgeOffset(activity)
    }
    params.token = token
    return params
}
fun showWindowToast(title: String, icon: String, mask: Boolean, duration: Number, position: String, fail: ((errMsg: String) -> Unit)?): Unit {
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        if (fail != null) {
            fail("getUniActivity() 为 null，无法挂窗")
        }
        return
    }
    val activity = act as Activity
    activity.runOnUiThread(fun(){
        try {
            val existing = toastRoot
            val maskChanged = lastMask != mask
            val positionChanged = lastPosition != position
            val needRebuildForIcon = iconText == null && iconEmoji(icon).length > 0
            if (existing != null && !maskChanged && !positionChanged && !needRebuildForIcon) {
                console.log("[unix-window] 复用已有窗口视图，更新文案 position=" + position, " at uni_modules/unix-window/utssdk/app-android/index.uts:224")
                updateTexts(icon, title)
                scheduleHide(duration)
                return
            }
            if (existing != null) {
                removeRootImmediate(existing)
                toastRoot = null
            }
            val oldMask = maskRoot
            if (oldMask != null) {
                removeRootImmediate(oldMask)
                maskRoot = null
            }
            val token = activity.getWindow().getDecorView().getWindowToken()
            if (token == null) {
                if (fail != null) {
                    fail("windowToken 为 null（页面未就绪），无法挂窗")
                }
                return
            }
            val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            if (mask) {
                val maskParams = WindowManager.LayoutParams()
                maskParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_PANEL
                maskParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                maskParams.format = PixelFormat.TRANSLUCENT
                maskParams.width = WindowManager.LayoutParams.MATCH_PARENT
                maskParams.height = WindowManager.LayoutParams.MATCH_PARENT
                maskParams.token = token
                val maskView = buildMask(activity)
                wm.addView(maskView, maskParams)
                maskRoot = maskView
            }
            val cardParams = buildCardParams(activity, position, token)
            val card = buildCard(activity, title, icon)
            wm.addView(card, cardParams)
            toastRoot = card
            lastMask = mask
            lastPosition = position
            console.log("[unix-window] addView 成功 mask=" + mask + " position=" + position + " gravity=" + cardParams.gravity + " y=" + cardParams.y, " at uni_modules/unix-window/utssdk/app-android/index.uts:268")
            card.setAlpha(0.0f)
            card.animate().alpha(1.0f).setDuration(200).start()
            if (maskRoot != null) {
                maskRoot!!.setAlpha(0.0f)
                maskRoot!!.animate().alpha(1.0f).setDuration(200).start()
            }
            scheduleHide(duration)
        }
         catch (e: Throwable) {
            if (fail != null) {
                fail("挂窗异常: " + e.message)
            }
        }
    }
    )
}
fun hideWindowToast(): Unit {
    if (hideTimer != 0) {
        clearTimeout(hideTimer)
        hideTimer = 0
    }
    val root = toastRoot
    val mask = maskRoot
    if (root == null && mask == null) {
        return
    }
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        return
    }
    val activity = act as Activity
    toastRoot = null
    maskRoot = null
    iconText = null
    titleText = null
    activity.runOnUiThread(fun(){
        try {
            if (root != null) {
                root.animate().alpha(0.0f).setDuration(200).start()
            }
            if (mask != null) {
                mask.animate().alpha(0.0f).setDuration(200).start()
            }
            setTimeout(fun(){
                val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                if (root != null) {
                    try {
                        wm.removeView(root)
                    }
                     catch (e: Throwable) {}
                }
                if (mask != null) {
                    try {
                        wm.removeView(mask)
                    }
                     catch (e: Throwable) {}
                }
            }
            , 220)
        }
         catch (e: Throwable) {}
    }
    )
}
open class UniUTSMethodRegister {
    companion object {
        @UTSAutoRegister
        fun registerUTSMethod(): Unit {
            UTSBridge.registerUTSMethod("unix-window", fun(methodId: Number, params: kotlin.Array<Any?>): Any? {
                when (methodId) {
                    0 -> 
                        {
                            when (params.size) {
                                5 -> 
                                    return showWindowToast(params[0] as String, params[1] as String, params[2] as Boolean, params[3] as Number, params[4] as String, null)
                                6 -> 
                                    return showWindowToast(params[0] as String, params[1] as String, params[2] as Boolean, params[3] as Number, params[4] as String, if (params[5] == null) {
                                        null
                                    } else {
                                        (((params[5] as UTSCallback).fnJS ?: (fun(arg0: String): Unit {
                                            (params[5] as UTSCallback)(arg0)
                                        }
                                        ).also(fun(fnJS): Unit {
                                            (params[5] as UTSCallback).fnJS = fnJS
                                        }
                                        )) as (arg0: String) -> Unit)
                                    }
                                    )
                                else -> 
                                    throw UTSError("showWindowToast parameters length error, got " + params.size + " parameters")
                            }
                        }
                    1 -> 
                        {
                            when (params.size) {
                                0 -> 
                                    return hideWindowToast()
                                else -> 
                                    throw UTSError("hideWindowToast parameters length error, got " + params.size + " parameters")
                            }
                        }
                    else -> 
                        throw UTSError("methodId " + methodId + " not found in module unix-window")
                }
            }
            )
        }
    }
}

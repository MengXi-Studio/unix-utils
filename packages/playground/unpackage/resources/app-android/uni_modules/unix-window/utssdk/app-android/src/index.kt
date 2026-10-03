@file:Suppress("UNCHECKED_CAST", "USELESS_CAST", "INAPPLICABLE_JVM_NAME", "UNUSED_ANONYMOUS_PARAMETER", "SENSELESS_COMPARISON", "NAME_SHADOWING", "UNNECESSARY_NOT_NULL_ASSERTION")
package uts.sdk.modules.unixWindow
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
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
var iconText: TextView? = null
var titleText: TextView? = null
var lastMask: Boolean = false
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
fun screenFifteenPercent(activity: Activity): Int {
    val h = UTSNumber.from(activity.getResources().getDisplayMetrics().heightPixels)
    return (h * 0.15).toInt()
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
fun buildRoot(activity: Activity, title: String, icon: String, mask: Boolean, position: String): View {
    val card = buildCard(activity, title, icon)
    if (!mask) {
        return card
    }
    val root = FrameLayout(activity)
    val dim = GradientDrawable()
    dim.setColor(Color.parseColor("#80000000"))
    root.setBackground(dim)
    val lp = FrameLayout.LayoutParams(WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT)
    lp.gravity = positionGravity(position)
    if (position == "top") {
        lp.topMargin = screenFifteenPercent(activity)
    }
    if (position == "bottom") {
        lp.bottomMargin = screenFifteenPercent(activity)
    }
    root.addView(card, lp)
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
            val needRebuildForIcon = iconText == null && iconEmoji(icon).length > 0
            if (existing != null && !maskChanged && !needRebuildForIcon) {
                updateTexts(icon, title)
                scheduleHide(duration)
                return
            }
            if (existing != null) {
                removeRootImmediate(existing)
                toastRoot = null
            }
            val token = activity.getWindow().getDecorView().getWindowToken()
            if (token == null) {
                if (fail != null) {
                    fail("windowToken 为 null（页面未就绪），无法挂窗")
                }
                return
            }
            val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val root = buildRoot(activity, title, icon, mask, position)
            val params = WindowManager.LayoutParams()
            params.type = WindowManager.LayoutParams.TYPE_APPLICATION_PANEL
            if (mask) {
                params.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
            } else {
                params.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
            }
            params.format = PixelFormat.TRANSLUCENT
            if (mask) {
                params.width = WindowManager.LayoutParams.MATCH_PARENT
                params.height = WindowManager.LayoutParams.MATCH_PARENT
            } else {
                params.width = WindowManager.LayoutParams.WRAP_CONTENT
                params.height = WindowManager.LayoutParams.WRAP_CONTENT
                params.gravity = positionGravity(position)
                if (position == "top") {
                    params.y = screenFifteenPercent(activity)
                }
                if (position == "bottom") {
                    params.y = -screenFifteenPercent(activity)
                }
            }
            params.token = token
            wm.addView(root, params)
            toastRoot = root
            lastMask = mask
            root.setAlpha(0.0f)
            root.animate().alpha(1.0f).setDuration(200).start()
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
    if (root == null) {
        return
    }
    val act = UTSAndroid.getUniActivity()
    if (act == null) {
        return
    }
    val activity = act as Activity
    toastRoot = null
    iconText = null
    titleText = null
    activity.runOnUiThread(fun(){
        try {
            root.animate().alpha(0.0f).setDuration(200).start()
            setTimeout(fun(){
                try {
                    val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                    wm.removeView(root)
                }
                 catch (e: Throwable) {}
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

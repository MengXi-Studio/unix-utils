@file:Suppress("UNCHECKED_CAST", "USELESS_CAST", "INAPPLICABLE_JVM_NAME", "UNUSED_ANONYMOUS_PARAMETER", "SENSELESS_COMPARISON", "NAME_SHADOWING", "UNNECESSARY_NOT_NULL_ASSERTION")
package uts.sdk.modules.unixUtils
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
import io.dcloud.uniapp.extapi.getSystemInfoSync as uni_getSystemInfoSync
import io.dcloud.uniapp.extapi.showToast as uni_showToast
typealias ToastIcon = String
typealias ToastPosition = String
typealias ToastErrorCode = Number
open class ToastResult (
    @JsonNotNull
    open var errMsg: String,
) : UTSObject()
open class ToastFail (
    @JsonNotNull
    open var errCode: ToastErrorCode,
    @JsonNotNull
    open var errSubject: String,
    @JsonNotNull
    open var errMsg: String,
    open var param: String? = null,
    @JsonNotNull
    open var platform: String,
) : UTSObject()
open class ToastOptions (
    @JsonNotNull
    open var title: String,
    open var icon: ToastIcon? = null,
    open var image: String? = null,
    open var mask: Boolean? = null,
    open var duration: Number? = null,
    open var position: ToastPosition? = null,
    open var success: ((res: ToastResult) -> Unit)? = null,
    open var fail: ((err: ToastFail) -> Unit)? = null,
    open var complete: ((res: Any) -> Unit)? = null,
) : UTSObject()
open class NormalizedOptions (
    @JsonNotNull
    open var title: String,
    @JsonNotNull
    open var icon: ToastIcon,
    open var image: String? = null,
    @JsonNotNull
    open var mask: Boolean = false,
    @JsonNotNull
    open var duration: Number,
    open var position: ToastPosition? = null,
    open var success: ((res: ToastResult) -> Unit)? = null,
    open var fail: ((err: ToastFail) -> Unit)? = null,
    open var complete: ((res: Any) -> Unit)? = null,
) : UTSObject()
open class NormalizeResult (
    @JsonNotNull
    open var options: NormalizedOptions,
    @JsonNotNull
    open var degraded: UTSArray<String>,
) : UTSObject()
open class ToastDefaults (
    open var duration: Number? = null,
    open var icon: ToastIcon? = null,
    open var mask: Boolean? = null,
) : UTSObject()
typealias ShowToast = (options: ToastOptions) -> Unit
typealias HideToast = () -> Unit
typealias ShowToastAsync = (options: ToastOptions) -> UTSPromise<Unit>
typealias ConfigureToast = (defaults: ToastDefaults) -> Unit
typealias ShowToastQuick = (title: String) -> Unit
typealias ToastIcon__1 = String
typealias ToastPosition__1 = String
typealias ToastErrorCode__1 = Number
val ERR_PARAM_INVALID: ToastErrorCode__1 = 1001
val ERR_PLATFORM_UNSUPPORTED: ToastErrorCode__1 = 2001
val BUILTIN_DURATION: Number = 1500
val BUILTIN_ICON: ToastIcon__1 = "success"
val BUILTIN_MASK: Boolean = false
val WECHAT_TITLE_MAX_LENGTH: Number = 7
val NATIVE_TITLE_MAX_LENGTH: Number = 20
val TOAST_ERR_SUBJECT: String = "unix-utils:toast"
fun getPlatform(): String {
    try {
        val info = uni_getSystemInfoSync()
        return info.uniPlatform
    }
     catch (e: Throwable) {
        return "unknown"
    }
}
fun isSelfDrawPlatform(platform: String): Boolean {
    return true
}
var currentDefaults = ToastDefaults(duration = BUILTIN_DURATION, icon = BUILTIN_ICON, mask = BUILTIN_MASK)
fun configureToastImpl(defaults: ToastDefaults): Unit {
    currentDefaults = defaults
}
fun getToastDefaults(): ToastDefaults {
    return currentDefaults
}
fun truncateTitle(title: String, platform: String): String {
    if (platform === "mp-weixin") {
        if (title.length > WECHAT_TITLE_MAX_LENGTH) {
            return title.substring(0, WECHAT_TITLE_MAX_LENGTH) + "…"
        }
        return title
    }
    if (platform === "app-harmony") {
        if (title.length > NATIVE_TITLE_MAX_LENGTH) {
            return title.substring(0, NATIVE_TITLE_MAX_LENGTH) + "…"
        }
    }
    return title
}
fun normalizeIcon(icon: ToastIcon__1, platform: String, degraded: UTSArray<String>): ToastIcon__1 {
    if (icon === "fail" || icon === "exception") {
        degraded.push("icon")
        return "error"
    }
    if (icon === "warning") {
        if (!isSelfDrawPlatform(platform)) {
            degraded.push("icon")
            return "none"
        }
    }
    return icon
}
fun normalizePosition(position: ToastPosition__1?, platform: String, degraded: UTSArray<String>): ToastPosition__1? {
    if (position == null) {
        return null
    }
    if (isSelfDrawPlatform(platform)) {
        return position
    }
    degraded.push("position")
    return null
}
fun normalizeImage(image: String?, platform: String, degraded: UTSArray<String>): String? {
    if (image == null) {
        return null
    }
    if (isSelfDrawPlatform(platform)) {
        return image
    }
    if (image.toLowerCase().endsWith(".gif")) {
        degraded.push("image")
        return null
    }
    return image
}
fun normalize(options: ToastOptions): NormalizeResult {
    val platform = getPlatform()
    val defaults = getToastDefaults()
    val degraded: UTSArray<String> = _uA()
    val icon: ToastIcon__1 = normalizeIcon(if (options.icon != null) {
        options.icon!!
    } else {
        if (defaults.icon != null) {
            defaults.icon!!
        } else {
            BUILTIN_ICON
        }
    }
    , platform, degraded)
    val position: ToastPosition__1? = normalizePosition(options.position, platform, degraded)
    val image: String? = normalizeImage(options.image, platform, degraded)
    val title: String = truncateTitle(options.title, platform)
    val mask: Boolean = if (options.mask != null) {
        options.mask!!
    } else {
        if (defaults.mask != null) {
            defaults.mask!!
        } else {
            BUILTIN_MASK
        }
    }
    val duration: Number = if (options.duration != null) {
        options.duration!!
    } else {
        if (defaults.duration != null) {
            defaults.duration!!
        } else {
            BUILTIN_DURATION
        }
    }
    val normalized = NormalizedOptions(title = title, icon = icon, image = image, mask = mask, duration = duration, position = position, success = options.success, fail = options.fail, complete = options.complete)
    val result = NormalizeResult(options = normalized, degraded = degraded)
    return result
}
fun iconToNativeString(icon: ToastIcon__1): String {
    if (icon == "success") {
        return "success"
    }
    if (icon == "error") {
        return "error"
    }
    if (icon == "loading") {
        return "loading"
    }
    return "none"
}
fun positionToNativeString(position: ToastPosition__1): String {
    if (position == "top") {
        return "top"
    }
    if (position == "center") {
        return "center"
    }
    return "bottom"
}
fun showNative(options: NormalizedOptions): Unit {
    val platform = getPlatform()
    uni_showToast(ShowToastOptions(title = options.title, icon = iconToNativeString(options.icon), image = options.image, mask = options.mask, duration = options.duration, position = if (options.position == null) {
        null
    } else {
        positionToNativeString(options.position!!)
    }
    , success = fun(_){
        if (options.success != null) {
            val r = ToastResult(errMsg = "showToast:ok")
            options.success!!(r)
        }
    }
    , fail = fun(err: ShowToastFail){
        if (options.fail != null) {
            val f = ToastFail(errCode = ERR_PARAM_INVALID, errSubject = TOAST_ERR_SUBJECT, errMsg = err.errMsg, param = null, platform = platform)
            options.fail!!(f)
        }
    }
    , complete = fun(res: Any){
        if (options.complete != null) {
            options.complete!!(res)
        }
    }
    ))
}
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
                console.log("[unix-window] 复用已有窗口视图，更新文案 position=" + position)
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
            console.log("[unix-window] addView 成功 mask=" + mask + " position=" + position + " gravity=" + cardParams.gravity + " y=" + cardParams.y)
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
fun iconToSelfDrawString(icon: ToastIcon__1): String {
    if (icon == "success") {
        return "success"
    }
    if (icon == "error") {
        return "error"
    }
    if (icon == "warning") {
        return "warning"
    }
    if (icon == "loading") {
        return "loading"
    }
    return "none"
}
fun positionToSelfDrawString(position: ToastPosition__1?): String {
    if (position == "top") {
        return "top"
    }
    if (position == "center") {
        return "center"
    }
    return "bottom"
}
fun notifyFallback(options: NormalizedOptions, param: String?, errMsg: String): Unit {
    if (options.fail == null) {
        return
    }
    val f = ToastFail(errCode = ERR_PLATFORM_UNSUPPORTED, errSubject = TOAST_ERR_SUBJECT, errMsg = errMsg, param = param, platform = getPlatform())
    options.fail!!(f)
}
fun showSelfDraw(options: NormalizedOptions): Unit {
    var iconStr = iconToSelfDrawString(options.icon)
    if (options.image != null) {
        iconStr = "none"
        notifyFallback(options, "image", "直挂窗口通道暂不渲染 image 自定义图标，已降级")
    }
    showWindowToast(options.title, iconStr, options.mask, options.duration, positionToSelfDrawString(options.position), fun(errMsg: String){
        console.log("[toast] 窗口直挂失败，降级 uni.showToast: " + errMsg)
        showNative(options)
        notifyFallback(options, null, "窗口直挂失败，已降级原生通道: " + errMsg)
    }
    )
}
fun hideSelfDraw(): Unit {
    hideWindowToast()
}
fun notifyDegraded(options: ToastOptions, degraded: UTSArray<String>): Unit {
    if (degraded.length === 0 || options.fail == null) {
        return
    }
    val platform = getPlatform()
    run {
        var i: Number = 0
        while(i < degraded.length){
            val f = ToastFail(errCode = ERR_PLATFORM_UNSUPPORTED, errSubject = TOAST_ERR_SUBJECT, errMsg = "参数在当前端不支持，已降级处理", param = degraded[i], platform = platform)
            options.fail!!(f)
            i++
        }
    }
}
fun dispatchShow(options: NormalizedOptions): Unit {
    showSelfDraw(options)
}
fun showToastImpl(options: ToastOptions): Unit {
    val result = normalize(options)
    notifyDegraded(options, result.degraded)
    dispatchShow(result.options)
}
fun hideToastImpl(): Unit {
    hideSelfDraw()
}
fun showToastAsyncImpl(options: ToastOptions): UTSPromise<Unit> {
    return UTSPromise<Unit>(fun(resolve, reject){
        val wrapped = ToastOptions(title = options.title, icon = options.icon, image = options.image, mask = options.mask, duration = options.duration, position = options.position, success = fun(res: ToastResult){
            if (options.success != null) {
                options.success!!(res)
            }
            resolve(Unit)
        }
        , fail = fun(err: ToastFail){
            if (options.fail != null) {
                options.fail!!(err)
            }
            reject(err)
        }
        , complete = options.complete)
        showToastImpl(wrapped)
    }
    )
}
fun quickShow(title: String, icon: ToastIcon__1): Unit {
    val defaults = getToastDefaults()
    val duration: Number = if (defaults.duration != null) {
        defaults.duration!!
    } else {
        BUILTIN_DURATION
    }
    val mask: Boolean = if (defaults.mask != null) {
        defaults.mask!!
    } else {
        BUILTIN_MASK
    }
    val options = ToastOptions(title = title, icon = icon, image = null, mask = mask, duration = duration, position = null, success = null, fail = null, complete = null)
    showToastImpl(options)
}
fun showToastSuccessImpl(title: String): Unit {
    quickShow(title, "success")
}
fun showToastErrorImpl(title: String): Unit {
    quickShow(title, "error")
}
fun showToastInfoImpl(title: String): Unit {
    quickShow(title, "none")
}
val DEFAULT_DURATION: Number = 1500
val DEFAULT_ICON: ToastIcon = "success"
val DEFAULT_MASK: Boolean = false
val TOAST_ERR_PARAM_INVALID: ToastErrorCode = 1001
val TOAST_ERR_PLATFORM_UNSUPPORTED: ToastErrorCode = 2001
val showToast: ShowToast = fun(options: ToastOptions): Unit {
    showToastImpl(options)
}
val hideToast: HideToast = fun(): Unit {
    hideToastImpl()
}
val showToastAsync: ShowToastAsync = fun(options: ToastOptions): UTSPromise<Unit> {
    return showToastAsyncImpl(options)
}
val configureToast: ConfigureToast = fun(defaults: ToastDefaults): Unit {
    configureToastImpl(defaults)
}
val showToastSuccess: ShowToastQuick = fun(title: String): Unit {
    showToastSuccessImpl(title)
}
val showToastError: ShowToastQuick = fun(title: String): Unit {
    showToastErrorImpl(title)
}
val showToastInfo: ShowToastQuick = fun(title: String): Unit {
    showToastInfoImpl(title)
}
open class UniUTSMethodRegister {
    companion object {
        fun createUTSToastDefaults(options: UTSJSONObject): ToastDefaults {
            return ToastDefaults(options.get("duration") as Number?, options.get("icon") as ToastIcon?, options.get("mask") as Boolean?)
        }
        fun createUTSToastOptions(options: UTSJSONObject): ToastOptions {
            return ToastOptions(options.get("title") as String, options.get("icon") as ToastIcon?, options.get("image") as String?, options.get("mask") as Boolean?, options.get("duration") as Number?, options.get("position") as ToastPosition?, if (options.hasOwnProperty("success") && options.get("success") != null) {
                (((options.get("success") as UTSCallback).fnJS ?: (fun(arg0: ToastResult): Unit {
                    (options.get("success") as UTSCallback)(arg0)
                }).also(fun(fnJS): Unit {
                    (options.get("success") as UTSCallback).fnJS = fnJS
                })) as (arg0: ToastResult) -> Unit)
            } else {
                null
            }
            , if (options.hasOwnProperty("fail") && options.get("fail") != null) {
                (((options.get("fail") as UTSCallback).fnJS ?: (fun(arg0: ToastFail): Unit {
                    (options.get("fail") as UTSCallback)(arg0)
                }).also(fun(fnJS): Unit {
                    (options.get("fail") as UTSCallback).fnJS = fnJS
                })) as (arg0: ToastFail) -> Unit)
            } else {
                null
            }
            , if (options.hasOwnProperty("complete") && options.get("complete") != null) {
                (((options.get("complete") as UTSCallback).fnJS ?: (fun(arg0: Any): Unit {
                    (options.get("complete") as UTSCallback)(arg0)
                }).also(fun(fnJS): Unit {
                    (options.get("complete") as UTSCallback).fnJS = fnJS
                })) as (arg0: Any) -> Unit)
            } else {
                null
            }
            )
        }
        @UTSAutoRegister
        fun registerUTSMethod(): Unit {
            UTSBridge.registerUTSMethod("unix-utils", fun(methodId: Number, params: kotlin.Array<Any?>): Any? {
                when (methodId) {
                    0 -> 
                        {
                            when (params.size) {
                                1 -> 
                                    return showToast(createUTSToastOptions(params[0] as UTSJSONObject))
                                else -> 
                                    throw UTSError("showToast parameters length error, got " + params.size + " parameters")
                            }
                        }
                    1 -> 
                        {
                            when (params.size) {
                                0 -> 
                                    return hideToast()
                                else -> 
                                    throw UTSError("hideToast parameters length error, got " + params.size + " parameters")
                            }
                        }
                    2 -> 
                        {
                            when (params.size) {
                                2 -> 
                                    {
                                        showToastAsync(createUTSToastOptions(params[1] as UTSJSONObject)).then(fun(res: Any?): Unit {
                                            (params[0] as (res: Any?, err: Any?) -> Unit)(res, null)
                                        }
                                        ).`catch`(fun(err: Any?): Unit {
                                            (params[0] as (res: Any?, err: Any?) -> Unit)(null, err)
                                        }
                                        )
                                        return null
                                    }
                                else -> 
                                    throw UTSError("showToastAsync parameters length error, got " + (params.size - 1) + " parameters")
                            }
                        }
                    3 -> 
                        {
                            when (params.size) {
                                1 -> 
                                    return configureToast(createUTSToastDefaults(params[0] as UTSJSONObject))
                                else -> 
                                    throw UTSError("configureToast parameters length error, got " + params.size + " parameters")
                            }
                        }
                    4 -> 
                        {
                            when (params.size) {
                                1 -> 
                                    return showToastSuccess(params[0] as String)
                                else -> 
                                    throw UTSError("showToastSuccess parameters length error, got " + params.size + " parameters")
                            }
                        }
                    5 -> 
                        {
                            when (params.size) {
                                1 -> 
                                    return showToastError(params[0] as String)
                                else -> 
                                    throw UTSError("showToastError parameters length error, got " + params.size + " parameters")
                            }
                        }
                    6 -> 
                        {
                            when (params.size) {
                                1 -> 
                                    return showToastInfo(params[0] as String)
                                else -> 
                                    throw UTSError("showToastInfo parameters length error, got " + params.size + " parameters")
                            }
                        }
                    else -> 
                        throw UTSError("methodId " + methodId + " not found in module unix-utils")
                }
            }
            )
        }
    }
}

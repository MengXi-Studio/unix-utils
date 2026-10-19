import DCloudUTSFoundation
import DCloudUniappRuntime
import UIKit
import DCloudUTSExtAPI
public var showModal__1 = DCloudUTSExtAPI.showModal
public var showToast__1 = DCloudUTSExtAPI.showToast
public typealias ToastIcon = String
public typealias ToastPosition = String
public typealias ToastErrorCode = NSNumber
@objc(UTSSDKModulesUxUtilsToastResult)
@objcMembers
public class ToastResult : NSObject, UTSObject {
    public var errMsg: String!
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "errMsg":
                    self.errMsg = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.errMsg = obj["errMsg"] as! String
    }
}
@objc(UTSSDKModulesUxUtilsToastFail)
@objcMembers
public class ToastFail : NSObject, UTSObject {
    public var errCode: ToastErrorCode!
    public var errSubject: String!
    public var errMsg: String!
    public var param: String?
    public var platform: String!
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "errCode":
                    self.errCode = try! utsSubscriptCheckValue(newValue)
                case "errSubject":
                    self.errSubject = try! utsSubscriptCheckValue(newValue)
                case "errMsg":
                    self.errMsg = try! utsSubscriptCheckValue(newValue)
                case "param":
                    self.param = try! utsSubscriptCheckValueIfPresent(newValue)
                case "platform":
                    self.platform = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.errCode = obj["errCode"] as! ToastErrorCode
        self.errSubject = obj["errSubject"] as! String
        self.errMsg = obj["errMsg"] as! String
        self.param = obj["param"] as! String?
        self.platform = obj["platform"] as! String
    }
}
@objc(UTSSDKModulesUxUtilsToastOptions)
@objcMembers
public class ToastOptions : NSObject, UTSObject {
    public var title: String!
    public var icon: ToastIcon?
    public var image: String?
    public var mask: Bool = false
    public var duration: NSNumber?
    public var position: ToastPosition?
    public var success: ((_ res: ToastResult) -> Void)?
    public var fail: ((_ err: ToastFail) -> Void)?
    public var complete: ((_ res: Any) -> Void)?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "title":
                    self.title = try! utsSubscriptCheckValue(newValue)
                case "icon":
                    self.icon = try! utsSubscriptCheckValueIfPresent(newValue)
                case "image":
                    self.image = try! utsSubscriptCheckValueIfPresent(newValue)
                case "mask":
                    self.mask = try! utsSubscriptCheckValue(newValue)
                case "duration":
                    self.duration = try! utsSubscriptCheckValueIfPresent(newValue)
                case "position":
                    self.position = try! utsSubscriptCheckValueIfPresent(newValue)
                case "success":
                    self.success = try! utsSubscriptCheckValueIfPresent(newValue)
                case "fail":
                    self.fail = try! utsSubscriptCheckValueIfPresent(newValue)
                case "complete":
                    self.complete = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.title = obj["title"] as! String
        self.icon = obj["icon"] as! ToastIcon?
        self.image = obj["image"] as! String?
        self.mask = (obj["mask"] as? Bool) ?? false
        self.duration = obj["duration"] as! NSNumber?
        self.position = obj["position"] as! ToastPosition?
        self.success = obj["success"] as! ((_ res: ToastResult) -> Void)?
        self.fail = obj["fail"] as! ((_ err: ToastFail) -> Void)?
        self.complete = obj["complete"] as! ((_ res: Any) -> Void)?
    }
}
@objc(UTSSDKModulesUxUtilsNormalizedOptions)
@objcMembers
public class NormalizedOptions : NSObject, UTSObject {
    public var title: String!
    public var icon: ToastIcon!
    public var image: String?
    public var mask: Bool = false
    public var duration: NSNumber!
    public var position: ToastPosition?
    public var success: ((_ res: ToastResult) -> Void)?
    public var fail: ((_ err: ToastFail) -> Void)?
    public var complete: ((_ res: Any) -> Void)?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "title":
                    self.title = try! utsSubscriptCheckValue(newValue)
                case "icon":
                    self.icon = try! utsSubscriptCheckValue(newValue)
                case "image":
                    self.image = try! utsSubscriptCheckValueIfPresent(newValue)
                case "mask":
                    self.mask = try! utsSubscriptCheckValue(newValue)
                case "duration":
                    self.duration = try! utsSubscriptCheckValue(newValue)
                case "position":
                    self.position = try! utsSubscriptCheckValueIfPresent(newValue)
                case "success":
                    self.success = try! utsSubscriptCheckValueIfPresent(newValue)
                case "fail":
                    self.fail = try! utsSubscriptCheckValueIfPresent(newValue)
                case "complete":
                    self.complete = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.title = obj["title"] as! String
        self.icon = obj["icon"] as! ToastIcon
        self.image = obj["image"] as! String?
        self.mask = obj["mask"] as! Bool
        self.duration = obj["duration"] as! NSNumber
        self.position = obj["position"] as! ToastPosition?
        self.success = obj["success"] as! ((_ res: ToastResult) -> Void)?
        self.fail = obj["fail"] as! ((_ err: ToastFail) -> Void)?
        self.complete = obj["complete"] as! ((_ res: Any) -> Void)?
    }
}
@objc(UTSSDKModulesUxUtilsNormalizeResult)
@objcMembers
public class NormalizeResult : NSObject, UTSObject {
    public var options: NormalizedOptions!
    public var degraded: [String]!
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "options":
                    self.options = try! utsSubscriptCheckValue(newValue)
                case "degraded":
                    self.degraded = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.options = obj["options"] as! NormalizedOptions
        self.degraded = obj["degraded"] as! [String]
    }
}
@objc(UTSSDKModulesUxUtilsToastDefaults)
@objcMembers
public class ToastDefaults : NSObject, UTSObject {
    public var duration: NSNumber?
    public var icon: ToastIcon?
    public var mask: Bool = false
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "duration":
                    self.duration = try! utsSubscriptCheckValueIfPresent(newValue)
                case "icon":
                    self.icon = try! utsSubscriptCheckValueIfPresent(newValue)
                case "mask":
                    self.mask = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.duration = obj["duration"] as! NSNumber?
        self.icon = obj["icon"] as! ToastIcon?
        self.mask = (obj["mask"] as? Bool) ?? false
    }
}
public typealias ShowToast = (_ options: ToastOptions) -> Void
public typealias HideToast = () -> Void
public typealias ShowToastAsync = (_ options: ToastOptions) -> UTSPromise<Void>
public typealias ConfigureToast = (_ defaults: ToastDefaults) -> Void
public typealias ShowToastQuick = (_ title: String) -> Void
public typealias ModalErrorCode = NSNumber
@objc(UTSSDKModulesUxUtilsModalResult)
@objcMembers
public class ModalResult : NSObject, UTSObject {
    public var confirm: Bool = false
    public var cancel: Bool = false
    public var content: String?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "confirm":
                    self.confirm = try! utsSubscriptCheckValue(newValue)
                case "cancel":
                    self.cancel = try! utsSubscriptCheckValue(newValue)
                case "content":
                    self.content = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.confirm = obj["confirm"] as! Bool
        self.cancel = obj["cancel"] as! Bool
        self.content = obj["content"] as! String?
    }
}
@objc(UTSSDKModulesUxUtilsModalFail)
@objcMembers
public class ModalFail : NSObject, UTSObject {
    public var errCode: ModalErrorCode!
    public var errSubject: String!
    public var errMsg: String!
    public var param: String?
    public var platform: String!
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "errCode":
                    self.errCode = try! utsSubscriptCheckValue(newValue)
                case "errSubject":
                    self.errSubject = try! utsSubscriptCheckValue(newValue)
                case "errMsg":
                    self.errMsg = try! utsSubscriptCheckValue(newValue)
                case "param":
                    self.param = try! utsSubscriptCheckValueIfPresent(newValue)
                case "platform":
                    self.platform = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.errCode = obj["errCode"] as! ModalErrorCode
        self.errSubject = obj["errSubject"] as! String
        self.errMsg = obj["errMsg"] as! String
        self.param = obj["param"] as! String?
        self.platform = obj["platform"] as! String
    }
}
@objc(UTSSDKModulesUxUtilsModalOptions)
@objcMembers
public class ModalOptions : NSObject, UTSObject {
    public var title: String?
    public var content: String?
    public var showCancel: Bool = false
    public var cancelText: String?
    public var cancelColor: String?
    public var confirmText: String?
    public var confirmColor: String?
    public var editable: Bool = false
    public var placeholderText: String?
    public var success: ((_ res: ModalResult) -> Void)?
    public var fail: ((_ err: ModalFail) -> Void)?
    public var complete: ((_ res: Any) -> Void)?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "title":
                    self.title = try! utsSubscriptCheckValueIfPresent(newValue)
                case "content":
                    self.content = try! utsSubscriptCheckValueIfPresent(newValue)
                case "showCancel":
                    self.showCancel = try! utsSubscriptCheckValue(newValue)
                case "cancelText":
                    self.cancelText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "cancelColor":
                    self.cancelColor = try! utsSubscriptCheckValueIfPresent(newValue)
                case "confirmText":
                    self.confirmText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "confirmColor":
                    self.confirmColor = try! utsSubscriptCheckValueIfPresent(newValue)
                case "editable":
                    self.editable = try! utsSubscriptCheckValue(newValue)
                case "placeholderText":
                    self.placeholderText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "success":
                    self.success = try! utsSubscriptCheckValueIfPresent(newValue)
                case "fail":
                    self.fail = try! utsSubscriptCheckValueIfPresent(newValue)
                case "complete":
                    self.complete = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.title = obj["title"] as! String?
        self.content = obj["content"] as! String?
        self.showCancel = (obj["showCancel"] as? Bool) ?? false
        self.cancelText = obj["cancelText"] as! String?
        self.cancelColor = obj["cancelColor"] as! String?
        self.confirmText = obj["confirmText"] as! String?
        self.confirmColor = obj["confirmColor"] as! String?
        self.editable = (obj["editable"] as? Bool) ?? false
        self.placeholderText = obj["placeholderText"] as! String?
        self.success = obj["success"] as! ((_ res: ModalResult) -> Void)?
        self.fail = obj["fail"] as! ((_ err: ModalFail) -> Void)?
        self.complete = obj["complete"] as! ((_ res: Any) -> Void)?
    }
}
@objc(UTSSDKModulesUxUtilsNormalizedModalOptions)
@objcMembers
public class NormalizedModalOptions : NSObject, UTSObject {
    public var title: String!
    public var content: String!
    public var showCancel: Bool = false
    public var cancelText: String!
    public var cancelColor: String?
    public var confirmText: String!
    public var confirmColor: String?
    public var editable: Bool = false
    public var placeholderText: String?
    public var success: ((_ res: ModalResult) -> Void)?
    public var fail: ((_ err: ModalFail) -> Void)?
    public var complete: ((_ res: Any) -> Void)?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "title":
                    self.title = try! utsSubscriptCheckValue(newValue)
                case "content":
                    self.content = try! utsSubscriptCheckValue(newValue)
                case "showCancel":
                    self.showCancel = try! utsSubscriptCheckValue(newValue)
                case "cancelText":
                    self.cancelText = try! utsSubscriptCheckValue(newValue)
                case "cancelColor":
                    self.cancelColor = try! utsSubscriptCheckValueIfPresent(newValue)
                case "confirmText":
                    self.confirmText = try! utsSubscriptCheckValue(newValue)
                case "confirmColor":
                    self.confirmColor = try! utsSubscriptCheckValueIfPresent(newValue)
                case "editable":
                    self.editable = try! utsSubscriptCheckValue(newValue)
                case "placeholderText":
                    self.placeholderText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "success":
                    self.success = try! utsSubscriptCheckValueIfPresent(newValue)
                case "fail":
                    self.fail = try! utsSubscriptCheckValueIfPresent(newValue)
                case "complete":
                    self.complete = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.title = obj["title"] as! String
        self.content = obj["content"] as! String
        self.showCancel = obj["showCancel"] as! Bool
        self.cancelText = obj["cancelText"] as! String
        self.cancelColor = obj["cancelColor"] as! String?
        self.confirmText = obj["confirmText"] as! String
        self.confirmColor = obj["confirmColor"] as! String?
        self.editable = obj["editable"] as! Bool
        self.placeholderText = obj["placeholderText"] as! String?
        self.success = obj["success"] as! ((_ res: ModalResult) -> Void)?
        self.fail = obj["fail"] as! ((_ err: ModalFail) -> Void)?
        self.complete = obj["complete"] as! ((_ res: Any) -> Void)?
    }
}
@objc(UTSSDKModulesUxUtilsNormalizeModalResult)
@objcMembers
public class NormalizeModalResult : NSObject, UTSObject {
    public var options: NormalizedModalOptions!
    public var degraded: [String]!
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "options":
                    self.options = try! utsSubscriptCheckValue(newValue)
                case "degraded":
                    self.degraded = try! utsSubscriptCheckValue(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.options = obj["options"] as! NormalizedModalOptions
        self.degraded = obj["degraded"] as! [String]
    }
}
@objc(UTSSDKModulesUxUtilsModalDefaults)
@objcMembers
public class ModalDefaults : NSObject, UTSObject {
    public var cancelText: String?
    public var confirmText: String?
    public var cancelColor: String?
    public var confirmColor: String?
    public subscript(_ key: String) -> Any? {
        get {
            return utsSubscriptGetValue(key)
        }
        set {
            switch(key){
                case "cancelText":
                    self.cancelText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "confirmText":
                    self.confirmText = try! utsSubscriptCheckValueIfPresent(newValue)
                case "cancelColor":
                    self.cancelColor = try! utsSubscriptCheckValueIfPresent(newValue)
                case "confirmColor":
                    self.confirmColor = try! utsSubscriptCheckValueIfPresent(newValue)
                default:
                    break
            }
        }
    }
    public override init() {
        super.init()
    }
    public init(_ obj: UTSJSONObject) {
        self.cancelText = obj["cancelText"] as! String?
        self.confirmText = obj["confirmText"] as! String?
        self.cancelColor = obj["cancelColor"] as! String?
        self.confirmColor = obj["confirmColor"] as! String?
    }
}
public typealias ShowModal = (_ options: ModalOptions) -> Void
public typealias ShowModalAsync = (_ options: ModalOptions) -> UTSPromise<ModalResult>
public typealias ShowModalAlert = (_ title: String, _ content: String?) -> Void
public typealias ConfigureModal = (_ defaults: ModalDefaults) -> Void
public typealias ToastIcon__1 = String
public typealias ToastPosition__1 = String
public typealias ToastErrorCode__1 = NSNumber
public var ERR_PARAM_INVALID: ToastErrorCode__1 = 1001
public var ERR_PLATFORM_UNSUPPORTED: ToastErrorCode__1 = 2001
public var BUILTIN_DURATION: NSNumber = 1500
public var BUILTIN_ICON: ToastIcon__1 = "success"
public var BUILTIN_MASK: Bool = false
public var WECHAT_TITLE_MAX_LENGTH: NSNumber = 7
public var NATIVE_TITLE_MAX_LENGTH: NSNumber = 20
public var TOAST_ERR_SUBJECT: String = "unix-utils:toast"
public func getPlatform() -> String {
    do {
        var info = DCloudUTSExtAPI.getSystemInfoSync()
        return info.uniPlatform
    }
     catch let e {
        var e = UTSError(e)
        return "unknown"
    }
}
public func isSelfDrawPlatform(_ platform: String) -> Bool {
    return true
}
public var currentDefaults = ToastDefaults(UTSJSONObject([
    "duration": BUILTIN_DURATION,
    "icon": BUILTIN_ICON,
    "mask": BUILTIN_MASK
]))
public func configureToastImpl(_ defaults: ToastDefaults) -> Void {
    currentDefaults = defaults
}
public func getToastDefaults() -> ToastDefaults {
    return currentDefaults
}
public func truncateTitle(_ title: String, _ platform: String) -> String {
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
public func normalizeIcon(_ icon: ToastIcon__1, _ platform: String, _ degraded: [String]) -> ToastIcon__1 {
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
public func normalizePosition(_ position: ToastPosition__1?, _ platform: String, _ degraded: [String]) -> ToastPosition__1? {
    if (position == nil) {
        return nil
    }
    if (isSelfDrawPlatform(platform)) {
        return position
    }
    degraded.push("position")
    return nil
}
public func normalizeImage(_ image: String?, _ platform: String, _ degraded: [String]) -> String? {
    if (image == nil) {
        return nil
    }
    if (isSelfDrawPlatform(platform)) {
        return image
    }
    if ((image as! String).toLowerCase().endsWith(".gif")) {
        degraded.push("image")
        return nil
    }
    return image
}
public func normalize(_ options: ToastOptions) -> NormalizeResult {
    var platform = getPlatform()
    var defaults = getToastDefaults()
    var degraded: [String] = []
    var icon: ToastIcon__1 = normalizeIcon(options.icon != nil ? options.icon as! String : defaults.icon != nil ? defaults.icon as! String : BUILTIN_ICON, platform, degraded)
    var position: ToastPosition__1? = normalizePosition(options.position, platform, degraded)
    var image: String? = normalizeImage(options.image, platform, degraded)
    var title: String = truncateTitle(options.title, platform)
    var mask: Bool = options.mask != nil ? options.mask as! Bool : defaults.mask != nil ? defaults.mask as! Bool : BUILTIN_MASK
    var duration: NSNumber = options.duration != nil ? options.duration as! NSNumber : defaults.duration != nil ? defaults.duration as! NSNumber : BUILTIN_DURATION
    var normalized = NormalizedOptions(UTSJSONObject([
        "title": title,
        "icon": icon,
        "image": image,
        "mask": mask,
        "duration": duration,
        "position": position,
        "success": options.success,
        "fail": options.fail,
        "complete": options.complete
    ]))
    var result = NormalizeResult(UTSJSONObject([
        "options": normalized,
        "degraded": degraded
    ]))
    return result
}
public func iconToNativeString(_ icon: ToastIcon__1) -> String {
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
public func positionToNativeString(_ position: ToastPosition__1) -> String {
    if (position == "top") {
        return "top"
    }
    if (position == "center") {
        return "center"
    }
    return "bottom"
}
public func showNative(_ options: NormalizedOptions) -> Void {
    var platform = getPlatform()
    DCloudUTSExtAPI.showToast(ShowToastOptions(UTSJSONObject([
        "title": options.title,
        "icon": iconToNativeString(options.icon),
        "image": options.image,
        "mask": options.mask,
        "duration": options.duration,
        "position": options.position == nil ? nil : positionToNativeString(options.position as! String),
        "success": {
        (_: ShowToastSuccess) -> Void in
        if (options.success != nil) {
            var r = ToastResult(UTSJSONObject([
                "errMsg": "showToast:ok"
            ]))
            (options.success as! (_ res: ToastResult) -> Void)(r)
        }
        },
        "fail": {
        (err: ShowToastFail) -> Void in
        if (options.fail != nil) {
            var f = ToastFail(UTSJSONObject([
                "errCode": ERR_PARAM_INVALID,
                "errSubject": TOAST_ERR_SUBJECT,
                "errMsg": err.errMsg,
                "param": nil,
                "platform": platform
            ]))
            (options.fail as! (_ err: ToastFail) -> Void)(f)
        }
        },
        "complete": {
        (res: Any) -> Void in
        if (options.complete != nil) {
            (options.complete as! (_ res: Any) -> Void)(res)
        }
        }
    ])))
}
public var iosRoot: UIView? = nil
public var iosLabel: UILabel? = nil
public var lastMask: Bool = false
public var lastPosition: String = ""
public var iosHideTimer: NSNumber = 0
public func iconEmoji(_ icon: String) -> String {
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
public func combinedText(_ icon: String, _ title: String) -> String {
    var emoji = iconEmoji(icon)
    if (emoji.length > 0) {
        return emoji + "\n" + title
    }
    return title
}
public func buildLabel(_ winW: NSNumber, _ icon: String, _ title: String) -> UILabel {
    var label = UILabel()
    label.text = combinedText(icon, title)
    label.textColor = UIColor.white
    label.backgroundColor = UIColor.black.colorWithAlphaComponent(0.75)
    label.textAlignment = NSTextAlignment.center
    label.numberOfLines = 0
    label.layer.cornerRadius = 8.0
    label.layer.masksToBounds = true
    label.userInteractionEnabled = false
    var fit = label.sizeThatFits(CGSizeMake(240.0, 9999.0))
    var w = fit.width + 40.0
    if (w > 280.0) {
        w = 280.0
    }
    var h = fit.height + 24.0
    var x = winW / 2.0 - w / 2.0
    label.frame = CGRectMake(x, 0.0, w, h)
    return label
}
public func labelY(_ winH: NSNumber, _ h: NSNumber, _ position: String) -> NSNumber {
    if (position == "top") {
        return winH * 0.1
    }
    if (position == "center") {
        return winH / 2.0 - h / 2.0
    }
    return winH * 0.9 - h
}
public func updateTexts(_ icon: String, _ title: String) -> Void {
    var label = iosLabel
    if (label != nil) {
        label!.text = combinedText(icon, title)
    }
}
public func scheduleHide(_ duration: NSNumber) -> Void {
    if (iosHideTimer != 0) {
        clearTimeout(iosHideTimer)
    }
    iosHideTimer = setTimeout({
    () -> Void in
    iosHideTimer = 0
    hideWindowToast()
    }, duration)
}
public func showWindowToast(_ title: String, _ icon: String, _ mask: Bool, _ duration: NSNumber, _ position: String, _ fail: ((_ errMsg: String) -> Void)?) -> Void {
    var win = UTSiOS.getKeyWindow()
    if (win == nil) {
        if (fail != nil) {
            (fail as! (_ errMsg: String) -> Void)("getKeyWindow() 为 null，无法挂载")
        }
        return
    }
    do {
        var winW = win.bounds.width
        var winH = win.bounds.height
        var existing = iosRoot
        var maskChanged = lastMask != mask
        var positionChanged = lastPosition != position
        var needRebuildForIcon = iosLabel == nil && iconEmoji(icon).length > 0
        if (existing != nil && !maskChanged && !positionChanged && !needRebuildForIcon) {
            updateTexts(icon, title)
            scheduleHide(duration)
            return
        }
        if (existing != nil) {
            existing!.removeFromSuperview()
            iosRoot = nil
            iosLabel = nil
        }
        var label = buildLabel(winW, icon, title)
        label.frame = CGRectMake(label.frame.origin.x, labelY(winH, label.frame.size.height, position), label.frame.size.width, label.frame.size.height)
        if (mask) {
            var root = UIView()
            root.frame = CGRectMake(0.0, 0.0, winW, winH)
            root.backgroundColor = UIColor.black.colorWithAlphaComponent(0.5)
            root.addSubview(label)
            win.addSubview(root)
            iosRoot = root
        } else {
            win.addSubview(label)
            iosRoot = label
        }
        iosLabel = label
        lastMask = mask
        lastPosition = position
        scheduleHide(duration)
    }
     catch let e {
        var e = UTSError(e)
        if (fail != nil) {
            (fail as! (_ errMsg: String) -> Void)("挂窗异常: " + e.message)
        }
    }
}
public func hideWindowToast() -> Void {
    if (iosHideTimer != 0) {
        clearTimeout(iosHideTimer)
        iosHideTimer = 0
    }
    var root = iosRoot
    var label = iosLabel
    if (root == nil) {
        return
    }
    iosRoot = nil
    iosLabel = nil
    label!.layer.opacity = 0.0
    setTimeout({
    () -> Void in
    root!.removeFromSuperview()
    }, 300)
}
public func iconToSelfDrawString(_ icon: ToastIcon__1) -> String {
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
public func positionToSelfDrawString(_ position: ToastPosition__1?) -> String {
    if (position == "top") {
        return "top"
    }
    if (position == "center") {
        return "center"
    }
    return "bottom"
}
public func notifyFallback(_ options: NormalizedOptions, _ param: String?, _ errMsg: String) -> Void {
    if (options.fail == nil) {
        return
    }
    var f = ToastFail(UTSJSONObject([
        "errCode": ERR_PLATFORM_UNSUPPORTED,
        "errSubject": TOAST_ERR_SUBJECT,
        "errMsg": errMsg,
        "param": param,
        "platform": getPlatform()
    ]))
    (options.fail as! (_ err: ToastFail) -> Void)(f)
}
public func showSelfDraw(_ options: NormalizedOptions) -> Void {
    var iconStr = iconToSelfDrawString(options.icon)
    if (options.image != nil) {
        iconStr = "none"
        notifyFallback(options, "image", "直挂窗口通道暂不渲染 image 自定义图标，已降级")
    }
    showWindowToast(options.title, iconStr, options.mask, options.duration, positionToSelfDrawString(options.position), {
    (errMsg: String) -> Void in
    console.log("[toast] 窗口直挂失败，降级 uni.showToast: " + errMsg)
    showNative(options)
    notifyFallback(options, nil, "窗口直挂失败，已降级原生通道: " + errMsg)
    })
}
public func hideSelfDraw() -> Void {
    hideWindowToast()
}
public func notifyDegraded(_ options: ToastOptions, _ degraded: [String]) -> Void {
    if (degraded.length === 0 || options.fail == nil) {
        return
    }
    var platform = getPlatform()
    do {
        var i: NSNumber = 0
        while(i < degraded.length){
            var f = ToastFail(UTSJSONObject([
                "errCode": ERR_PLATFORM_UNSUPPORTED,
                "errSubject": TOAST_ERR_SUBJECT,
                "errMsg": "参数在当前端不支持，已降级处理",
                "param": degraded[i],
                "platform": platform
            ]))
            (options.fail as! (_ err: ToastFail) -> Void)(f)
            i++
        }
    }
}
public func dispatchShow(_ options: NormalizedOptions) -> Void {
    showSelfDraw(options)
}
public func showToastImpl(_ options: ToastOptions) -> Void {
    var result = normalize(options)
    notifyDegraded(options, result.degraded)
    dispatchShow(result.options)
}
public func hideToastImpl() -> Void {
    hideSelfDraw()
}
public func showToastAsyncImpl(_ options: ToastOptions) -> UTSPromise<Void> {
    return UTSPromise<Void>({
    (_ resolve, _ reject) -> Void in
    var wrapped = ToastOptions(UTSJSONObject([
        "title": options.title,
        "icon": options.icon,
        "image": options.image,
        "mask": options.mask,
        "duration": options.duration,
        "position": options.position,
        "success": {
        (_ res: ToastResult) -> Void in
        if (options.success != nil) {
            (options.success as! (_ res: ToastResult) -> Void)(res)
        }
        resolve(())
        },
        "fail": {
        (_ err: ToastFail) -> Void in
        if (options.fail != nil) {
            (options.fail as! (_ err: ToastFail) -> Void)(err)
        }
        reject(err)
        },
        "complete": options.complete
    ]))
    showToastImpl(wrapped)
    })
}
public func quickShow(_ title: String, _ icon: ToastIcon__1) -> Void {
    var defaults = getToastDefaults()
    var duration: NSNumber = defaults.duration != nil ? defaults.duration as! NSNumber : BUILTIN_DURATION
    var mask: Bool = defaults.mask != nil ? defaults.mask as! Bool : BUILTIN_MASK
    var options = ToastOptions(UTSJSONObject([
        "title": title,
        "icon": icon,
        "image": nil,
        "mask": mask,
        "duration": duration,
        "position": nil,
        "success": nil,
        "fail": nil,
        "complete": nil
    ]))
    showToastImpl(options)
}
public func showToastSuccessImpl(_ title: String) -> Void {
    quickShow(title, "success")
}
public func showToastErrorImpl(_ title: String) -> Void {
    quickShow(title, "error")
}
public func showToastInfoImpl(_ title: String) -> Void {
    quickShow(title, "none")
}
public typealias ModalErrorCode__1 = NSNumber
public var MODAL_ERR_PARAM_INVALID: ModalErrorCode__1 = 1001
public var MODAL_ERR_PLATFORM_UNSUPPORTED: ModalErrorCode__1 = 2001
public var BUILTIN_CONFIRM_TEXT: String = "确定"
public var BUILTIN_CANCEL_TEXT: String = "取消"
public var MODAL_TEXT_MAX_LENGTH: NSNumber = 4
public var MODAL_ERR_SUBJECT: String = "unix-utils:modal"
public func isModalHexChar(_ c: String) -> Bool {
    var code = c.charCodeAt(0)
    if (code == nil) {
        return false
    }
    if (code >= 48 && code <= 57) {
        return true
    }
    if (code >= 65 && code <= 70) {
        return true
    }
    if (code >= 97 && code <= 102) {
        return true
    }
    return false
}
public func normalizeModalColor(_ value: String?, _ supportsAlpha: Bool, _ param: String, _ degraded: [String]) -> String? {
    if (value == nil) {
        return nil
    }
    if (!(value as! String).startsWith("#")) {
        degraded.push(param)
        return nil
    }
    var hex = (value as! String).substring(1)
    var len = hex.length
    if (len != 3 && len != 6 && len != 8) {
        degraded.push(param)
        return nil
    }
    do {
        var i: NSNumber = 0
        while(i < len){
            if (!isModalHexChar(hex.charAt(i))) {
                degraded.push(param)
                return nil
            }
            i++
        }
    }
    if (len == 3) {
        var r = hex.charAt(0)
        var g = hex.charAt(1)
        var b = hex.charAt(2)
        return "#" + r + r + g + g + b + b
    }
    if (len == 8) {
        if (supportsAlpha) {
            return value
        }
        degraded.push(param)
        return "#" + hex.substring(0, 6)
    }
    return value
}
public var currentModalDefaults = ModalDefaults(UTSJSONObject([
    "cancelText": nil,
    "confirmText": nil,
    "cancelColor": nil,
    "confirmColor": nil
]))
public func configureModalImpl(_ defaults: ModalDefaults) -> Void {
    currentModalDefaults = defaults
}
public func getModalDefaults() -> ModalDefaults {
    return currentModalDefaults
}
public func truncateModalText(_ text: String, _ platform: String) -> String {
    if (platform === "mp-weixin" || platform === "app-harmony") {
        if (text.length > MODAL_TEXT_MAX_LENGTH) {
            return text.substring(0, MODAL_TEXT_MAX_LENGTH)
        }
    }
    return text
}
public func normalizeModal(_ options: ModalOptions) -> NormalizeModalResult {
    var platform = getPlatform()
    var defaults = getModalDefaults()
    var degraded: [String] = []
    var title: String = options.title != nil ? options.title as! String : ""
    var content: String = options.content != nil ? options.content as! String : ""
    var showCancel: Bool = options.showCancel != nil ? options.showCancel as! Bool : true
    var editable: Bool = options.editable != nil ? options.editable as! Bool : false
    var placeholderText: String? = options.placeholderText != nil ? options.placeholderText : nil
    var rawCancelText = options.cancelText != nil ? options.cancelText as! String : defaults.cancelText != nil ? defaults.cancelText as! String : BUILTIN_CANCEL_TEXT
    var rawConfirmText = options.confirmText != nil ? options.confirmText as! String : defaults.confirmText != nil ? defaults.confirmText as! String : BUILTIN_CONFIRM_TEXT
    var cancelText: String = truncateModalText(rawCancelText, platform)
    var confirmText: String = truncateModalText(rawConfirmText, platform)
    var supportsAlpha = platform === "web"
    var rawCancelColor = options.cancelColor != nil ? options.cancelColor as! String : defaults.cancelColor
    var cancelColor: String? = normalizeModalColor(rawCancelColor, supportsAlpha, "cancelColor", degraded)
    var rawConfirmColor = options.confirmColor != nil ? options.confirmColor as! String : defaults.confirmColor
    var confirmColor: String? = normalizeModalColor(rawConfirmColor, supportsAlpha, "confirmColor", degraded)
    var normalized = NormalizedModalOptions(UTSJSONObject([
        "title": title,
        "content": content,
        "showCancel": showCancel,
        "cancelText": cancelText,
        "cancelColor": cancelColor,
        "confirmText": confirmText,
        "confirmColor": confirmColor,
        "editable": editable,
        "placeholderText": placeholderText,
        "success": options.success,
        "fail": options.fail,
        "complete": options.complete
    ]))
    var result = NormalizeModalResult(UTSJSONObject([
        "options": normalized,
        "degraded": degraded
    ]))
    return result
}
public func showModalNative(_ options: NormalizedModalOptions) -> Void {
    var platform = getPlatform()
    DCloudUTSExtAPI.showModal(ShowModalOptions(UTSJSONObject([
        "title": options.title,
        "content": options.content,
        "showCancel": options.showCancel,
        "cancelText": options.cancelText,
        "cancelColor": options.cancelColor,
        "confirmText": options.confirmText,
        "confirmColor": options.confirmColor,
        "editable": options.editable,
        "placeholderText": options.placeholderText,
        "success": {
        (res: ShowModalSuccess) -> Void in
        if (options.success == nil) {
            return
        }
        var confirm = res.confirm == true
        var content: String? = nil
        if (options.editable && confirm) {
            var raw = res.content
            content = raw != nil ? raw : ""
        }
        var r = ModalResult(UTSJSONObject([
            "confirm": confirm,
            "cancel": !confirm,
            "content": content
        ]))
        (options.success as! (_ res: ModalResult) -> Void)(r)
        },
        "fail": {
        (err: ShowModalFail) -> Void in
        if (options.fail != nil) {
            var f = ModalFail(UTSJSONObject([
                "errCode": MODAL_ERR_PARAM_INVALID,
                "errSubject": MODAL_ERR_SUBJECT,
                "errMsg": err.errMsg,
                "param": nil,
                "platform": platform
            ]))
            (options.fail as! (_ err: ModalFail) -> Void)(f)
        }
        },
        "complete": {
        (res: Any) -> Void in
        if (options.complete != nil) {
            (options.complete as! (_ res: Any) -> Void)(res)
        }
        }
    ])))
}
public func notifyModalDegraded(_ options: ModalOptions, _ degraded: [String]) -> Void {
    if (degraded.length === 0 || options.fail == nil) {
        return
    }
    var platform = getPlatform()
    do {
        var i: NSNumber = 0
        while(i < degraded.length){
            var f = ModalFail(UTSJSONObject([
                "errCode": MODAL_ERR_PLATFORM_UNSUPPORTED,
                "errSubject": MODAL_ERR_SUBJECT,
                "errMsg": "参数在当前端不支持，已降级处理",
                "param": degraded[i],
                "platform": platform
            ]))
            (options.fail as! (_ err: ModalFail) -> Void)(f)
            i++
        }
    }
}
public func notifyModalParamInvalid(_ options: ModalOptions) -> Void {
    var f = ModalFail(UTSJSONObject([
        "errCode": MODAL_ERR_PARAM_INVALID,
        "errSubject": MODAL_ERR_SUBJECT,
        "errMsg": "title 与 content 至少其一非空",
        "param": "title",
        "platform": getPlatform()
    ]))
    if (options.fail != nil) {
        (options.fail as! (_ err: ModalFail) -> Void)(f)
    }
    if (options.complete != nil) {
        (options.complete as! (_ res: Any) -> Void)(f)
    }
}
public func dispatchModalShow(_ options: NormalizedModalOptions) -> Void {
    showModalNative(options)
}
public func showModalImpl(_ options: ModalOptions) -> Void {
    var title = options.title != nil ? options.title as! String : ""
    var content = options.content != nil ? options.content as! String : ""
    if (title.length === 0 && content.length === 0) {
        notifyModalParamInvalid(options)
        return
    }
    var result = normalizeModal(options)
    notifyModalDegraded(options, result.degraded)
    dispatchModalShow(result.options)
}
public func showModalAsyncImpl(_ options: ModalOptions) -> UTSPromise<ModalResult> {
    return UTSPromise<ModalResult>({
    (_ resolve, _ reject) -> Void in
    var wrapped = ModalOptions(UTSJSONObject([
        "title": options.title,
        "content": options.content,
        "showCancel": options.showCancel,
        "cancelText": options.cancelText,
        "cancelColor": options.cancelColor,
        "confirmText": options.confirmText,
        "confirmColor": options.confirmColor,
        "editable": options.editable,
        "placeholderText": options.placeholderText,
        "success": {
        (_ res: ModalResult) -> Void in
        if (options.success != nil) {
            (options.success as! (_ res: ModalResult) -> Void)(res)
        }
        resolve(res)
        },
        "fail": {
        (_ err: ModalFail) -> Void in
        if (options.fail != nil) {
            (options.fail as! (_ err: ModalFail) -> Void)(err)
        }
        reject(err)
        },
        "complete": options.complete
    ]))
    showModalImpl(wrapped)
    })
}
public func showModalAlertImpl(_ title: String, _ content: String?) -> Void {
    var options = ModalOptions(UTSJSONObject([
        "title": title,
        "content": content,
        "showCancel": false,
        "cancelText": nil,
        "cancelColor": nil,
        "confirmText": nil,
        "confirmColor": nil,
        "editable": false,
        "placeholderText": nil,
        "success": nil,
        "fail": nil,
        "complete": nil
    ]))
    showModalImpl(options)
}
public var DEFAULT_DURATION: NSNumber = 1500
public var DEFAULT_ICON: ToastIcon = "success"
public var DEFAULT_MASK: Bool = false
public var TOAST_ERR_PARAM_INVALID: ToastErrorCode = 1001
public var TOAST_ERR_PLATFORM_UNSUPPORTED: ToastErrorCode = 2001
public var showToast: ShowToast = {
(_ options: ToastOptions) -> Void in
showToastImpl(options)
}
public var hideToast: HideToast = {
() -> Void in
hideToastImpl()
}
public var showToastAsync: ShowToastAsync = {
(_ options: ToastOptions) -> UTSPromise<Void> in
return showToastAsyncImpl(options)
}
public var configureToast: ConfigureToast = {
(_ defaults: ToastDefaults) -> Void in
configureToastImpl(defaults)
}
public var showToastSuccess: ShowToastQuick = {
(_ title: String) -> Void in
showToastSuccessImpl(title)
}
public var showToastError: ShowToastQuick = {
(_ title: String) -> Void in
showToastErrorImpl(title)
}
public var showToastInfo: ShowToastQuick = {
(_ title: String) -> Void in
showToastInfoImpl(title)
}
public var DEFAULT_CONFIRM_TEXT: String = "确定"
public var DEFAULT_CANCEL_TEXT: String = "取消"
public var DEFAULT_CONFIRM_COLOR: String = "#007aff"
public var DEFAULT_CANCEL_COLOR: String = "#000000"
public var showModal: ShowModal = {
(_ options: ModalOptions) -> Void in
showModalImpl(options)
}
public var showModalAsync: ShowModalAsync = {
(_ options: ModalOptions) -> UTSPromise<ModalResult> in
return showModalAsyncImpl(options)
}
public var showModalAlert: ShowModalAlert = {
(_ title: String, _ content: String?) -> Void in
showModalAlertImpl(title, content)
}
public var configureModal: ConfigureModal = {
(_ defaults: ModalDefaults) -> Void in
configureModalImpl(defaults)
}
@objc(UTSSDKModulesUxUtilsToastOptionsJSONObject)
@objcMembers
public class ToastOptionsJSONObject : NSObject {
    public var title: String!
    public var icon: ToastIcon?
    public var image: String?
    public var mask: Bool = false
    public var duration: NSNumber?
    public var position: ToastPosition?
    public var success: UTSCallback?
    public var fail: UTSCallback?
    public var complete: UTSCallback?
}
@objc(UTSSDKModulesUxUtilsToastDefaultsJSONObject)
@objcMembers
public class ToastDefaultsJSONObject : NSObject {
    public var duration: NSNumber?
    public var icon: ToastIcon?
    public var mask: Bool = false
}
@objc(UTSSDKModulesUxUtilsModalOptionsJSONObject)
@objcMembers
public class ModalOptionsJSONObject : NSObject {
    public var title: String?
    public var content: String?
    public var showCancel: Bool = false
    public var cancelText: String?
    public var cancelColor: String?
    public var confirmText: String?
    public var confirmColor: String?
    public var editable: Bool = false
    public var placeholderText: String?
    public var success: UTSCallback?
    public var fail: UTSCallback?
    public var complete: UTSCallback?
}
@objc(UTSSDKModulesUxUtilsModalDefaultsJSONObject)
@objcMembers
public class ModalDefaultsJSONObject : NSObject {
    public var cancelText: String?
    public var confirmText: String?
    public var cancelColor: String?
    public var confirmColor: String?
}
public func showToastByJs(_ options: ToastOptionsJSONObject) -> Void {
    return showToast(ToastOptions(UTSJSONObject([
        "title": options.title,
        "icon": options.icon,
        "image": options.image,
        "mask": options.mask,
        "duration": options.duration,
        "position": options.position,
        "success": {
        (res: ToastResult) -> Void in
        options.success?(res)
        },
        "fail": {
        (err: ToastFail) -> Void in
        options.fail?(err)
        },
        "complete": {
        (res: Any) -> Void in
        options.complete?(res)
        }
    ])))
}
public func hideToastByJs() -> Void {
    return hideToast()
}
public func showToastAsyncByJs(_ options: ToastOptionsJSONObject, utsCompletionHandler: @escaping (_ res: Any?, _ err: Any?) -> Void) {
    showToastAsync(ToastOptions(UTSJSONObject([
        "title": options.title,
        "icon": options.icon,
        "image": options.image,
        "mask": options.mask,
        "duration": options.duration,
        "position": options.position,
        "success": {
        (res: ToastResult) -> Void in
        options.success?(res)
        },
        "fail": {
        (err: ToastFail) -> Void in
        options.fail?(err)
        },
        "complete": {
        (res: Any) -> Void in
        options.complete?(res)
        }
    ]))).then({
    (res) -> Void in
    utsCompletionHandler(res, nil)
    }).catch({
    (err) -> Void in
    utsCompletionHandler(nil, err)
    })
}
public func configureToastByJs(_ defaults: ToastDefaultsJSONObject) -> Void {
    return configureToast(ToastDefaults(UTSJSONObject([
        "duration": defaults.duration,
        "icon": defaults.icon,
        "mask": defaults.mask
    ])))
}
public func showToastSuccessByJs(_ title: String) -> Void {
    return showToastSuccess(title)
}
public func showToastErrorByJs(_ title: String) -> Void {
    return showToastError(title)
}
public func showToastInfoByJs(_ title: String) -> Void {
    return showToastInfo(title)
}
public func showModalByJs(_ options: ModalOptionsJSONObject) -> Void {
    return showModal(ModalOptions(UTSJSONObject([
        "title": options.title,
        "content": options.content,
        "showCancel": options.showCancel,
        "cancelText": options.cancelText,
        "cancelColor": options.cancelColor,
        "confirmText": options.confirmText,
        "confirmColor": options.confirmColor,
        "editable": options.editable,
        "placeholderText": options.placeholderText,
        "success": {
        (res: ModalResult) -> Void in
        options.success?(res)
        },
        "fail": {
        (err: ModalFail) -> Void in
        options.fail?(err)
        },
        "complete": {
        (res: Any) -> Void in
        options.complete?(res)
        }
    ])))
}
public func showModalAsyncByJs(_ options: ModalOptionsJSONObject, utsCompletionHandler: @escaping (_ res: Any?, _ err: Any?) -> Void) {
    showModalAsync(ModalOptions(UTSJSONObject([
        "title": options.title,
        "content": options.content,
        "showCancel": options.showCancel,
        "cancelText": options.cancelText,
        "cancelColor": options.cancelColor,
        "confirmText": options.confirmText,
        "confirmColor": options.confirmColor,
        "editable": options.editable,
        "placeholderText": options.placeholderText,
        "success": {
        (res: ModalResult) -> Void in
        options.success?(res)
        },
        "fail": {
        (err: ModalFail) -> Void in
        options.fail?(err)
        },
        "complete": {
        (res: Any) -> Void in
        options.complete?(res)
        }
    ]))).then({
    (res) -> Void in
    utsCompletionHandler(res, nil)
    }).catch({
    (err) -> Void in
    utsCompletionHandler(nil, err)
    })
}
public func showModalAlertByJs(_ title: String, _ content: String?) -> Void {
    return showModalAlert(title, content)
}
public func configureModalByJs(_ defaults: ModalDefaultsJSONObject) -> Void {
    return configureModal(ModalDefaults(UTSJSONObject([
        "cancelText": defaults.cancelText,
        "confirmText": defaults.confirmText,
        "cancelColor": defaults.cancelColor,
        "confirmColor": defaults.confirmColor
    ])))
}
@objc(UTSSDKModulesUxUtilsIndexSwift)
@objcMembers
public class UTSSDKModulesUxUtilsIndexSwift : NSObject {
    public static func s_showToastByJs(_ options: ToastOptionsJSONObject) -> Void {
        return showToastByJs(options)
    }
    public static func s_hideToastByJs() -> Void {
        return hideToastByJs()
    }
    public static func s_showToastAsyncByJs(_ options: ToastOptionsJSONObject, utsCompletionHandler: @escaping (_ res: Any?, _ err: Any?) -> Void) {
        return showToastAsyncByJs(options, utsCompletionHandler: utsCompletionHandler)
    }
    public static func s_configureToastByJs(_ defaults: ToastDefaultsJSONObject) -> Void {
        return configureToastByJs(defaults)
    }
    public static func s_showToastSuccessByJs(_ title: String) -> Void {
        return showToastSuccessByJs(title)
    }
    public static func s_showToastErrorByJs(_ title: String) -> Void {
        return showToastErrorByJs(title)
    }
    public static func s_showToastInfoByJs(_ title: String) -> Void {
        return showToastInfoByJs(title)
    }
    public static func s_showModalByJs(_ options: ModalOptionsJSONObject) -> Void {
        return showModalByJs(options)
    }
    public static func s_showModalAsyncByJs(_ options: ModalOptionsJSONObject, utsCompletionHandler: @escaping (_ res: Any?, _ err: Any?) -> Void) {
        return showModalAsyncByJs(options, utsCompletionHandler: utsCompletionHandler)
    }
    public static func s_showModalAlertByJs(_ title: String, _ content: String?) -> Void {
        return showModalAlertByJs(title, content)
    }
    public static func s_configureModalByJs(_ defaults: ModalDefaultsJSONObject) -> Void {
        return configureModalByJs(defaults)
    }
}

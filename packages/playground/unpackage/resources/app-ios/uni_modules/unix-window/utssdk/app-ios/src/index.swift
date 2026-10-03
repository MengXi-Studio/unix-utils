import DCloudUTSFoundation
import DCloudUniappRuntime
import UIKit
public var iosRoot: UIView? = nil
public var iosLabel: UILabel? = nil
public var lastMask: Bool = false
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
        return winH * 0.15
    }
    if (position == "center") {
        return winH / 2.0 - h / 2.0
    }
    return winH * 0.85 - h
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
        var needRebuildForIcon = iosLabel == nil && iconEmoji(icon).length > 0
        if (existing != nil && !maskChanged && !needRebuildForIcon) {
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
public func showWindowToastByJs(_ title: String, _ icon: String, _ mask: Bool, _ duration: NSNumber, _ position: String, _ fail: UTSCallback?) -> Void {
    return showWindowToast(title, icon, mask, duration, position, {
    (errMsg: String) -> Void in
    fail?(errMsg)
    })
}
public func hideWindowToastByJs() -> Void {
    return hideWindowToast()
}
@objc(UTSSDKModulesUnixWindowIndexSwift)
@objcMembers
public class UTSSDKModulesUnixWindowIndexSwift : NSObject {
    public static func s_showWindowToastByJs(_ title: String, _ icon: String, _ mask: Bool, _ duration: NSNumber, _ position: String, _ fail: UTSCallback?) -> Void {
        return showWindowToastByJs(title, icon, mask, duration, position, fail)
    }
    public static func s_hideWindowToastByJs() -> Void {
        return hideWindowToastByJs()
    }
}

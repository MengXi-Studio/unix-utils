(function(vue) {
  "use strict";
  var ToastIcon;
  (function(ToastIcon2) {
    ToastIcon2["SUCCESS"] = "success";
    ToastIcon2["ERROR"] = "error";
    ToastIcon2["FAIL"] = "fail";
    ToastIcon2["EXCEPTION"] = "exception";
    ToastIcon2["WARNING"] = "warning";
    ToastIcon2["LOADING"] = "loading";
    ToastIcon2["NONE"] = "none";
  })(ToastIcon || (ToastIcon = {}));
  var ToastPosition;
  (function(ToastPosition2) {
    ToastPosition2["TOP"] = "top";
    ToastPosition2["CENTER"] = "center";
    ToastPosition2["BOTTOM"] = "bottom";
  })(ToastPosition || (ToastPosition = {}));
  var ToastErrorCode;
  (function(ToastErrorCode2) {
    ToastErrorCode2[ToastErrorCode2["PARAM_INVALID"] = 1001] = "PARAM_INVALID";
    ToastErrorCode2[ToastErrorCode2["PLATFORM_UNSUPPORTED"] = 2001] = "PLATFORM_UNSUPPORTED";
  })(ToastErrorCode || (ToastErrorCode = {}));
  class ToastResult extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            errMsg: { type: String, optional: false }
          };
        }
      };
    }
    constructor(options, metadata = ToastResult.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.errMsg = this.__props__.errMsg;
      delete this.__props__;
    }
  }
  class ToastFail extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            errCode: { type: "Unknown", optional: false },
            errSubject: { type: String, optional: false },
            errMsg: { type: String, optional: false },
            param: { type: String, optional: true },
            platform: { type: String, optional: false }
          };
        }
      };
    }
    constructor(options, metadata = ToastFail.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.errCode = this.__props__.errCode;
      this.errSubject = this.__props__.errSubject;
      this.errMsg = this.__props__.errMsg;
      this.param = this.__props__.param;
      this.platform = this.__props__.platform;
      delete this.__props__;
    }
  }
  class ToastOptions extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            title: { type: String, optional: false },
            icon: { type: "Unknown", optional: true },
            image: { type: String, optional: true },
            mask: { type: Boolean, optional: false },
            duration: { type: Number, optional: false },
            position: { type: "Unknown", optional: true },
            success: { type: "Unknown", optional: true },
            fail: { type: "Unknown", optional: true },
            complete: { type: "Unknown", optional: true }
          };
        }
      };
    }
    constructor(options, metadata = ToastOptions.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.title = this.__props__.title;
      this.icon = this.__props__.icon;
      this.image = this.__props__.image;
      this.mask = this.__props__.mask;
      this.duration = this.__props__.duration;
      this.position = this.__props__.position;
      this.success = this.__props__.success;
      this.fail = this.__props__.fail;
      this.complete = this.__props__.complete;
      delete this.__props__;
    }
  }
  class NormalizedOptions extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            title: { type: String, optional: false },
            icon: { type: "Unknown", optional: false },
            image: { type: String, optional: true },
            mask: { type: Boolean, optional: false },
            duration: { type: Number, optional: false },
            position: { type: "Unknown", optional: true },
            success: { type: "Unknown", optional: true },
            fail: { type: "Unknown", optional: true },
            complete: { type: "Unknown", optional: true }
          };
        }
      };
    }
    constructor(options, metadata = NormalizedOptions.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.title = this.__props__.title;
      this.icon = this.__props__.icon;
      this.image = this.__props__.image;
      this.mask = this.__props__.mask;
      this.duration = this.__props__.duration;
      this.position = this.__props__.position;
      this.success = this.__props__.success;
      this.fail = this.__props__.fail;
      this.complete = this.__props__.complete;
      delete this.__props__;
    }
  }
  class NormalizeResult extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            options: { type: NormalizedOptions, optional: false },
            degraded: { type: UTS.UTSType.withGenerics(Array, [String]), optional: false }
          };
        }
      };
    }
    constructor(options, metadata = NormalizeResult.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.options = this.__props__.options;
      this.degraded = this.__props__.degraded;
      delete this.__props__;
    }
  }
  class ToastDefaults extends UTS.UTSType {
    static get$UTSMetadata$() {
      return {
        kind: 2,
        get fields() {
          return {
            duration: { type: Number, optional: true },
            icon: { type: "Unknown", optional: true },
            mask: { type: Boolean, optional: true },
            dialogPath: { type: String, optional: true }
          };
        }
      };
    }
    constructor(options, metadata = ToastDefaults.get$UTSMetadata$(), isJSONParse = false) {
      super();
      this.__props__ = UTS.UTSType.initProps(options, metadata, isJSONParse);
      this.duration = this.__props__.duration;
      this.icon = this.__props__.icon;
      this.mask = this.__props__.mask;
      this.dialogPath = this.__props__.dialogPath;
      delete this.__props__;
    }
  }
  const TOAST_ERR_SUBJECT = "unix-utils:toast";
  const DEFAULT_DURATION = 1500;
  const DEFAULT_ICON = ToastIcon.SUCCESS;
  const DEFAULT_MASK = false;
  const WECHAT_TITLE_MAX_LENGTH = 7;
  const NATIVE_TITLE_MAX_LENGTH = 20;
  const DEFAULT_DIALOG_PATH = "node_modules/@meng-xi/unix-utils/src/toast/app/dialog-page";
  const EVENT_TOAST_UPDATE = "unix-toast:update";
  const EVENT_TOAST_HIDE = "unix-toast:hide";
  const DIALOG_CLOSE_DELAY = 300;
  let currentDefaults = new ToastDefaults(
    {
      duration: DEFAULT_DURATION,
      icon: DEFAULT_ICON,
      mask: DEFAULT_MASK,
      dialogPath: null
    }
    /**
     * 设置全局默认配置
     * @param defaults 默认值
     */
  );
  function getToastDefaults() {
    return currentDefaults;
  }
  function getPlatform() {
    try {
      const info = uni.getSystemInfoSync();
      return info.uniPlatform;
    } catch (e) {
      return "unknown";
    }
  }
  function isSelfDrawPlatform(platform) {
    return platform === "app-android" || platform === "app-ios";
  }
  function truncateTitle(title, platform) {
    if (platform === "mp-weixin") {
      if (title.length > WECHAT_TITLE_MAX_LENGTH) {
        return title.substring(0, WECHAT_TITLE_MAX_LENGTH) + "…";
      }
      return title;
    }
    if (platform === "web" || platform === "app-harmony") {
      if (title.length > NATIVE_TITLE_MAX_LENGTH) {
        return title.substring(0, NATIVE_TITLE_MAX_LENGTH) + "…";
      }
    }
    return title;
  }
  function normalizeIcon(icon, platform, degraded) {
    if (icon === ToastIcon.FAIL || icon === ToastIcon.EXCEPTION) {
      degraded.push("icon");
      return ToastIcon.ERROR;
    }
    if (icon === ToastIcon.WARNING) {
      if (!isSelfDrawPlatform(platform)) {
        degraded.push("icon");
        return ToastIcon.NONE;
      }
    }
    return icon;
  }
  function normalizePosition(position = null, platform, degraded) {
    if (position == null)
      return null;
    if (isSelfDrawPlatform(platform))
      return position;
    degraded.push("position");
    return null;
  }
  function normalizeImage(image = null, platform, degraded) {
    if (image == null)
      return null;
    if (isSelfDrawPlatform(platform))
      return image;
    if (image.toLowerCase().endsWith(".gif")) {
      degraded.push("image");
      return null;
    }
    return image;
  }
  function normalize(options) {
    const platform = getPlatform();
    const defaults = getToastDefaults();
    const degraded = [];
    const icon = normalizeIcon(options.icon != null ? options.icon : defaults.icon != null ? defaults.icon : DEFAULT_ICON, platform, degraded);
    const position = normalizePosition(options.position, platform, degraded);
    const image = normalizeImage(options.image, platform, degraded);
    const title = truncateTitle(options.title, platform);
    const mask = options.mask != null ? options.mask : defaults.mask != null ? defaults.mask : DEFAULT_MASK;
    const duration = options.duration != null ? options.duration : defaults.duration != null ? defaults.duration : DEFAULT_DURATION;
    const normalized = new NormalizedOptions({
      title,
      icon,
      image,
      mask,
      duration,
      position,
      success: options.success,
      fail: options.fail,
      complete: options.complete
    });
    const result = new NormalizeResult({
      options: normalized,
      degraded
    });
    return result;
  }
  let dialogOpened = false;
  let hideTimer = null;
  function resolveDialogPath() {
    const defaults = getToastDefaults();
    if (defaults.dialogPath != null && defaults.dialogPath.length > 0) {
      return defaults.dialogPath;
    }
    return DEFAULT_DIALOG_PATH;
  }
  function emitUpdate(options) {
    uni.$emit(EVENT_TOAST_UPDATE, new UTSJSONObject({
      title: options.title,
      icon: options.icon,
      image: options.image,
      mask: options.mask,
      duration: options.duration,
      position: options.position
    }));
  }
  function emitHide() {
    uni.$emit(EVENT_TOAST_HIDE);
  }
  function startTimer(duration) {
    if (hideTimer != null) {
      clearTimeout(hideTimer);
    }
    hideTimer = setTimeout(() => {
      hideTimer = null;
      emitHide();
      setTimeout(() => {
        if (dialogOpened) {
          uni.closeDialogPage();
          dialogOpened = false;
        }
      }, DIALOG_CLOSE_DELAY);
    }, duration);
  }
  function ensureDialogThenUpdate(options) {
    if (dialogOpened) {
      emitUpdate(options);
      return null;
    }
    uni.openDialogPage({
      url: resolveDialogPath(),
      success: () => {
        dialogOpened = true;
        emitUpdate(options);
      },
      fail: () => {
        dialogOpened = false;
      }
    });
  }
  function showSelfDraw(options) {
    ensureDialogThenUpdate(options);
    startTimer(options.duration);
  }
  function notifyDegraded(options, degraded) {
    if (degraded.length === 0 || options.fail == null)
      return null;
    const platform = getPlatform();
    for (let i = 0; i < degraded.length; i++) {
      const f = new ToastFail({
        errCode: ToastErrorCode.PLATFORM_UNSUPPORTED,
        errSubject: TOAST_ERR_SUBJECT,
        errMsg: "参数在当前端不支持，已降级处理",
        param: degraded[i],
        platform
      });
      options.fail(f);
    }
  }
  function dispatchShow(options) {
    showSelfDraw(options);
  }
  function showToast(options) {
    const result = normalize(options);
    notifyDegraded(options, result.degraded);
    dispatchShow(result.options);
  }
  function quickShow(title, icon) {
    const defaults = getToastDefaults();
    const duration = defaults.duration != null ? defaults.duration : DEFAULT_DURATION;
    const mask = defaults.mask != null ? defaults.mask : DEFAULT_MASK;
    const options = new ToastOptions({
      title,
      icon,
      image: null,
      mask,
      duration,
      position: null,
      success: null,
      fail: null,
      complete: null
    });
    showToast(options);
  }
  function showToastSuccess(title) {
    quickShow(title, ToastIcon.SUCCESS);
  }
  function showToastError(title) {
    quickShow(title, ToastIcon.ERROR);
  }
  function showToastInfo(title) {
    quickShow(title, ToastIcon.NONE);
  }
  const __className = "GenPagesIndexIndex";
  const _sfc_main$1 = /* @__PURE__ */ vue.defineVaporSharedDataComponent({
    __dynamicSharedData: true,
    __className,
    __filename: "pages/index/index.uvue",
    __name: "index",
    setup(__props) {
      const __sharedDataRenderer = vue.useSharedDataRenderer();
      const __sharedData = __sharedDataRenderer == "component" ? vue.withSharedDataComponent(new UniDynamicSharedDataComponent(vue.useSharedDataScope(), vue.useSharedDataComponentOptions({ bundleKey: "GenPagesIndexIndexSharedData", sharedDataClassId: 0 }))) : vue.withSharedDataPage(new UniDynamicSharedDataPage(vue.useSharedDataPageId(), vue.useSharedDataPageOptions({ bundleKey: "GenPagesIndexIndexSharedData", sharedDataClassId: 0 })));
      vue.useSharedDataScope(__sharedData);
      function onSuccess() {
        showToastSuccess("操作成功");
      }
      function onError() {
        showToastError("操作失败");
      }
      function onInfo() {
        showToastInfo("这是一条消息");
      }
      function onWarning() {
        showToast(new UTSJSONObject({
          title: "请注意",
          icon: ToastIcon.WARNING,
          mask: true,
          duration: 2e3
        }));
      }
      return () => {
        "raw js";
        const _component_button = vue.resolveComponent("button");
        const n1 = vue.createSharedDataComponentWithFallback(_component_button, "59e5d897", { onClick: () => {
          return onSuccess;
        } }, {
          "default": vue.withSharedDataVaporCtx(() => {
          }, "string")
        });
        vue.setSharedData(__sharedData, 0, n1 == null ? void 0 : n1.sharedData);
        const n3 = vue.createSharedDataComponentWithFallback(_component_button, "59e5d929", { onClick: () => {
          return onError;
        } }, {
          "default": vue.withSharedDataVaporCtx(() => {
          }, "string")
        });
        vue.setSharedData(__sharedData, 1, n3 == null ? void 0 : n3.sharedData);
        const n5 = vue.createSharedDataComponentWithFallback(_component_button, "3a5594ac", { onClick: () => {
          return onInfo;
        } }, {
          "default": vue.withSharedDataVaporCtx(() => {
          }, "string")
        });
        vue.setSharedData(__sharedData, 2, n5 == null ? void 0 : n5.sharedData);
        const n7 = vue.createSharedDataComponentWithFallback(_component_button, "3a5593b8", { onClick: () => {
          return onWarning;
        } }, {
          "default": vue.withSharedDataVaporCtx(() => {
          }, "string")
        });
        vue.setSharedData(__sharedData, 3, n7 == null ? void 0 : n7.sharedData);
        return __sharedData;
      };
    }
  });
  const _style_0 = {};
  const _export_sfc = (sfc, props) => {
    const target = sfc.__vccOpts || sfc;
    for (const [key, val] of props) {
      target[key] = val;
    }
    return target;
  };
  const PagesIndexIndex = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["styles", [_style_0]]]);
  __definePage("pages/index/index", PagesIndexIndex);
  const _sfc_main = /* @__PURE__ */ vue.defineVaporSharedDataComponent({
    __name: "App",
    setup(__props) {
      vue.onLaunch(() => {
        uni.__log__("log", "at App.uvue:3", "App Launch");
      });
    }
  });
  const __global__ = typeof globalThis === "undefined" ? Function("return this")() : globalThis;
  __global__.__uniX = true;
  function createApp() {
    const app = vue.createSSRApp(_sfc_main);
    return {
      app
    };
  }
  createApp().app.mount("#app");
})(Vue);

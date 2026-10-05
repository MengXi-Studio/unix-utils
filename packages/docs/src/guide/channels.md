# 通道架构与降级

unix-utils 的核心策略是**分端混合实现**：各端自动选择最优通道，业务零配置。本页说明通道如何分发、降级何时发生、业务如何感知。

## 通道架构

| 端 | 通道 | 实现方式 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口 | `WindowManager` / `UIWindow` 免注册挂窗（TYPE_APPLICATION_PANEL + Activity token），触摸穿透 / 蒙层 / 动画 / 精确计时 / hideToast 全自管 |
| Web | DOM 单例自绘 | body 挂载 + 一次注入样式 + class 过渡动画 + `setTimeout` 精确计时 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | 平台原生实现，统一入口 |
| App 端（fallback） | `uni.showToast` 原生 | 直挂窗口失败（如页面未就绪）自动回落，`fail` 回调留痕 |

> 为什么 App 端要绕开 `uni.showToast` 直挂窗口：原生通道的 `position` 在 Android 仅支持 `bottom`、icon 值不对齐、生命周期绑定不一致——这些表现层差异只有窗口级自绘能消除。而 Android 系统 `Toast` 不支持 icon/mask、iOS 根本没有系统 Toast API，所以直挂窗口自绘是 App 端唯一能「属性全生效」的路径。

## 分发流程

```
业务调用 showToast(options)
      │
      ▼
normalize 层：icon 归一化 / title 截断 / 平台不支持参数降级
      │
      ▼
dispatch 层（编译期条件编译判定，通道可替换）
   ├─ App 直挂窗口通道（App-Android / App-iOS 默认）
   ├─ Web 自绘通道（Web 默认）
   ├─ uni 原生通道（微信 / 鸿蒙默认；App 端 fallback）
   └─ UTS 扩展通道（后续演进）
      │
      ▼
callback 层：success / fail / complete 回调透传，错误结构化
```

平台判定使用**编译期条件编译**（`#ifdef APP-ANDROID || APP-IOS || WEB`），而非运行时字符串匹配（`uni.getSystemInfoSync().uniPlatform` 实测返回 `'app'`，不含 android/ios 后缀，运行时匹配不可靠）。

## 参数抹平矩阵

各参数在三条通道下的行为（✅ 全生效 / ⚠️ 降级并留痕 / ✗ 不支持）：

| 参数 | App（直挂通道） | Web（自绘通道） | 微信 / 鸿蒙（原生通道） |
| --- | --- | --- | --- |
| `title` | ✅ 无平台截断 | ✅ 无平台截断 | ✅ 微信 7 汉字 / 鸿蒙 20 字截断 |
| `icon = fail` / `exception` | ✅ 真实渲染 | ✅ 真实渲染 | ⚠️ 归一化为 `error` |
| `icon = warning`（扩展） | ✅ 真实渲染 | ✅ 真实渲染 | ⚠️ 降级为 `none`，errCode 2001 |
| `image` | ⚠️ 降级 icon `none`，errCode 2001 | ✅（含 gif） | ✅（gif 降级不展示） |
| `mask` | ✅ | ✅ | ✅ |
| `duration` | ✅ 精确毫秒 | ✅ 精确毫秒 | ✅（粒度受平台约束） |
| `position` | ✅ 三值全支持 | ✅ 三值全支持 | ⚠️ 降级居中，errCode 2001 |
| position + `hideToast` | ✅ 可靠隐藏 | ✅ 可靠隐藏 | —（position 本不支持） |
| 连续调用 | ✅ 复用窗口替换 | ✅ 单例替换 | ✅ 替换 |
| 生命周期 | ✅ 系统窗口级，跨页面存活 | ✅ SPA 存活 | 与页面绑定（页面关闭即消失） |

## 降级感知：fail 回调

所有降级都会通过 `fail` 回调返回结构化 [ToastFail](/api/type-toast-fail)，业务可精确感知「哪个参数、哪个端」：

```ts
showToast({
	title: '警告信息',
	icon: 'warning', // 微信原生通道不支持
	position: 'top', // 微信原生通道不支持
	fail: (err) => {
		// errCode: 2001（PLATFORM_UNSUPPORTED）
		// param: 'icon' / 'position' —— 触发降级的参数名
		// platform: 'mp-weixin' —— 当前端标识
		// errSubject: 'unix-utils:toast'
	}
})
```

- errCode `2001`（PLATFORM_UNSUPPORTED）为**信息级**通知：参数已降级、toast 照常显示，业务可选择忽略；
- errCode `1001`（PARAM_INVALID）为真正的参数错误。

## 表现层三原则

微信 / 鸿蒙端保留原生通道，其残余差异（视觉样式、生命周期绑定）按三原则管理：

1. **可预期**：所有残余差异写入上方矩阵，无隐藏行为；
2. **可见**：降级发生时 `fail` 回调结构化留痕；
3. **可替换**：App 端需要更强表现时，UTS 直挂通道直接消除全部表现层差异。

## 已知约束

- **App 端**：直挂窗口盖过页面树全部内容（含原生 tabbar 之上），但 `SurfaceView` 类独立图层（video 原生层、地图）与系统 UI（状态栏 / 导航栏 / 系统弹窗）仍在之上——普通业务场景不受影响；
- **App 端 mask**：蒙层拦截触摸但不消费返回键，Android 返回键仍作用于业务页面栈；
- **小程序端自绘的取舍**：微信端如需自绘会遇到原生组件（video / map / camera）及原生弹窗的遮挡问题，因此微信 / 鸿蒙保留原生通道是经过权衡的选择。

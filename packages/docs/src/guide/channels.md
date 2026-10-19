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

modal 模块（v0.2 起）的通道划分：

| 端 | 通道 | 实现方式 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口自绘 | `WindowManager` / `UIWindow` 免注册挂窗 + 蒙层 + 居中卡片 + 按钮行 + 真实输入框（editable），v0.2.0 起 App 端不再走 `uni.showModal` 原生通道 |
| Web | DOM 单例自绘 | body 挂载单例 + 蒙层 + 居中卡片 + 按钮行 + `input`（editable），蒙层点击不关闭，文案与 alpha 色完整生效 |
| 微信 / 鸿蒙 | `uni.showModal` 原生 | 直调 + 库内归一化（颜色校验与 alpha 剥离、受限端文案截断、返回值 `confirm` / `cancel` 恒存在互斥） |

> 为什么 modal 也做 App 直挂自绘：`uni.showModal` 原生通道的参数在各端语义基本对齐，残余差异（文案截断、返回值缺字段）大多能在库内归一化层抹平；但 editable 输入框的 `content` 初始值与光标位置控制、alpha 色在原生端被剥离等表现层差异无法归一化。v0.2.0 起 modal 复用 toast 的直挂窗口基建，App 端实现 editable 真实输入框、alpha 色全生效、蒙层点击不关闭、Android 返回键取消语义，弹窗表现与 Web 自绘一致。微信 / 鸿蒙保留原生通道——小程序端自绘会遇到原生组件与原生弹窗的遮挡问题，且原生 modal 参数语义本身对齐，归一化足以抹平。

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

## modal 参数抹平矩阵

modal 各参数在三条通道下的行为（✅ 全生效 / ⚠️ 降级并留痕）：

| 参数 | App（直挂自绘通道） | Web（自绘通道） | 微信 / 鸿蒙（原生通道） |
| --- | --- | --- | --- |
| `title` / `content` | ✅ 真实渲染（`textContent` 写入，规避 XSS） | ✅ 真实渲染（`textContent` 写入，规避 XSS） | ✅ 原生渲染 |
| `showCancel` | ✅ | ✅ | ✅ |
| `cancelText` / `confirmText` | ✅ 完整显示 | ✅ 完整显示 | ⚠️ 微信 / 鸿蒙超 4 字符静默截断 |
| `cancelColor` / `confirmColor` = `#RGB` / `#RRGGBB` | ✅（`#RGB` 展开为 `#RRGGBB`） | ✅（`#RGB` 展开为 `#RRGGBB`） | ✅（`#RGB` 展开为 `#RRGGBB`） |
| `cancelColor` / `confirmColor` = `#RRGGBBAA` | ✅ alpha 全生效 | ✅ alpha 全生效 | ⚠️ 剥离 alpha 生效，errCode 2001 |
| 颜色非法值 | ⚠️ 回退内置默认色，errCode 2001 | ⚠️ 回退内置默认色，errCode 2001 | ⚠️ 降级平台默认色，errCode 2001 |
| `editable` | ✅ 真实渲染输入框（`content` 兼作初始值、光标定位末尾） | ✅ 真实渲染 `<input>`（`content` 兼作初始值、光标定位末尾） | ✅（`content` 兼作输入框初始值，光标位置由平台决定） |
| `placeholderText` | ✅ | ✅ | ✅ |
| 正文限高滚动 | ✅ 超屏高 60% 限高滚动 | ✅ 超屏高 60% 限高滚动 | ✅ 原生行为 |
| 返回值 `confirm` / `cancel` | ✅ 恒存在且互斥 | ✅ 恒存在且互斥 | ✅ 库内归一化恒存在且互斥 |
| 蒙层点击 | 不关闭（仅按钮可关闭） | 不关闭（仅按钮可关闭） | 原生行为（不关闭） |
| Android 返回键 | 以取消语义关闭（`cancel: true`） | —（无系统返回键） | —（返回键作用于页面导航） |
| 连续调用 | 单例替换 | 单例替换 | ✅ 替换 |
| 生命周期 | 系统窗口级 | DOM 单例，SPA 内存活 | 页面级模态，阻塞交互 |

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

modal 同样走 `fail` 回调返回结构化 [ModalFail](/api/type-modal-fail)（`errSubject: 'unix-utils:modal'`）：

```ts
showModal({
	title: '提示',
	content: '继续操作',
	confirmColor: 'blue', // 非法颜色：原生通道不支持命名色
	fail: (err) => {
		// errCode: 2001（PLATFORM_UNSUPPORTED）
		// param: 'confirmColor' —— 触发降级的参数名
		// platform: 'mp-weixin' —— 当前端标识
	}
})
```

modal 特有：`title` 与 `content` 均为空时走 `fail` 1001（`param: 'title'`），弹窗不显示；Promise 式 [showModalAsync](/api/show-modal-async) 下降级（2001）也会 reject（reject 值为 `ModalFail` 结构的 JSON 字符串，全端统一，业务侧 `JSON.parse<ModalFail>(err as string)` 还原）。

## 表现层三原则

微信 / 鸿蒙端保留原生通道，其残余差异（视觉样式、生命周期绑定）按三原则管理：

1. **可预期**：所有残余差异写入上方矩阵，无隐藏行为；
2. **可见**：降级发生时 `fail` 回调结构化留痕；
3. **可替换**：App 端需要更强表现时，UTS 直挂通道直接消除全部表现层差异。

## 已知约束

- **App 端**：直挂窗口盖过页面树全部内容（含原生 tabbar 之上），但 `SurfaceView` 类独立图层（video 原生层、地图）与系统 UI（状态栏 / 导航栏 / 系统弹窗）仍在之上——普通业务场景不受影响；
- **App 端 toast mask**：蒙层拦截触摸但不消费返回键，Android 返回键仍作用于业务页面栈（modal 不同：返回键以取消语义关闭弹窗）；
- **小程序端自绘的取舍**：微信端如需自绘会遇到原生组件（video / map / camera）及原生弹窗的遮挡问题，因此微信 / 鸿蒙保留原生通道是经过权衡的选择。

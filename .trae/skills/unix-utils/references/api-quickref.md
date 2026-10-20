# unix-utils API 速查表

> 供 AI 编码助手按需查阅。所有示例为 UTS / uni-app x 语法；import 路径按项目形态替换（npm / uni_modules：`@/uni_modules/unix-utils`；本仓库 playground：`@/uni_modules/ux-utils`）。

## 导出清单

| 模块 | API | 常量 | 类型 |
| --- | --- | --- | --- |
| toast | `showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo` | `DEFAULT_DURATION`(1500) / `DEFAULT_ICON`('success') / `DEFAULT_MASK`(false) / `TOAST_ERR_PARAM_INVALID`(1001) / `TOAST_ERR_PLATFORM_UNSUPPORTED`(2001) | `ToastFail`（0.2.0+，`import type`）。`icon` / `position` / 错误码的值域为字面量联合（`'success' \| ... \| 'none'` 等），直接传字面量，无需 import 类型名 |
| modal | `showModal` / `showModalAsync` / `showModalAlert` / `configureModal` | `DEFAULT_CONFIRM_TEXT`('确定') / `DEFAULT_CANCEL_TEXT`('取消') / `DEFAULT_CONFIRM_COLOR`('#007aff') / `DEFAULT_CANCEL_COLOR`('#000000') | `ModalResult` / `ModalFail`（0.2.0+，`import type`） |

> 对外可 `import type` 的类型仅 `ToastFail` / `ModalResult` / `ModalFail` 三个（入口 `export type` 显式导出）；其余类型（`ToastIcon` / `ToastPosition` / `ToastErrorCode` / `ToastOptions` / `ModalOptions` / `ToastDefaults` / `ModalDefaults`）为库内声明，业务侧不 import。

## ToastOptions

| 字段 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `title` | `string` | **必填** | 提示内容；微信 7 汉字 / 鸿蒙 20 字截断 |
| `icon` | `'success' \| 'error' \| 'fail' \| 'exception' \| 'warning' \| 'loading' \| 'none'` | `'success'` | `warning` 为扩展值（原生端降级 `none` 留痕 2001）；`fail` / `exception` 原生端归一化 `error`；自绘通道真实渲染 |
| `image` | `string` | - | 自定义图标本地路径；App 直挂通道降级 icon `none` 留痕 2001；Web 全支持（含 gif）；微信 gif 不展示 |
| `mask` | `boolean` | `false` | 是否显示透明蒙层，防止触摸穿透 |
| `duration` | `number` | `1500` | 不钳制原样透传；自绘通道精确毫秒，原生通道粒度受平台约束 |
| `position` | `'top' \| 'center' \| 'bottom'` | 不传 = 不启用 position 形态（表现居中） | 自绘通道三值全生效（top 顶边距顶 10% / bottom 底边距底 10% / center 居中）；原生通道降级居中留痕 2001 |
| `success` | `(res) => void` | - | `res` 为 `{ errMsg: string }`（对齐原生 `ToastResult` 形态） |
| `fail` | `(err: ToastFail) => void` | - | 结构化降级留痕 |
| `complete` | `(res: any) => void` | - | 成功或失败都执行 |

## ToastFail 结构

```ts
type ToastFail = {
	errCode: number     // 1001 PARAM_INVALID / 2001 PLATFORM_UNSUPPORTED（字面量联合 ToastErrorCode）
	errSubject: string  // 固定 'unix-utils:toast'
	errMsg: string      // 错误描述
	param: string | null // 触发降级的参数名（如 'icon' / 'position' / 'image'），无则 null
	platform: string    // 端标识，如 'app-android' / 'web' / 'mp-weixin'
}
```

## ModalOptions

| 字段 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `title` | `string` | - | 与 `content` 均为空时 fail 1001（`param: 'title'`），不弹窗 |
| `content` | `string` | - | `editable: true` 时兼作输入框初始值（自绘通道光标定位末尾） |
| `showCancel` | `boolean` | `true` | `false` 为单确定按钮（alert 形态） |
| `cancelText` | `string` | `'取消'` | 微信 / 鸿蒙超 4 字符库内静默截断 |
| `cancelColor` | `string` | 平台默认色 | 仅 16 进制：`#RGB`（自动展开）/ `#RRGGBB` / `#RRGGBBAA`；非法值降级留痕 2001 |
| `confirmText` | `string` | `'确定'` | 同上截断约束 |
| `confirmColor` | `string` | `'#007aff'` | alpha 在 App / Web 自绘通道全生效；微信 / 鸿蒙剥 alpha 留痕 2001 |
| `editable` | `boolean` | `false` | 自绘通道真实渲染输入框；正文超屏高 60% 自动限高滚动 |
| `placeholderText` | `string` | - | 仅 `editable: true` 时生效 |
| `success` | `(res: ModalResult) => void` | - | — |
| `fail` | `(err: ModalFail) => void` | - | 结构化降级留痕 |
| `complete` | `() => void` | - | — |

## ModalResult 结构

```ts
type ModalResult = {
	confirm: boolean          // 恒存在；点确定为 true
	cancel: boolean           // 恒存在且与 confirm 互斥；Android 返回键关闭时为 true
	content: string | null    // 仅 editable: true 且点确认时携带输入文本，其余恒 null
}
```

## ModalFail 结构

```ts
type ModalFail = {
	errCode: number     // 1001 参数非法（title/content 双空，param: 'title'）/ 2001 平台不支持且已降级
	errSubject: string  // 固定 'unix-utils:modal'
	errMsg: string      // 错误描述
	param: string | null // 触发问题的参数名（如 'confirmColor'），无则 null
	platform: string    // 端标识
}
```

## 颜色归一化（modal）

| 传入值 | App / Web 自绘通道 | 微信 / 鸿蒙原生通道 |
| --- | --- | --- |
| `#RGB` | ✅ 展开为 `#RRGGBB` | ✅ 展开为 `#RRGGBB` |
| `#RRGGBB` | ✅ 直接生效 | ✅ 直接生效 |
| `#RRGGBBAA` | ✅ alpha 保留 | ⚠️ 剥离 alpha 生效，留痕 2001 |
| 非法值（命名色 / 缺 `#` / 长度不对 / 非 hex） | ⚠️ 回退内置默认色，留痕 2001 | ⚠️ 降级平台默认色，留痕 2001 |

## 双轨 API 与 Promise 契约

| API | 行为 |
| --- | --- |
| `showToast` / `showModal` | 回调式（主）：fail 回调收**结构化对象**；toast 的 success 回调参数为 `{ errMsg: string }` |
| `showToastAsync` / `showModalAsync` | Promise 式：`showToastAsync` 成功 resolve `void`，`showModalAsync` 成功 resolve `ModalResult`；失败 reject **JSON 字符串**（`JSON.parse<ToastFail \| ModalFail>(err as string)` 还原，判空后使用）。modal 点取消不算失败、正常 resolve；降级（2001）也 reject（弹窗仍以降级形态显示） |
| `showToastSuccess` / `showToastError` / `showToastInfo` | 语义快捷（icon 预设 success / error / none） |
| `showModalAlert` | 单确定按钮 alert 语义（`title` 必填 + `content` 可选） |
| `hideToast` | 自绘通道可靠隐藏（含原生不支持隐藏的 position 形态） |
| `configureToast` / `configureModal` | 全局默认；字段传 `null` = 沿用库内置默认 / 平台默认 |

## 通道矩阵

### toast

| 端 | 通道 | 关键差异 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口（`WindowManager` / `UIWindow`） | position / warning / mask / 精确 duration 全生效；窗口级生命周期跨页面存活；挂窗失败自动回落 `uni.showToast` 留痕；`image` 降级 icon `none`（2001） |
| Web | DOM 单例自绘 | position / warning / 无平台截断全生效 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | `warning` → `none`（2001）、`position` → 居中（2001）、title 截断（微信 7 汉字 / 鸿蒙 20 字）、生命周期与页面绑定 |

连续调用（后调替换前调）：App 直挂通道复用系统窗口替换、Web 单例替换、原生通道平台替换，三端均无叠加残留。

### modal

| 端 | 通道 | 关键差异 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口自绘 | 全参数生效；蒙层点击不关闭；Android 返回键取消语义关闭；连续调用替换；60% 限高滚动 |
| Web | DOM 单例自绘 | 同 App；SPA 内存活 |
| 微信 / 鸿蒙 | `uni.showModal` 原生 | 8 位色剥 alpha 留痕、按钮文案超 4 字符截断（静默）、editable 光标不受控 |

## 平台判定

通道分发使用**编译期条件编译**（`#ifdef APP-ANDROID || APP-IOS || WEB`），非运行时字符串匹配（`uni.getSystemInfoSync().uniPlatform` 实测返回 `'app'`，不含 android / ios 后缀，运行时匹配不可靠）。

## 版本要点

- 0.2.0：modal 模块上线（App 端 UTS 直挂自绘 / Web DOM 自绘 / 微信鸿蒙原生三分通道）；交互语义跨端对齐（蒙层不关闭 / Android 返回键取消 / 连续调用替换）；editable 真实输入框（光标末尾 + 60% 限高滚动）；alpha 色自绘全生效；**破坏性**：`showToastAsync` reject 值由对象改为 JSON 字符串；`ToastFail` / `ModalFail` / `ModalResult` 类型导出
- 0.1.0：仅 toast 模块（App 直挂 / Web 自绘 / 微信鸿蒙原生三分通道，position / warning / 结构化降级）

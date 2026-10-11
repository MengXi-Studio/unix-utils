**中文** | [English](./README-en.md)

<div align="center">
  <h1>@meng-xi/unix-utils</h1>
  <p>为 uni-app x 提供便利工具的集合（UTS 编写，全端兼容，插件市场 + npm 双轨分发）</p>

[![license](https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg)](LICENSE) [![npm](https://img.shields.io/npm/v/@meng-xi/unix-utils?color=blue)](https://www.npmjs.com/package/@meng-xi/unix-utils)
![npm](https://img.shields.io/npm/dt/@meng-xi/unix-utils?color=green)

</div>

## 特性

### toast 模块（uni.showToast 全端兼容封装）

- **App 端 UTS 直挂系统窗口** - Android `WindowManager` / iOS `UIWindow` 免注册挂窗，position / warning / mask / 精确 duration 全生效，系统窗口级生命周期跨页面存活，挂窗失败自动降级 `uni.showToast`
- **Web 端 DOM 单例自绘** - body 挂载单例，position / warning / 无平台截断全生效
- **参数完全对齐** - 与 `uni.showToast` 同构（`title / icon / image / mask / duration / position / success / fail / complete`），迁移零成本
- **icon 超集** - 原生 6 值 + 扩展 `warning`；`fail` / `exception` 在原生端归一化为 `error`（多数端行为未定义），自绘通道真实渲染
- **position 三值全支持** - `top` / `center` / `bottom` 自绘通道全生效，位置语义三端一致（top 顶边距顶 10%、bottom 底边距底 10%、center 居中）
- **双轨 API** - 回调式 `showToast`（主）+ Promise 式 `showToastAsync`（辅）；语义化快捷 API `showToastSuccess` / `showToastError` / `showToastInfo`
- **可靠隐藏** - `hideToast` 在自绘通道可靠隐藏，含原生不支持隐藏的 position 形态
- **全局默认配置** - `configureToast` 项目级预设 duration / icon / mask
- **结构化降级** - `ToastFail`（`errCode` / `errSubject` / `param` / `platform`），降级经 `fail` 回调留痕，可感知、可过滤
- **强类型 UTS** - `ToastOptions` 除 `title` 外均为可选字段，`icon` / `position` / 错误码为字面量联合类型

### modal 模块（uni.showModal 全端兼容封装，v0.2.0 起）

- **参数完全对齐** - 与 `uni.showModal` 同构（`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete`），迁移零成本
- **返回值恒定** - `ModalResult` 的 `confirm` / `cancel` 恒存在且互斥（消除各端 `cancel` 字段缺失差异），`editable` 场景 `content` 携带用户输入
- **颜色归一化** - 校验 `#RGB` / `#RRGGBB` / `#RRGGBBAA`，非法值降级平台默认色并留痕；App 原生通道不支持 alpha 时自动剥离并留痕；库内默认确认色 `#007aff` / 取消色 `#000000`
- **受限端文案截断** - 微信 / 鸿蒙端按钮文案超 4 字符库内自动截断，App / Web 端完整显示
- **Promise 式 + 快捷 API** - `showModalAsync` 点取消不算失败；`showModalAlert` 单确定按钮 alert 语义
- **全局默认配置** - `configureModal` 项目级预设按钮文案与颜色
- **结构化降级** - `ModalFail`（`errCode` 1001 参数非法 / 2001 平台不支持且已降级），`ModalFail` / `ModalResult` 类型对外导出

## 安装

**方式一：插件市场**（推荐）——在 HBuilderX 中从插件市场搜索 `unix-utils` 导入到工程 `uni_modules/`。

**方式二：npm**——安装后将包内容同步到工程 `uni_modules/unix-utils/`（编译器不扫描 node_modules）：

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

> `packages/core` 为标准 **uni_modules UTS 插件**（`utssdk/` 官方目录结构 + `interface.uts` 对外声明），UTS 源分发：web / 小程序 → JS，Android → Kotlin，iOS → Swift，由 uni-app x 编译链现场编译。

## 快速开始

### 1. 发出第一条 toast

```ts
import { showToast } from '@/uni_modules/unix-utils'

// 与 uni.showToast 同构，迁移零成本
showToast({
	title: '保存成功',
	icon: 'success',
	duration: 2000
})
```

### 2. Promise 式与语义化快捷

```ts
import {
	showToastAsync,
	showToastSuccess,
	showToastError,
	showToastInfo,
	hideToast
} from '@/uni_modules/unix-utils'

// Promise 式：失败 reject ToastFail 结构的 JSON 字符串（全端统一，JSON.parse 还原）
try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
} catch (err) {
	const fail = JSON.parse<ToastFail>(err as string)
	if (fail != null) {
		console.error(fail.errCode, fail.param, fail.platform)
	}
}

// 语义化快捷
showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')

// 手动隐藏（自绘通道可靠隐藏，含 position 形态）
hideToast()
```

> `icon` / `position` 为字符串字面量联合类型（`'success' | 'error' | 'fail' | 'exception' | 'warning' | 'loading' | 'none'`），直接传字面量即可。

### 3. 全局默认配置

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})
```

### 4. 弹出第一个模态弹窗（modal 模块）

```ts
import { showModal } from '@/uni_modules/unix-utils'

// 与 uni.showModal 同构，迁移零成本
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	confirmColor: '#ff0000',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel 恒存在且互斥
	}
})
```

### 5. Promise 式、alert 语义与全局默认

```ts
import {
	showModalAsync,
	showModalAlert,
	configureModal
} from '@/uni_modules/unix-utils'

// Promise 式：点取消不算失败（resolve），失败 reject ModalFail 结构的 JSON 字符串（全端统一，JSON.parse 还原）
const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
if (res.confirm) save()

// alert 语义（单确定按钮）
showModalAlert('提示', '操作已完成')

// 全局默认：字段传 null 表示沿用库内置默认 / 平台默认
configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,
	cancelColor: null
})
```

## 通道架构（自动选择，无需配置）

### toast 模块

| 端 | 通道 | 说明 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口 | `WindowManager` / `UIWindow` 免注册挂窗，position / warning / image / mask 全生效，失败自动降级 `uni.showToast` |
| Web | DOM 单例自绘 | position / warning / 不截断全生效 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | 不支持的参数自动降级并经 `fail` 回调留痕 |

### modal 模块

| 端 | 通道 | 说明 |
| --- | --- | --- |
| App-Android / App-iOS / 微信 / 鸿蒙 | `uni.showModal` 原生 | 颜色校验与 alpha 剥离、受限端文案截断、`cancel` 字段恒存在，降级经 `fail` 回调留痕 |
| Web | DOM 单例自绘 | 蒙层点击不关闭（对齐原生语义）、`editable` 真实渲染输入框、文案与 alpha 色完整显示 |

## ToastOptions 常用参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✅ | - | 提示内容；微信 7 汉字 / 鸿蒙 20 字截断（自绘通道无截断） |
| `icon` | `ToastIcon` | ✗ | `'success'` | 图标，见上方字面量联合 |
| `image` | `string` | ✗ | - | 自定义图标本地路径（App 直挂通道暂不渲染，降级为无图标并留痕） |
| `mask` | `boolean` | ✗ | `false` | 透明蒙层，防止触摸穿透 |
| `duration` | `number` | ✗ | `1500` | 毫秒，不钳制、原样透传 |
| `position` | `ToastPosition` | ✗ | - | `top` / `center` / `bottom`（原生通道端降级居中并留痕） |
| `success` / `fail` / `complete` | 回调 | ✗ | - | `fail` 携带结构化 `ToastFail`（`errCode` 1001 参数非法 / 2001 平台不支持） |

## ModalOptions 常用参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✗ | - | 标题；与 `content` 至少其一非空，均空 `fail` 1001 |
| `content` | `string` | ✗ | - | 内容；`editable` 为 `true` 时兼作输入框初始值（原生通道；Web 自绘通道 content 仅显示为文本、输入框初始为空） |
| `showCancel` | `boolean` | ✗ | `true` | 是否显示取消按钮 |
| `cancelText` / `confirmText` | `string` | ✗ | `'取消'` / `'确定'` | 按钮文案；微信 / 鸿蒙超 4 字符库内自动截断 |
| `cancelColor` / `confirmColor` | `string` | ✗ | 平台默认 | 按钮颜色，支持 `#RGB` / `#RRGGBB` / `#RRGGBBAA`；未传透传平台默认色（Web 自绘回退 `'#000000'` / `'#007aff'`），非法值降级平台默认色并留痕 |
| `editable` | `boolean` | ✗ | `false` | 是否可输入；`ModalResult.content` 携带用户输入 |
| `placeholderText` | `string` | ✗ | - | 输入框占位文本（`editable` 为 `true` 时生效） |
| `success` / `fail` / `complete` | 回调 | ✗ | - | `success` 携带 `ModalResult`（`confirm` / `cancel` 恒存在且互斥）；`fail` 携带结构化 `ModalFail`（`errCode` 1001 参数非法 / 2001 平台不支持且已降级） |

## 降级行为

### toast 模块

原生通道端（微信 / 鸿蒙）不支持的参数会通过 `fail` 回调以 `errCode = 2001`（PLATFORM_UNSUPPORTED）通知：

- `warning` 图标 → 降级为 `none`
- `position` → 降级为居中
- `image` gif → 降级为不展示自定义图
- `title` 超过上限 → 微信 7 字、鸿蒙 20 字后加省略号

App 与 Web 自绘通道全属性生效，无降级；App 端 `image` 自定义图暂不渲染（降级为无图标并回调留痕）。

### modal 模块

原生通道（App / 微信 / 鸿蒙）的降级通过 `fail` 回调以 `errCode = 2001` 通知，参数非法以 `errCode = 1001` 通知：

- 颜色非法（不匹配 `#RGB` / `#RRGGBB` / `#RRGGBBAA`）→ 降级平台默认色，`param` 指明触发字段
- 8 位 alpha 色值（仅 Web 自绘支持）→ 自动剥离 alpha 并留痕
- 按钮文案超 4 字符 → 微信 / 鸿蒙库内自动截断，App / Web 完整显示
- `title` 与 `content` 均为空 → `errCode = 1001`，`param = 'title'`

Web 自绘通道 alpha 色与文案完整生效，无降级。

## 导出

### toast 模块

- API：`showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- 常量：`DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` / `TOAST_ERR_PARAM_INVALID(1001)` / `TOAST_ERR_PLATFORM_UNSUPPORTED(2001)`
- 字面量联合类型：`ToastIcon` / `ToastPosition` / `ToastErrorCode`

### modal 模块

- API：`showModal` / `showModalAsync` / `showModalAlert` / `configureModal`
- 常量：`DEFAULT_CONFIRM_TEXT` / `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_COLOR` / `DEFAULT_CANCEL_COLOR`
- 对外类型：`ModalResult` / `ModalFail`（`import type` 引入，用于 Promise 回调标注与字段访问）

## 文档

📖 从入门到精通的完整文档（指南 + API 参考 + 更新日志）：

**[https://mengxi-studio.github.io/unix-utils/](https://mengxi-studio.github.io/unix-utils/)**

阅读建议：先看[介绍](https://mengxi-studio.github.io/unix-utils/guide/introduction.html)与[快速开始](https://mengxi-studio.github.io/unix-utils/guide/getting-started.html)，再按 [Toast 提示](https://mengxi-studio.github.io/unix-utils/guide/toast.html) → [Modal 弹窗](https://mengxi-studio.github.io/unix-utils/guide/modal.html) → [通道架构与降级](https://mengxi-studio.github.io/unix-utils/guide/channels.html) 深入各端行为，API 细节查 [showToast](https://mengxi-studio.github.io/unix-utils/api/show-toast.html)与 [showModal](https://mengxi-studio.github.io/unix-utils/api/show-modal.html)。

## 更新日志

📝 **[https://mengxi-studio.github.io/unix-utils/changelog.html](https://mengxi-studio.github.io/unix-utils/changelog.html)**

## License

[MIT](LICENSE)

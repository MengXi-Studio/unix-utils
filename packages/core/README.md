**中文** | [English](./README-en.md)

<div align="center">
  <h1>@meng-xi/unix-utils</h1>
  <p>为 uni-app x 提供便利工具的集合（UTS 编写，全端兼容，插件市场 + npm 双轨分发）</p>

[![license](https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg)](LICENSE) [![npm](https://img.shields.io/npm/v/@meng-xi/unix-utils?color=blue)](https://www.npmjs.com/package/@meng-xi/unix-utils)
![npm](https://img.shields.io/npm/dt/@meng-xi/unix-utils?color=green)

</div>

## 特性

- **全端兼容** - Android / iOS / Web / 微信 / 鸿蒙五端覆盖，分端混合通道自动分发，业务零配置
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

// Promise 式：失败 reject 结构化 ToastFail
try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
} catch (err) {
	console.error(err.errCode, err.param, err.platform)
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

## 通道架构（自动选择，无需配置）

| 端 | 通道 | 说明 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口 | `WindowManager` / `UIWindow` 免注册挂窗，position / warning / image / mask 全生效，失败自动降级 `uni.showToast` |
| Web | DOM 单例自绘 | position / warning / 不截断全生效 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | 不支持的参数自动降级并经 `fail` 回调留痕 |

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

## 降级行为

原生通道端（微信 / 鸿蒙）不支持的参数会通过 `fail` 回调以 `errCode = 2001`（PLATFORM_UNSUPPORTED）通知：

- `warning` 图标 → 降级为 `none`
- `position` → 降级为居中
- `image` gif → 降级为不展示自定义图
- `title` 超过上限 → 微信 7 字、鸿蒙 20 字后加省略号

App 与 Web 自绘通道全属性生效，无降级；App 端 `image` 自定义图暂不渲染（降级为无图标并回调留痕）。

## 导出

- API：`showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- 常量：`DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` / `TOAST_ERR_PARAM_INVALID(1001)` / `TOAST_ERR_PLATFORM_UNSUPPORTED(2001)`
- 字面量联合类型：`ToastIcon` / `ToastPosition` / `ToastErrorCode`

## 文档

📖 从入门到精通的完整文档（指南 + API 参考 + 更新日志）：

**[https://mengxi-studio.github.io/unix-utils/](https://mengxi-studio.github.io/unix-utils/)**

阅读建议：先看[介绍](https://mengxi-studio.github.io/unix-utils/guide/introduction.html)与[快速开始](https://mengxi-studio.github.io/unix-utils/guide/getting-started.html)，再按 [Toast 提示](https://mengxi-studio.github.io/unix-utils/guide/toast.html) → [通道架构与降级](https://mengxi-studio.github.io/unix-utils/guide/channels.html) 深入各端行为，API 细节查 [API 参考](https://mengxi-studio.github.io/unix-utils/api/show-toast.html)。

## 更新日志

📝 **[https://github.com/MengXi-Studio/unix-utils/blob/master/packages/core/changelog.md](https://github.com/MengXi-Studio/unix-utils/blob/master/packages/core/changelog.md)**

## License

[MIT](LICENSE)

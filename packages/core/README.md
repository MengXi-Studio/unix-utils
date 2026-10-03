# @meng-xi/unix-utils

为 uni-app x 提供便利工具（UTS 源码分发，按平台编译）。

当前模块：**toast**（`showToast` 全端兼容封装）。

## 安装

```bash
pnpm add @meng-xi/unix-utils
```

## 快速使用

```ts
import {
	showToast,
	showToastSuccess,
	showToastError,
	showToastInfo,
	configureToast,
	ToastIcon
} from '@meng-xi/unix-utils'

// 回调式（与 uni.showToast 同构）
showToast({
	title: '保存成功',
	icon: ToastIcon.SUCCESS,
	duration: 2000
})

// Promise 式
await showToastAsync({ title: '加载中', icon: ToastIcon.LOADING })

// 语义化快捷
showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')
```

## App 端接入（自绘通道，必需）

App-Android / App-iOS 走窗口级自绘（dialogPage 承载页），需完成以下三步：

### 1. 复制承载页到业务工程

将 `node_modules/@meng-xi/unix-utils/src/toast/channels/app/dialog-page.uvue`
复制到业务工程的 `pages/toast/dialog-page.uvue`。

### 2. 在 pages.json 中注册

```json
{
  "pages": [
    {
      "path": "pages/toast/dialog-page",
      "style": {
        "navigationStyle": "custom",
        "backgroundColor": "transparent",
        "app-plus": { "popGesture": "none" }
      }
    }
  ]
}
```

### 3. 配置承载页路径

```ts
import { configureToast } from '@meng-xi/unix-utils'

// #ifdef APP
configureToast({ dialogPagePath: 'pages/toast/dialog-page' })
// #endif
```

> 未配置时默认指向 `node_modules/@meng-xi/unix-utils/src/toast/channels/app/dialog-page`，
> 打包后该路径不可用，因此必须在 App 端显式覆盖。

## 其他端

微信小程序 / 鸿蒙自动走 `uni.showToast` 原生通道，无需额外配置；
Web 与 App 一致走自绘通道（`#ifdef WEB` 的 DOM 单例，position / warning / 不截断全生效），同样无需额外配置。

## 全局默认配置

```ts
configureToast({
	duration: 2000,   // 默认展示时长
	icon: ToastIcon.SUCCESS, // 默认图标
	mask: false       // 默认是否显示蒙层
})
```

## 降级行为

原生通道端（微信 / 鸿蒙）不支持的参数会通过 `fail` 回调以 `errCode = PLATFORM_UNSUPPORTED(2001)` 通知：
- `warning` 图标 → 降级为 `none`
- `position` → 降级为居中
- `image` gif → 降级为不展示自定义图
- `title` 超过上限 → 微信 7 字、鸿蒙 20 字后加省略号

App 与 Web 自绘通道全属性生效，无降级。

## 导出

- API：`showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- 枚举：`ToastIcon` / `ToastPosition` / `ToastErrorCode`
- 类型：`ToastOptions` / `ToastResult` / `ToastFail` / `NormalizedOptions` / `ToastDefaults`

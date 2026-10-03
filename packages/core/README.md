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

## App 端接入（UTS 直挂通道，必需）

App-Android / App-iOS 走 UTS 直挂系统窗口（Android `WindowManager` / iOS `UIWindow`，免注册、免承载页），只需将随包附带的 UTS 插件复制到工程 `uni_modules/`：

```shell
cp -R node_modules/@meng-xi/unix-utils/uni-modules/unix-window uni_modules/
```

> UTS 插件必须位于工程 `uni_modules/` 目录（编译器不扫描 node_modules）。漏复制时 App 端编译期即报错（可发现性好）。插件挂窗失败时自动降级 `uni.showToast` 原生通道并输出日志。

若以 uni_modules 形式整体安装本包，插件目录会随 sync 机制一并就位，无需手动复制。

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

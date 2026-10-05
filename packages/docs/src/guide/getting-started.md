# 快速开始

本页带你跑通 unix-utils 的 toast 模块：发出第一条提示、处理失败、使用快捷 API。

## 导入

```ts
import {
	showToast,
	showToastAsync,
	hideToast,
	showToastSuccess,
	showToastError,
	showToastInfo
} from '@/uni_modules/unix-utils'
```

> import 路径固定为 `@/uni_modules/unix-utils`（插件市场导入或 npm 安装后复制均落位到工程 `uni_modules/unix-utils/`）。

## 发出第一条 toast

```ts
// 回调式（与 uni.showToast 同构，迁移零成本）
showToast({
	title: '保存成功',
	icon: 'success',
	duration: 2000
})
```

无需任何配置——各端通道自动选择（App 直挂系统窗口 / Web DOM 自绘 / 小程序原生），详见[通道架构与降级](/guide/channels)。

## Promise 式调用

```ts
try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
} catch (err) {
	// err 为结构化 ToastFail，而非粗糙的 errMsg
	console.error(`toast 失败：errCode=${err.errCode} param=${err.param} platform=${err.platform}`)
}
```

## 语义化快捷 API

最常见的三种提示一行搞定：

```ts
showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')
```

## 隐藏 toast

```ts
showToast({ title: '正在处理…', icon: 'loading', duration: 0 })
// 业务完成后手动隐藏（自绘通道可靠隐藏，含 position 形态）
hideToast()
```

## 项目级默认配置（可选）

多个页面的提示风格需要统一时，用 `configureToast` 一次预设：

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})
```

字段传 `null` 表示沿用库内置默认（1500ms / `'success'` / `false`）。详见 [configureToast()](/api/configure-toast)。

## 下一步

- 了解 `icon` / `position` 等参数在各端的行为：[Toast 提示](./toast)；
- 想知道降级何时发生、如何感知：[通道架构与降级](./channels)；
- 完整参数表：[ToastOptions](/api/type-toast-options)。

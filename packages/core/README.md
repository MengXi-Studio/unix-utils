# @meng-xi/unix-utils

为 uni-app x 提供便利工具（标准 uni_modules UTS 插件形态，插件市场 + npm 双轨分发）。

当前模块：**toast**（`showToast` 全端兼容封装）。

## 安装

**方式一：插件市场**（推荐）——在 HBuilderX 中从插件市场搜索 `unix-utils` 导入到工程 `uni_modules/`。

**方式二：npm**——安装后将包内容同步到工程 `uni_modules/unix-utils/`（编译器不扫描 node_modules）：

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

> App 端 UTS 直挂通道在 v0.8 起内联为插件自身实现（`utssdk/app-android` / `utssdk/app-ios`），无需再复制任何附加插件目录。

## 快速使用

```ts
import {
	showToast,
	showToastAsync,
	showToastSuccess,
	showToastError,
	showToastInfo
} from '@/uni_modules/unix-utils'

// 回调式（与 uni.showToast 同构）
showToast({
	title: '保存成功',
	icon: 'success',
	duration: 2000
})

// Promise 式
await showToastAsync({ title: '加载中', icon: 'loading' })

// 语义化快捷
showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')
```

> `icon` / `position` 为字符串字面量联合类型（`'success' | 'error' | 'fail' | 'exception' | 'warning' | 'loading' | 'none'`），直接传字面量即可。

## 通道架构（自动选择，无需配置）

| 端 | 通道 | 说明 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口 | `WindowManager` / `UIWindow` 免注册挂窗，position / warning / image / mask 全生效，失败自动降级 `uni.showToast` |
| Web | DOM 单例自绘 | position / warning / 不截断全生效 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | 不支持的参数自动降级并经 `fail` 回调留痕 |

## 全局默认配置

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})
```

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

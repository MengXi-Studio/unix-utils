# ToastOptions

`showToast` / `showToastAsync` 的选项类型，与 `uni.showToast` 参数完全同构。**除 `title` 外均为可选字段**（v0.8.1 起，业务漏传可选项安全）。

## 类型定义

```ts
export type ToastOptions = {
	/** 提示内容 */
	title: string
	/** 图标；不传或 null 表示使用全局默认（success） */
	icon?: ToastIcon | null
	/** 自定义图标本地路径；不传或 null 表示不使用 */
	image?: string | null
	/** 是否显示透明蒙层，防止触摸穿透 */
	mask?: boolean
	/** 提示延迟时间（毫秒），不钳制，原样透传 */
	duration?: number
	/** 位置；不传或 null 表示不启用 position 形态（居中普通 toast） */
	position?: ToastPosition | null
	/** 成功回调 */
	success?: ((res: ToastResult) => void) | null
	/** 失败回调（含降级通知） */
	fail?: ((err: ToastFail) => void) | null
	/** 结束回调（成功或失败都执行） */
	complete?: ((res: any) => void) | null
}
```

## 字段说明

| 字段 | 类型 | 必填 | 默认 | 说明与各端行为 |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✅ | — | 提示内容；微信 7 汉字 / 鸿蒙 20 字截断（自绘通道无截断） |
| `icon` | [ToastIcon](/api/type-enums#toasticon) \| `null` | ✗ | `'success'` | `fail` / `exception` 原生端归一化为 `error`；`warning` 原生端降级 `none` |
| `image` | `string \| null` | ✗ | `null` | 自定义图标本地路径；Web 自绘通道支持 gif；App 直挂通道暂不渲染（降级 icon `none` + 留痕）；原生通道 App 端 gif 降级 |
| `mask` | `boolean` | ✗ | `false` | 透明蒙层防触摸穿透；App 端蒙层拦截触摸但不消费返回键 |
| `duration` | `number` | ✗ | `1500` | 毫秒，不钳制原样透传；原生通道端实际粒度受平台约束 |
| `position` | [ToastPosition](/api/type-enums#toastposition) \| `null` | ✗ | `null` | `top` / `center` / `bottom` 自绘通道全支持；原生通道降级居中 + 留痕 |
| `success` | `(res: [ToastResult](#toastresult)) => void` \| `null` | ✗ | `null` | 成功回调 |
| `fail` | `(err: [ToastFail](/api/type-toast-fail)) => void` \| `null` | ✗ | `null` | 失败回调（含降级通知，errCode 2001 为信息级） |
| `complete` | `(res: any) => void` \| `null` | ✗ | `null` | 结束回调（成功或失败都执行） |

## ToastResult

成功回调结果，对齐原生：

```ts
export type ToastResult = {
	errMsg: string
}
```

## 相关类型

- [ToastIcon / ToastPosition / ToastErrorCode](/api/type-enums)
- [ToastFail](/api/type-toast-fail)

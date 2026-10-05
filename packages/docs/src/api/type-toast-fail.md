# ToastFail

toast 失败结构。比原生 `errCode` + `errMsg` 更结构化：携带「哪个参数、哪个端」，降级与错误业务均可精确感知。

## 类型定义

```ts
export type ToastFail = {
	/** 错误码 */
	errCode: ToastErrorCode
	/** 固定主题，便于业务过滤 */
	errSubject: string
	/** 错误描述 */
	errMsg: string
	/** 触发问题的参数名（如 'position' / 'image' / 'icon'），无则 null */
	param: string | null
	/** 当前端标识（'app-android' / 'web' / 'mp-weixin' / ...） */
	platform: string
}
```

## 字段说明

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `errCode` | [ToastErrorCode](/api/type-enums#toasterrorcode) | `1001` 参数非法 / `2001` 平台不支持（已降级，信息级） |
| `errSubject` | `string` | 固定为 `'unix-utils:toast'`，业务可据此过滤 unix-utils 的失败通知 |
| `errMsg` | `string` | 人类可读的错误描述 |
| `param` | `string \| null` | 触发问题的参数名，如 `'position'` / `'image'` / `'icon'` |
| `platform` | `string` | 当前端标识，如 `'app-android'` / `'web'` / `'mp-weixin'` |

## 示例

```ts
import { showToast, showToastAsync } from '@/uni_modules/unix-utils'

// 回调式
showToast({
	title: '警告信息',
	icon: 'warning',
	position: 'top',
	fail: (err) => {
		// 微信端：err.errCode=2001, err.param='icon'（position 亦降级，多次回调逐一通知）
		if (err.errCode === 2001) {
			console.warn(`参数 ${err.param} 在 ${err.platform} 已降级`)
		}
	}
})

// Promise 式（仅参数错误 reject）
try {
	await showToastAsync({ title: '加载中' })
} catch (err) {
	console.error(err.errSubject, err.errCode, err.errMsg)
}
```

## 相关常量

| 常量 | 值 | 说明 |
| --- | --- | --- |
| `TOAST_ERR_PARAM_INVALID` | `1001` | 参数非法（PARAM_INVALID） |
| `TOAST_ERR_PLATFORM_UNSUPPORTED` | `2001` | 参数当前端不支持且已降级（PLATFORM_UNSUPPORTED，信息级） |

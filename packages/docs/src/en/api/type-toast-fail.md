# ToastFail

The structured failure shape for toast calls. More structured than the native `errCode` + `errMsg`: it carries "which parameter, which platform", so business code can precisely detect both fallbacks and errors.

## Type Definition

```ts
export type ToastFail = {
	/** Error code */
	errCode: ToastErrorCode
	/** Fixed subject, easy to filter on in business code */
	errSubject: string
	/** Error description */
	errMsg: string
	/** Name of the parameter that triggered the problem (e.g. 'position' / 'image' / 'icon'); null if none */
	param: string | null
	/** Current platform identifier ('app-android' / 'web' / 'mp-weixin' / ...) */
	platform: string
}
```

## Field Details

| Field | Type | Description |
| --- | --- | --- |
| `errCode` | [ToastErrorCode](/en/api/type-enums#toasterrorcode) | `1001` (invalid parameter) / `2001` (platform unsupported — already fallen back, informational) |
| `errSubject` | `string` | Fixed to `'unix-utils:toast'`; business code can filter unix-utils failure notices by it |
| `errMsg` | `string` | Human-readable error description |
| `param` | `string \| null` | Name of the parameter that triggered the problem, e.g. `'position'` / `'image'` / `'icon'` |
| `platform` | `string` | Current platform identifier, e.g. `'app-android'` / `'web'` / `'mp-weixin'` |

## Example

```ts
import { showToast, showToastAsync } from '@/uni_modules/unix-utils'

// Callback style
showToast({
	title: '警告信息',
	icon: 'warning',
	position: 'top',
	fail: (err) => {
		// On WeChat: err.errCode=2001, err.param='icon' (position also falls back; each fallback notifies through a separate callback)
		if (err.errCode === 2001) {
			console.warn(`参数 ${err.param} 在 ${err.platform} 已降级`)
		}
	}
})

// Promise style (only invalid parameters reject)
try {
	await showToastAsync({ title: '加载中' })
} catch (err) {
	console.error(err.errSubject, err.errCode, err.errMsg)
}
```

## Related Constants

| Constant | Value | Description |
| --- | --- | --- |
| `TOAST_ERR_PARAM_INVALID` | `1001` | Invalid parameter (PARAM_INVALID) |
| `TOAST_ERR_PLATFORM_UNSUPPORTED` | `2001` | The parameter is unsupported on the current platform and has been fallen back (PLATFORM_UNSUPPORTED, informational) |

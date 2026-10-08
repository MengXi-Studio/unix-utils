# showToast()

Displays a toast notification that works across all platforms. The API shape is fully isomorphic with `uni.showToast`, so migration costs nothing; each platform is dispatched automatically through channels — see [Channel Architecture & Fallback](/en/guide/channels).

## Type

```ts
export const showToast: (options: ToastOptions) => void
```

## Parameters

### options: ToastOptions

See [ToastOptions](/en/api/type-toast-options) for the full list of fields. All fields except `title` are optional fields.

## Return Value

None (results are delivered through the `success` / `fail` / `complete` callbacks).

## Example

```ts
import { showToast } from '@/uni_modules/unix-utils'

// Minimal call
showToast({ title: '保存成功' })

// Full options
showToast({
	title: '已同步到云端',
	icon: 'success',
	duration: 2000,
	mask: false,
	position: 'top',
	success: (res) => {
		console.log(res.errMsg)
	},
	fail: (err) => {
		// Fallback notice or invalid parameter; structured details in ToastFail
		console.error(err.errCode, err.param, err.platform)
	}
})
```

## Notes

- **Consecutive calls**: the later call replaces the earlier one (consistent with WeChat); on the App direct-attach channel, when the mask and position are the same, the window is reused and only its content is updated;
- **No duration clamping**: the value is passed through as-is; the self-drawn channel controls timing precisely with a timer;
- **Fallback**: parameters unsupported on native-channel platforms (WeChat / HarmonyOS) fall back automatically and leave a trace via the `fail` callback (errCode 2001); see [Channel Architecture & Fallback](/en/guide/channels#fallback-perception-the-fail-callback).

## Related APIs

- [showToastAsync()](/en/api/show-toast-async) — the Promise-based version
- [Semantic Shortcut APIs](/en/api/shortcuts) — success / error / info in one line

# showToastAsync()

The Promise-based version of `showToast()`: it resolves on success and rejects with a JSON string of the [ToastFail](/en/api/type-toast-fail) structure on failure (unified across all platforms; business code restores it via `JSON.parse<ToastFail>(err as string)`). Internally it reuses the same normalization and dispatch pipeline, only wrapping the callbacks.

## Type

```ts
export const showToastAsync: (options: ToastOptions) => Promise<void>
```

## Parameters

### options: ToastOptions

Exactly the same as [showToast()](/en/api/show-toast#options-toastoptions).

## Return Value

- **resolve**: the toast is displayed normally;
- **reject**: any `fail` callback firing along the pipeline rejects — both parameter errors (errCode 1001) and parameter fallbacks (errCode 2001) reject, and the rejection value is a JSON string of the `ToastFail` structure (unified across all platforms).

## Example

```ts
import { showToastAsync } from '@/uni_modules/unix-utils'

try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
	// the toast is now visible
} catch (err) {
	const fail = JSON.parse<ToastFail>(err as string)
	if (fail != null) {
		console.error(`toast 失败：errCode=${fail.errCode} param=${fail.param} platform=${fail.platform}`)
	}
}
```

## Notes

- **Fallbacks also reject**: a parameter fallback (e.g. passing `position: 'top'` on WeChat, errCode 2001) fires the `fail` callback and the Promise rejects as well — after the fallback the toast still displays; it is an informational notice that business code may ignore after catching. If you do not want to handle fallback exceptions, use the callback-based [showToast()](/en/api/show-toast) and read its `fail` callback;
- UTS supports Promise on all platforms, so this API works on all five platforms.

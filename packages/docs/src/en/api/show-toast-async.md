# showToastAsync()

The Promise-based version of `showToast()`: it resolves on success and rejects with the structured [ToastFail](/en/api/type-toast-fail) on failure. Internally it reuses the same normalization and dispatch pipeline, only wrapping the callbacks.

## Type

```ts
export const showToastAsync: (options: ToastOptions) => Promise<void>
```

## Parameters

### options: ToastOptions

Exactly the same as [showToast()](/en/api/show-toast#options-toastoptions).

## Return Value

- **resolve**: the toast is displayed normally (including fallback scenarios — a fallback is an informational notice, not a reject);
- **reject**: genuine failures such as invalid parameters; the rejection value is a `ToastFail` structure.

## Example

```ts
import { showToastAsync } from '@/uni_modules/unix-utils'

try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
	// the toast is now visible
} catch (err) {
	console.error(`toast 失败：errCode=${err.errCode} param=${err.param} platform=${err.platform}`)
}
```

## Notes

- Parameter fallbacks (e.g. passing `position: 'top'` on WeChat) follow the `fail` callback semantics and **do not reject** — after the fallback the toast still displays; it is an informational notice. To detect fallbacks, use the callback-based [showToast()](/en/api/show-toast) and read its `fail` callback;
- UTS supports Promise on all platforms, so this API works on all five platforms.

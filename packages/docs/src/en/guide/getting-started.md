# Getting Started

This page walks you through the toast module of unix-utils: showing your first toast, handling failures, and using the shortcut APIs.

## Import

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

> The import path is fixed as `@/uni_modules/unix-utils` (both the plugin-market import and the npm install + copy land in the project's `uni_modules/unix-utils/` directory).

## Show Your First Toast

```ts
// Callback style (mirrors uni.showToast, zero migration cost)
showToast({
	title: '保存成功',
	icon: 'success',
	duration: 2000
})
```

No configuration needed — the channel is selected automatically per platform (App attaches directly to system windows / Web self-drawn DOM / Mini Program native). See [Channel Architecture and Fallback](/en/guide/channels) for details.

## Promise-Style Calls

```ts
try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
} catch (err) {
	// err is a structured ToastFail, not a coarse errMsg
	console.error(`toast 失败：errCode=${err.errCode} param=${err.param} platform=${err.platform}`)
}
```

## Semantic Shortcut APIs

The three most common toasts, one line each:

```ts
showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')
```

## Hide the Toast

```ts
showToast({ title: '正在处理…', icon: 'loading', duration: 0 })
// Hide manually once the work is done (reliable hiding on the self-drawn channel, including the position variant)
hideToast()
```

## Project-Level Default Configuration (Optional)

When multiple pages need a unified toast style, preset it once with `configureToast`:

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // default display duration
	icon: 'success', // default icon
	mask: false      // whether to show the mask by default
})
```

Passing `null` for a field means keeping the library's built-in default (1500ms / `'success'` / `false`). See [configureToast()](/en/api/configure-toast) for details.

## Next Steps

- How parameters like `icon` / `position` behave on each platform: [Toast](./toast);
- When fallbacks happen and how to perceive them: [Channel Architecture and Fallback](./channels);
- The complete parameter table: [ToastOptions](/en/api/type-toast-options).

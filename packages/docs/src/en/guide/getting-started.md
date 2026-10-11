# Getting Started

This page walks you through the two modules of unix-utils: showing your first toast, popping up your first modal dialog, handling failures, and using the shortcut APIs.

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

## Show Your First Modal Dialog (modal module)

```ts
import { showModal } from '@/uni_modules/unix-utils'

// Mirrors uni.showModal, zero migration cost
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	confirmColor: '#ff0000',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel are always present and mutually exclusive
	}
})
```

## modal's Promise Style, alert Semantics, and Global Defaults

```ts
import {
	showModalAsync,
	showModalAlert,
	configureModal
} from '@/uni_modules/unix-utils'

// Promise style: canceling does not count as failure (resolves); failures reject with a JSON string of the ModalFail structure (unified across all platforms, restored via JSON.parse<ModalFail>)
const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
if (res.confirm) save()

// alert semantics (single confirm button)
showModalAlert('提示', '操作已完成')

// Global defaults: passing null for a field keeps the library built-in default / platform default
configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,
	cancelColor: null
})
```

See [showModal()](/en/api/show-modal) and [Modal](./modal) for details.

## Next Steps

- How parameters like `icon` / `position` behave on each platform: [Toast](./toast);
- How modal features like button colors and editable input behave: [Modal](./modal);
- When fallbacks happen and how to perceive them: [Channel Architecture and Fallback](./channels);
- The complete parameter tables: [ToastOptions](/en/api/type-toast-options) / [ModalOptions](/en/api/type-modal-options).

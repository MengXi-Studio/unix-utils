# Toast

toast is the first module of unix-utils: a full-platform compatibility wrapper around `uni.showToast`. This page covers every usage pattern and caveat you need for daily work.

## Basic Usage

```ts
showToast({
	title: '已复制到剪贴板',
	icon: 'success',
	duration: 2000
})
```

The parameters mirror `uni.showToast` exactly (`title / icon / image / mask / duration / position / success / fail / complete`), so migration costs nothing. Every field except `title` is optional; see [ToastOptions](/en/api/type-toast-options) for the complete field table.

## Icons

`icon` is a string literal union type — just pass the literal directly:

```ts
showToast({ title: '成功', icon: 'success' })   // success icon (default value)
showToast({ title: '失败', icon: 'error' })     // error icon
showToast({ title: '加载中', icon: 'loading' }) // loading icon
showToast({ title: '纯文字', icon: 'none' })    // no icon
showToast({ title: '警告', icon: 'warning' })   // extended value: new in unix-utils
```

Per-platform behavior differences are handled by in-library normalization:

| icon value | App / Web self-drawn channels | WeChat / HarmonyOS native channel |
| --- | --- | --- |
| `success` / `error` / `loading` / `none` | ✅ Really rendered | ✅ Really rendered |
| `fail` / `exception` | ✅ Really rendered | Normalized to `error` (the original values are undefined on most platforms) |
| `warning` (extended) | ✅ Really rendered | Falls back to `none`, with a trace left via the `fail` callback (errCode 2001) |

## Position

`position` supports three values, fully supported on the App / Web self-drawn channels:

```ts
showToast({ title: '顶部提示', position: 'top' })
showToast({ title: '居中提示', position: 'center' })
showToast({ title: '底部提示', position: 'bottom' })
```

Position semantics (finalized in v0.7.2): `top` is 10% from the top edge of the visible area, `bottom` is 10% from the bottom edge (equivalent to Web `bottom: 10vh`), and `center` is centered. Consistent across the three platforms.

Notes:

- The WeChat / HarmonyOS native channel does not support position — it automatically falls back to centered, with a trace left via the `fail` callback (errCode 2001);
- On the self-drawn channels, a position-variant toast can still be reliably hidden via [hideToast()](/en/api/hide-toast) (the native channel cannot do this).

## Mask and Custom Image

```ts
// mask: show a transparent mask to prevent touch pass-through
showToast({ title: '提交中…', icon: 'loading', mask: true })

// image: local path of a custom icon (the Web self-drawn channel supports gif)
showToast({ title: '自定义图', image: '/static/custom.png' })
```

`image` is not rendered on the App window-attachment channel for now (it falls back to no icon, with a trace left via the `fail` callback); the WeChat / HarmonyOS native channel detects the `.gif` extension and falls back to not displaying it.

## Global Default Configuration

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // default display duration
	icon: 'success', // default icon
	mask: false      // whether to show the mask by default
})
```

- When `showToast` omits a field, the global default applies; when no global default is set, the library's built-in default applies (1500ms / `'success'` / `false`);
- Global defaults only affect default values; they do not change any fallback behavior.

## Consecutive Calls

The semantics of consecutive `showToast` calls are unified as **the latter replacing the former** (consistent with WeChat):

- App window-attachment channel: with the same mask and position, the window is reused and only the content is updated; if mask / position change, it is rebuilt entirely;
- Web self-drawn channel: the DOM singleton replaces its content;
- Native channel: verified in practice on WeChat to behave as a replacement.

## duration

Not clamped and passed through as-is; the self-drawn channels control it precisely with a timer. On native-channel platforms (WeChat / HarmonyOS), the actual granularity is constrained by the platform (e.g., the system Toast behind the Android fallback has only short/long presets).

## title Length

The self-drawn channels (App / Web) have no platform truncation — fully effective. The WeChat / HarmonyOS native channels truncate per platform (7 Chinese characters on WeChat, 20 characters on HarmonyOS, ellipsis appended beyond the limit) so the visuals never break.

## Lifecycle

- The App window-attachment channel lives at the system-window level and **survives across pages** — the toast does not disappear when a page closes;
- The Web self-drawn channel mounts on the body and survives within the SPA;
- The WeChat native channel binds the toast to the page, so it disappears when the page closes (a presentation-layer residual; see [Channel Architecture and Fallback](./channels) for details).

## Next Steps

- When each fallback happens and how business code perceives it: [Channel Architecture and Fallback](./channels);
- Complete type definitions for every parameter: [ToastOptions](/en/api/type-toast-options).

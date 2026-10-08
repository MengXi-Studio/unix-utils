[中文](./README.md) | **English**

<div align="center">
  <h1>@meng-xi/unix-utils</h1>
  <p>A collection of handy utilities for uni-app x (written in UTS, cross-platform, distributed via uni plugin market + npm)</p>

[![license](https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg)](LICENSE) [![npm](https://img.shields.io/npm/v/@meng-xi/unix-utils?color=blue)](https://www.npmjs.com/package/@meng-xi/unix-utils)
![npm](https://img.shields.io/npm/dt/@meng-xi/unix-utils?color=green)

</div>

## Features

- **Cross-platform compatible** - Covers Android / iOS / Web / WeChat Mini Program / HarmonyOS with per-platform channels dispatched automatically — zero configuration in business code
- **UTS native window on App** - Registration-free native windows (Android `WindowManager` / iOS `UIWindow`): position / warning / mask / precise duration all take effect, window-level lifecycle survives page navigation, with automatic fallback to `uni.showToast` on failure
- **DOM singleton on Web** - Body-mounted singleton with position / warning / no platform truncation
- **Fully aligned parameters** - Same signature as `uni.showToast` (`title / icon / image / mask / duration / position / success / fail / complete`), zero-cost migration
- **Icon superset** - 6 native values plus the extended `warning`; `fail` / `exception` are normalized to `error` on native channels (undefined behavior on most platforms) and rendered natively on self-drawn channels
- **All three position values** - `top` / `center` / `bottom` fully supported on self-drawn channels with consistent semantics across platforms (top 10% from the top edge, bottom 10% from the bottom edge, center)
- **Dual-style API** - Callback-style `showToast` (primary) + Promise-style `showToastAsync`; semantic shortcuts `showToastSuccess` / `showToastError` / `showToastInfo`
- **Reliable hiding** - `hideToast` reliably hides on self-drawn channels, including position-mode toasts that native channels cannot hide
- **Global defaults** - `configureToast` for project-level duration / icon / mask presets
- **Structured degradation** - `ToastFail` (`errCode` / `errSubject` / `param` / `platform`) reported through the `fail` callback — degradations are observable and filterable
- **Strongly typed UTS** - All `ToastOptions` fields except `title` are optional; `icon` / `position` / error codes are literal union types

## Installation

**Option 1: uni plugin market** (recommended) — search for `unix-utils` in HBuilderX and import it into your project's `uni_modules/` directory.

**Option 2: npm** — install and copy the package into your project's `uni_modules/unix-utils/` (the compiler does not scan node_modules):

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

> `packages/core` is a standard **uni_modules UTS plugin** (`utssdk/` official directory layout + `interface.uts` API declarations), distributed as UTS source: Web / Mini Program → JS, Android → Kotlin, iOS → Swift, compiled on the fly by the uni-app x build chain.

## Quick Start

### 1. Show your first toast

```ts
import { showToast } from '@/uni_modules/unix-utils'

// Same signature as uni.showToast, zero-cost migration
showToast({
	title: 'Saved',
	icon: 'success',
	duration: 2000
})
```

### 2. Promise style & semantic shortcuts

```ts
import {
	showToastAsync,
	showToastSuccess,
	showToastError,
	showToastInfo,
	hideToast
} from '@/uni_modules/unix-utils'

// Promise style: rejects with a structured ToastFail on failure
try {
	await showToastAsync({ title: 'Loading', icon: 'loading' })
} catch (err) {
	console.error(err.errCode, err.param, err.platform)
}

// Semantic shortcuts
showToastSuccess('Done')
showToastError('Failed')
showToastInfo('FYI')

// Manual hide (reliable on self-drawn channels, including position-mode toasts)
hideToast()
```

> `icon` / `position` are string literal union types (`'success' | 'error' | 'fail' | 'exception' | 'warning' | 'loading' | 'none'`) — pass literals directly.

### 3. Global defaults

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // default display duration
	icon: 'success', // default icon
	mask: false      // default transparent mask
})
```

## Channel Architecture (auto-selected, zero configuration)

| Platform | Channel | Description |
| --- | --- | --- |
| App-Android / App-iOS | UTS native window | Registration-free `WindowManager` / `UIWindow`; position / warning / image / mask all take effect; falls back to `uni.showToast` on failure |
| Web | DOM singleton self-drawn | position / warning / no truncation all take effect |
| WeChat / HarmonyOS | `uni.showToast` native | Unsupported parameters degrade automatically and are reported via the `fail` callback |

## Common ToastOptions

| Option | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✅ | - | Toast content; truncated at 7 CJK chars on WeChat / 20 on HarmonyOS (no truncation on self-drawn channels) |
| `icon` | `ToastIcon` | ✗ | `'success'` | Icon, see the literal union above |
| `image` | `string` | ✗ | - | Local path of a custom icon image (not rendered on the App native-window channel yet — degrades to no icon with a callback notice) |
| `mask` | `boolean` | ✗ | `false` | Transparent mask to prevent touch-through |
| `duration` | `number` | ✗ | `1500` | Milliseconds, passed through without clamping |
| `position` | `ToastPosition` | ✗ | - | `top` / `center` / `bottom` (degrades to center with a notice on native channels) |
| `success` / `fail` / `complete` | callbacks | ✗ | - | `fail` receives a structured `ToastFail` (`errCode` 1001 invalid param / 2001 platform unsupported) |

## Degradation Behavior

On native-channel platforms (WeChat / HarmonyOS), unsupported parameters are reported through the `fail` callback with `errCode = 2001` (PLATFORM_UNSUPPORTED):

- `warning` icon → degrades to `none`
- `position` → degrades to center
- `image` gif → degrades to no custom image
- `title` over the limit → truncated with an ellipsis at 7 chars (WeChat) / 20 chars (HarmonyOS)

Self-drawn channels on App and Web apply every option with no degradation; the `image` custom image is not rendered on App yet (degrades to no icon with a callback notice).

## Exports

- API: `showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- Constants: `DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` / `TOAST_ERR_PARAM_INVALID(1001)` / `TOAST_ERR_PLATFORM_UNSUPPORTED(2001)`
- Literal union types: `ToastIcon` / `ToastPosition` / `ToastErrorCode`

## Documentation

📖 Complete documentation (guides + API reference + changelog):

**[https://mengxi-studio.github.io/unix-utils/](https://mengxi-studio.github.io/unix-utils/)**

Suggested reading: start with the [Introduction](https://mengxi-studio.github.io/unix-utils/guide/introduction.html) and [Quick Start](https://mengxi-studio.github.io/unix-utils/guide/getting-started.html), then dive into platform behavior with [Toast](https://mengxi-studio.github.io/unix-utils/guide/toast.html) and [Channel Architecture & Degradation](https://mengxi-studio.github.io/unix-utils/guide/channels.html); for API details see the [API Reference](https://mengxi-studio.github.io/unix-utils/api/show-toast.html).

> The documentation site is currently available in Chinese only; an English version is planned.

## Changelog

📝 **[https://github.com/MengXi-Studio/unix-utils/blob/master/packages/core/changelog.md](https://github.com/MengXi-Studio/unix-utils/blob/master/packages/core/changelog.md)**

## License

[MIT](LICENSE)

[中文](./README.md) | **English**

<div align="center">
  <h1>@meng-xi/unix-utils</h1>
  <p>A collection of handy utilities for uni-app x (written in UTS, cross-platform, distributed via uni plugin market + npm)</p>

[![license](https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg)](LICENSE) [![npm](https://img.shields.io/npm/v/@meng-xi/unix-utils?color=blue)](https://www.npmjs.com/package/@meng-xi/unix-utils)
![npm](https://img.shields.io/npm/dt/@meng-xi/unix-utils?color=green)

</div>

## Features

### toast module (cross-platform wrapper around uni.showToast)

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

### modal module (cross-platform wrapper around uni.showModal, since v0.2.0)

- **Fully aligned parameters** - Same signature as `uni.showModal` (`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete`), zero-cost migration
- **Consistent result values** - `confirm` / `cancel` in `ModalResult` always exist and are mutually exclusive (eliminating cross-platform differences where the `cancel` field may be missing); with `editable`, `content` carries the user input
- **Color normalization** - Validates `#RGB` / `#RRGGBB` / `#RRGGBBAA`; invalid values fall back to the platform default color with a trace left via the fail callback; alpha is stripped automatically with a trace when the App native channel does not support it; library defaults are confirm `#007aff` / cancel `#000000`
- **Button text truncation on restricted platforms** - On WeChat / HarmonyOS, button text over 4 characters is truncated in the library (eliminating silent platform differences); full text on App / Web
- **Promise style & shortcut APIs** - `showModalAsync` resolves on cancel (not a failure); `showModalAlert` provides single-confirm-button alert semantics
- **Global defaults** - `configureModal` for project-level button text and color presets
- **Structured degradation** - `ModalFail` (`errCode` 1001 invalid param / 2001 platform unsupported with fallback applied); `ModalFail` / `ModalResult` types are exported

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

// Promise style: rejects with a JSON string of the ToastFail structure on failure (unified across all platforms, restored via JSON.parse)
try {
	await showToastAsync({ title: 'Loading', icon: 'loading' })
} catch (err) {
	const fail = JSON.parse<ToastFail>(err as string)
	if (fail != null) {
		console.error(fail.errCode, fail.param, fail.platform)
	}
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

### 4. Show your first modal dialog (modal module)

```ts
import { showModal } from '@/uni_modules/unix-utils'

// Same signature as uni.showModal, zero-cost migration
showModal({
	title: 'Delete Confirmation',
	content: 'This action cannot be undone. Continue?',
	confirmColor: '#ff0000',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel always exist and are mutually exclusive
	}
})
```

### 5. Promise style, alert semantics & global defaults

```ts
import {
	showModalAsync,
	showModalAlert,
	configureModal
} from '@/uni_modules/unix-utils'

// Promise style: tapping cancel is not a failure (resolve); failures reject with a JSON string of the ModalFail structure (unified across all platforms, restored via JSON.parse)
const res = await showModalAsync({ title: 'Save Changes', content: 'Save your current changes?' })
if (res.confirm) save()

// alert semantics (single confirm button)
showModalAlert('Notice', 'Operation completed')

// Global defaults: passing null to a field keeps the library built-in default / platform default
configureModal({
	confirmText: 'Got it',
	confirmColor: '#00aa00',
	cancelText: null,
	cancelColor: null
})
```

## Channel Architecture (auto-selected, zero configuration)

### toast module

| Platform | Channel | Description |
| --- | --- | --- |
| App-Android / App-iOS | UTS native window | Registration-free `WindowManager` / `UIWindow`; position / warning / image / mask all take effect; falls back to `uni.showToast` on failure |
| Web | DOM singleton self-drawn | position / warning / no truncation all take effect |
| WeChat / HarmonyOS | `uni.showToast` native | Unsupported parameters degrade automatically and are reported via the `fail` callback |

### modal module

| Platform | Channel | Description |
| --- | --- | --- |
| App-Android / App-iOS / WeChat / HarmonyOS | `uni.showModal` native | Color validation & alpha stripping, button text truncation on restricted platforms, `cancel` field always present; degradations reported via the `fail` callback |
| Web | DOM singleton self-drawn | Mask taps do not close the dialog (aligned with native behavior), `editable` rendered as a real input, full text and alpha colors |

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

## Common ModalOptions

| Option | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✗ | - | Dialog title; at least one of `title` / `content` must be non-empty, otherwise `fail` 1001 |
| `content` | `string` | ✗ | - | Dialog content; also serves as the initial input value when `editable` is `true` (native channels; on the Web self-drawn channel content shows as text only and the input starts empty) |
| `showCancel` | `boolean` | ✗ | `true` | Whether to show the cancel button |
| `cancelText` / `confirmText` | `string` | ✗ | `'取消'` / `'确定'` | Button text; truncated in the library at 4 characters on WeChat / HarmonyOS |
| `cancelColor` / `confirmColor` | `string` | ✗ | platform default | Button colors in hex, `#RGB` / `#RRGGBB` / `#RRGGBBAA`; unset values pass through the platform default (Web self-drawn falls back to `'#000000'` / `'#007aff'`); invalid values degrade to the platform default with a trace |
| `editable` | `boolean` | ✗ | `false` | Whether the dialog is editable; `ModalResult.content` carries the user input |
| `placeholderText` | `string` | ✗ | - | Input placeholder (effective when `editable` is `true`) |
| `success` / `fail` / `complete` | callbacks | ✗ | - | `success` receives `ModalResult` (`confirm` / `cancel` always exist and are mutually exclusive); `fail` receives a structured `ModalFail` (`errCode` 1001 invalid param / 2001 platform unsupported with fallback applied) |

## Degradation Behavior

### toast module

On native-channel platforms (WeChat / HarmonyOS), unsupported parameters are reported through the `fail` callback with `errCode = 2001` (PLATFORM_UNSUPPORTED):

- `warning` icon → degrades to `none`
- `position` → degrades to center
- `image` gif → degrades to no custom image
- `title` over the limit → truncated with an ellipsis at 7 chars (WeChat) / 20 chars (HarmonyOS)

Self-drawn channels on App and Web apply every option with no degradation; the `image` custom image is not rendered on App yet (degrades to no icon with a callback notice).

### modal module

On the native channel (App / WeChat / HarmonyOS), degradations are reported via the `fail` callback with `errCode = 2001`; invalid parameters are reported with `errCode = 1001`:

- Invalid color (not matching `#RGB` / `#RRGGBB` / `#RRGGBBAA`) → falls back to the platform default color, with `param` naming the offending option
- 8-digit alpha colors (supported only by the Web self-drawn channel) → alpha stripped automatically with a trace
- Button text over 4 characters → truncated in the library on WeChat / HarmonyOS; full text on App / Web
- Both `title` and `content` empty → `errCode = 1001` with `param = 'title'`

The Web self-drawn channel applies alpha colors and full text with no degradation.

## Exports

### toast module

- API: `showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- Constants: `DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` / `TOAST_ERR_PARAM_INVALID(1001)` / `TOAST_ERR_PLATFORM_UNSUPPORTED(2001)`
- Literal union types: `ToastIcon` / `ToastPosition` / `ToastErrorCode`

### modal module

- API: `showModal` / `showModalAsync` / `showModalAlert` / `configureModal`
- Constants: `DEFAULT_CONFIRM_TEXT` / `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_COLOR` / `DEFAULT_CANCEL_COLOR`
- Exported types: `ModalResult` / `ModalFail` (import via `import type` for Promise callback typing and field access)

## Documentation

📖 Complete documentation (guides + API reference + changelog):

**[https://mengxi-studio.github.io/unix-utils/](https://mengxi-studio.github.io/unix-utils/)**

Suggested reading: start with the [Introduction](https://mengxi-studio.github.io/unix-utils/guide/introduction.html) and [Quick Start](https://mengxi-studio.github.io/unix-utils/guide/getting-started.html), then dive into platform behavior with [Toast](https://mengxi-studio.github.io/unix-utils/guide/toast.html) → [Modal](https://mengxi-studio.github.io/unix-utils/guide/modal.html) → [Channel Architecture & Degradation](https://mengxi-studio.github.io/unix-utils/guide/channels.html); for API details see [showToast](https://mengxi-studio.github.io/unix-utils/api/show-toast.html) and [showModal](https://mengxi-studio.github.io/unix-utils/api/show-modal.html).

## Changelog

📝 **[https://mengxi-studio.github.io/unix-utils/changelog.html](https://mengxi-studio.github.io/unix-utils/changelog.html)**

## License

[MIT](LICENSE)

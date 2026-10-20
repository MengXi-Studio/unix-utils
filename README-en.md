[中文](./README.md) | **English**

<div align="center">
  <a href="https://github.com/MengXi-Studio/unix-utils">
    <img alt="MengXi Studio Logo" width="215" src="https://github.com/MengXi-Studio/unix-utils/blob/master/packages/docs/src/public/logo.png">
  </a>
  <a href="https://github.com/MengXi-Studio/unix-utils">
    <img alt="WeChat Official Account QR" width="215" src="https://github.com/MengXi-Studio/unix-utils/blob/master/packages/docs/src/public/QR_code.jpg">
  </a>
  <br>
  <h1>@meng-xi/unix-utils</h1>
  <p>A collection of handy utilities for uni-app x (written in UTS, one API set covering all platforms)</p>

[![license](https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg)](LICENSE) [![npm](https://img.shields.io/npm/v/@meng-xi/unix-utils?color=blue)](https://www.npmjs.com/package/@meng-xi/unix-utils)
![npm](https://img.shields.io/npm/dt/@meng-xi/unix-utils?color=green)

</div>

## Why unix-utils

Write business code directly with `uni.showToast` / `uni.showModal` and the pitfalls hide in per-platform differences: `position` is unsupported on Mini Programs, the `fail` / `exception` icons behave unpredictably on most platforms, the modal `cancel` field is missing on some platforms, WeChat silently truncates button text, alpha color values behave differently per platform…… you hit each one, wrap it yourself, then do it all over again in the next project. unix-utils collapses that repeated work into a single library:

- **Zero-cost migration?** Options share the exact signature of `uni.showToast` / `uni.showModal`, and results are constant (`confirm` / `cancel` always exist and are mutually exclusive) — switching libraries requires no business code changes;
- **Multi-platform release?** The self-drawn channels on App / Web apply every option, while WeChat / HarmonyOS native channels degrade automatically with structured traces via the `fail` callback (`errCode` / `param` / `platform`) — differences are observable and filterable;
- **Care about types?** Every field except `title` is optional, with literal union types and full UTS / TypeScript IntelliSense.

No dialog stack is reinvented underneath: on App the library mounts native windows directly via UTS (Android `WindowManager` / iOS `UIWindow`), on Web it uses a self-drawn DOM singleton, and on Mini Programs it keeps the native `uni` API. Distributed as UTS source (Web / Mini Program → JS, Android → Kotlin, iOS → Swift), compiled on the fly by the uni-app x build chain.

## Features

### toast module (cross-platform wrapper around uni.showToast)

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

### modal module (cross-platform wrapper around uni.showModal)

- **Fully aligned parameters** - Same signature as `uni.showModal` (`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete`), zero-cost migration
- **Consistent result values** - `confirm` / `cancel` in `ModalResult` always exist and are mutually exclusive (eliminating cross-platform differences where the `cancel` field may be missing); with `editable`, `content` carries the user input
- **UTS native window on App** - Registration-free native windows (Android `WindowManager` / iOS `UIWindow`; since v0.2.0 App no longer goes through the `uni.showModal` native channel) for consistent dialog behavior across platforms
- **Aligned interaction semantics** - Mask taps do not close the dialog (aligned with WeChat's official semantics), the Android back key closes it as a cancellation (`cancel = true`), and consecutive calls replace the previous dialog
- **Real editable input** - Self-drawn channels render a real input; `content` doubles as the initial input value with the cursor placed at the end; content taller than 60% of the screen height (built-in threshold) scrolls automatically
- **Color normalization** - Validates `#RGB` / `#RRGGBB` / `#RRGGBBAA`; invalid values fall back to the platform default color with a trace; alpha colors fully apply on the App / Web self-drawn channels and are stripped automatically with a trace on WeChat / HarmonyOS native channels; library defaults are confirm `#007aff` / cancel `#000000`
- **Button text truncation on restricted platforms** - On WeChat / HarmonyOS, button text over 4 characters is truncated in the library (eliminating silent platform differences); full text on App / Web
- **Promise style & shortcut APIs** - `showModalAsync` resolves on cancel (not a failure); `showModalAlert` provides single-confirm-button alert semantics
- **Global defaults** - `configureModal` for project-level button text and color presets
- **Structured degradation** - `ModalFail` (`errCode` 1001 invalid param / 2001 platform unsupported with fallback applied); `ModalFail` / `ModalResult` types are exported

## Install

**npm** — sync the package into your project's `uni_modules/unix-utils/` (the compiler does not scan node_modules):

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

**Plugin market**: search `unix-utils` in HBuilderX.

> `packages/core` is a standard **uni_modules UTS plugin** (official `utssdk/` layout + `interface.uts` declarations); import from `@/uni_modules/unix-utils` in your code.

## Quick start

### 1. Show your first toast

```uts
import { showToast } from '@/uni_modules/unix-utils'

// Same signature as uni.showToast, zero-cost migration
showToast({
  title: 'Saved',
  icon: 'success',
  duration: 2000
})
```

### 2. Promise style & semantic shortcuts

```uts
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

```uts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
  duration: 2000,  // default display duration
  icon: 'success', // default icon
  mask: false      // default transparent mask
})
```

### 4. Show your first modal dialog (modal module)

```uts
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

```uts
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

### Verification

The repo ships a demo app at [packages/playground](https://github.com/MengXi-Studio/unix-utils/tree/master/packages/playground) — a runnable verification matrix covering every feature (12 pages: 2 toast topics + 8 modal topics + 1 platform-native probe + home navigation), with in-page run logs on every test case so you can compare real behavior across platforms. Open `packages/playground` in HBuilderX to release H5 / WeChat Mini Program / Android and re-run the same suite.

**Android demo APK (cloud-packaged build)**: [Download APK](https://mp-b8b8347a-48e9-434d-8302-3e9d99c2cb01.cdn.bspapp.com/cloudstorage/app-build-pkg/1792463929395-__UNI__7970947_1792463883197.apk)

## Community & Support

- 📖 [Documentation](https://mengxi-studio.github.io/unix-utils/) (guides + API reference + changelog, bilingual)
- 🐛 [Issues](https://github.com/MengXi-Studio/unix-utils/issues) / 💬 [Discussions](https://github.com/MengXi-Studio/unix-utils/discussions)

## Exports

### toast module

- API: `showToast` / `showToastAsync` / `hideToast` / `configureToast` / `showToastSuccess` / `showToastError` / `showToastInfo`
- Constants: `DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` / `TOAST_ERR_PARAM_INVALID(1001)` / `TOAST_ERR_PLATFORM_UNSUPPORTED(2001)`
- Exported type: `ToastFail` (import via `import type` for fail callback typing and `JSON.parse` restoration); `icon` / `position` / error codes are literal unions — pass literals directly

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

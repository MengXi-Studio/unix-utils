# Changelog

## [0.2.0] - 2026-10-11

Second release: the modal module (a cross-platform wrapper around `uni.showModal`).

### Added

- **modal module**: a cross-platform wrapper around `uni.showModal` covering Android / iOS / Web / WeChat / HarmonyOS (five platforms); business code imports uniformly via `import { showModal } from '@/uni_modules/unix-utils'`
- **Full parameter alignment**: `title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete` are isomorphic to `uni.showModal`, making migration zero-cost; all fields are optional except the callbacks
- **Per-platform hybrid channels** (automatic dispatch, zero configuration for business code):
  - App / WeChat / HarmonyOS: the native `uni.showModal` channel (colors verified fully effective in M0 real-device testing) + in-library normalization
  - Web: self-drawn DOM singleton (mask taps do not close the dialog; `editable` genuinely rendered as an `<input>`)
- **Consistent result values**: `confirm` / `cancel` in `ModalResult` always exist and are mutually exclusive (eliminating cross-platform differences where the cancel field may be missing); with `editable`, `content` carries the user input
- **Color normalization**: validates `#RGB` / `#RRGGBB` / `#RRGGBBAA`; invalid values fall back to the platform default color with a trace left via the fail callback; when the App native channel does not support alpha, it is stripped automatically with a trace left; when unconfigured, the library defaults are confirm `#007aff` / cancel `#000000` (WeChat is left untouched, following the platform default)
- **Button text truncation on restricted platforms**: on WeChat / HarmonyOS, button text longer than 4 characters is truncated in the library (eliminating silent platform behavior differences); App / Web display the full text
- **Promise-style `showModalAsync`**: resolves with `ModalResult`; tapping cancel does not count as a failure (consistent with uni semantics); failures reject with a JSON string of the `ModalFail` structure (unified across all platforms; business code restores it via `JSON.parse<ModalFail>(err as string)`)
- **Shortcut API `showModalAlert`**: single-confirm-button alert semantics (`title` + optional `content`)
- **Global default configuration `configureModal`**: project-level presets for button text and colors; passing `null` to a field keeps the library built-in default / platform default
- **Structured failure info `ModalFail`**: `errCode` (1001 invalid parameter / 2001 platform not supported with fallback applied), `errSubject` (fixed `'unix-utils:modal'`), `param` (the name of the parameter that triggered the issue), and `platform` (platform identifier) — fallbacks are observable and filterable; the `ModalFail` / `ModalResult` types are exported

### Breaking Changes

- **`showToastAsync` rejection value changed to a JSON string**: in 0.1.0 it rejected with a `ToastFail` object; real-device testing showed that on the App side the runtime async proxy passes rejection values through as strings only (all object fields are lost). For a consistent contract across all platforms, since 0.2.0 it uniformly rejects with a JSON string of the `ToastFail` structure, and business code restores it via `JSON.parse<ToastFail>(err as string)`. The callback-style `showToast` `fail` callback still receives the structured object and is unaffected; the `ToastFail` type is exported starting from 0.2.0

## [0.1.0] - 2026-10-04

First release: the toast module (a cross-platform wrapper around `uni.showToast`).

### Added

- **toast module**: a cross-platform wrapper around `uni.showToast` covering Android / iOS / Web / WeChat / HarmonyOS (five platforms), shipped as a standard uni_modules UTS plugin (`utssdk/` official directory structure + `interface.uts` public declarations) with dual-track distribution via the DCloud plugin market + npm; business code imports uniformly via `import { showToast } from '@/uni_modules/unix-utils'`
- **Full parameter alignment**: `title / icon / image / mask / duration / position / success / fail / complete` are isomorphic to `uni.showToast`, making migration zero-cost; all `ToastOptions` fields are optional except `title`, with `icon` / `position` / error codes as string/number literal union types
- **Per-platform hybrid channels** (automatic dispatch, zero configuration for business code):
  - App-Android / App-iOS: UTS directly attaches to system windows (registration-free attachment via Android `WindowManager` / iOS `UIWindow`); position / warning / mask / precise duration all take effect; the system-window-level lifecycle survives across pages; window-attachment failures automatically fall back to the native `uni.showToast` channel
  - Web: self-drawn DOM singleton (position / warning / no platform truncation all take effect)
  - WeChat / HarmonyOS: the native `uni.showToast` channel; unsupported parameters fall back automatically with a trace left behind
- **Icon superset**: the 6 native values plus the extended `warning`; `fail` / `exception` are normalized to `error` on native platforms (behavior is undefined on most platforms) and genuinely rendered by the self-drawn channel; `warning` falls back to `none` on native platforms with a trace left via the fail callback
- **Full support for the three position values**: `top` / `center` / `bottom` all take effect on the self-drawn channel, with consistent position semantics across all three values (top: 10% from the top of the display area; bottom: 10% from the bottom of the display area; center: centered); the native channel falls back to center with a trace left
- **Dual-track API**: callback-style `showToast` (primary) + Promise-style `showToastAsync` (secondary); semantic shortcut APIs `showToastSuccess` / `showToastError` / `showToastInfo`
- **Unified `hideToast` semantics**: reliable hiding on the self-drawn channel (including position variants that native platforms cannot hide)
- **Global default configuration `configureToast`**: project-level presets for duration / icon / mask; passing `null` to a field keeps the library built-in default (1500ms / `'success'` / `false`)
- **Structured failure info `ToastFail`**: `errCode` (1001 invalid parameter / 2001 platform not supported), `errSubject` (fixed `'unix-utils:toast'`), `param` (the name of the parameter that triggered the fallback), and `platform` (platform identifier) — fallbacks are observable and filterable

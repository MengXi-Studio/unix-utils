# Changelog

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

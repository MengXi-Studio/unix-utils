# Channel Architecture and Fallback

The core strategy of unix-utils is **per-platform mixed implementation**: each platform automatically selects the optimal channel — zero configuration for business code. This page explains how channels are dispatched, when fallbacks happen, and how business code perceives them.

## Channel Architecture

| Platform | Channel | Implementation |
| --- | --- | --- |
| App-Android / App-iOS | UTS direct attachment to system windows | Registration-free window attachment via `WindowManager` / `UIWindow` (TYPE_APPLICATION_PANEL + Activity token); touch pass-through / mask / animation / precise timing / hideToast are all self-managed |
| Web | Self-drawn DOM singleton | body mount + one-time style injection + class transition animation + precise timing via `setTimeout` |
| WeChat / HarmonyOS | Native `uni.showToast` | Platform-native implementation behind a unified entry |
| App (fallback) | Native `uni.showToast` | Automatically falls back when window attachment fails (e.g., the page is not ready), with a trace left via the `fail` callback |

> Why the App side bypasses `uni.showToast` and attaches to windows directly: the native channel's `position` only supports `bottom` on Android, icon values are not aligned, and lifecycle binding is inconsistent — these presentation-layer differences can only be eliminated by window-level self-drawing. Meanwhile, the Android system `Toast` does not support icon/mask, and iOS has no system Toast API at all, so direct window attachment with self-drawing is the only path on App where "every parameter takes effect".

The modal module (since v0.2) has a different channel split:

| Platform | Channel | Implementation |
| --- | --- | --- |
| App-Android / App-iOS / WeChat / HarmonyOS | Native `uni.showModal` | Direct call + in-library normalization (color validation and alpha stripping, restricted-platform text truncation, return value `confirm` / `cancel` always present and mutually exclusive) |
| Web | Self-drawn DOM singleton | Mask + centered card + button row + `input` (editable); tapping the mask does not close; text and alpha colors fully effective |

> Why modal does not do App-side window-attachment self-drawing: the parameters of the `uni.showModal` native channel are basically aligned in semantics across platforms, and the residual differences (alpha colors, text truncation, missing return-value fields) can all be smoothed out in the in-library normalization layer — the benefit of self-drawing does not outweigh its cost, so the App side reuses the native channel. The Web side uses self-drawing because there is no usable (or controllable) `uni.showModal` on Web, while DOM self-drawing can fully support alpha colors and untruncated text.

## Dispatch Flow

```
Business code calls showToast(options)
      │
      ▼
normalize layer: icon normalization / title truncation / fallback for platform-unsupported parameters
      │
      ▼
dispatch layer (determined by compile-time conditional compilation; channels are replaceable)
   ├─ App window-attachment channel (default for App-Android / App-iOS)
   ├─ Web self-drawn channel (default for Web)
   ├─ uni native channel (default for WeChat / HarmonyOS; App-side fallback)
   └─ UTS extension channel (future evolution)
      │
      ▼
callback layer: success / fail / complete callbacks passed through, errors structured
```

Platform detection uses **compile-time conditional compilation** (`#ifdef APP-ANDROID || APP-IOS || WEB`) instead of runtime string matching (`uni.getSystemInfoSync().uniPlatform` is verified in practice to return `'app'` without the android/ios suffix, so runtime matching is unreliable).

## Parameter Normalization Matrix

Behavior of each parameter across the three channels (✅ fully effective / ⚠️ falls back with a trace / ✗ unsupported):

| Parameter | App (window-attachment channel) | Web (self-drawn channel) | WeChat / HarmonyOS (native channel) |
| --- | --- | --- | --- |
| `title` | ✅ No platform truncation | ✅ No platform truncation | ✅ Truncated at 7 Chinese characters on WeChat / 20 characters on HarmonyOS |
| `icon = fail` / `exception` | ✅ Really rendered | ✅ Really rendered | ⚠️ Normalized to `error` |
| `icon = warning` (extended) | ✅ Really rendered | ✅ Really rendered | ⚠️ Falls back to `none`, errCode 2001 |
| `image` | ⚠️ Falls back to icon `none`, errCode 2001 | ✅ (including gif) | ✅ (gif falls back to not displayed) |
| `mask` | ✅ | ✅ | ✅ |
| `duration` | ✅ Precise milliseconds | ✅ Precise milliseconds | ✅ (granularity constrained by the platform) |
| `position` | ✅ All three values supported | ✅ All three values supported | ⚠️ Falls back to centered, errCode 2001 |
| position + `hideToast` | ✅ Reliable hiding | ✅ Reliable hiding | — (position is not supported in the first place) |
| Consecutive calls | ✅ Window reused with content replaced | ✅ Singleton replaced | ✅ Replaced |
| Lifecycle | ✅ System-window level, survives across pages | ✅ Survives within the SPA | Bound to the page (disappears when the page closes) |

## Modal Normalization Matrix

Behavior of each modal parameter across the two channels (✅ fully effective / ⚠️ falls back with a trace):

| Parameter | App / WeChat / HarmonyOS (native channel) | Web (self-drawn channel) |
| --- | --- | --- |
| `title` / `content` | ✅ Rendered natively | ✅ Really rendered (written via `textContent` to avoid XSS) |
| `showCancel` | ✅ | ✅ |
| `cancelText` / `confirmText` | ⚠️ Silently truncated beyond 4 characters on WeChat / HarmonyOS (full display on App) | ✅ Full display |
| `cancelColor` / `confirmColor` = `#RGB` / `#RRGGBB` | ✅ (`#RGB` expanded to `#RRGGBB`) | ✅ |
| `cancelColor` / `confirmColor` = `#RRGGBBAA` | ⚠️ Alpha stripped then applied, errCode 2001 | ✅ Alpha preserved |
| Invalid color values | ⚠️ Falls back to the platform default color, errCode 2001 | ⚠️ Falls back to the built-in default color, errCode 2001 |
| `editable` | ✅ (`content` doubles as the input's initial value) | ✅ Really renders an `<input>` (`content` shows as text; the input starts empty) |
| `placeholderText` | ✅ | ✅ |
| Return value `confirm` / `cancel` | ✅ Always present and mutually exclusive via in-library normalization | ✅ |
| Tapping the mask | Native behavior (does not close on any platform) | Does not close (only buttons close it) |
| Lifecycle | Page-level modal, blocks interaction | DOM singleton, survives within the SPA |

## Fallback Perception: the fail Callback

Every fallback returns structured [ToastFail](/en/api/type-toast-fail) through the `fail` callback, so business code can precisely perceive "which parameter, which platform":

```ts
showToast({
	title: '警告信息',
	icon: 'warning', // not supported by the WeChat native channel
	position: 'top', // not supported by the WeChat native channel
	fail: (err) => {
		// errCode: 2001 (PLATFORM_UNSUPPORTED)
		// param: 'icon' / 'position' — the parameter names that triggered the fallback
		// platform: 'mp-weixin' — the current platform identifier
		// errSubject: 'unix-utils:toast'
	}
})
```

- errCode `2001` (PLATFORM_UNSUPPORTED) is an **informational** notice: the parameter has fallen back and the toast still shows as usual; business code may choose to ignore it;
- errCode `1001` (PARAM_INVALID) is a genuine parameter error.

modal likewise returns the structured [ModalFail](/en/api/type-modal-fail) through the `fail` callback (`errSubject: 'unix-utils:modal'`):

```ts
showModal({
	title: '提示',
	content: '继续操作',
	confirmColor: 'blue', // invalid color: named colors are not supported by native channels
	fail: (err) => {
		// errCode: 2001 (PLATFORM_UNSUPPORTED)
		// param: 'confirmColor' — the parameter name that triggered the fallback
		// platform: 'mp-weixin' — the current platform identifier
	}
})
```

modal specifics: when both `title` and `content` are empty, it fails with 1001 (`param: 'title'`) and no dialog is shown; under the Promise-based [showModalAsync](/en/api/show-modal-async), a fallback (2001) also rejects (the rejection value is a JSON string of the `ModalFail` structure, unified across all platforms; business code restores it via `JSON.parse<ModalFail>(err as string)`).

## Three Principles for the Presentation Layer

The WeChat / HarmonyOS sides keep the native channel; their residual differences (visual style, lifecycle binding) are managed by three principles:

1. **Predictable**: all residual differences are written into the matrix above — no hidden behavior;
2. **Visible**: when a fallback happens, the `fail` callback leaves a structured trace;
3. **Replaceable**: when the App side needs stronger presentation, the UTS window-attachment channel directly eliminates all presentation-layer differences.

## Known Constraints

- **App side**: the attached window covers everything in the page tree (including above the native tabbar), but independent layers of the `SurfaceView` kind (native video layers, maps) and system UI (status bar / navigation bar / system dialogs) still sit above it — ordinary business scenarios are unaffected;
- **App-side mask**: the mask intercepts touches but does not consume the back button; the Android back button still acts on the business page stack;
- **The trade-off of self-drawing on Mini Programs**: self-drawn toasts on WeChat would be occluded by native components (video / map / camera) and native dialogs, so keeping the native channel on WeChat / HarmonyOS is a deliberately weighed choice.

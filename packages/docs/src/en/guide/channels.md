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

## Three Principles for the Presentation Layer

The WeChat / HarmonyOS sides keep the native channel; their residual differences (visual style, lifecycle binding) are managed by three principles:

1. **Predictable**: all residual differences are written into the matrix above — no hidden behavior;
2. **Visible**: when a fallback happens, the `fail` callback leaves a structured trace;
3. **Replaceable**: when the App side needs stronger presentation, the UTS window-attachment channel directly eliminates all presentation-layer differences.

## Known Constraints

- **App side**: the attached window covers everything in the page tree (including above the native tabbar), but independent layers of the `SurfaceView` kind (native video layers, maps) and system UI (status bar / navigation bar / system dialogs) still sit above it — ordinary business scenarios are unaffected;
- **App-side mask**: the mask intercepts touches but does not consume the back button; the Android back button still acts on the business page stack;
- **The trade-off of self-drawing on Mini Programs**: self-drawn toasts on WeChat would be occluded by native components (video / map / camera) and native dialogs, so keeping the native channel on WeChat / HarmonyOS is a deliberately weighed choice.

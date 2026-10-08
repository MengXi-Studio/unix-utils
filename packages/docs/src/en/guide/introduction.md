# Introduction

`@meng-xi/unix-utils` is a utility library for **uni-app x**. Together with [unix-router](https://mengxi-studio.github.io/unix-router/), it belongs to MengXi-Studio and follows the same engineering paradigm:

- **UTS source distribution**: `main` points directly to `utssdk/index.uts`, and the uni-app x build chain compiles it on the fly for the target platform (Web / Mini Program → JS, Android → Kotlin, iOS → Swift);
- **Strongly typed UTS**: object types defined with `type`, enums defined with literal unions, no `undefined`, strict boolean conditions;
- **Platform differences converge inside the library**: business code is written once, and platform-specific logic is isolated inside the library via conditional compilation (`#ifdef`).

The current module is **toast**: a full-platform compatibility wrapper around `uni.showToast`.

## Why You Need It

The native `uni.showToast` of uni-app x behaves noticeably differently across the five platforms (Android / iOS / Web / WeChat / HarmonyOS). All of the following facts come from the official docs and official examples (verified in October 2026):

| Difference | Current state |
| --- | --- |
| **`icon` valid values are not aligned** | `fail` only takes effect on Alipay and Douyin Mini Programs; `exception` only on Alipay; behavior on the other platforms is undefined |
| **`position` is unusable** | Only takes effect on App, and Android only supports `bottom` (`top` / `center` are not supported yet); once set, the icon stops working and the toast cannot be hidden via `uni.hideToast()` |
| **Inconsistent lifecycle binding** | On iOS / WeChat / Web the toast is bound to the page and disappears when the page closes; on Android `bottom` is a system Toast bound to the App |
| **Inconsistent `title` truncation** | On WeChat, with the `success` / `loading` icons the `title` shows at most 7 Chinese characters and is truncated beyond that; the limits differ across platforms |
| **Missing warning icon** | There is no warning icon natively; extended icons such as `warning` are simply not supported |
| **Coarse error info** | Failures carry only `errCode` + `errMsg`, lacking structured failure info about "which parameter, which platform" |

unix-utils smooths over these differences with a single `showToast` API.

## Two-Layer Compatibility Model

Compatibility differences fall into two layers, where the library's ability to eliminate them — and its guarantees — differ:

**Functionality layer** (whether parameter semantics take effect on each platform) — **fully eliminated** through in-library normalization:

- `fail` / `exception` icons are normalized to `error` (really rendered on the self-drawn channel);
- All three `position` values (`top` / `center` / `bottom`) are fully supported on the App / Web self-drawn channels;
- `title` length follows a unified per-platform truncation policy (7 Chinese characters on WeChat, 20 characters + ellipsis on HarmonyOS);
- Failure info is structured as `ToastFail` (`errSubject` / `param` / `platform`).

**Presentation layer** (visual style, lifecycle binding, duration granularity, framework-level bugs) — eliminated directly on App / Web by the self-drawn channel; the remaining platforms (WeChat / HarmonyOS) keep the native channel, managed by three principles:

1. **Predictable**: all residual differences are documented in the [parameter normalization matrix](/en/guide/channels#parameter-normalization-matrix) and the docs — no hidden behavior;
2. **Visible**: when a fallback happens, the `fail` callback returns structured [ToastFail](/en/api/type-toast-fail) so business code can perceive it;
3. **Replaceable**: when stronger presentation is needed, the App-side UTS window-attachment channel directly eliminates all presentation-layer differences on that platform.

## Channel Architecture

Each platform automatically selects the optimal channel — zero configuration for business code:

| Platform | Channel | Description |
| --- | --- | --- |
| App-Android / App-iOS | UTS direct attachment to system windows | Registration-free window attachment via Android `WindowManager` / iOS `UIWindow`; position / warning / mask all take effect; automatically falls back to `uni.showToast` on failure |
| Web | Self-drawn DOM singleton | position / warning / no truncation all take effect |
| WeChat / HarmonyOS | Native `uni.showToast` | Unsupported parameters automatically fall back, with a trace left via the `fail` callback |

See [Channel Architecture and Fallback](/en/guide/channels) for details.

## Capabilities at a Glance

| Capability | Description |
| --- | --- |
| Fully aligned parameters | `title / icon / image / mask / duration / position / success / fail / complete` are all preserved — zero migration cost |
| icon superset | 6 native values + the extended `warning`; `fail` / `exception` are normalized or really rendered on each platform |
| Three position values | `top` / `center` / `bottom` are fully supported on the App / Web self-drawn channels (position semantics finalized in v0.7.2: 10% from the edge) |
| Dual-track API | Callback-style `showToast` (primary) + Promise-style `showToastAsync` (auxiliary) |
| Semantic shortcuts | `showToastSuccess` / `showToastError` / `showToastInfo`, one line each |
| Global defaults | `configureToast` presets duration / icon / mask at the project level |
| Reliable hiding | `hideToast` reliably hides toasts on the self-drawn channels (including the position variant) |
| Structured fallback | `ToastFail.errCode` (1001 invalid parameter / 2001 platform unsupported) + `param` / `platform` for precise locating |
| Strong typing | Every `ToastOptions` field except `title` is optional; `icon` / `position` are literal union types |

## Who Is It For

- **You need consistent toast behavior across platforms**: one API set covers the five platforms, with predictable and perceivable parameter fallbacks.
- **You are fed up with native toast differences**: unusable position, misaligned icons per platform, WeChat's 7-character truncation — the library handles them all.
- **You want strong typing with zero dependencies**: UTS source distribution, introducing no third-party UI dependencies.

## Next Steps

- Want to get hands-on right away? Start with [Installation](./installation) or [Getting Started](./getting-started).
- Want to understand the platform-specific behavior details? See [Channel Architecture and Fallback](/en/guide/channels).

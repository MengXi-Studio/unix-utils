# ToastIcon / ToastPosition / ToastErrorCode

Literal union types of the toast module. Note: these are **string / number literal unions** (not enums) — pass the literals directly. UTS enums cannot cross the UTS plugin proxy boundary (uts-proxy), so the public contract is uniformly literal unions.

## ToastIcon

Toast icons, aligned with the official `icon` parameter of `uni.showToast` and extended with `warning`:

```ts
export type ToastIcon =
	| 'success'    // success icon (default)
	| 'error'      // error icon
	| 'fail'       // error icon (alias; the title is displayed without a length limit)
	| 'exception'  // exception icon (the title is displayed without a length limit)
	| 'warning'    // warning icon (unix-utils extension)
	| 'loading'    // loading icon
	| 'none'       // no icon
```

Per-platform behavior (see the [parameter normalization matrix](/en/guide/channels#parameter-normalization-matrix) for details):

| Value | App / Web self-drawn channel | WeChat / HarmonyOS native channel |
| --- | --- | --- |
| `success` | ✅ | ✅ |
| `error` | ✅ | ✅ |
| `fail` | ✅ actually rendered | normalized to `error` (the original value only works on Alipay and Douyin; undefined on other platforms) |
| `exception` | ✅ actually rendered | normalized to `error` (the original value only works on Alipay) |
| `warning` | ✅ actually rendered | falls back to `none` + leaves a trace via the fail callback (2001) |
| `loading` | ✅ | ✅ |
| `none` | ✅ | ✅ |

## ToastPosition

Toast position:

```ts
export type ToastPosition = 'top' | 'center' | 'bottom'
```

- The self-drawn channel (App / Web) supports all three values. Position semantics: `top` — the top edge is 10% from the top of the display area; `bottom` — the bottom edge is 10% from the bottom of the display area; `center` — centered (finalized in v0.7.2, consistent across all three platforms);
- Not supported on native-channel platforms (WeChat / HarmonyOS); falls back to center + leaves a trace via the fail callback (2001).

## ToastErrorCode

Toast error codes (a number literal union, aligned with the official error code pattern):

```ts
export type ToastErrorCode = 1001 | 2001
```

| Value | Constant | Meaning |
| --- | --- | --- |
| `1001` | `TOAST_ERR_PARAM_INVALID` | Invalid parameter (e.g. passing a gif as `image` on App) |
| `2001` | `TOAST_ERR_PLATFORM_UNSUPPORTED` | Platform unsupported: the parameter is not supported on the current platform and has been fallen back (informational; the toast still displays) |

## Related

- [ToastOptions](/en/api/type-toast-options) — usage scenarios for the fields
- [ToastFail](/en/api/type-toast-fail) — the consumer of these error codes

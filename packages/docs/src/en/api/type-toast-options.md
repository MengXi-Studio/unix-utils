# ToastOptions

The options type for `showToast` / `showToastAsync`, fully isomorphic with the parameters of `uni.showToast`. **All fields except `title` are optional fields** (since v0.8.1, it is safe for business code to omit optional fields).

## Type Definition

```ts
export type ToastOptions = {
	/** Message text */
	title: string
	/** Icon; omitted or null means the global default is used (success) */
	icon?: ToastIcon | null
	/** Local path of a custom icon image; omitted or null means none */
	image?: string | null
	/** Whether to show a transparent mask to prevent touch-through */
	mask?: boolean
	/** Toast display duration (ms); not clamped, passed through as-is */
	duration?: number
	/** Position; omitted or null means the position style is disabled (a centered plain toast) */
	position?: ToastPosition | null
	/** Success callback */
	success?: ((res: ToastResult) => void) | null
	/** Failure callback (including fallback notices) */
	fail?: ((err: ToastFail) => void) | null
	/** Completion callback (runs on both success and failure) */
	complete?: ((res: any) => void) | null
}
```

## Field Details

| Field | Type | Required | Default | Description & Per-Platform Behavior |
| --- | --- | --- | --- | --- |
| `title` | `string` | ✅ | — | Message text; truncated to 7 Chinese characters on WeChat / 20 characters on HarmonyOS (no truncation on the self-drawn channel) |
| `icon` | [ToastIcon](/en/api/type-enums#toasticon) \| `null` | ✗ | `'success'` | `fail` / `exception` are normalized to `error` on native channels; `warning` falls back to `none` on native channels |
| `image` | `string \| null` | ✗ | `null` | Local path of a custom icon image; the Web self-drawn channel supports gif; the App direct-attach channel does not render it yet (falls back to icon `none` + leaves a trace); on native channels, gif falls back on the App platform |
| `mask` | `boolean` | ✗ | `false` | Transparent mask prevents touch-through; on App the mask intercepts touches but does not consume the back button |
| `duration` | `number` | ✗ | `1500` | In milliseconds; passed through as-is without clamping; the actual granularity on native channels is constrained by the platform |
| `position` | [ToastPosition](/en/api/type-enums#toastposition) \| `null` | ✗ | `null` | `top` / `center` / `bottom` are all supported on the self-drawn channel; native channels fall back to center + leave a trace |
| `success` | `(res: [ToastResult](#toastresult)) => void` \| `null` | ✗ | `null` | Success callback |
| `fail` | `(err: [ToastFail](/en/api/type-toast-fail)) => void` \| `null` | ✗ | `null` | Failure callback (including fallback notices; errCode 2001 is informational) |
| `complete` | `(res: any) => void` \| `null` | ✗ | `null` | Completion callback (runs on both success and failure) |

## ToastResult

The result passed to the success callback, aligned with the native API:

```ts
export type ToastResult = {
	errMsg: string
}
```

## Related Types

- [ToastIcon / ToastPosition / ToastErrorCode](/en/api/type-enums)
- [ToastFail](/en/api/type-toast-fail)

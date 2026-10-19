# ModalOptions

The options type of `showModal` / `showModalAsync`, mirroring the `uni.showModal` parameters exactly. **Every field except the callbacks is optional** (only optional fields generate null-safe encoding in the proxy layer; the implementation layer uniformly null-checks and falls back).

## Type Definition

```ts
export type ModalOptions = {
	/** Title; at least one of title and content must be non-empty, otherwise fail 1001 */
	title?: string | null
	/** Content */
	content?: string | null
	/** Whether to show the cancel button, default true */
	showCancel?: boolean
	/** Cancel button text, default '取消'; truncated in-library beyond 4 characters on WeChat / HarmonyOS */
	cancelText?: string | null
	/** Cancel button color (hexadecimal); invalid values fall back to the platform default color */
	cancelColor?: string | null
	/** Confirm button text, default '确定'; truncated in-library beyond 4 characters on WeChat / HarmonyOS */
	confirmText?: string | null
	/** Confirm button color (hexadecimal); invalid values fall back to the platform default color */
	confirmColor?: string | null
	/** Whether the dialog is editable, default false */
	editable?: boolean
	/** Input placeholder text (takes effect when editable is true) */
	placeholderText?: string | null
	/** Success callback */
	success?: ((res: ModalResult) => void) | null
	/** Failure callback (including fallback notices) */
	fail?: ((err: ModalFail) => void) | null
	/** Completion callback (runs on both success and failure) */
	complete?: ((res: any) => void) | null
}
```

## Field Reference

| Field | Type | Required | Default | Description & per-platform behavior |
| --- | --- | --- | --- | --- |
| `title` | `string \| null` | ✗ | — | Title; at least one of `title` and `content` must be non-empty, otherwise `fail` 1001 (`param: 'title'`) |
| `content` | `string \| null` | ✗ | — | Content; doubles as the input's initial value when `editable` (cursor at the end on the App / Web self-drawn channels, cursor position decided by the platform on WeChat / HarmonyOS native channels) |
| `showCancel` | `boolean` | ✗ | `true` | Whether to show the cancel button; `false` gives a single-confirm-button (alert form) |
| `cancelText` / `confirmText` | `string \| null` | ✗ | `'取消'` / `'确定'` | Button texts; truncated in-library beyond 4 characters on WeChat / HarmonyOS (silent), full display on App / Web |
| `cancelColor` / `confirmColor` | `string \| null` | ✗ | Platform default | Button colors; only hexadecimal is accepted: `#RGB` expanded, `#RRGGBB`, `#RRGGBBAA` (alpha fully effective on the App / Web self-drawn channels, stripped with a trace on WeChat / HarmonyOS native channels); invalid values fall back to the platform default color + `fail` trace (2001); `null` passes through the platform default color (Web self-drawn falls back to `'#000000'` / `'#007aff'`) |
| `editable` | `boolean` | ✗ | `false` | Whether the dialog is editable; the App / Web self-drawn channels really render an input (`content` as the initial value, cursor at the end) |
| `placeholderText` | `string \| null` | ✗ | `null` | Input placeholder text (takes effect when `editable` is `true`) |
| `success` | `(res: [ModalResult](#modalresult)) => void` \| `null` | ✗ | `null` | Success callback (both confirm / cancel taps go here) |
| `fail` | `(err: [ModalFail](/en/api/type-modal-fail)) => void` \| `null` | ✗ | `null` | Failure callback (including fallback notices; errCode 2001 is informational) |
| `complete` | `(res: any) => void` \| `null` | ✗ | `null` | Completion callback (runs on both success and failure) |

## ModalResult

The success callback result; in-library normalization guarantees `confirm` / `cancel` are always present and mutually exclusive:

```ts
export type ModalResult = {
	/** Whether the confirm button was tapped */
	confirm: boolean
	/** Whether the cancel button was tapped / the dialog was closed by the Android back button */
	cancel: boolean
	/** The text entered by the user when editable is true; always null when not editable */
	content: string | null
}
```

`content` only carries the input when `editable: true` and confirm was tapped (an empty string if nothing was entered); it is always `null` when not `editable` or on cancel.

## Related Types

- [ModalFail](/en/api/type-modal-fail)

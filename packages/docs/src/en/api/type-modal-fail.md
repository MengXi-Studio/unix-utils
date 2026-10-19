# ModalFail

The modal failure structure. More structured than the native `errCode` + `errMsg`: it carries "which parameter, which platform", so both fallbacks and errors can be precisely perceived. Import it via `import type { ModalFail } from '@/uni_modules/unix-utils'` for annotating Promise `catch` callbacks and accessing fields.

## Type Definition

```ts
export type ModalFail = {
	/** Error code */
	errCode: ModalErrorCode
	/** Fixed subject, easy for business filtering */
	errSubject: string
	/** Error description */
	errMsg: string
	/** The parameter name that triggered the problem (e.g. 'confirmColor' / 'title'), null if none */
	param: string | null
	/** The current platform identifier ('app-android' / 'web' / 'mp-weixin' / ...) */
	platform: string
}
```

where `ModalErrorCode` is a numeric literal union:

```ts
export type ModalErrorCode = 1001 | 2001
```

## Field Reference

| Field | Type | Description |
| --- | --- | --- |
| `errCode` | `ModalErrorCode` | `1001` invalid parameter / `2001` platform unsupported (fallen back, informational) |
| `errSubject` | `string` | Fixed to `'unix-utils:modal'`, so business code can filter unix-utils failure notices by it |
| `errMsg` | `string` | Human-readable error description |
| `param` | `string \| null` | The parameter name that triggered the problem, e.g. `'confirmColor'` / `'title'`; `null` when a native API call fails with no corresponding parameter |
| `platform` | `string` | The current platform identifier, e.g. `'app-android'` / `'web'` / `'mp-weixin'` |

## Error Codes

| Value | Meaning | Trigger scenarios |
| --- | --- | --- |
| `1001` | Invalid parameter | Both `title` and `content` are empty (`param: 'title'`, no dialog shown); native API call failure (`param: null`, native `errMsg` passed through) |
| `2001` | Parameter unsupported on the current platform, fallen back (informational) | Invalid color (falls back to the platform default color, `param` names the field); 8-digit alpha color on WeChat / HarmonyOS native channels (alpha stripped, `param` names the field) |

> Unlike toast, modal does not export error-code constants at the entry — compare against the literals `1001` / `2001` directly (the type is a literal union, so values other than 1001 / 2001 cannot pass type checking).

## Example

```ts
import { showModal, showModalAsync } from '@/uni_modules/unix-utils'

// Callback style
showModal({
	title: '提示',
	content: '继续操作',
	confirmColor: 'blue', // invalid color (not hexadecimal)
	fail: (err) => {
		// err.errCode=2001, err.param='confirmColor'
		console.warn(`parameter ${err.param} fell back on ${err.platform}`)
	}
})

// Promise style (both invalid parameters and fallbacks reject; the rejection value is a JSON string of the ModalFail structure)
try {
	const res = await showModalAsync({ title: '', content: '' })
} catch (err) {
	const fail = JSON.parse<ModalFail>(err as string)
	if (fail != null) {
		// fail.errCode=1001, fail.param='title'
		console.error(fail.errSubject, fail.errCode, fail.errMsg)
	}
}
```

## Related Types

- [ModalOptions / ModalResult](/en/api/type-modal-options)

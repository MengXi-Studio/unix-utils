# showModalAsync()

The Promise-based version of `showModal()`: it resolves with [ModalResult](/en/api/type-modal-options#modalresult) once the user interaction finishes, and rejects with a JSON string of the [ModalFail](/en/api/type-modal-fail) structure when the call itself fails (unified across all platforms; business code restores it via `JSON.parse<ModalFail>(err as string)`). Internally it reuses the same normalization and dispatch pipeline, only wrapping the callbacks.

This differs deliberately from `showToastAsync` (`Promise<void>`): the successful result of a modal is the interaction result, which business code must obtain — hence the resolve value is `ModalResult` rather than void.

## Type

```ts
export const showModalAsync: (options: ModalOptions) => Promise<ModalResult>
```

## Parameters

### options: ModalOptions

Identical to [showModal()](/en/api/show-modal#options-modaloptions).

## Return Value

- **resolve**: the user finished the interaction (tapping confirm or cancel both count as success) — tapping cancel resolves `{ confirm: false, cancel: true, content: null }`, consistent with uni's "cancel is not a failure" semantics;
- **reject**: the API call itself failed — invalid parameters (errCode 1001) or parameter fallbacks (errCode 2001, e.g. an invalid color); the rejection value is a JSON string of the `ModalFail` structure (unified across all platforms).

## Example

```ts
import { showModalAsync } from '@/uni_modules/unix-utils'

try {
	const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
	if (res.confirm) save()
} catch (err) {
	const fail = JSON.parse<ModalFail>(err as string)
	if (fail != null) {
		console.error(`modal 失败：errCode=${fail.errCode} param=${fail.param} platform=${fail.platform}`)
	}
}
```

## Notes

- **Canceling does not count as failure**: `confirm: false, cancel: true` resolves normally; no try/catch is needed to distinguish it;
- **Fallbacks also reject**: unlike toast, a modal's fallback notice (2001, e.g. an invalid color) goes through reject — the dialog still shows in its fallback form, but the Promise settles with a JSON string of the `ModalFail` structure;
- UTS supports Promise on all platforms, so this API works on all five platforms.

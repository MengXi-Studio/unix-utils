# showModal()

Shows a full-platform compatible modal dialog. The API shape mirrors `uni.showModal` exactly — zero migration cost; each platform is dispatched automatically through its channel, see [Channel Architecture and Fallback](/en/guide/channels).

## Type

```ts
export const showModal: (options: ModalOptions) => void
```

## Parameters

### options: ModalOptions

See [ModalOptions](/en/api/type-modal-options) for all fields. Every field except the callbacks is optional; at least one of `title` and `content` must be non-empty.

## Return Value

None (results are returned through the `success` / `fail` / `complete` callbacks). Tapping cancel **does not count as failure** — it goes through `success` (`confirm: false, cancel: true`), consistent with uni semantics.

## Example

```ts
import { showModal } from '@/uni_modules/unix-utils'

// Minimal call
showModal({ title: '提示', content: '是否继续？' })

// Full parameters
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	showCancel: true,
	cancelText: '再想想',
	confirmText: '删除',
	confirmColor: '#ff0000',
	success: (res) => {
		// confirm / cancel are always present and mutually exclusive
		if (res.confirm) doDelete()
	},
	fail: (err) => {
		// fallback notice or parameter error; see ModalFail for structured info
		console.error(err.errCode, err.param, err.platform)
	}
})
```

## Notes

- **Constant return values**: `ModalResult`'s `confirm` / `cancel` are always present and mutually exclusive (eliminating the missing `cancel` field differences across platforms);
- **Color validation**: only hexadecimal values are accepted (`#RGB` / `#RRGGBB` / `#RRGGBBAA`); invalid values fall back to the platform default color with a trace via the `fail` callback (errCode 2001); 8-digit alpha colors are fully effective on the App / Web self-drawn channels, while WeChat / HarmonyOS native channels strip the alpha with a trace;
- **Interaction semantics**: mask taps never close the dialog (aligned with WeChat's official semantics); the Android back button closes it with cancel semantics (`cancel: true`); consecutive calls replace the previous dialog;
- **Text truncation**: button text beyond 4 characters is truncated in-library on WeChat / HarmonyOS (silent behavior, no `fail` notice); App / Web show it in full;
- **Parameter error**: when both `title` and `content` are empty, `fail` fires with 1001 (`param: 'title'`) and no dialog is shown;
- **Fallbacks**: see [Channel Architecture and Fallback](/en/guide/channels#modal-normalization-matrix).

## See Also

- [showModalAsync()](/en/api/show-modal-async) — Promise-based version
- [showModalAlert()](/en/api/show-modal-alert) — single-confirm-button alert semantics

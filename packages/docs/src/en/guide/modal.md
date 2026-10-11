# Modal

modal is the second module of unix-utils: a full-platform compatibility wrapper around `uni.showModal`. This page covers every usage pattern and caveat for daily work.

## Basic Usage

```ts
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel are always present and mutually exclusive
	}
})
```

The parameters mirror `uni.showModal` exactly (`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete`) — zero migration cost. Every field except the callbacks is optional; see [ModalOptions](/en/api/type-modal-options) for the full field table.

## Constant Return Values

The native `uni.showModal` return values are inconsistent across platforms (the `cancel` field is missing on some platforms). unix-utils normalizes this in-library so `ModalResult` behaves identically everywhere:

- `confirm` / `cancel` are **always present and mutually exclusive**: tapping confirm gives `{ confirm: true, cancel: false }`, tapping cancel gives `{ confirm: false, cancel: true }`;
- `content` only carries the entered text when `editable: true` and confirm was tapped; it is always `null` otherwise.

## Buttons

```ts
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	showCancel: true,        // default true; false gives a single-confirm-button (alert form)
	cancelText: '再想想',
	confirmText: '删除',
	cancelColor: '#666666',
	confirmColor: '#ff0000'
})
```

Text defaults to `'取消'` / `'确定'` (exported constants `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_TEXT`). Colors default to passing through the platform default color (Web self-drawn falls back to `'#000000'` / `'#007aff'`, exported constants `DEFAULT_CANCEL_COLOR` / `DEFAULT_CONFIRM_COLOR`).

## Colors

Button colors only accept hexadecimal; each form is normalized in-library:

| Input | App / WeChat / HarmonyOS native channel | Web self-drawn channel |
| --- | --- | --- |
| `#RGB` | ✅ Expanded to `#RRGGBB` | ✅ Expanded to `#RRGGBB` |
| `#RRGGBB` | ✅ Applied directly | ✅ Applied directly |
| `#RRGGBBAA` | ⚠️ Alpha stripped then applied, `fail` trace (errCode 2001) | ✅ Alpha preserved |
| Invalid values (named colors / missing `#` / wrong length / non-hex characters) | ⚠️ Falls back to the platform default color, trace (2001, `param` names the field) | ⚠️ Falls back to the built-in default color, trace (2001) |

Basis from M0 testing: 8-digit colors and named colors silently fall back to the default color on native platforms without errors — the library validates explicitly so fallbacks are perceivable.

## Text Length

The App / Web channels have no truncation; everything takes effect. Button text beyond 4 characters on the WeChat / HarmonyOS native channels is truncated in-library (aligned with the uni official constraint). Truncation is a **silent behavior** (it does not trigger a `fail` notice) and keeps the visuals intact.

## Editable Input

```ts
showModal({
	title: '重命名',
	editable: true,
	content: '未命名文件夹',   // native channels: doubles as the input's initial value
	placeholderText: '请输入名称',
	success: (res) => {
		if (res.confirm) rename(res.content) // the entered text; always null on cancel
	}
})
```

- App / WeChat / HarmonyOS native channels: `content` doubles as the input's initial value (uni native behavior);
- Web self-drawn channel: a real `<input>` is rendered; `content` still shows as text and the input starts empty (a presentation-layer difference, see [Channels](/en/guide/channels#modal-normalization-matrix));
- `placeholderText` only takes effect when `editable: true`.

## Promise Style and alert Semantics

```ts
// Promise style: tapping confirm / cancel both resolve; failures reject with a JSON string of the ModalFail structure (unified across all platforms, restored via JSON.parse<ModalFail>)
const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
if (res.confirm) save()

// Single-confirm-button dialog (showCancel: false, aligned with HTML alert semantics)
showModalAlert('提示', '操作已完成')
```

Note the difference from toast: a modal's fallback notice (2001) does **reject** under the Promise form (the dialog still shows in its fallback form); tapping cancel does not count as failure and resolves normally. See [showModalAsync()](/en/api/show-modal-async) for details.

## Global Default Configuration

```ts
import { configureModal } from '@/uni_modules/unix-utils'

configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,   // keep the library built-in default '取消'
	cancelColor: null   // restore passing through the platform default color
})
```

- When `showModal` omits a field, the global default is used; when the global default is unset, the library built-in default text / platform default color is used;
- Global defaults only affect default values; they do not change any fallback behavior.

## Lifecycle

- App / WeChat / HarmonyOS go through the `uni.showModal` native channel: a page-level modal that blocks interaction until the user taps;
- The Web self-drawn channel is a DOM singleton (mask + centered card) that survives within the SPA; tapping the mask does not close it — only the buttons do.

## Next Steps

- When each fallback happens and how business code perceives it: [Channel Architecture and Fallback](./channels);
- The full type definition of every parameter: [ModalOptions](/en/api/type-modal-options).

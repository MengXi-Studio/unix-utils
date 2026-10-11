# showModalAlert()

Shows a single-confirm-button dialog (alert semantics), aligned with HTML `alert()`. It is the shorthand form of `showModal({ showCancel: false, ... })`.

## Type

```ts
export const showModalAlert: (title: string, content: string | null) => void
```

## Parameters

### title: string

The dialog title.

### content: string | null

The dialog content; may be `null` (title only). When both `title` and `content` are empty, it fails with a parameter error (fail 1001) — this API has no callbacks, so the dialog silently does not show.

## Return Value

None.

## Example

```ts
import { showModalAlert } from '@/uni_modules/unix-utils'

showModalAlert('提示', '操作已完成')
showModalAlert('版本更新', null)
```

## Notes

- Equivalent to `showModal({ title, content, showCancel: false })`; button texts and colors follow the global defaults ([configureModal](/en/api/configure-modal));
- No `success` / `fail` / `complete` callbacks — use [showModal()](/en/api/show-modal) and check `res.confirm` when you need to perceive the user's tap;
- modal has many parameters but few combinations, so the shortcut layer only converges on this single highest-frequency form (no showConfirm / showPrompt etc., to avoid API surface bloat).

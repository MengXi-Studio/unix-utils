# configureModal()

Sets the global default configuration for modal (a project-level preset). `showModal` calls that omit the corresponding fields will use these defaults.

## Type

```ts
export const configureModal: (defaults: ModalDefaults) => void
```

## Parameters

### defaults: ModalDefaults

| Field | Type | Description |
| --- | --- | --- |
| `confirmText` | `string \| null` | Default confirm button text; `null` keeps the library built-in default (`'确定'`) |
| `cancelText` | `string \| null` | Default cancel button text; `null` keeps the library built-in default (`'取消'`) |
| `confirmColor` | `string \| null` | Default confirm button color; `null` restores the "unset" state — the platform default color passes through (Web self-drawn falls back to `'#007aff'`) |
| `cancelColor` | `string \| null` | Default cancel button color; `null` restores the "unset" state — the platform default color passes through (Web self-drawn falls back to `'#000000'`) |

## Example

```ts
import { configureModal } from '@/uni_modules/unix-utils'

configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,    // keep the library built-in default '取消'
	cancelColor: null    // restore passing through the platform default color
})

// Later calls that omit the fields use the global defaults
showModal({ title: '提示', content: '已同步' }) // confirm button shows「知道了」(#00aa00)
```

## Priority

Call parameters > global defaults (configureModal) > library built-in defaults (`'确定'` / `'取消'`) / platform default colors.

## Notes

- Global defaults only affect **default values**; they do not change any fallback behavior (an invalid color passed into `configureModal` still falls back with a trace at call time);
- The `null` semantics of the color fields match the call parameters: `null` = pass through the platform default color, not "set some color";
- The exported constants `DEFAULT_CONFIRM_TEXT` / `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_COLOR` / `DEFAULT_CANCEL_COLOR` are exactly the library built-in defaults.

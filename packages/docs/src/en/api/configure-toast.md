# configureToast()

Sets the global default configuration for toasts (project-level presets); `showToast` calls that omit these fields will use the defaults configured here.

## Type

```ts
export const configureToast: (defaults: ToastDefaults) => void
```

## Parameters

### defaults: ToastDefaults

| Field | Type | Description |
| --- | --- | --- |
| `duration` | `number \| null` | Default display duration (ms); `null` means the library built-in default is kept (1500ms) |
| `icon` | [ToastIcon](/en/api/type-enums#toasticon) \| `null` | Default icon; `null` means the library built-in default is kept (`'success'`) |
| `mask` | `boolean \| null` | Whether to show the mask by default; `null` means the library built-in default is kept (`false`) |

## Example

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // default display duration
	icon: 'success', // default icon
	mask: false      // whether to show the mask by default
})

// Later calls that omit these fields use the global defaults
showToast({ title: '已保存' }) // icon=success duration=2000 mask=false
```

## Precedence

Call arguments > global defaults (configureToast) > library built-in defaults (1500ms / `'success'` / `false`).

## Notes

- Global defaults only affect **default values**; they do not change any fallback behavior;
- The corresponding exported constants `DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` are the library built-in default values.

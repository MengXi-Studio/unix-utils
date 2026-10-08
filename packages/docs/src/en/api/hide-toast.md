# hideToast()

Hides the currently visible toast.

## Type

```ts
export const hideToast: () => void
```

## Parameters

None.

## Example

```ts
import { showToast, hideToast } from '@/uni_modules/unix-utils'

showToast({ title: '正在处理…', icon: 'loading', duration: 0 })
// Hide it manually once your work is done
hideToast()
```

## Per-Platform Behavior

| Platform | Behavior |
| --- | --- |
| App direct-attach channel | Removes the attached view proactively and hides reliably |
| Web self-drawn channel | The DOM singleton fades out, then the mask resets; hides reliably |
| WeChat / HarmonyOS native channels | Best effort (passes `uni.hideToast()` through) |

For the native `uni.showToast`, position-style toasts are officially not supported for hiding; unix-utils removes this limitation on the self-drawn channel, so position-style toasts can also be hidden reliably.

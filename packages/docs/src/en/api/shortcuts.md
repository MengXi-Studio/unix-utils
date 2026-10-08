# Semantic Shortcut APIs

A second layer of wrappers around `showToast`, providing one-line calls for the three most common notification styles.

## Type

```ts
export const showToastSuccess: (title: string) => void
export const showToastError: (title: string) => void
export const showToastInfo: (title: string) => void
```

## Parameters

### title: string

The message text.

## Behavior Mapping

| API | Equivalent Call | Icon |
| --- | --- | --- |
| `showToastSuccess(title)` | `showToast({ title, icon: 'success' })` | Success |
| `showToastError(title)` | `showToast({ title, icon: 'error' })` | Error |
| `showToastInfo(title)` | `showToast({ title, icon: 'none' })` | No icon (text only) |

## Example

```ts
import { showToastSuccess, showToastError, showToastInfo } from '@/uni_modules/unix-utils'

showToastSuccess('已复制')
showToastError('网络异常')
showToastInfo('下拉刷新可更新列表')
```

## Notes

- The shortcut APIs go through the same normalization and channel dispatch pipeline, following the same rules as [Channel Architecture & Fallback](/en/guide/channels) (e.g. `icon: 'error'` on WeChat is unaffected — it is natively supported);
- When you need a custom duration / mask / position, use [showToast()](/en/api/show-toast) directly.

# 语义化快捷 API

对 `showToast` 的第二层封装，为最常见的三种提示提供一行调用。

## 类型

```ts
export const showToastSuccess: (title: string) => void
export const showToastError: (title: string) => void
export const showToastInfo: (title: string) => void
```

## 参数

### title: string

提示内容。

## 行为对照

| API | 等价调用 | 图标 |
| --- | --- | --- |
| `showToastSuccess(title)` | `showToast({ title, icon: 'success' })` | 成功 |
| `showToastError(title)` | `showToast({ title, icon: 'error' })` | 错误 |
| `showToastInfo(title)` | `showToast({ title, icon: 'none' })` | 无图标（纯文字） |

## 示例

```ts
import { showToastSuccess, showToastError, showToastInfo } from '@/uni_modules/unix-utils'

showToastSuccess('已复制')
showToastError('网络异常')
showToastInfo('下拉刷新可更新列表')
```

## 注意事项

- 快捷 API 同样走归一化与通道分发链路，[通道架构与降级](/guide/channels)规则一致（如微信端 `icon: 'error'` 不受影响，原生支持）；
- 需要自定义 duration / mask / position 时，直接用 [showToast()](/api/show-toast)。

# showModalAlert()

展示单确定按钮弹窗（alert 语义），对齐 HTML `alert()`。是 `showModal({ showCancel: false, ... })` 的快捷形态。

## 类型

```ts
export const showModalAlert: (title: string, content: string | null) => void
```

## 参数

### title: string

弹窗标题。

### content: string | null

弹窗内容；可为 `null`（仅标题）。`title` 与 `content` 均空时走参数错误（fail 1001，本 API 无回调，弹窗静默不显示）。

## 返回

无。

## 示例

```ts
import { showModalAlert } from '@/uni_modules/unix-utils'

showModalAlert('提示', '操作已完成')
showModalAlert('版本更新', null)
```

## 注意事项

- 等价于 `showModal({ title, content, showCancel: false })`，按钮文案与颜色遵循全局默认（[configureModal](/api/configure-modal)）；
- 无 `success` / `fail` / `complete` 回调——需要感知用户点击时，用 [showModal()](/api/show-modal) 并判断 `res.confirm`；
- modal 参数多、组合少，快捷层只收敛这一最高频形态（不做 showConfirm / showPrompt 等，避免 API 面膨胀）。

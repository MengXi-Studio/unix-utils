# showToastAsync()

`showToast()` 的 Promise 式版本：成功 resolve，失败 reject 结构化 [ToastFail](/api/type-toast-fail)。内部复用同一归一化与分发链路，仅包装回调。

## 类型

```ts
export const showToastAsync: (options: ToastOptions) => Promise<void>
```

## 参数

### options: ToastOptions

与 [showToast()](/api/show-toast#options-toastoptions) 完全一致。

## 返回

- **resolve**：toast 正常显示（含参数降级场景——降级是信息级通知，不 reject）；
- **reject**：参数错误等真正失败，reject 值为 `ToastFail` 结构。

## 示例

```ts
import { showToastAsync } from '@/uni_modules/unix-utils'

try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
	// toast 已显示
} catch (err) {
	console.error(`toast 失败：errCode=${err.errCode} param=${err.param} platform=${err.platform}`)
}
```

## 注意事项

- 参数降级（如微信端传 `position: 'top'`）走 `fail` 回调语义时**不会 reject**——降级后 toast 照常显示，属信息级通知；需要感知降级时用回调式 [showToast()](/api/show-toast) 读取 `fail` 回调；
- UTS 全端支持 Promise，五端可用。

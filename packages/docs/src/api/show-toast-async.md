# showToastAsync()

`showToast()` 的 Promise 式版本：成功 resolve，失败 reject [ToastFail](/api/type-toast-fail) 结构的 JSON 字符串（全端统一，业务侧 `JSON.parse<ToastFail>(err as string)` 还原）。内部复用同一归一化与分发链路，仅包装回调。

## 类型

```ts
export const showToastAsync: (options: ToastOptions) => Promise<void>
```

## 参数

### options: ToastOptions

与 [showToast()](/api/show-toast#options-toastoptions) 完全一致。

## 返回

- **resolve**：toast 正常显示；
- **reject**：调用链路上任何 `fail` 回调触发都会 reject——参数错误（errCode 1001）与参数降级（errCode 2001）均会 reject，reject 值为 `ToastFail` 结构的 JSON 字符串（全端统一）。

## 示例

```ts
import { showToastAsync } from '@/uni_modules/unix-utils'

try {
	await showToastAsync({ title: '加载中', icon: 'loading' })
	// toast 已显示
} catch (err) {
	const fail = JSON.parse<ToastFail>(err as string)
	if (fail != null) {
		console.error(`toast 失败：errCode=${fail.errCode} param=${fail.param} platform=${fail.platform}`)
	}
}
```

## 注意事项

- **降级也会 reject**：参数降级（如微信端传 `position: 'top'`，errCode 2001）触发 `fail` 回调时 Promise 同样 reject——降级后 toast 照常显示，属信息级通知，业务捕获后可选择忽略；不想处理降级异常时，用回调式 [showToast()](/api/show-toast) 读取 `fail` 回调；
- UTS 全端支持 Promise，五端可用。

# showModalAsync()

`showModal()` 的 Promise 式版本：用户交互结束 resolve [ModalResult](/api/type-modal-options#modalresult)，调用失败 reject [ModalFail](/api/type-modal-fail) 结构的 JSON 字符串（全端统一，业务侧 `JSON.parse<ModalFail>(err as string)` 还原）。内部复用同一归一化与分发链路，仅包装回调。

与 `showToastAsync`（`Promise<void>`）的刻意差异：modal 的成功结果即交互结果，业务必须拿到，故 resolve 值为 `ModalResult` 而非 void。

## 类型

```ts
export const showModalAsync: (options: ModalOptions) => Promise<ModalResult>
```

## 参数

### options: ModalOptions

与 [showModal()](/api/show-modal#options-modaloptions) 完全一致。

## 返回

- **resolve**：用户完成交互（点确认或点取消都算成功）——点取消 resolve `{ confirm: false, cancel: true, content: null }`，与 uni「取消不属于失败」语义一致；
- **reject**：API 调用本身失败——参数非法（errCode 1001）或参数降级（errCode 2001，如非法颜色），reject 值为 `ModalFail` 结构的 JSON 字符串（全端统一）。

## 示例

```ts
import { showModalAsync } from '@/uni_modules/unix-utils'

try {
	const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
	if (res.confirm) save()
} catch (err) {
	const fail = JSON.parse<ModalFail>(err as string)
	if (fail != null) {
		console.error(`modal 失败：errCode=${fail.errCode} param=${fail.param} platform=${fail.platform}`)
	}
}
```

## 注意事项

- **点取消不算失败**：`confirm: false, cancel: true` 正常 resolve，无需 try/catch 区分；
- **降级会 reject**：与 toast 不同，modal 的降级通知（2001，如非法颜色降级）走 reject——弹窗仍会以降级后的形态显示，但 Promise 以 `ModalFail` 结构的 JSON 字符串收尾；
- UTS 全端支持 Promise，五端可用。

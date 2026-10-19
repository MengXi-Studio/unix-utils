# ModalFail

modal 失败结构。比原生 `errCode` + `errMsg` 更结构化：携带「哪个参数、哪个端」，降级与错误业务均可精确感知。可通过 `import type { ModalFail } from '@/uni_modules/unix-utils'` 引入，用于 Promise `catch` 回调标注与字段访问。

## 类型定义

```ts
export type ModalFail = {
	/** 错误码 */
	errCode: ModalErrorCode
	/** 固定主题，便于业务过滤 */
	errSubject: string
	/** 错误描述 */
	errMsg: string
	/** 触发问题的参数名（如 'confirmColor' / 'title'），无则 null */
	param: string | null
	/** 当前端标识（'app-android' / 'web' / 'mp-weixin' / ...） */
	platform: string
}
```

其中 `ModalErrorCode` 为数字字面量联合：

```ts
export type ModalErrorCode = 1001 | 2001
```

## 字段说明

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `errCode` | `ModalErrorCode` | `1001` 参数非法 / `2001` 平台不支持（已降级，信息级） |
| `errSubject` | `string` | 固定为 `'unix-utils:modal'`，业务可据此过滤 unix-utils 的失败通知 |
| `errMsg` | `string` | 人类可读的错误描述 |
| `param` | `string \| null` | 触发问题的参数名，如 `'confirmColor'` / `'title'`；原生 API 调用失败时无对应参数，为 `null` |
| `platform` | `string` | 当前端标识，如 `'app-android'` / `'web'` / `'mp-weixin'` |

## 错误码

| 值 | 含义 | 触发场景 |
| --- | --- | --- |
| `1001` | 参数非法 | `title` 与 `content` 均为空（`param: 'title'`，弹窗不显示）；原生 API 调用失败（`param: null`，透传原生 `errMsg`） |
| `2001` | 参数当前端不支持且已降级（信息级） | 颜色非法（降级平台默认色，`param` 指明字段）；8 位 alpha 色在微信 / 鸿蒙原生通道（剥离 alpha，`param` 指明字段） |

> 与 toast 不同，modal 未在入口导出错误码常量，业务直接比较字面量 `1001` / `2001` 即可（类型为字面量联合，非 1001 / 2001 的值无法通过类型检查）。

## 示例

```ts
import { showModal, showModalAsync } from '@/uni_modules/unix-utils'

// 回调式
showModal({
	title: '提示',
	content: '继续操作',
	confirmColor: 'blue', // 非法颜色（非 16 进制）
	fail: (err) => {
		// err.errCode=2001, err.param='confirmColor'
		console.warn(`参数 ${err.param} 在 ${err.platform} 已降级`)
	}
})

// Promise 式（参数非法与降级都会 reject，值为 ModalFail 结构的 JSON 字符串）
try {
	const res = await showModalAsync({ title: '', content: '' })
} catch (err) {
	const fail = JSON.parse<ModalFail>(err as string)
	if (fail != null) {
		// fail.errCode=1001, fail.param='title'
		console.error(fail.errSubject, fail.errCode, fail.errMsg)
	}
}
```

## 相关类型

- [ModalOptions / ModalResult](/api/type-modal-options)

# ModalOptions

`showModal` / `showModalAsync` 的选项类型，与 `uni.showModal` 参数完全同构。**除回调外均为可选字段**（可选字段代理层才生成 null-safe 编码，实现层统一判空兜底）。

## 类型定义

```ts
export type ModalOptions = {
	/** 标题；与 content 至少其一非空，均空 fail 1001 */
	title?: string | null
	/** 内容 */
	content?: string | null
	/** 是否显示取消按钮，默认 true */
	showCancel?: boolean
	/** 取消按钮文案，默认 '取消'；微信 / 鸿蒙超 4 字符库内截断 */
	cancelText?: string | null
	/** 取消按钮颜色（16 进制），非法值降级平台默认色 */
	cancelColor?: string | null
	/** 确认按钮文案，默认 '确定'；微信 / 鸿蒙超 4 字符库内截断 */
	confirmText?: string | null
	/** 确认按钮颜色（16 进制），非法值降级平台默认色 */
	confirmColor?: string | null
	/** 是否可输入，默认 false */
	editable?: boolean
	/** 输入框占位文本（editable 为 true 时生效） */
	placeholderText?: string | null
	/** 成功回调 */
	success?: ((res: ModalResult) => void) | null
	/** 失败回调（含降级通知） */
	fail?: ((err: ModalFail) => void) | null
	/** 结束回调（成功或失败都执行） */
	complete?: ((res: any) => void) | null
}
```

## 字段说明

| 字段 | 类型 | 必填 | 默认 | 说明与各端行为 |
| --- | --- | --- | --- | --- |
| `title` | `string \| null` | ✗ | — | 标题；与 `content` 至少其一非空，均空 `fail` 1001（`param: 'title'`） |
| `content` | `string \| null` | ✗ | — | 内容；`editable` 时兼作输入框初始值（App / Web 自绘通道光标定位末尾，微信 / 鸿蒙原生通道光标位置由平台决定） |
| `showCancel` | `boolean` | ✗ | `true` | 是否显示取消按钮；`false` 时为单确定按钮（alert 形态） |
| `cancelText` / `confirmText` | `string \| null` | ✗ | `'取消'` / `'确定'` | 按钮文案；微信 / 鸿蒙超 4 字符库内自动截断（静默），App / Web 完整显示 |
| `cancelColor` / `confirmColor` | `string \| null` | ✗ | 平台默认 | 按钮颜色，仅接受 16 进制：`#RGB` 展开、`#RRGGBB`、`#RRGGBBAA`（alpha 在 App / Web 自绘通道全生效，微信 / 鸿蒙原生通道剥离并留痕）；非法值降级平台默认色 + `fail` 留痕（2001）；`null` 透传平台默认色（Web 自绘回退 `'#000000'` / `'#007aff'`） |
| `editable` | `boolean` | ✗ | `false` | 是否可输入；App / Web 自绘通道真实渲染输入框（`content` 兼作初始值、光标定位末尾） |
| `placeholderText` | `string \| null` | ✗ | `null` | 输入框占位文本（`editable` 为 `true` 时生效） |
| `success` | `(res: [ModalResult](#modalresult)) => void` \| `null` | ✗ | `null` | 成功回调（点确认 / 点取消都走这里） |
| `fail` | `(err: [ModalFail](/api/type-modal-fail)) => void` \| `null` | ✗ | `null` | 失败回调（含降级通知，errCode 2001 为信息级） |
| `complete` | `(res: any) => void` \| `null` | ✗ | `null` | 结束回调（成功或失败都执行） |

## ModalResult

成功回调结果，库内归一化保证 `confirm` / `cancel` 恒存在且互斥：

```ts
export type ModalResult = {
	/** 是否点击了确认按钮 */
	confirm: boolean
	/** 是否点击了取消按钮 / Android 返回键关闭 */
	cancel: boolean
	/** editable 为 true 时用户输入的文本；非 editable 恒 null */
	content: string | null
}
```

`content` 仅在 `editable: true` 且点击确认时携带输入（未输入为空字符串）；非 `editable` 或点取消恒为 `null`。

## 相关类型

- [ModalFail](/api/type-modal-fail)

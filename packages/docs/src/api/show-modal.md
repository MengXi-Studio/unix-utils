# showModal()

显示一个全端兼容的模态弹窗。API 形态与 `uni.showModal` 完全同构，迁移零成本；各端通过通道自动分发，见[通道架构与降级](/guide/channels)。

## 类型

```ts
export const showModal: (options: ModalOptions) => void
```

## 参数

### options: ModalOptions

完整字段见 [ModalOptions](/api/type-modal-options)。除回调外均为可选字段；`title` 与 `content` 至少其一非空。

## 返回

无（结果经 `success` / `fail` / `complete` 回调返回）。点击取消**不属于失败**——走 `success`（`confirm: false, cancel: true`），与 uni 语义一致。

## 示例

```ts
import { showModal } from '@/uni_modules/unix-utils'

// 最简调用
showModal({ title: '提示', content: '是否继续？' })

// 完整参数
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	showCancel: true,
	cancelText: '再想想',
	confirmText: '删除',
	confirmColor: '#ff0000',
	success: (res) => {
		// confirm / cancel 恒存在且互斥
		if (res.confirm) doDelete()
	},
	fail: (err) => {
		// 降级通知或参数错误，结构化信息见 ModalFail
		console.error(err.errCode, err.param, err.platform)
	}
})
```

## 注意事项

- **返回值恒定**：`ModalResult` 的 `confirm` / `cancel` 恒存在且互斥（消除各端 `cancel` 字段缺失差异）；
- **颜色校验**：仅接受 16 进制（`#RGB` / `#RRGGBB` / `#RRGGBBAA`），非法值降级平台默认色并经 `fail` 回调留痕（errCode 2001）；8 位 alpha 色在 App / Web 自绘通道全生效，微信 / 鸿蒙原生通道剥离 alpha 并留痕；
- **交互语义**：蒙层点击不关闭（对齐微信官方语义）；Android 返回键以取消语义关闭（`cancel: true`）；连续调用时后一次调用替换前一次弹窗；
- **文案截断**：微信 / 鸿蒙按钮文案超 4 字符库内自动截断（静默行为，无 `fail` 通知），App / Web 完整显示；
- **参数错误**：`title` 与 `content` 均为空时 `fail` 1001（`param: 'title'`），弹窗不显示；
- **降级**：详见[通道架构与降级](/guide/channels#modal-参数抹平矩阵)。

## 另见

- [showModalAsync()](/api/show-modal-async) —— Promise 式版本
- [showModalAlert()](/api/show-modal-alert) —— 单确定按钮 alert 语义

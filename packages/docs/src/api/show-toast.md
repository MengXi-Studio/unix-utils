# showToast()

显示一个全端兼容的 toast 提示。API 形态与 `uni.showToast` 完全同构，迁移零成本；各端通过通道自动分发，见[通道架构与降级](/guide/channels)。

## 类型

```ts
export const showToast: (options: ToastOptions) => void
```

## 参数

### options: ToastOptions

完整字段见 [ToastOptions](/api/type-toast-options)。除 `title` 外均为可选字段。

## 返回

无（结果经 `success` / `fail` / `complete` 回调返回）。

## 示例

```ts
import { showToast } from '@/uni_modules/unix-utils'

// 最简调用
showToast({ title: '保存成功' })

// 完整参数
showToast({
	title: '已同步到云端',
	icon: 'success',
	duration: 2000,
	mask: false,
	position: 'top',
	success: (res) => {
		console.log(res.errMsg)
	},
	fail: (err) => {
		// 降级通知或参数错误，结构化信息见 ToastFail
		console.error(err.errCode, err.param, err.platform)
	}
})
```

## 注意事项

- **连续调用**：后者替换前者（与微信一致）；App 直挂通道同 mask 同 position 时复用窗口仅更新内容；
- **duration 不钳制**：原样透传，自绘通道以计时器精确控制；
- **降级**：原生通道端（微信 / 鸿蒙）不支持的参数自动降级并经 `fail` 回调留痕（errCode 2001），详见[通道架构与降级](/guide/channels#降级感知-fail-回调)。

## 另见

- [showToastAsync()](/api/show-toast-async) —— Promise 式版本
- [语义化快捷 API](/api/shortcuts) —— success / error / info 一行调用

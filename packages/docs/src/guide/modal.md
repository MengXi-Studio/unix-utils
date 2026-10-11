# Modal 弹窗

modal 是 unix-utils 的第二个模块：对 `uni.showModal` 的全端兼容封装。本页覆盖日常使用的全部姿势与注意点。

## 基本用法

```ts
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel 恒存在且互斥
	}
})
```

参数与 `uni.showModal` 完全同构（`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete`），迁移零成本。除回调外均为可选字段，完整字段表见 [ModalOptions](/api/type-modal-options)。

## 返回值恒定

原生 `uni.showModal` 各端返回值不齐（部分端不返回 `cancel` 字段）。unix-utils 库内归一化，`ModalResult` 三端表现一致：

- `confirm` / `cancel` **恒存在且互斥**：点确认 `{ confirm: true, cancel: false }`，点取消 `{ confirm: false, cancel: true }`；
- `content` 仅 `editable: true` 且点确认时携带输入文本，其余场景恒 `null`。

## 按钮

```ts
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	showCancel: true,        // 默认 true；false 时为单确定按钮（alert 形态）
	cancelText: '再想想',
	confirmText: '删除',
	cancelColor: '#666666',
	confirmColor: '#ff0000'
})
```

文案默认 `'取消'` / `'确定'`（导出常量 `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_TEXT`）。颜色默认透传平台默认色（Web 自绘回退 `'#000000'` / `'#007aff'`，导出常量 `DEFAULT_CANCEL_COLOR` / `DEFAULT_CONFIRM_COLOR`）。

## 颜色

按钮颜色仅接受 16 进制，各形态由库内归一化处理：

| 传入值 | App / 微信 / 鸿蒙原生通道 | Web 自绘通道 |
| --- | --- | --- |
| `#RGB` | ✅ 展开为 `#RRGGBB` | ✅ 展开为 `#RRGGBB` |
| `#RRGGBB` | ✅ 直接生效 | ✅ 直接生效 |
| `#RRGGBBAA` | ⚠️ 剥离 alpha 生效，`fail` 回调留痕（errCode 2001） | ✅ alpha 保留 |
| 非法值（命名色 / 缺 `#` / 长度不对 / 非 hex 字符） | ⚠️ 降级平台默认色，留痕（2001，`param` 指明字段） | ⚠️ 回退内置默认色，留痕（2001） |

M0 实测依据：8 位色与命名色在原生平台静默回退默认色、不报错——库内显式校验，让降级可感知。

## 文案长度

App / Web 通道无截断，全生效；微信 / 鸿蒙原生通道按钮文案超 4 字符时库内自动截断（与 uni 官方约束对齐）。截断是**静默行为**（不触发 `fail` 通知），保证视觉不破。

## 可输入（editable）

```ts
showModal({
	title: '重命名',
	editable: true,
	content: '未命名文件夹',   // 原生通道：兼作输入框初始值
	placeholderText: '请输入名称',
	success: (res) => {
		if (res.confirm) rename(res.content) // 用户输入文本；点取消恒 null
	}
})
```

- App / 微信 / 鸿蒙原生通道：`content` 兼作输入框初始值（uni 原生行为）；
- Web 自绘通道：真实渲染 `<input>`，`content` 仍显示为文本、输入框初始为空（表现层差异，见[通道架构](/guide/channels#modal-参数抹平矩阵)）；
- `placeholderText` 仅 `editable: true` 时生效。

## Promise 式与 alert 语义

```ts
// Promise 式：点确认 / 点取消都 resolve，失败 reject ModalFail 结构的 JSON 字符串（全端统一，JSON.parse<ModalFail> 还原）
const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
if (res.confirm) save()

// 单确定按钮弹窗（showCancel: false，对齐 HTML alert 语义）
showModalAlert('提示', '操作已完成')
```

注意与 toast 的差异：modal 的降级通知（2001）在 Promise 式下会 **reject**（弹窗仍以降级形态显示）；点取消不算失败、正常 resolve。详见 [showModalAsync()](/api/show-modal-async)。

## 全局默认配置

```ts
import { configureModal } from '@/uni_modules/unix-utils'

configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,   // 沿用库内置默认 '取消'
	cancelColor: null   // 恢复透传平台默认色
})
```

- `showModal` 未传对应字段时使用全局默认；全局默认未设置时使用库内置默认文案 / 平台默认色；
- 全局默认只影响默认值，不改变任何降级行为。

## 生命周期

- App / 微信 / 鸿蒙走 `uni.showModal` 原生通道，弹窗为页面级模态，阻塞交互直至用户点击；
- Web 自绘通道为 DOM 单例（蒙层 + 居中卡片），SPA 内存活；蒙层点击不关闭，仅按钮可关闭。

## 下一步

- 了解每条降级何时发生、业务如何感知：[通道架构与降级](./channels)；
- 每个参数的完整类型定义：[ModalOptions](/api/type-modal-options)。

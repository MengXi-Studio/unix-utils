---
name: unix-utils
description: 在 uni-app x 项目中使用 @meng-xi/unix-utils（npm）或 unix-utils（uni_modules / 插件市场）实现 toast 提示与 modal 弹窗时使用。涵盖两种引入形态判定、toast / modal 全部 API 的正确写法、分端通道降级行为、fail 回调与 Promise reject 契约、UTS 强类型约束。
---

# unix-utils 使用技能

本库是 uni-app x 的 `uni.showToast` / `uni.showModal` 全端兼容封装，UTS 源码分发，编译期转 JS / Kotlin / Swift。两个模块：**toast**（7 个 API）与 **modal**（4 个 API）。按以下流程操作；需要完整字段与常量速查表时读 `references/api-quickref.md`。

## 1. 判定引入形态

先检查项目形态，决定 import 前置动作（同一项目禁止混用）：

- 项目存在 `uni_modules/unix-utils/` → 直接 `import { showToast } from '@/uni_modules/unix-utils'`
- 仅 `package.json` 有 `@meng-xi/unix-utils` 而 `uni_modules/` 下无目录 → **先同步再 import**（uni-app x 编译器不扫描 node_modules）：

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

例外：本仓库示例工程 `packages/playground` 的插件副本目录名为 `ux-utils`（`@/uni_modules/ux-utils`），在 playground 内写示例沿用该路径；业务项目一律 `@/uni_modules/unix-utils`。

## 2. 快速上手

```ts
import { showToast, showModal } from '@/uni_modules/unix-utils'

// toast：与 uni.showToast 同构，title 必填
showToast({ title: '保存成功', icon: 'success', duration: 2000 })

// modal：与 uni.showModal 同构，除回调外全可选
showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel 恒存在且互斥
	}
})
```

## 3. 任务配方

### 基础提示与位置控制

```ts
showToast({ title: '网络异常', icon: 'none', position: 'top' })
```

`icon` 取值：`'success' | 'error' | 'fail' | 'exception' | 'warning' | 'loading' | 'none'`；`position` 取值：`'top' | 'center' | 'bottom'`。微信 / 鸿蒙端 `warning` 降级 `none`、`position` 降级居中（均 2001 留痕）；App / Web 自绘通道全生效。

### 语义化快捷与手动隐藏

```ts
import { showToastSuccess, showToastError, showToastInfo, hideToast } from '@/uni_modules/unix-utils'

showToastSuccess('成功')
showToastError('失败')
showToastInfo('消息')

hideToast() // 自绘通道可靠隐藏（含原生不支持隐藏的 position 形态）
```

### Promise 式与降级感知

```ts
import { showToastAsync } from '@/uni_modules/unix-utils'
import type { ToastFail } from '@/uni_modules/unix-utils'

try {
	await showToastAsync({ title: '加载中', icon: 'loading' }) // 成功 resolve void
} catch (err) {
	// reject 值是 ToastFail 结构的 JSON 字符串（全端统一，0.2.0 起契约）
	const fail = JSON.parse<ToastFail>(err as string)
	if (fail != null) {
		console.error(fail.errCode, fail.param, fail.platform)
		// 2001 信息级（已降级、功能仍可用）可忽略；1001 真错误需修正参数
	}
}
```

回调式 `showToast` 的 fail 回调则直接收到结构化对象，无需 parse。

### 全局默认（toast）

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})
```

字段传 `null` 表示恢复库内置默认（1500ms / `'success'` / `false`）。

### 确认弹窗（modal 主流程）

```ts
import { showModal } from '@/uni_modules/unix-utils'

showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	showCancel: true,        // 默认 true；false 即单确定按钮
	cancelText: '再想想',
	confirmText: '删除',
	confirmColor: '#ff0000',
	success: (res) => {
		if (res.confirm) doDelete()
		else if (res.cancel) onCancelled() // 恒存在且互斥，直接判字段
	}
})
```

交互语义：蒙层点击不关闭（仅按钮可关闭）；Android 返回键以取消语义关闭（`cancel = true`）；连续调用后调替换前调。按钮文案微信 / 鸿蒙超 4 字符库内静默截断，建议 ≤ 4 字符。

### 单确定按钮（alert 语义）

```ts
import { showModalAlert } from '@/uni_modules/unix-utils'

showModalAlert('提示', '操作已完成') // title 必填，content 可选
```

### 输入弹窗（editable）

```ts
import { showModalAsync } from '@/uni_modules/unix-utils'
import type { ModalResult } from '@/uni_modules/unix-utils'

// 自绘通道（App / Web）：content 兼作输入框初始值，光标自动定位末尾
const res: ModalResult = await showModalAsync({
	title: '重命名',
	editable: true,
	content: '未命名文件夹',
	placeholderText: '请输入名称'
})
if (res.confirm && res.content != null) rename(res.content) // res.content 为 string | null，判空后使用；点取消恒 null
```

正文超过屏高 60%（内置阈值）自动限高滚动；微信 / 鸿蒙走原生 editable，光标位置不受控（表现层残余，文档已标注）。

### Promise 式确认与全局默认（modal）

```ts
import { showModalAsync, configureModal } from '@/uni_modules/unix-utils'
import type { ModalFail } from '@/uni_modules/unix-utils'

// 点取消不算失败（正常 resolve）；失败 reject ModalFail 结构的 JSON 字符串
const res = await showModalAsync({ title: '保存修改', content: '是否保存当前修改？' })
if (res.confirm) save()

configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,   // 传 null = 沿用库内置默认 '取消'
	cancelColor: null   // 传 null = 恢复透传平台默认色
})
```

### 降级与非法参数的 fail 处理

```ts
showModal({
	title: '提示',
	confirmColor: 'blue', // 非法颜色（命名色）：原生通道降级并留痕
	fail: (err) => {
		// errCode: 2001（PLATFORM_UNSUPPORTED）
		// param: 'confirmColor'
		// platform: 'mp-weixin'
	}
})
```

modal 特有：`title` 与 `content` 均为空走 fail 1001（`param: 'title'`），弹窗不显示。

## 4. UTS 强类型红线（写码时逐条自检）

1. `icon` / `position` / 错误码为字面量联合类型，直接传字面量，禁止自造字符串值
2. Promise 式 catch 中必须 `JSON.parse<ToastFail | ModalFail>(err as string)` 还原且判空（`fail != null`）后再访问字段；err 不是对象
3. `ModalResult` 的 `confirm` / `cancel` 恒存在互斥：判 `res.confirm` / `res.cancel`，勿写 `!res.confirm` 兜底
4. `editable` 场景的 `res.content` 类型为 `string | null`，使用前判空
5. 可空值用 `null` 禁止 `undefined`；条件语句必须布尔表达式，禁止 truthy / falsy 隐式判断
6. `import type` 引入类型：`ToastFail` / `ModalFail` / `ModalResult`
7. modal 颜色仅 16 进制（`#RGB` / `#RRGGBB` / `#RRGGBBAA`），传命名色会被降级并留痕
8. uni-app x 页面文件后缀 `.uvue`；可滚动内容放在 scroll-view 等滚动容器内

## 5. 错误排查

| 信号 | 处置 |
| --- | --- |
| import 模块找不到 | npm 装完未同步 uni_modules；先 `cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils` |
| Promise catch 拿不到 errCode | reject 值是 JSON 字符串：`JSON.parse` 还原 + 判空；0.1.0 的对象 reject 已废弃，升级 0.2.0+ |
| `icon: 'warning'` 无图标 | 微信 / 鸿蒙降级 `none`（2001）属预期；App / Web 自绘真实渲染 |
| `position: 'top'` 小程序居中 | 原生通道降级居中（2001）属预期；需生效用 App / Web |
| 按钮颜色透明度丢失 | 微信 / 鸿蒙剥 alpha 留痕（2001）；看 fail 回调确认端 |
| modal 不弹窗 | `title` / `content` 双空触发 fail 1001；至少传一项 |
| 按钮文案被截断 | 微信 / 鸿蒙超 4 字符库内静默截断属预期 |
| Android 返回键没走确认分支 | 返回键是取消语义（`cancel = true`），判 `res.confirm` |
| `showToastAsync` 0.1.0 升级后行为变化 | 0.2.0 起 reject 值改为 JSON 字符串（破坏性变更）；回调式 fail 不受影响 |

## 6. 深入资料

- 完整字段表 / 常量 / 通道矩阵 / 错误码：本技能目录 `references/api-quickref.md`
- 官方文档站与更新日志：仓库 `packages/docs`（`src/changelog.md`）
- 通道架构与降级设计：`packages/docs/src/guide/channels.md`
- 示例工程（12 页验证矩阵，带页内运行日志）：`packages/playground`

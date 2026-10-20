# unix-utils 使用规则

> 本文件面向 AI 编码助手。当项目引入了 `@meng-xi/unix-utils`（npm 包）或 `unix-utils`（uni_modules / 插件市场分发，导入路径 `@/uni_modules/unix-utils`）时，必须遵循以下约定编写代码。所有代码示例均为 UTS / uni-app x（uvue）语法。

## 1. 引入形态判定

两种形态 API 完全一致，仅 import 路径不同，同一项目禁止混用：

- npm 形态：`import { showToast } from '@/uni_modules/unix-utils'`——**npm 装完必须同步到 uni_modules**（uni-app x 编译器不扫描 node_modules）：`mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils`
- uni_modules / 插件市场形态：`import { showToast } from '@/uni_modules/unix-utils'`

判定方法：项目存在 `uni_modules/unix-utils/` → 用 uni_modules 路径（与 npm 同路径，但前提是目录真实存在）；仅 `package.json` 有依赖而 `uni_modules/` 下无目录 → 先执行上面的 cp 同步再 import，直接 import 会模块找不到。

例外：本仓库示例工程 `packages/playground` 的插件副本目录名为 `ux-utils`（`@/uni_modules/ux-utils`），在 playground 内写示例沿用该路径；业务项目一律 `@/uni_modules/unix-utils`。

## 2. 标准用法

```ts
// toast：与 uni.showToast 同构（title 必填，其余全可选）
import { showToast } from '@/uni_modules/unix-utils'

showToast({
	title: '保存成功',
	icon: 'success', // 'success' | 'error' | 'fail' | 'exception' | 'warning' | 'loading' | 'none'
	duration: 2000
})
```

```ts
// modal：与 uni.showModal 同构（除回调外全可选）
import { showModal } from '@/uni_modules/unix-utils'

showModal({
	title: '删除确认',
	content: '删除后不可恢复，是否继续？',
	confirmColor: '#ff0000',
	success: (res) => {
		if (res.confirm) doDelete() // confirm / cancel 恒存在且互斥
	}
})
```

## 3. 强制约定（红线）

1. **Promise 式失败 reject 的是 JSON 字符串，不是对象**（0.2.0 起契约）：`showToastAsync` / `showModalAsync` 的 `catch` 中必须 `JSON.parse<ToastFail>(err as string)`（或 `ModalFail`）还原，且 parse 结果需判空（`fail != null`）再访问字段。直接把 err 当对象访问字段在 App 端拿到的是全丢失的对象 `toString` 形态。
2. **降级留痕语义分级**：errCode `2001`（PLATFORM_UNSUPPORTED）为**信息级**——参数已降级、功能照常工作（如 `icon: 'warning'` 降级 `none` 后 toast 仍显示），业务可忽略；errCode `1001`（PARAM_INVALID）为**真错误**——modal 的 `title` 与 `content` 均为空时不弹窗。判断写 `err.errCode === 2001`，不要按 message 字符串匹配。
3. **`icon` / `position` / 错误码是字面量联合类型**，直接传字面量（`icon: 'warning'`、`position: 'top'`）；禁止自造字符串值，编译期即报错。
4. **toast 原生通道的平台降级（自动发生并经 `fail` 留痕，业务无需预判）**：`icon = warning` 在微信 / 鸿蒙降级 `none`（2001）；`fail` / `exception` 在原生端归一化 `error`（多数端行为未定义）；`position` 在微信 / 鸿蒙降级居中（2001）；`image` 在 App 直挂通道降级 icon `none`（2001）、微信端 gif 不展示；`title` 微信 7 汉字 / 鸿蒙 20 字截断。自绘通道（App / Web）无这些降级。
5. **modal 颜色仅接受 16 进制**：`#RGB`（自动展开）/ `#RRGGBB` / `#RRGGBBAA`。alpha 在 App / Web 自绘通道全生效；微信 / 鸿蒙原生通道自动剥离 alpha 并留痕（2001）；非法值（命名色、缺 `#`、长度不对）降级平台默认色并留痕（2001，`param` 指明字段）。
6. **modal 返回值恒定**：`confirm` / `cancel` 恒存在且互斥（点确认 `{ confirm: true, cancel: false }`，点取消反之）；`content` 仅 `editable: true` 且点确认时携带输入文本，其余场景恒 `null`。禁止依赖「`cancel` 字段可能缺失」的旧习惯写 `!res.confirm` 兜底。
7. **modal 交互语义**：蒙层点击不关闭（对齐微信官方语义，仅按钮可关闭）；Android 返回键以取消语义关闭（`cancel = true`）；连续调用后调替换前调。设计确认流程时勿假设「点蒙层能关闭」。
8. **modal 受限端文案截断**：微信 / 鸿蒙端按钮文案超 4 字符库内自动截断（静默，不触发 fail），App / Web 端完整显示。自定义按钮文案建议 ≤ 4 字符以保三端一致。
9. **editable 行为**：自绘通道（App / Web）真实渲染输入框，`content` 兼作输入框初始值且光标定位末尾，正文超屏高 60%（内置阈值）自动限高滚动；微信 / 鸿蒙走原生 `editable`，光标位置不受控（表现层残余）。
10. **全局默认配置传 `null` = 沿用默认**：`configureToast` / `configureModal` 的字段传 `null` 表示恢复库内置默认（toast：1500ms / `'success'` / `false`；modal：确认 `'确定'` `#007aff` / 取消 `'取消'` `#000000`），不是清除配置。
11. **UTS 通用红线**：可空值用 `null` 禁止 `undefined`，判空写 `!= null` / `== null`；条件语句必须布尔表达式，禁止 truthy / falsy 隐式判断；回调参数类型显式标注。

## 4. 平台差异速查

### toast 通道矩阵

| 端 | 通道 | 关键差异 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口（`WindowManager` / `UIWindow`） | position / warning / mask / 精确 duration 全生效；窗口级生命周期跨页面存活；挂窗失败自动回落 `uni.showToast` 并留痕；`image` 降级 icon `none`（2001） |
| Web | DOM 单例自绘 | position / warning / 无平台截断全生效；`hideToast` 可靠隐藏 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | `warning` 降级 `none`（2001）、`position` 降级居中（2001）、title 截断（微信 7 汉字 / 鸿蒙 20 字）、生命周期与页面绑定 |

### modal 通道矩阵

| 端 | 通道 | 关键差异 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口自绘 | 全参数生效：editable 真实输入框（光标末尾）、alpha 色生效、蒙层不关闭、返回键取消、60% 限高滚动 |
| Web | DOM 单例自绘 | 同 App（DOM 单例，SPA 内存活） |
| 微信 / 鸿蒙 | `uni.showModal` 原生 | 8 位色剥 alpha 留痕（2001）、按钮文案超 4 字符截断（静默）、editable 光标不受控 |

## 5. 错误码与失败结构速查

| 错误码 | 值 | 含义 | 业务处置 |
| --- | --- | --- | --- |
| `PARAM_INVALID` | 1001 | 参数非法 | 真错误：修正参数。modal 的 `title` / `content` 双空时触发（`param: 'title'`），弹窗不显示 |
| `PLATFORM_UNSUPPORTED` | 2001 | 平台不支持且已降级 | 信息级：功能已按降级形态工作，可忽略或上报 |

失败结构（`ToastFail` / `ModalFail`，字段一致）：`errCode` / `errSubject`（`'unix-utils:toast'` / `'unix-utils:modal'`）/ `errMsg`（错误描述）/ `param`（触发降级或错误的参数名，`string | null`，无则 null）/ `platform`（端标识，如 `'mp-weixin'`）。对外可 `import type` 的类型仅 `ToastFail` / `ModalResult` / `ModalFail` 三个（0.2.0 起）；`icon` / `position` 的字面量联合是参数值域，直接传字面量即可，无需（也无法）import 类型名。

回调式 `showToast` / `showModal` 的 fail 回调收到**结构化对象**；Promise 式收到 **JSON 字符串**（`JSON.parse<ToastFail>(err as string)` 还原后判空）。modal 的降级（2001）在 Promise 式下也会 reject（弹窗仍以降级形态显示）；点取消不算失败、正常 resolve。

## 6. 常见编译 / 运行错误排查

| 现象 | 原因与修复 |
| --- | --- |
| import 模块找不到 | npm 装完未同步：`cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils`（编译器不扫描 node_modules） |
| `JSON.parse<ToastFail>(err)` 后访问字段崩溃 | parse 结果判空：`if (fail != null)`；0.1.0 的 `showToastAsync` reject 对象已废弃，升级到 0.2.0+ |
| `icon: 'warning'` 真机显示无图标 | 微信 / 鸿蒙原生通道降级 `none`（2001 留痕）属预期；App / Web 自绘通道真实渲染 |
| `position: 'top'` 小程序端居中 | 原生通道不支持，降级居中（2001 留痕）属预期；需位置生效改用自绘通道（App / Web） |
| 确认按钮颜色没生效 / 变透明度丢失 | 微信 / 鸿蒙原生通道剥 alpha 留痕（2001）；检查 fail 回调确认端 |
| modal `title` / `content` 都为空不弹窗 | 库内 fail 1001（`param: 'title'`）拦截；至少传一项 |
| 自定义按钮文案被截断 | 微信 / 鸿蒙超 4 字符库内静默截断属预期；需完整显示改用 App / Web |
| Android 点返回键业务逻辑没走确认分支 | 返回键以取消语义关闭（`cancel = true`），确认分支需判 `res.confirm` |

## 7. 版本要求

- 建议 0.2.0+：modal 模块上线、App 端 UTS 直挂自绘、`showToastAsync` reject 契约统一（破坏性）、`ToastFail` / `ModalFail` / `ModalResult` 类型导出
- 0.1.0：仅 toast 模块
- 完整文档：仓库 `packages/docs`（更新日志 `packages/docs/src/changelog.md`）

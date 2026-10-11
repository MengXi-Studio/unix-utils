# unix-utils · showModal 兼容层 设计文档

|          |                                                                                                                                                                                                                                                                                                            |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 状态     | 定稿 v0.2（Q1–Q10 全部落定：App 端先实测再锁定通道、Web 端 DOM 自绘、showModalAlert + configureModal 提供、截断 / 颜色 / 空参 / 位置 / 鸿蒙按 3.4 与 Q&A 建议执行；继承 toast 已定型架构：monorepo / 双轨 API / 结构化错误 / 分端混合通道）                                                                |
| 日期     | 2026-10-09                                                                                                                                                                                                                                                                                                 |
| 前置模块 | [showToast 兼容层设计](./show-toast.md)（通道架构 / 工程约束 / 错误范式均沿用）                                                                                                                                                                                                                            |
| 事实依据 | [uni-app x 官方 showModal 文档](https://doc.dcloud.net.cn/uni-app-x/api/show-modal.html)、[微信 wx.showModal 官方文档](https://developers.weixin.qq.com/miniprogram/dev/api/ui/interaction/wx.showModal.html)、[uni-app 通用平台差异说明](https://uniapp.dcloud.net.cn/api/ui/prompt.html)（2026-10 查证） |

---

## 1. 来源

### 1.1 项目定位

`unix-utils` 的第二个模块为 **modal**：对 `uni.showModal`
的全端兼容封装。工程范式与 toast 完全一致（UTS 源分发 / 强类型 / 平台差异收敛在库内），本设计文档只展开 modal 与 toast 的**差异部分**，重复的工程约束（uts-proxy 符号重整、Impl 后缀、可选字段非空强转等）不再赘述，实现时直接遵循
[show-toast.md](./show-toast.md) 3.6 节要点与项目记忆。

### 1.2 为什么需要封装：uni.showModal 的现状

以下事实全部来自官方文档（2026-10 查证）：

**① API 可用版本不一致**

| Web   | 微信小程序                                     | Android | iOS    | HarmonyOS                                                                                |
| ----- | ---------------------------------------------- | ------- | ------ | ---------------------------------------------------------------------------------------- |
| ≥ 4.0 | 复用 wx.showModal（editable 需基础库 2.17.1+） | ≥ 3.9.0 | ≥ 4.11 | uni-app x 官方兼容表**未列出**（uni-app 通用文档标注 HBuilderX 4.23+，实际可用性待实测） |

> 注意：uni-app x 官方兼容性表只列 Web / Android / iOS 三端；微信端编译产物复用 uni API → wx.showModal 映射，能力由微信平台决定。

**② 颜色参数（cancelColor / confirmColor）支持端不一致**

| 参数           | 支持端（uni-app 通用文档「平台差异说明」）                       | 默认值差异                                                    |
| -------------- | ---------------------------------------------------------------- | ------------------------------------------------------------- |
| `cancelColor`  | Web、微信、百度、抖音（2.62.0+）、支付宝、小红书；**App 端未列** | `#000000`                                                     |
| `confirmColor` | 同上                                                             | Web `#007aff`、微信 `#576B95`、百度 `#3c76ff` —— **三端三色** |

> uni-app x 的 App 端为官方新实现（原生 Dialog / UIAlertController），颜色参数是否生效**官方未标注、待实测**——这直接决定 App 端通道选型（见 Q1）。

**③ 文案长度限制（仅小程序平台）**

- `cancelText` / `confirmText` 小程序平台**最多 4 个字符**，超出由平台截断（微信文档明示「最多 4 个字符」）；App / Web 无此限制。

**④ editable / placeholderText 支持端不一致**

- H5（3.2.10+）、App（3.2.10+）、微信（基础库 2.17.1+）、抖音（2.62.0+）、小红书；**鸿蒙端未列出，待实测**。

**⑤ 按钮位置不一致（官方注意事项原文）**

- 微信 / Web：确认按钮默认在**右**；
- App 中 iOS 确认在**右**、Android 确认在**左**（原生平台策略不同）。

**⑥ 蒙层 / 返回键交互不一致**

- 微信 Android 6.7.2+ 与 iOS：点击蒙层**不关闭**模态弹窗；
- Android（uni 官方语义）：success.cancel 注释「用于 Android 系统区分点击蒙层关闭还是点击取消按钮关闭」→ Android 点蒙层**关闭**并返回 cancel=true；
- Android 返回键可关闭弹窗（模态但非阻塞），各端行为未统一标注。

**⑦ 返回值规则不一**

- 各家小程序 `confirm` / `cancel` 字段返回规则不同：`{ confirm: true, cancel: false }` 或 `{ confirm: true }`（cancel 字段可能缺失）。

**⑧ 错误信息粗糙**

- 失败仅 errCode（1 撤销 / 1001 参数非法）+ errMsg，与 toast 封装前同病：缺少「哪个参数、哪个端不支持」的结构化信息。

### 1.3 痛点归纳

1. **品牌色不可控**：confirmColor / cancelColor 在 App 端（原生通道）支持情况不明，且各端默认色不一致（Web 蓝 / 微信绿 / 百度蓝）；
2. **文案长度**：小程序 4 字符限制导致超长文案各端表现不一；
3. **确认按钮位置**：Android 左 / 其余右，迁移后交互不可预期；
4. **返回值结构不稳**：cancel 字段可能缺失，业务需双重判空；
5. **鸿蒙可用性存疑**：官方 uni-app x 兼容表未列，editable 支持未标注；
6. **错误信息粗糙**：同 toast 痛点 6。

### 1.4 兼容性抹平边界（两层模型，沿用 toast 定型结论）

**第一层：功能层**（参数语义在各端是否生效）——库内归一化**全消除**：

| 功能层差异                                          | 归一化策略                                                     |
| --------------------------------------------------- | -------------------------------------------------------------- |
| confirmColor / cancelColor 部分端不生效、默认色不一 | 库内统一默认色 + 通道保障生效（App 端通道方案见 Q1）+ 降级留痕 |
| cancelText / confirmText 小程序 4 字符限制          | 库内按端截断（见 Q6）                                          |
| 返回值 cancel 字段可能缺失                          | 库内归一化：confirm / cancel **恒双返回**、互斥确定（见 3.3）  |
| 颜色值非法（非 16 进制）                            | 库内校验，非法降级默认色 + 结构化回调（见 Q7）                 |
| 错误信息粗糙                                        | 结构化 `ModalFail`（errSubject / param / platform）            |

**第二层：表现层**（按钮位置、蒙层 / 返回键交互、视觉细节、系统行为）——承诺三点不变：

- **可预期**：所有残余差异写入 3.4 矩阵与文档；
- **可见**：降级发生时 fail 回调返回结构化 `ModalFail`；
- **可替换**：App 端提供 UTS 通道消除本端差异（方案见 Q1）；其余端保留原生通道兜底。

> 与 toast 的关键差异：modal 是**模态**交互，系统 Dialog（Android AlertDialog / iOS
> UIAlertController）本身就是「蒙层 + 返回键 + 输入法 + 焦点」的全处理组件——**完全自绘成本远高于 toast**。通道选型的核心问题从「要不要自绘」变为「原生 Dialog 的能力缺口（主要是颜色）值不值得用 UTS 直调补齐」（Q1）。**已确认（Q2）：Web 端走 DOM 自绘**——蒙层点击不关闭、颜色 / 文案 /
> editable 全生效、默认色统一，Web 表现层差异一并消除，通道架构与 toast 完全对齐（App + Web 自绘、微信 / 鸿蒙原生）。

---

## 2. 设计目标与非目标

**目标**

- G1 **参数完全对齐**：`title / content / showCancel / cancelText / cancelColor / confirmText / confirmColor / editable / placeholderText / success / fail / complete` 全部保留，迁移零成本；
- G2 **分端最优实现**：通道方案按 Q1 / Q2 结论执行（App 端候选：uni 原生 / UTS 直调系统 Dialog / 窗口自绘；Web 端候选：uni 原生 / DOM 自绘；微信 / 鸿蒙原生通道）。不引入任何第三方 UI 依赖；
- G3 **行为抹平**：功能层差异全消除——颜色归一化与生效保障、文案截断、返回值双字段恒定、editable 降级留痕、错误结构化；表现层差异可预期 / 可见 / 可替换（边界见 1.4）；
- G4 **强类型**：UTS type / 无 undefined / 显式 null / 字面量联合，通过各端编译；
- G5 **工程对齐**：目录结构、错误码、常量命名、changelog 全部沿用 toast 模块范式。

**非目标**

- 不追求**非自绘端**（微信 / 鸿蒙）的像素级视觉统一；
- 不提供 `hideModal`——模态交互以用户操作结束，无隐藏语义（uni 官方亦无此 API）；
- 不在本期实现 `showLoading` / `showActionSheet`（后续模块）；
- 不扩展 modal 参数超集（如第三按钮、富文本 content）——模态弹窗保持与官方语义 1:1，扩展诉求应走自绘组件而非本库。

---

## 3. 功能点

### 3.1 核心 API（双轨，回调式为主——与 toast 一致）

```ts
/* 回调式（主，参数 100% 对齐 uni.showModal，迁移零成本） */
showModal(options: ModalOptions): void

/* Promise 式（辅）——注意：modal 的成功结果即交互结果，业务必须拿到，
 * 故 resolve 值为 ModalResult（confirm / cancel / content），非 void。
 * 这是与 showToastAsync（Promise<void>）的刻意差异。 */
showModalAsync(options: ModalOptions): Promise<ModalResult>
```

> 用户点击取消**不属于失败**（与 uni 语义一致）：点取消走 success / resolve（confirm=false, cancel=true）；仅 API 调用本身失败（参数非法、平台不支持、系统错误）走 fail / reject。失败契约（全端统一）：`showModalAsync` reject `ModalFail` 结构的 JSON 字符串，业务侧 `JSON.parse<ModalFail>(err as string)` 还原——实测 App 端运行时 async 代理仅将 reject 值按字符串透传（类型化对象字段全部丢失），故库内统一 `JSON.stringify` 后 reject。

### 3.2 语义化快捷 API（✅ 已确认：提供）

```ts
/* 单确定按钮弹窗（showCancel: false），对齐 HTML alert 语义 */
showModalAlert(title: string, content: string | null): void
```

> modal 参数多、组合少，快捷层只收敛最高频形态；不做 showConfirm / showPrompt 等更多命名（避免 API 面膨胀）。

### 3.3 类型设计（UTS 约束，字面量联合跨 uts-proxy 边界）

```ts
/* 选项：对齐 uni.showModal 全参数；除 title/content 外全可选（uts-proxy 可选字段才生成 null-safe 编码） */
type ModalOptions = {
	title?: string | null
	content?: string | null
	showCancel?: boolean // 默认 true
	cancelText?: string | null // 默认 '取消'
	cancelColor?: string | null // 16 进制颜色（#RGB / #RRGGBB / #RRGGBBAA），非法值降级默认色
	confirmText?: string | null // 默认 '确定'
	confirmColor?: string | null // 同上
	editable?: boolean // 默认 false
	placeholderText?: string | null // editable 为 true 时生效
	success?: ((res: ModalResult) => void) | null
	fail?: ((err: ModalFail) => void) | null
	complete?: ((res: any) => void) | null
}

/* 成功结果：库内归一化保证 confirm / cancel 恒存在且互斥（1.2⑦ 抹平） */
type ModalResult = {
	confirm: boolean
	cancel: boolean
	content: string | null // editable 为 true 时用户输入的文本；非 editable 恒 null
}

/* 失败结构：对齐 ToastFail 范式 */
type ModalFail = {
	errCode: ModalErrorCode
	errSubject: string // 固定 'unix-utils:modal'
	errMsg: string
	param: string | null // 触发问题的参数名（如 'confirmColor' / 'cancelText'）
	platform: string // 当前端标识（'app-android' / 'web' / 'mp-weixin' / ...）
}

/* 错误码：与 toast 同值域（1001 参数非法 / 2001 平台不支持且已降级） */
type ModalErrorCode = 1001 | 2001
```

### 3.4 参数抹平矩阵（核心功能点，✅ 策略已确认）

> App 列通道按 Q1 于 M0 实测后锁定（候选：uni 原生 / UTS 直调系统 Dialog / 完全自绘）；Web 列 = DOM 自绘通道（已确认 Q2）；微信 / 鸿蒙 = uni 原生通道。`⏳` = 待实测。

| 参数                           | App-Android（M0 实测已回填，Mi 10 Pro / HBuilderX 5.26）      | Web（自绘通道）      | App-HarmonyOS | 微信小程序           | 策略说明                                                              |
| ------------------------------ | ------------------------------------------------------------- | -------------------- | ------------- | -------------------- | --------------------------------------------------------------------- |
| `title` / `content`            | ✅ 生效；均空平台弹空窗不报错 → 库内 fail 1001（Q8）          | ✅（均空 fail 1001） | ⏳            | ✅（均空 fail 1001） | 直接透传                                                              |
| `showCancel`                   | ✅ 单按钮形态正常（confirm=true / cancel=false）              | ✅                   | ⏳            | ✅                   | 直接透传                                                              |
| `cancelText` / `confirmText`   | ⏳（官方无长度限制声明，实测待补）                            | ✅（无长度限制）     | ⏳            | ✅ + 4 字符限制      | 受限端超长库内主动截断（Q6），自绘端不截断                            |
| `cancelColor`                  | ✅ 6 位 hex 生效（M0 实测）                                   | ✅（全生效）         | ⏳            | ✅（默认 #000000）   | 原生通道不支持时降默认色 + 2001 留痕；UTS 通道补齐                    |
| `confirmColor`                 | ✅ 6 位 hex 生效；✗ 8 位 #RRGGBBAA 与命名色平台**静默回退默认色**（不报错）→ 库内校验先行：非法降默认 + 2001，App 原生通道剥 alpha 并留痕 | ✅（全生效）         | ⏳            | ✅（默认 #576B95）   | 库内默认 #007aff（Q7），各端默认色差异归零（微信不干预随平台）        |
| `editable` / `placeholderText` | ✅ 实测生效：输入框 / placeholder 出现，确认后 content 返回输入内容（观测到传入 content 值回显，疑似兼作输入初始值，M3 复核） | ✅（input 元素）     | ⏳            | ✅（基础库 2.17.1+） | 不支持端降级：editable 视为 false + 2001 留痕（结果 content 恒 null） |
| 返回值 `confirm` / `cancel`    | ✅ 平台已恒双返回、互斥（M0 实测）；非 editable 时 content 为 undefined → 库内归一 null | ✅ 归一化恒双返回    | ⏳            | ✅ 归一化恒双返回    | 库内补齐缺失字段：仅 confirm=true 时 cancel 补 false，反之亦然        |
| 蒙层点击关闭                   | ✅ 实测**关闭**弹窗且返回 cancel=true（Android 语义）          | ✗（不关闭，统一）    | ⏳            | ✗（不可关）          | Web 自绘统一「不关闭」；App 原生随平台（表现层残余，Q9）              |
| Android 返回键关闭             | ⏳（随平台，未实测）                                          | -                    | ⏳            | ✅（随平台）         | 表现层残余，文档标注                                                  |
| 确认按钮位置                   | ✅ 实测**在右**（uni-app x 新实现统一右，与 uni-app 通用文档「Android 左」不一致） | ✅ 右                | ⏳            | ✅ 右                | 尊重平台惯例，写入矩阵                                                |
| 连续调用                       | ✅ 实测**排队**（后调用先弹出，关闭后显示先调用的，重复两次一致） | ✅ 单例复用替换      | ⏳            | ⏳                   | 模态弹窗语义下连续调用本身反模式，不主动抹平，实测后文档标注          |

### 3.5 全局默认配置（✅ 已确认：提供）

```ts
/* modal 的品牌色 / 文案全局预设（每弹窗传色重复度高，预设价值大于 toast） */
configureModal(defaults: ModalDefaults): void
// ModalDefaults: { cancelText / confirmText / cancelColor / confirmColor，全部可空 = 沿用库内置 }
```

### 3.6 目录结构（沿用 toast 范式）

```
packages/core/utssdk/
├── interface.uts              # 追加 ModalOptions / ModalResult / ModalFail / ModalErrorCode + API 类型别名
├── index.uts                  # 追加 export const showModal / showModalAsync / (showModalAlert) / (configureModal)
└── modal/
    ├── show-modal.uts         # showModalImpl / showModalAsyncImpl
    ├── shortcut.uts           # showModalAlertImpl（若 Q5 确认）
    ├── enums/modal-error-code.uts
    ├── constants/             # BUILTIN_CONFIRM_TEXT / BUILTIN_CANCEL_TEXT / BUILTIN_CONFIRM_COLOR / BUILTIN_CANCEL_COLOR / limits / keys
    ├── types/modal.uts
    ├── config/index.uts       # configureModalImpl / getModalDefaults（若 Q10 确认）
    ├── utils/
    │   ├── color.uts          # 16 进制颜色校验（#RGB / #RRGGBB / #RRGGBBAA）
    │   ├── normalize.uts      # 参数归一化 / 文案截断 / 降级收集 / 返回值归一化
    │   └── index.uts
    └── channels/
        ├── native.uts         # uni.showModal 封装（App / 微信 / 鸿蒙——Q1 锁定 A 原生通道）
        └── web.uts            # #ifdef WEB DOM 自绘（蒙层 + 卡片 + 按钮行 + input，Q2 已确认）
```

实现分层（Q1 锁定 A 原生通道，Web 已确认自绘）：

```
业务调用 showModal(options)
      │
      ▼
normalize 层：空参校验（Q8）/ 颜色校验 / 文案按端截断 / editable 降级 / 默认值填充 + 降级收集
      │
      ▼
dispatch 层（条件编译，编译期判定）
   ├─ App / 微信 / 鸿蒙原生通道（Q1 锁定 A：uni.showModal 直调 + 库内归一化）
   └─ Web 自绘通道（Q2 已确认：#ifdef WEB DOM 单例，蒙层 + 卡片 + 按钮行 + input）
      │
      ▼
result-normalize 层：confirm / cancel 恒双返回 + content 空值归一
      │
      ▼
callback 层：success / fail / complete 回调（showModalAsync 包装为 Promise<ModalResult>）
```

### 3.7 工程与验证

- **分发**：沿用 `@meng-xi/unix-utils` 单包（modal 为 `utssdk/modal/` 子模块），插件市场 + npm 双轨，无新增分发事项；
- **验证**：`packages/playground` 增加 modal 测试页（showCancel 双态 / 文案定制 / 颜色定制 / editable + placeholder / 4 字符截断 / 连续调用 / showModalAsync），以**运行日志**为 DoD 依据；
- **前置实测**（Q1 决策依据）：用 playground 直接实测 uni.showModal 在 App-Android / App-iOS / 鸿蒙的真实参数生效情况（颜色 / editable / 位置），实测结论回填 3.4 矩阵后再锁定通道方案。

### 3.8 风险与待实测项

| 风险                               | 说明                                                                                                   | 缓解                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------ |
| ~~App 端原生通道颜色未知~~（已消除） | M0 App-Android 实测：颜色 6 位 hex 全生效 → Q1 锁 A 原生通道；iOS 同为 uni 官方实现，M3 复核           | 库内归一化 + 2001 留痕兜底                 |
| App 端 editable                   | ✅ 已实测（App-Android）：输入框 / placeholder 出现，确认后 content 返回输入内容（观测到传入 content 值回显，疑似兼作输入初始值）；iOS / 鸿蒙待 M3 复核 | 不支持场景降级 editable=false 留痕    |
| 鸿蒙端可用性                       | uni-app x 兼容表未列 showModal；editable 支持未标注                                                    | 原生通道实测；不支持项降级 + 2001 留痕     |
| UTS 直调 Dialog 的主题视觉漂移     | ~~已消除~~：Q1 锁定 A 原生通道，不走 UTS 直调                                                          | -                                          |
| 微信 4 字符截断位置                | 超长文案平台截断行为（硬截 vs 省略号）未标注                                                           | 库内主动截断保证可预期（Q6）               |
| 连续调用行为                       | ✅ App-Android 已实测：排队（后调用先弹，关闭后显示先调用）；微信 / 鸿蒙待测                            | 实测后文档标注；不做库内队列               |
| editable 输入法与弹窗遮挡          | App 端软键盘弹出与 Dialog 位置适配由系统处理                                                           | M3 真机复测                                |
| `string.ColorString` 类型边界      | ✅ App-Android 已实测：8 位 #RRGGBBAA 与命名色平台静默回退默认色（不报错）；微信要求 16 进制待 M3       | 库内校验先行，不支持格式降级 + 留痕        |

---

## 4. 需要你作答的疑问（Q&A）

> 每题附建议，可直接回复「全部按建议」或逐条批注。已由 toast 定型的决策（双轨 API / 结构化错误 / monorepo / 条件编译判定 / Impl 后缀等）不再重复提问。

**Q1 App 端通道方案** ✅ 已锁定：**A 原生通道**（M0 App-Android 真机实测：confirmColor / cancelColor 6 位 hex 全生效 → 决策树命中 A；8 位 #RRGGBBAA 平台静默回退默认色，库内剥 alpha + 2001 留痕，不影响通道选型）

- A. **uni 原生通道**：App 端直接走 uni.showModal。若前置实测证明 uni-app x 的 App 端已支持 confirmColor / cancelColor / editable，则此方案零成本、真原生视觉，库只做归一化；
- B. **UTS 直调系统 Dialog**：Android `AlertDialog`（`getButton().setTextColor()` 补颜色、`setView(EditText)` 补输入框）+ iOS `UIAlertController`（`view.tintColor` /
  `addTextField`）。原生模态组件 + 能力缺口逐项补齐；蒙层 / 返回键 / 输入法全由系统处理，成本远低于完全自绘；
- C. **UTS 直挂窗口完全自绘**：与 toast 同架构、视觉 100% 统一，但需自造输入框焦点 / 输入法 / 返回键 / 蒙层手势全套逻辑，风险与工作量最高。

**建议**：先实测 uni.showModal App 端参数生效矩阵；若颜色已支持 → A；若仅颜色缺失 → B；仅当 A / B 都无法满足且需要视觉统一时才 C。

答：C。

**Q2 Web 端通道方案** ✅ 已确认：B（DOM 自绘）——蒙层 / 颜色 / 文案 / editable 全生效且视觉与 App 自绘统一，通道架构与 toast 完全对齐；Web 端 uni.showModal 原生实现保留为代码内 fallback 参考（自绘通道为唯一 Web 通道）

- A. **uni 原生通道**：Web 端 uni.showModal 本身就是框架 DOM 实现，颜色 / 文案 / editable 全支持、无平台截断——与 toast 的 Web 情况相反（toast 的 Web 原生通道有 position / warning 能力缺口），此处原生通道**零缺口**；
- B. **DOM 自绘**：仅当追求「App 自绘视觉与 Web 全统一」时才有意义。

**建议**：A（原生通道无缺口，自绘无收益）。

答：B。

**Q3 Promise 返回值形态** ✅ 已确认：`showModalAsync` resolve `ModalResult`（含 confirm / cancel / content），点取消不算 reject

`showModalAsync` resolve `ModalResult`（含 confirm / cancel / content），而非 toast 的 `Promise<void>`。

**建议**：确认（modal 的交互结果必须可达，点取消不算 reject）。

答：按建议。

**Q4 快捷 API** ✅ 已确认：提供 `showModalAlert(title, content)`；不做 confirm / prompt 命名

仅提供 `showModalAlert(title, content)`（单确定按钮，alert 语义）；不做 confirm / prompt 命名。

**建议**：确认提供（与 toast 快捷层对称）；若觉得 API 面大可砍掉，modal 场景业务通常自带封装。

答：按建议。

**Q5 全局默认配置** ✅ 已确认：提供 `configureModal`（cancelText / confirmText / cancelColor / confirmColor 四字段预设）

`configureModal`（cancelText / confirmText / cancelColor / confirmColor 四字段预设）。

**建议**：提供——modal 的品牌色统一诉求强于 toast（每弹窗传 confirmColor 重复度高）。

答：按建议。

**Q6 文案 4 字符截断策略** ✅ 已确认：A（库内主动截断到 4 字符，仅受限端的原生通道生效；App / Web 自绘端不截断，与 toast 微信 7 汉字截断策略同构）

- A. 库内主动截断到 4 字符（可预期，与 toast 的微信 7 汉字截断策略一致）；
- B. 透传由平台截断（零成本，表现不可预期）。

**建议**：A。截断规则：`cancelText` / `confirmText` 超过 4 字符截断，仅对原生通道且受限制的端生效（App / Web 不截断）。

答：按建议。

**Q7 颜色归一化策略** ✅ 已确认：库内默认 confirmColor `#007aff` / cancelColor `#000000`（微信不干预随平台）；校验接受 `#RGB` / `#RRGGBB` / `#RRGGBBAA`，非法值降级默认色 + fail
2001（param='confirmColor'）；原生通道不支持 alpha 时剥离并留痕

- 库内统一默认值：confirmColor 默认 `#007aff`（取 Web 默认，中性蓝）、cancelColor 默认 `#000000`——各端默认色差异归零；
- 校验：接受 `#RGB` / `#RRGGBB` / `#RRGGBBAA`；非法值（命名色 / 缺 # / 越界）降级默认色 + fail 回调 2001（param='confirmColor'）；
- 仅自绘 / UTS 通道支持 #RRGGBBAA；原生通道按端实测，不支持 alpha 时剥离 alpha 并留痕。

**建议**：确认（可预期 + 可见的既有原则）。

答：按建议。

**Q8 title / content 均为空时的行为** ✅ 已确认：B（库内 fail 1001 PARAM_INVALID，param='title'）

- A. 透传给平台（可能弹空窗）；
- B. 库内 fail 1001 PARAM_INVALID（title 与 content 至少其一非空）。

**建议**：B——空弹窗无意义且难排查，结构化报错符合库的定位。

答：按建议。

**Q9 确认按钮位置语义** ✅ 已确认：A（尊重平台惯例——Android 左确认写入矩阵；文案互换 hack 不采用）

- A. 尊重平台惯例（Android 左确认，官方原因即「原生平台策略本身不同」）；
- B. 强制统一确认在右（仅完全自绘 C 方案可实现，或文案互换 hack——官方不建议）。

**建议**：A（平台惯例本身就是可预期性的一部分，写入矩阵即可）。

答：按建议。

**Q10 鸿蒙端纳入策略** ✅ 已确认：五端全含，鸿蒙走原生通道，可用性与 editable 支持以实测为准，不支持项降级 + 留痕

沿用 toast 结论：五端全含，鸿蒙走原生通道，可用性与 editable 支持以实测为准，不支持项降级 + 留痕。

**建议**：确认。

答：按建议。

---

## 5. 里程碑（建议，待 Q&A 后细化）

| 阶段        | 内容                                                                                    | DoD                         |
| ----------- | --------------------------------------------------------------------------------------- | --------------------------- |
| M0 前置实测 | uni.showModal App-Android / App-iOS / 鸿蒙参数生效矩阵（颜色 / editable / 位置 / 蒙层） | 实测记录回填 3.4 矩阵       |
| M1 设计定稿 | Q1–Q10 落定，通道方案锁定                                                               | 已确认                      |
| M2 实现     | normalize + 通道实现 + 双轨 API + 快捷 / 配置 API（按 Q4 / Q5 结论）                    | 五端编译通过                |
| M3 全端验证 | playground modal 测试页五端实测（双按钮 / 单按钮 / 颜色 / editable / 截断 / 异步）      | 运行日志验证，无运行时错误  |
| M4 文档     | README（中英）+ 抹平矩阵 + playground 用例说明                                          | 与 unix-router 文档风格对齐 |

---

## 6. 修订记录

| 版本 | 日期       | 修订内容                                                                                                                                                                                                                                                                                                        |
| ---- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v0.1 | 2026-10-09 | 初稿：官方文档查证（uni-app x / 微信 / uni-app 通用）、痛点与两层模型、Q1–Q10                                                                                                                                                                                                                                   |
| v0.2 | 2026-10-09 | Q&A 全部落定：Q1 App 端先实测再锁定（决策树）、Q2 Web 切 DOM 自绘（通道架构与 toast 对齐）、Q4 showModalAlert / Q5 configureModal 确认提供、Q6 截断 / Q7 颜色默认 #007aff/#000000 + 非法降级 / Q8 空参 fail 1001 / Q9 尊重平台位置 / Q10 鸿蒙五端全含；3.4 矩阵 Web 列改自绘通道、3.6 目录恢复 channels/web.uts |
| v0.3 | 2026-10-10 | M0 App-Android 真机实测（Mi 10 Pro / HBuilderX 5.26）回填 3.4：颜色 6 位 hex 全生效 → **Q1 锁 A 原生通道**（channels/app/ 目录移除）；8 位 alpha / 命名色平台静默回退默认色 → 库内校验先行 + 2001 留痕；返回值 confirm / cancel 平台已双返回互斥（归一化仅需 content 缺省归一 null）；蒙层点击关闭 + cancel=true；确认按钮**在右**（推翻 uni-app 通用文档「Android 左」，uni-app x 新实现统一右侧）；连续调用**排队**；非 editable 的 content=undefined → 库内归一 null；editable 输入框出现（content 返回待复测）；empty 用例平台弹空窗不报错（Q8 fail 1001 确认必要） |

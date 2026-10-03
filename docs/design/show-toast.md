# unix-utils · showToast 兼容层 设计文档

| | |
|---|---|
| 状态 | 定稿 v0.7（v0.7：App 通道切换为 UTS 直挂系统窗口——core 包附带 `uni-modules/unix-window` UTS 插件（Android WindowManager / iOS UIWindow），免注册、触摸穿透 / 蒙层 / 动画 / 计时全自管，dialogPage 承载页方案退役；历史落定项不变：双轨 API + 快捷 API + icon 扩 warning + 原生降级策略 + duration 不钳制 + configureToast + Web 自绘 + renderer 不暴露 + npm/uni_modules 双轨） |
| 日期 | 2026-10-03 |
| 工程惯例参照 | [unix-router](https://github.com/MengXi-Studio/unix-router)（UTS 源分发 / monorepo / 类型与错误码组织方式） |
| 事实依据 | [uni-app x 官方 showToast 文档](https://doc.dcloud.net.cn/uni-app-x/api/toast.html)、hello uni-app x 示例源码（toast.uvue） |

---

## 1. 来源

### 1.1 项目定位

`unix-utils` 是一个为 uni-app x 提供便利工具的库，与 `unix-router` 同属 MengXi-Studio，采用相同的工程范式：

- **UTS 源分发**：`main` 直接指向 `src/index.uts`，由 uni-app x 编译链按目标平台现场编译（Web/小程序 → JS，Android → Kotlin，iOS → Swift）；
- **强类型 UTS**：`type` 定义对象类型、`enum` 定义枚举、无 `undefined`、严格条件布尔，遵循 UTS 全部编译约束；
- **平台差异收敛在库内**：业务代码写一次，平台特有逻辑用条件编译（`#ifdef`）隔离在库内部。

首个模块为 **toast**：对 `uni.showToast` 的全端兼容封装。

### 1.2 为什么需要封装：uni.showToast 的现状

以下事实全部来自官方文档与官方示例（2026-10 查证）：

**① API 可用版本不一致**

| Web   | 微信小程序 | Android | iOS    | HarmonyOS |
| ----- | ---------- | ------- | ------ | --------- |
| ≥ 4.0 | ≥ 4.41     | ≥ 3.91  | ≥ 4.11 | ≥ 4.61    |

**② `icon` 合法值各端不对齐**

| icon 值     | 官方说明                   | 端限制                                         |
| ----------- | -------------------------- | ---------------------------------------------- |
| `success`   | 成功图标（默认值）         | 全端                                           |
| `error`     | 错误图标                   | 全端                                           |
| `fail`      | 错误图标，title 无长度显示 | **仅支付宝、抖音小程序生效**，其余端行为未定义 |
| `exception` | 异常图标，title 无长度显示 | **仅支付宝小程序生效**                         |
| `loading`   | 加载图标                   | 全端                                           |
| `none`      | 不显示图标                 | 全端                                           |

**③ `position` 仅 App 生效，且 Android 三缺二**

- 官方示例明确注释：「设置 position，仅 App 生效」；
- hello uni-app x 示例注释：`top` / `center` 在 **Android 暂不支持**，仅 `bottom` 可用；
- 设置 position 后**只有 title 生效**（icon 等参数失效）；
- position 形态的 toast **不支持通过 `uni.hideToast()` 隐藏**。

**④ 生命周期绑定不一致（官方 Bug & Tips）**

- iOS、微信小程序、Web：toast **与页面（含 dialogPage）绑定**，页面关闭 toast 即消失；
- Android：`position = bottom` 时为**系统 Toast，与 App 绑定**；其余情况与页面绑定。

**⑤ 其他参数差异**

| 参数       | 差异                                                                                                                       |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| `title`    | 「长度与 icon 取值有关」；微信小程序平台限制：`icon` 为 `success` / `loading` 时 title 最多显示 **7 个汉字长度**，超出截断 |
| `image`    | 自定义图标本地路径；**App 端暂不支持 gif**                                                                                 |
| `mask`     | 是否显示透明蒙层，各端视觉表现不一                                                                                         |
| `duration` | 默认 1500ms；Android `bottom` 系统 toast 时长粒度受系统约束（待实测）                                                      |

### 1.3 痛点归纳

1. **语义不对齐**：`fail` / `exception` 图标在多数端无效，行为未定义；
2. **位置不可用**：`position` 仅 App 且 Android 仅支持 `bottom`；
3. **生命周期不一致**：页面绑定 vs App 绑定，跨页面提示表现不可预测；
4. **长度限制不一**：title 截断行为各端不同；
5. **隐藏能力不一致**：position toast 无法 hideToast；
6. **错误信息粗糙**：失败仅 errCode（1 撤销 / 1001 参数非法）+ errMsg，缺少「哪个参数、哪个端不支持」的结构化信息。

### 1.4 兼容性抹平边界（两层模型）

兼容性差异分为两层，库的消除能力与承诺不同：

**第一层：功能层**（参数语义在各端是否生效）——库内归一化**全消除**：

| 功能层差异                                | 归一化策略                                                  |
| ----------------------------------------- | ------------------------------------------------------------ |
| `fail` / `exception` 图标多数端无效       | 归一化为 `error`（自绘通道可真实渲染，见 3.4）               |
| `position` 仅 App 且 Android 仅 bottom    | App / Web 自绘通道三值全支持（v0.6）；微信 / 鸿蒙降级 + 结构化回调（见 Q7） |
| position toast 不可 `hideToast`           | 自绘通道可靠隐藏；原生通道尽力而为 + 文档标注                |
| 微信 title 最多 7 汉字                    | 库内按端截断策略（见 Q8）                                    |
| App 原生通道 image 不支持 gif             | 自绘通道支持（待实测）；原生通道检测 `.gif` 降级 + 回调      |
| 错误信息粗糙（errCode 1 / 1001 + errMsg） | 结构化 `ToastFail`（errSubject / param / platform）          |

**第二层：表现层**（视觉样式、生命周期绑定、时长粒度、框架级 bug）——只要走 uni 原生通道就无法消除，库的承诺修正为三点：

- **可预期**：所有残余差异写入 3.4 矩阵与文档，无隐藏行为；
- **可见**：降级发生时 fail 回调返回结构化 `ToastFail`，业务可感知；
- **可替换**：App 端 UTS 直挂窗口通道（v0.7）直接消除本端表现层差异；其余端保留原生通道兜底。

> 方案 C（v0.4 定案、v0.7 演进）正是对表现层的正面回应：App 端通过窗口级自绘把表现层差异一并消除；其余端的表现层残余按上述三原则管理。

---

## 2. 设计目标与非目标

**目标**

- G1 **参数完全对齐**：`title / icon / image / mask / duration / position / success / fail / complete` 全部保留，迁移零成本；
- G2 **分端最优实现**：App-Android / App-iOS 走 UTS 直挂系统窗口（unix-window 插件：Android `WindowManager` / iOS `UIWindow`，v0.7，免注册、属性全生效）；Web 走 DOM 单例自绘（v0.6 Q15，属性全生效）；微信 / 鸿蒙走 `uni.showToast` 原生通道。不引入任何第三方 UI 依赖；
- G3 **行为抹平**：功能层差异全消除——icon 别名归一化、title 长度策略、position 降级、mask 降级、hideToast 统一语义；表现层差异**可预期（文档）、可见（结构化回调）、可替换（自绘 / UTS 通道）**（边界见 1.4）；
- G4 **强类型**：UTS type / enum / 无 undefined / 显式 null，通过各端编译；
- G5 **工程对齐 unix-router**：monorepo `packages/core`、constants / enums / types 分目录、错误码枚举风格、中文注释规范。

**非目标**

- 不追求**非自绘端**（微信 / 鸿蒙）的像素级视觉统一（小程序原生 toast 样式受平台控制，无法定制）；App / Web 端视觉统一由自绘通道达成，属目标而非非目标；
- 不在本期实现 `showModal` / `showLoading` / `showActionSheet`（目录预留，后续模块）。

---

## 3. 功能点

### 3.1 核心 API（已确认：双轨，回调式为主）

```ts
/* 回调式（主，参数 100% 对齐 uni.showToast，迁移零成本） */
showToast(options: ToastOptions): void
hideToast(): void

/* Promise 式（辅：成功 resolve，失败 reject ToastFail 结构） */
showToastAsync(options: ToastOptions): Promise<void>
```

> UTS 全端支持 Promise；`showToastAsync` 内部复用同一归一化与分发链路，仅包装回调。

**renderer 按端默认语义（v0.7 修订）**：不作为 `ToastOptions` 参数暴露，由端自动决定——

| 端                    | 默认通道 | 实现方式                                                 |
| --------------------- | -------- | --------------------------------------------------------- |
| App-Android / App-iOS | `custom` | UTS 直挂系统窗口（unix-window 插件：WindowManager / UIWindow，免注册，属性全生效） |
| Web                   | `custom` | DOM 单例自绘（`#ifdef WEB`，position / warning / 不截断全生效） |
| 微信 / 鸿蒙           | `native` | `uni.showToast`（平台原生实现）                           |
| App 端（fallback）    | `native` | 直挂窗口失败（如页面未就绪）自动回落 uni 原生通道 + fail 回调留痕 |

### 3.2 语义化快捷 API（已确认：提供）

```ts
/* 可选的第二层封装，降低调用侧心智 */
showToastSuccess(title: string): void   // icon: success
showToastError(title: string): void     // icon: error
showToastInfo(title: string): void      // icon: none
```

### 3.3 类型设计（UTS 约束）

```ts
/* 图标枚举：含 uni 原生 6 值，是否扩展见 Q6 */
enum ToastIcon {
	SUCCESS = 'success',
	ERROR = 'error',
	FAIL = 'fail', // 原生通道仅支付宝/抖音生效，多数端归一化为 error；自绘通道真实渲染
	EXCEPTION = 'exception', // 原生通道仅支付宝生效，多数端归一化为 error；自绘通道真实渲染
	WARNING = 'warning', // 扩展值：自绘通道真实渲染；原生通道降级为 none 并回调 PLATFORM_UNSUPPORTED
	LOADING = 'loading',
	NONE = 'none'
}

/* 位置枚举 */
enum ToastPosition {
	TOP = 'top',
	CENTER = 'center',
	BOTTOM = 'bottom'
}

/* 选项：对齐 uni.showToast 全参数；UTS 无默认参数与 undefined，可选项以 null 显式表达 */
type ToastOptions = {
	title: string
	icon: ToastIcon | null // null → 使用全局默认（success）
	image: string | null // 本地路径；原生通道 App 端 gif 降级，自绘通道支持（待实测）
	mask: boolean
	duration: number // 毫秒
	position: ToastPosition | null // null → 不启用 position 形态
	success: ((res: ToastResult) => void) | null
	fail: ((err: ToastFail) => void) | null
	complete: ((res: any) => void) | null
}

/* 失败结构：比原生 errCode 更结构化（对齐 unix-router 的 RouterError 思路） */
type ToastFail = {
	errCode: ToastErrorCode
	errSubject: string // 固定 'unix-utils:toast'
	errMsg: string
	param: string | null // 触发问题的参数名（如 'position'）
	platform: string // 当前端标识（'app-android' / 'web' / ...）
}

enum ToastErrorCode {
	PARAM_INVALID = 1001, // 参数非法（如 image 传 gif 于 App）
	PLATFORM_UNSUPPORTED = 2001 // 参数当前端不支持且已降级（info 级）
}
```

### 3.4 参数抹平矩阵（核心功能点）

对每个参数定义「各端策略」，**降级必须可预期**。App / Web 列指自绘通道（v0.7：App 为 UTS 直挂窗口通道，Web 为 DOM 单例），其余端为 uni 原生通道：

| 参数                         | App（自绘通道）          | Web（自绘通道）          | App-HarmonyOS | 微信小程序   | 策略说明                                                         |
| ---------------------------- | ------------------------ | ------------------------ | ------------- | ------------ | ----------------------------------------------------------------- |
| `title`                      | ✅ 全生效（无平台截断）  | ✅ 全生效（无平台截断）  | ✅（待实测）  | ✅ + 7字限制 | 微信超长按 Q8 截断（微信 7 汉字、鸿蒙 20 字 + 省略号）           |
| `icon = fail`                | ✅ 自绘真实渲染          | ✅ 自绘真实渲染          | ⚠️ 未定义     | ⚠️ 未定义    | 原生端**归一化为 `error`**（支付宝/抖音保持原值，非本期范围）     |
| `icon = exception`           | ✅ 自绘真实渲染          | ✅ 自绘真实渲染          | ⚠️            | ⚠️           | 原生端**归一化为 `error`**（支付宝保持原值，非本期范围）          |
| `icon = warning`（扩展）     | ✅ 自绘真实渲染          | ✅ 自绘真实渲染          | ✗            | ✗            | 原生端降级为 `none` + 回调 PLATFORM_UNSUPPORTED                  |
| `image`                      | ⚠️ 降级 icon 'none' + fail 回调 | ✅（含 gif，img 标签）   | 待实测        | ✅           | App 直挂通道暂不渲染图片：降级 + PLATFORM_UNSUPPORTED 留痕；原生通道检测 `.gif` 后缀 → 降级 icon |
| `mask`                       | ✅                       | ✅（pointer-events）     | 待实测        | ✅           | 直接透传                                                          |
| `duration`                   | ✅ 精确毫秒              | ✅ 精确毫秒              | 待实测        | ✅           | 不钳制，原样透传（见 Q11）；自绘通道计时器精确控制              |
| `position`                   | ✅ top / center / bottom | ✅ top / center / bottom | 待实测        | ✗            | 自绘通道三值全支持；微信降级见 Q7                                 |
| position toast + `hideToast` | ✅ 直挂视图主动移除      | ✅ DOM 单例可靠隐藏      | 待实测        | -            | 原生通道尽力而为 + 文档标注                                       |
| 连续调用                     | ✅ 复用窗口视图「替换」  | ✅ 单例统一「替换」      | 待实测        | ✅ 替换      | 直挂通道已挂载时仅更新内容；原生通道实测后统一（见 3.8）         |
| 生命周期                     | ✅ 系统窗口级、跨页面存活 | ✅ body 挂载、SPA 存活  | 待实测        | 与页面绑定   | 直挂窗口不随页面关闭消失；其余为表现层残余（见 1.4），文档明示   |

> App 列 = UTS 直挂系统窗口通道（v0.7，`uni_modules/unix-window`：Android WindowManager / iOS UIWindow，Spike 已于 Mi 10 Pro 真机验证全链路）；Web 列 = `#ifdef WEB` DOM 单例（v0.6 Q15）；鸿蒙端 UTS 插件形态不可用时回落原生通道并按微信列处理。

### 3.5 全局默认配置（已确认：提供）

```ts
/* 类似 createRouter 的 options 模式：允许项目级预设 */
configureToast(defaults: ToastDefaults): void
// ToastDefaults: { duration?: number, icon?: ToastIcon, mask?: boolean }
```

### 3.6 目录结构（对齐 unix-router 惯例：职责目录 + index.uts 桶文件）

```
packages/core/
├── package.json              # @meng-xi/unix-utils（已确认：单包工具集，toast 为子模块）
├── src/
│   ├── index.uts             # 统一入口
│   ├── toast/
│   │   ├── index.uts         # toast 模块桶：API / 类型 / 枚举 / 常量再导出
│   │   ├── show-toast.uts    # 主流程：归一化 → 通道分发 → 回调（showToast / showToastAsync / hideToast）
│   │   ├── shortcut.uts      # 语义化快捷 API（showToastSuccess / Error / Info）
│   │   ├── enums/            # 枚举（一枚举一文件 + 桶）
│   │   │   ├── toast-icon.uts      # ToastIcon（含扩展 WARNING）
│   │   │   ├── toast-position.uts  # ToastPosition
│   │   │   ├── toast-error-code.uts# ToastErrorCode
│   │   │   └── index.uts
│   │   ├── constants/        # 常量（按语义分文件 + 桶）
│   │   │   ├── defaults.uts        # DEFAULT_DURATION / DEFAULT_ICON / DEFAULT_MASK
│   │   │   ├── limits.uts          # title 截断上限
│   │   │   ├── keys.uts            # TOAST_ERR_SUBJECT
│   │   │   └── index.uts
│   │   ├── types/            # 类型（+ 桶）
│   │   │   ├── toast.uts           # ToastOptions / ToastFail / ToastDefaults / ...
│   │   │   └── index.uts
│   │   ├── config/           # 全局默认配置
│   │   │   └── index.uts           # configureToast / getToastDefaults（模块级单例）
│   │   ├── utils/            # 工具（+ 桶）
│   │   │   ├── platform.uts        # getPlatform / isSelfDrawPlatform
│   │   │   ├── normalize.uts       # 参数归一化与降级（纯函数，可单测）
│   │   │   └── index.uts
│   │   └── channels/         # 通道实现（按端隔离）
│   │       ├── native.uts          # uni 原生通道封装（微信 / 鸿蒙 + App fallback）
│   │       ├── web.uts             # #ifdef WEB 自绘通道（DOM 单例，v0.6 Q15）
│   │       └── app/                # App 自绘通道（#ifdef APP-ANDROID / APP-IOS）
│   │           └── self-draw.uts   # 直挂调用 + 双重降级（插件失败 → uni.showToast 原生通道）
│   └── types/
│       └── index.uts         # 全局类型再导出
└── uni-modules/
    └── unix-window/          # UTS 插件（v0.7 App 直挂通道实现，随 npm 包附带分发）
        ├── package.json      # uni_modules 插件清单（id: unix-window）
        └── utssdk/
            ├── index.uts           # Web / 小程序兜底空实现（+日志）
            ├── app-android/index.uts  # WindowManager 直挂（TYPE_APPLICATION_PANEL + Activity token）
            └── app-ios/index.uts      # UIWindow 直挂（getKeyWindow + addSubview）
```

> **`uni-modules/unix-window` 接入（v0.7）**：UTS 插件必须位于工程 `uni_modules/` 目录（官方规范不扫描 node_modules），故 npm 包附带 `uni-modules/` 目录，业务侧复制一行即可：
> `cp -R node_modules/@meng-xi/unix-utils/uni-modules/unix-window uni_modules/`
> 插件 API 采用**原始类型参数签名**（非 options 对象）：uts-proxy 不转发 type 导出，跨插件边界的对象类型签名会触发编译 warning 且运行时拿不到类型信息。`channels/app/self-draw.uts` 通过 `@/uni_modules/unix-window` 导入，插件挂窗失败时（activity / token 为 null、异常）经 fail 回调走 `uni.showToast` 原生降级并留痕日志。
> v0.6.2 的 dialogPage 承载页方案（`dialog-page.uvue` + pages.json 注册 + `DEFAULT_DIALOG_PATH`）已随 v0.7 退役，相关接入说明见修订记录。

实现分层：

```
业务调用 showToast(options)
      │
      ▼
normalize 层：icon 归一化 / duration 钳制 / 平台不支持参数降级 + 结构化日志
      │
      ▼
dispatch 层 = 按端分发到三通道（通道可替换）
   ├─ App 直挂窗口通道（App-Android / App-iOS 默认，v0.7）
   │    unix-window UTS 插件直挂系统窗口（Android WindowManager / iOS UIWindow）：
   │    免注册、触摸穿透 / 蒙层 / 动画 / 精确计时 / hideToast 全自管；
   │    #ifdef APP-ANDROID / APP-IOS 隔离；插件失败 → 原生通道双重降级
   ├─ Web 自绘通道（Web 默认，v0.6 Q15）
   │    #ifdef WEB DOM 单例（body 挂载 + 注入样式 + class 过渡 + setTimeout）
   ├─ uni 原生通道（微信 / 鸿蒙默认；App 端 fallback）
   │    uni.showToast——它本身就是官方原生实现，统一入口
   └─ UTS 扩展通道（后续演进）：unix-window 已落地窗口直挂，可继续扩展
      直调系统原生 API（如 Android 原生 Snackbar、iOS 触感反馈联动）
      │
      ▼
callback 层：success / fail / complete 回调透传，错误结构化
```

### 3.7 工程与验证

- **分发**：npm + uni_modules 双轨（见 Q10，对齐 unix-router 的 sync-uni-modules 机制）；npm 包 `main: src/index.uts`；App 直挂所需的 UTS 插件以 `uni-modules/unix-window` 目录随包附带，业务侧复制到工程 `uni_modules/`（见 3.6 接入说明，App 端接入仅此一步）；
- **验证**：`packages/playground` 覆盖 6 种 icon × 5 端、position 三值、mask、image、hideToast、连续调用，以**运行日志**为 DoD 依据（对齐 core-protocol 的 DoD 检查清单）；
- **连续调用语义**：统一为「后者替换前者」（与微信一致），待各端实测确认（见 3.8 风险）。

### 3.8 风险与待实测项

| 风险                               | 说明                                             | 缓解               |
| ---------------------------------- | ------------------------------------------------ | ------------------ |
| iOS 侧 Swift 编译门未过            | v0.7 仅完成 UTS→Swift 生成门（appResource 产物审计通过），Xcode 完整编译与真机验证因本机无 Xcode 未执行；NSNumber/CGFloat 桥接信任 DCloud 生成器 | 持有 Mac + Xcode 后补跑；Spike 同构代码曾通过 Swift 生成门，风险可控 |
| Android bottom y 方向语义 ✅ 已实测（M3） | BOTTOM gravity 的 y 以「向内（上）为正」（Gravity.apply：底边 = 容器底 − y）；实测传负值会把底边推到超屏方向、被系统 clamp 后**贴底显示**（dumpsys 取证 frame 底边 = display 底，无报错的静默位置错误）。已修正为正值：top 顶边距显示区顶 10%、bottom 底边距显示区底 10%（与 Web 10vh / iOS 底边锚定语义一致，观感调优 v0.7.2）；mask 两档统一双窗口架构（`buildCardParams()` 唯一来源），日志取证 y=220 两档一致 | M3 真机实测通过 |
| uts-proxy 类型转发限制             | 插件 API 不支持跨边界 type 导出，options 对象签名触发编译 warning | 插件 API 全部采用原始类型参数签名（已落实） |
| 插件分发依赖复制步骤               | UTS 插件必须位于工程 `uni_modules/`，node_modules 不被扫描 | npm 包附带 `uni-modules/` 目录 + README 一行 cp 命令；漏复制时 App 端编译期即报错（可发现性好） |
| 自绘通道残余遮挡（App 端）         | 窗口级直挂盖过页面树全部内容（含原生 tabbar 之上），但 `SurfaceView` 类独立图层（video 原生层、地图）与系统 UI（状态栏 / 导航栏 / 系统弹窗）仍在之上 | 已知约束写入文档；普通业务场景不受影响 |
| 直挂窗口与系统弹窗层级关系         | TYPE_APPLICATION_PANEL 子窗口位于 Activity 之上，但系统级弹窗（权限对话框、系统 Toast）层级更高；与 uni.showModal 原生 Dialog 的相对层级待实测 | M3 实测记录，文档标注 |
| mask=true 蒙层拦截语义 ✅ 触摸拦截已实测（M3） | 蒙层拦截触摸但不消费返回键；Android 返回键仍作用于业务页面栈——Mi 10 Pro 实测蒙层期间页面触摸被拦截生效（独立蒙层窗口 FLAG_NOT_FOCUSABLE\|FLAG_NOT_TOUCH_MODAL，不加 NOT_TOUCHABLE）；返回键语义未专门触发，待补 | 语义写入文档；与 dialogPage 方案（返回键可被消费）存在差异 |
| Android / iOS 双端一致性           | 两端窗口机制（WindowManager vs UIWindow）、动画、蒙层实现为两份代码，视觉细节可能漂移 | 共享参数语义 + M3 双端实测矩阵对齐 |
| Android bottom 系统 toast 时长粒度 | 仅影响原生 fallback 通道：系统 Toast 仅短/长两档，自定义 duration 可能失效 | 实测记录，文档标注 |
| 各端 icon=fail 实际渲染            | 官方仅说「生效范围」，未说其余端渲染结果（仅影响原生通道） | 实测矩阵补全       |
| 连续调用覆盖行为（原生通道）       | 各端可能排队 / 覆盖 / 叠加不一致——App 直挂通道已实测（M3）：同 mask 同 position 复用更新文案，mask / position 变化整体重建，语义「后者替换前者」；微信 / 鸿蒙原生通道仍待实测 | App 端实测通过；原生通道实测后确认 |
| HBuilderX 版本基线                 | 小程序端需 ≥4.41；UTS 插件需 ≥3.9（uts-proxy）   | 见 Q9              |

---

## 4. 需要你作答的疑问（Q&A）

> 每题附我的建议，可直接回复「全部按建议」或逐条批注。

**Q1 包名与模块划分** ✅ 已确认后续还有 showModal / clipboard / debounce 等工具，如何组织？

- A. 单包 `@meng-xi/unix-utils`，toast 为 `src/toast/` 子模块，命名空间导出 ✅
- B. 一功能一包（`@meng-xi/unix-toast`…），仓库内 monorepo 多包

**Q2 实现策略**（本设计最大分叉点）✅ 已确认（决策演进：v0.2 选 A → 经遮挡 / 渲染层级讨论后，v0.4 升级为分端混合）
- A. **原生适配层**：库内归一化后调用 `uni.showToast`。注意 `uni.showToast` 各端内部实现**本身就是原生**（Android 系统原生控件/系统 Toast、iOS 原生控件、微信平台组件、鸿蒙原生），uni API 是官方用原生写好的统一入口，不是原生的反义词。轻量、真原生，但**视觉随平台**、页面绑定差异无法抹平（v0.2 初选，v0.4 收窄为其他端的通道）
- B. **自绘统一层**：App/Web/小程序全部用库内组件自绘，视觉 100% 统一、生命周期完全可控，但小程序端失去「平台原生」、Web 端需挂载 DOM，且存在**层级遮挡风险**：小程序端 `video` / `map` / `camera` / `live-player` 等原生组件及 `showModal` 原生弹窗之上自绘 toast 不可达（同层渲染未生效的机型上 `z-index` 无效，`cover-view` 样式能力残缺无法补救），App 端 `SurfaceView` 类独立图层同样覆盖不了——自绘赢视觉一致性，输的是「全局提示的可达性」。（已否决；但注意 **App 端窗口级自绘不受页面树遮挡问题影响**——独立窗口天然盖过页面内容，这正是方案 C 在 App 端可行的关键）
- C. **混合可配置**：默认 A，`renderer: 'native' | 'custom'` 可切。多约 30% 工作量，但两头兼顾 ✅（v0.4 细化为**分端固定**而非运行时可配置：App = 自绘、其他端 = 原生；是否暴露 renderer 见 Q14）

✅ **最终决策（v0.4）——分端混合**：App-Android / App-iOS 采用**窗口级自绘**（dialogPage 承载页 + UTS 状态机），position 三值 / 精确 duration / 可靠 hideToast / 生命周期统一 / gif 等属性全生效；Web / 微信 / 鸿蒙保持 A（uni 原生通道 + 归一化）。

✅ **v0.6 修订（Q15）**：Web 移出原生通道、切入自绘（DOM 单例）；原生通道仅剩微信 / 鸿蒙。

✅ **v0.7 修订（Q13 演进）**：App 端窗口级自绘的承载方式由 dialogPage 切换为 UTS 直挂系统窗口（unix-window 插件），属性全生效语义不变；「窗口级自绘」通道定位不变，仅实现下沉到原生窗口层。

> **为什么不是「UTS 直调系统 API」**：Android 系统 `Toast` 不支持 icon/mask、duration 仅短/长两档（Android 11 后反射 hack 被禁），要支持就得自建 View 重画一遍官方已实现的内容；iOS 系统根本不存在 Toast API（任何 iOS toast 都是原生视图自绘）；微信沙箱仅 `wx.showToast` 一条路；Web 无系统 toast；鸿蒙 `promptAction.showToast` 与 uni API 等价。即绕过 uni API ≠ 原生程度提升，多数场景是能力降级或重复建设。仅当需要 uni API 未暴露的原生能力（如 Android 原生 Snackbar、iOS 触感反馈联动）时，UTS 直调才有价值 → 见 dispatch 层「UTS 扩展通道」设计。
>
> **为什么不是 subNVue**：subNVue 属旧 uni-app（nvue / plus 体系），uni-app x 架构上不存在该能力。App 端等价物 = `dialogPage`（`uni.openDialogPage`，v0.4–v0.6.2 的承载方式）或 UTS 直挂系统窗口（Android `WindowManager` / iOS `UIWindow`，v0.7 起的正式通道，见 Q13）。

**Q3 视觉一致性要求** ✅ 已确认（随 v0.2 方案 A 一并确认；v0.4 分端混合后收窄为：微信 / 鸿蒙接受「行为一致、视觉随平台」；v0.6 Q15 后 Web 亦由自绘通道统一视觉，App 端视觉由自绘通道统一）

- A. 接受，原生即可 ✅
- B. 不接受，核心场景必须视觉统一 → Q2 应选 B/C

**Q4 API 调用风格** ✅ 已确认

- A. 回调式，与 uni API 完全同构，迁移零成本（主）
- B. Promise 式：`await showToast(...)` 成功 resolve / 失败 reject（辅）
- C. 双轨提供 ✅（A 为主 + `showToastAsync`）

**Q5 语义化快捷 API** ✅ 已确认：需要，提供 `showToastSuccess / showToastError / showToastInfo`（命名即此）

**Q6 icon 超集** ✅ 已确认：扩展，新增 `warning` 警告图标（自绘通道真实渲染；原生通道降级为 `none` 并回调 PLATFORM_UNSUPPORTED）

**Q7 position 降级策略** ✅ A（降级为默认位置居中的普通 toast，fail 回调 PLATFORM_UNSUPPORTED；微信不支持；原生通道 Android 仅 bottom，自绘通道全支持；v0.6 起 Web 走自绘亦全支持）

**Q8 title 超长策略** ✅ A（库内按端截断：微信 7 汉字、鸿蒙 20 字 + 省略号，保证视觉不破；v0.6 起 Web / App 自绘通道不截断）

**Q9 平台范围与版本基线** ✅ 已确认

- 最小集：Android + iOS + Web + 微信小程序，对吗？
- HarmonyOS 是否纳入本期？（官方 4.61 支持，但需测试资源）
- HBuilderX 最低版本：跟随微信端需求定 **4.41+**？（unix-router 现状基线以你确认为准）

> ✅ 五端全含（Android / iOS / Web / 微信 / HarmonyOS）；HBuilderX 基线 4.41+（微信端最低要求），鸿蒙端实际可用性以 M3 实测为准。

**Q10 分发形式** ✅ B（npm + uni_modules 双轨）

**Q11 duration 钳制区间** ✅ 不限制（原样透传，不钳制）

**Q12 全局默认配置** ✅ 需要（`configureToast`）

**Q13 App 端自绘承载选型** ✅ 演进落定（v1 dialogPage：`uni.openDialogPage` 单实例复用；**v0.7 切换为 UTS 直挂** `WindowManager` / `UIWindow`——Spike 于 Mi 10 Pro 真机验证全链路通过（免注册挂窗 TYPE_APPLICATION_PANEL + Activity token、FLAG_NOT_TOUCHABLE 穿透、动画、自动/主动移除），dialogPage 承载页方案退役，实现收拢至 `uni_modules/unix-window` 插件）

**Q14 renderer 是否显式暴露** ✅ A（不暴露，按端自动：App / Web = custom、微信 / 鸿蒙 = native；内部预留切换能力）

**Q15 Web 通道归属** ✅ A（v0.6 新增：Web 切入自绘通道）
- 决策理由：Web 端 `uni.showToast` 本身即框架 DOM 实现，**没有原生能力加成**，且 position 仅 App、warning 不支持、title 受限——原生通道在 Web 上是「零收益 + 最多限制」的组合；而 Web 恰是自绘实现成本最低的平台（DOM/CSS 原生能力）。
- 实现：`#ifdef WEB` 的 DOM 单例（body 挂载 + 一次注入样式 + `textContent` 写入防 XSS + class 过渡动画 + `setTimeout` 精确计时）；连续调用替换内容复用单例；`hideToast` 淡出后复位蒙层。
- 联动变更：`isSelfDrawPlatform` 增加 `'web'`；truncateTitle 移除 Web 分支；dispatch 条件编译改为 `APP-ANDROID || APP-IOS || WEB` → 自绘、`#else` → 原生。
- 联动变更（v0.6.1 目录重构）：通道实现统一收拢至 `toast/channels/`（`native.uts` / `web.uts` / `app/`），enums / constants / types / config / utils 按职责拆目录并各设 `index.uts` 桶；`DEFAULT_DIALOG_PATH` 随承载页迁移同步更新为 `src/toast/channels/app/dialog-page`。重构过程中 web 编译暴露并修复了 `utils/normalize.uts` 漏 import `getPlatform` 的问题（否则运行时 ReferenceError）。对外 API 与 `@meng-xi/unix-utils` 导出零变化。

---

## 5. 里程碑（建议，待 Q&A 后细化）

| 阶段         | 内容                                                                                                  | DoD                         |
| ------------ | ----------------------------------------------------------------------------------------------------- | --------------------------- |
| M1 设计定稿 ✅ | 全部 Q1–Q15 落定                                                                                      | 已确认                      |
| M2a 原生通道 ✅ | normalize + uni 原生 dispatch + 回调/Promise 双轨，覆盖微信 / 鸿蒙（App 端亦可用原生通道兜底） | 五端编译通过                |
| M2b 自绘通道 ✅ | Web DOM 单例（v0.6 Q15）；v0.7 起 App 端由 dialogPage 承载页演进为 UTS 直挂（`uni-modules/unix-window` 插件，Spike 真机验证通过） | Android / iOS / Web 编译通过 |
| M3 全端验证  | playground 6 icon × 5 端矩阵实测，覆盖三通道与降级路径，补全 3.4 / 3.8 中「待实测」项（含 Android bottom 位移符号、mask 返回键语义、直挂与系统弹窗层级） | 运行日志验证，无运行时错误  |
| M4 文档      | README（中英）+ 抹平矩阵表 + uni-modules/unix-window 接入指南                                        | 与 unix-router 文档风格对齐 |

---

## 6. 修订记录

| 版本    | 日期       | 修订内容                                                                                                                                                                   |
| ------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v0.1–v0.5 | —          | 迭代定稿：通道方案 A → 分端混合 C（v0.4）、Q1–Q14 逐项落定、抹平矩阵与降级策略成形、里程碑拆分 M2a / M2b                                                                 |
| v0.6    | 2026-10-03 | 新增 Q15：Web 切入自绘通道（DOM 单例），`isSelfDrawPlatform` / truncateTitle / dispatch 条件编译联动；3.4 矩阵增 Web 列；M2b 扩围并标记编译通过                          |
| v0.6.1  | 2026-10-03 | 目录结构对齐 unix-router 规范：enums / constants / types / config / utils 职责目录 + `index.uts` 桶，通道实现归拢 `channels/`；`DEFAULT_DIALOG_PATH` 同步迁移；三端编译回归通过（web / app-android / mp-weixin），过程中修复 `utils/normalize.uts` 漏 import `getPlatform` |
| v0.6.2  | 2026-10-03 | App 接入简化：实测 `pages.json` 可直接注册 `node_modules` 包内承载页路径（app-android 产物含承载页字节码、mp-weixin 页面表正常、web 编译通过），接入从三步（复制 + 注册 + configureToast）降至一步（注册）；playground 删除副本页并移除 `configureToast` 调用，默认路径 `DEFAULT_DIALOG_PATH` 生效；README「App 端接入」、3.6 注释、3.8 风险表同步 |
| v0.7    | 2026-10-03 | **App 通道切换 UTS 直挂系统窗口（Q13 演进落定）**：Spike 于 Mi 10 Pro 真机验证通过后全面重构——core 包附带 `uni-modules/unix-window` UTS 插件（Android WindowManager TYPE_APPLICATION_PANEL + Activity token / iOS UIWindow getKeyWindow），免注册、穿透 / 蒙层 / 动画 / 计时全自管；`channels/app/self-draw.uts` 改为插件调用 + uni.showToast 双重降级；dialogPage 承载页方案退役（删除 dialog-page.uvue、pages.json 注册、DEFAULT_DIALOG_PATH / DIALOG_CLOSE_DELAY / 事件常量、ToastDefaults.dialogPath）；插件 API 采用原始类型参数签名（uts-proxy 不转发 type 导出）；App 端接入收敛为「复制 uni-modules/unix-window 到工程 uni_modules/」一步；image 参数在 App 端降级 icon 'none' + fail 回调。编译验证：web / mp-weixin 回归通过、app-ios Swift 生成门通过（Xcode 完整编译待补）、app-android UTS→Kotlin 生成门通过 |
| v0.7.1  | 2026-10-03 | **M3 Android 真机验证通过（Mi 10 Pro，HBuilderX 5.26）**：①修复 position 丢失——实测 `uni.getSystemInfoSync().uniPlatform` 返回 `'app'`（不含 android/ios 后缀），`isSelfDrawPlatform` 由运行时字符串匹配改为编译期条件编译判定；②修复 mask 两档 bottom 位置不一致——Android 插件重构为**双独立子窗口架构**（蒙层窗口先挂拦截触摸、卡片窗口后挂与 mask=false 共用 `buildCardParams()`，位置语义单一来源），日志取证两档参数一致；③连续调用复用/重建（lastMask+lastPosition）、蒙层触摸拦截、hideToast 提前隐藏均实测通过；过程坑：平台类型须显式 `import IBinder from 'android.os.IBinder'`（全限定名内联不识别）、可变全局变量判空后须先赋局部变量再使用（Kotlin smart cast 限制） |
| v0.7.2  | 2026-10-03 | **bottom 位置语义修复 + 纵向偏移调优**：①`dumpsys window` 实证 BOTTOM gravity 的 y「向内为正」，原 `y = -15%` 被 clamp 后实际贴底显示（预期 15% 的静默位置错误），修正为 `y = +10%`；②top / bottom 纵向偏移按观感统一由 15% 调整为 **10%**（Android `screenEdgeOffset` / iOS `0.1 & 0.9` / Web `10vh`，三端同步）；位置语义定稿：top 顶边距显示区顶 10%、bottom **底边**距显示区底 10%（等效 Web `bottom: 10vh`）、center 居中 |

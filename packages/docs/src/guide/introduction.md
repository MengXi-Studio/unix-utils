# 介绍

`@meng-xi/unix-utils` 是一个为 **uni-app x** 提供便利工具的库，与 [unix-router](https://mengxi-studio.github.io/unix-router/) 同属 MengXi-Studio，采用相同的工程范式：

- **UTS 源分发**：`main` 直接指向 `utssdk/index.uts`，由 uni-app x 编译链按目标平台现场编译（Web/小程序 → JS，Android → Kotlin，iOS → Swift）；
- **强类型 UTS**：`type` 定义对象类型、字面量联合定义枚举、无 `undefined`、严格条件布尔；
- **平台差异收敛在库内**：业务代码写一次，平台特有逻辑用条件编译（`#ifdef`）隔离在库内部。

当前模块为 **toast**：对 `uni.showToast` 的全端兼容封装。

## 为什么需要它

uni-app x 原生的 `uni.showToast` 在五端（Android / iOS / Web / 微信 / 鸿蒙）表现差异明显。以下事实全部来自官方文档与官方示例（2026-10 查证）：

| 差异点 | 现状 |
| --- | --- |
| **icon 合法值不对齐** | `fail` 仅支付宝、抖音小程序生效；`exception` 仅支付宝生效；其余端行为未定义 |
| **position 不可用** | 仅 App 生效，且 Android 仅支持 `bottom`（`top` / `center` 暂不支持）；设置后 icon 失效，且无法通过 `uni.hideToast()` 隐藏 |
| **生命周期绑定不一致** | iOS / 微信 / Web 的 toast 与页面绑定，页面关闭即消失；Android `bottom` 为系统 Toast，与 App 绑定 |
| **title 截断不一** | 微信 `success` / `loading` 图标下 title 最多显示 7 个汉字长度，超出截断；各端上限不同 |
| **warning 图标缺失** | 原生无警告图标，`warning` 等扩展图标直接不支持 |
| **错误信息粗糙** | 失败仅 `errCode` + `errMsg`，缺少「哪个参数、哪个端不支持」的结构化信息 |

unix-utils 用一条 `showToast` API 抹平这些差异。

## 两层兼容模型

兼容性差异分为两层，库的消除能力与承诺不同：

**功能层**（参数语义在各端是否生效）——库内归一化**全消除**：

- `fail` / `exception` 图标归一化为 `error`（自绘通道真实渲染）；
- `position` 三值（`top` / `center` / `bottom`）在 App / Web 自绘通道全支持；
- title 长度按端截断策略统一（微信 7 汉字、鸿蒙 20 字 + 省略号）；
- 失败信息结构化为 `ToastFail`（`errSubject` / `param` / `platform`）。

**表现层**（视觉样式、生命周期绑定、时长粒度、框架级 bug）——App / Web 端由自绘通道直接消除；其余端（微信 / 鸿蒙）保留原生通道，按三原则管理：

1. **可预期**：所有残余差异写入[参数抹平矩阵](/guide/channels#参数抹平矩阵)与文档，无隐藏行为；
2. **可见**：降级发生时 `fail` 回调返回结构化 [ToastFail](/api/type-toast-fail)，业务可感知；
3. **可替换**：需要更强表现时，App 端 UTS 直挂窗口通道直接消除本端全部表现层差异。

## 通道架构

各端自动选择最优通道，业务零配置：

| 端 | 通道 | 说明 |
| --- | --- | --- |
| App-Android / App-iOS | UTS 直挂系统窗口 | Android `WindowManager` / iOS `UIWindow` 免注册挂窗，position / warning / mask 全生效，失败自动降级 `uni.showToast` |
| Web | DOM 单例自绘 | position / warning / 不截断全生效 |
| 微信 / 鸿蒙 | `uni.showToast` 原生 | 不支持的参数自动降级并经 `fail` 回调留痕 |

详见[通道架构与降级](/guide/channels)。

## 核心能力一览

| 能力 | 说明 |
| --- | --- |
| 参数完全对齐 | `title / icon / image / mask / duration / position / success / fail / complete` 全部保留，迁移零成本 |
| icon 超集 | 原生 6 值 + 扩展 `warning`，`fail` / `exception` 各端归一化或真实渲染 |
| position 三值 | `top` / `center` / `bottom` 在 App / Web 自绘通道全支持（v0.7.2 定稿位置语义：距边 10%） |
| 双轨 API | 回调式 `showToast`（主）+ Promise 式 `showToastAsync`（辅） |
| 语义化快捷 | `showToastSuccess` / `showToastError` / `showToastInfo` 一行调用 |
| 全局默认 | `configureToast` 项目级预设 duration / icon / mask |
| 可靠隐藏 | `hideToast` 在自绘通道可靠隐藏（含 position 形态） |
| 结构化降级 | `ToastFail.errCode`（1001 参数非法 / 2001 平台不支持）+ `param` / `platform` 精确定位 |
| 强类型 | `ToastOptions` 除 `title` 外全可选字段，`icon` / `position` 为字面量联合类型 |

## 适合谁

- **需要跨端提示行为一致**：一套 API 覆盖五端，参数降级可预期、可感知。
- **受够了原生 toast 的差异**：position 不可用、icon 各端不对齐、微信 7 字截断——库里全部处理。
- **追求强类型与零依赖**：UTS 源分发，不引入任何第三方 UI 依赖。

## 下一步

- 想立即动手？从[安装](./installation)或[快速开始](./getting-started)开始。
- 想了解各端行为细节？查看[通道架构与降级](/guide/channels)。

## 0.1.0（2026-10-04）

首个版本：toast 模块（`uni.showToast` 全端兼容封装）。

### 新增

- **toast 模块**：对 `uni.showToast` 的全端兼容封装（Android / iOS / Web / 微信 / 鸿蒙五端），标准 uni_modules UTS 插件形态（`utssdk/` 官方目录结构 + `interface.uts` 对外声明），插件市场 + npm 双轨分发，业务侧统一 `import { showToast } from '@/uni_modules/unix-utils'`
- **参数完全对齐**：`title / icon / image / mask / duration / position / success / fail / complete` 与 `uni.showToast` 同构，迁移零成本；`ToastOptions` 除 `title` 外均为可选字段，`icon` / `position` / 错误码为字符串/数字字面量联合类型
- **分端混合通道**（自动分发，业务零配置）：
  - App-Android / App-iOS：UTS 直挂系统窗口（Android `WindowManager` / iOS `UIWindow` 免注册挂窗），position / warning / mask / 精确 duration 全生效，系统窗口级生命周期跨页面存活，挂窗失败自动降级 `uni.showToast` 原生通道
  - Web：DOM 单例自绘（position / warning / 无平台截断全生效）
  - 微信 / 鸿蒙：`uni.showToast` 原生通道，不支持的参数自动降级并留痕
- **icon 超集**：原生 6 值 + 扩展 `warning`；`fail` / `exception` 在原生端归一化为 `error`（多数端行为未定义），自绘通道真实渲染；`warning` 在原生端降级 `none` 并经 fail 回调留痕
- **position 三值全支持**：`top` / `center` / `bottom` 在自绘通道全生效，位置语义三端一致（top 顶边距显示区顶 10%、bottom 底边距显示区底 10%、center 居中）；原生通道端降级居中并留痕
- **双轨 API**：回调式 `showToast`（主）+ Promise 式 `showToastAsync`（辅）；语义化快捷 API `showToastSuccess` / `showToastError` / `showToastInfo`
- **`hideToast` 统一语义**：自绘通道可靠隐藏（含原生不支持隐藏的 position 形态）
- **全局默认配置 `configureToast`**：项目级预设 duration / icon / mask，字段传 `null` 表示沿用库内置默认（1500ms / `'success'` / `false`）
- **结构化失败信息 `ToastFail`**：`errCode`（1001 参数非法 / 2001 平台不支持）、`errSubject`（固定 `'unix-utils:toast'`）、`param`（触发降级的参数名）、`platform`（端标识），降级可感知、可过滤

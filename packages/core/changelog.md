# 更新日志

本文件遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 规范，
版本号遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

## [0.8.1] - 2026-10-04

### Fixed

- **ToastOptions 除 `title` 外全部改为可选字段**（真机实测修复）：UTS 插件代理层（uts-proxy）对必填字段生成非空强转（`null as Boolean`），业务侧漏传任意必填字段即触发 `NullPointerException`（如 `{ title, position }` 两字段调用崩溃于 `createUTSToastOptions`）；可选字段代理层才生成 null-safe 编码。实现层（normalize 等）本就全字段判空兜底，行为无变化
- 消除通道映射函数跨文件重名：`iconToString` / `positionToString` 在 native 通道与自绘通道各有一份（实现有差异），UTS 插件 native 编译时全部 `.uts` 合并同一 Kotlin package，同名 top-level 符号被静默重整为 `xxx__1`；现改为 `iconToNativeString` / `iconToSelfDrawString` 等按通道区分命名

### 已知无害现象

- 类型别名双声明（入口 `interface.uts` 与内部 `toast/enums/`）在 Kotlin 产物中产生 `ToastIcon__1` 等 typealias 重整：均为纯 String/Number 别名且引用自洽，uts-proxy 不转发 type 导出，业务侧不可见、无运行时影响

## [0.8.0] - 2026-10-04

### Changed（重构）

- **包形态改造**：core 整包从「npm 源码包 + 附带 uni-modules 子目录」改造为标准 **uni_modules UTS 插件**（`utssdk/` 官方目录结构），实现插件市场 + npm 双轨分发：
  - `src/` → `utssdk/`（对外 API 声明新增官方必需的 `interface.uts`）
  - `uni-modules/unix-window/`（App 直挂窗口插件）合并为插件内部 `utssdk/app-android/`、`utssdk/app-ios/` 平台实现，独立插件退役
  - Web DOM 自绘迁移至 `utssdk/web/` 官方平台目录
  - 微信 / 鸿蒙无平台目录，回落插件根 `index.uts`（uni 原生通道），与官方分发机制一致
- 业务侧引用方式变更：`import { showToast } from '@/uni_modules/unix-utils'`（插件市场导入或 npm 安装后同步至工程 `uni_modules/`）

### 兼容性

- toast 模块行为与 v0.7.2 完全一致（Android 双窗口蒙层架构、top/bottom 距边 10% 语义、降级链路、连续调用复用均未改动，仅目录与 import 归位）

## [0.7.2] - 2026-10-03

### Fixed

- Android bottom 档位 y 方向语义修正（BOTTOM gravity 以「向内」为正，负值被系统 clamp 后静默贴底），纵向偏移按观感定为屏高 10%
- 平台自绘判定改为编译期条件编译（`uni.getSystemInfoSync().uniPlatform` 实测返回 `'app'`，运行时字符串匹配不可靠）
- Android 蒙层与卡片改为双独立子窗口架构，两档 bottom 位置完全一致（共用 buildCardParams）

## [0.7.0] - 2026-10-03

### Changed

- App 通道切换为 UTS 直挂系统窗口（Android `WindowManager` / iOS `UIWindow`），免注册、触摸穿透 / 蒙层 / 动画 / 计时全自管；dialogPage 承载页通道退役

## [0.6.0] - 2026-10-03

### Added

- Web 端切换 DOM 单例自绘通道（position / warning / 无平台截断全生效）

## [0.5.0] - 2026-10-03

### Added

- toast 模块首个全端可用版本：App dialogPage 自绘 + Web 自绘 + 微信 / 鸿蒙原生

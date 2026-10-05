# 更新日志

本文件遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 规范，
版本号遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

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

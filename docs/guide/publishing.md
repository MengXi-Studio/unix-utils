# unix-utils 发布指南（npm + uni 插件市场双轨）

> 适用范围：`packages/core`（uni_modules UTS 插件形态，v0.8 起）。
> 事实依据：[npm docs](https://docs.npmjs.com/creating-and-publishing-unscoped-public-packages)、[DCloud 插件市场发布规范](https://uniapp.dcloud.net.cn/plugin/publish.html)（2026-10 查证）。

## 0. 双轨形态概览

```
packages/core/  ──┬── npm 发布为 @meng-xi/unix-utils（main: utssdk/index.uts）
                  └── 插件市场提交为 uni_modules 插件「unix-utils」（zip 根目录 = 插件 id）
```

同一份源码两种分发，业务侧统一 `import { showToast } from '@/uni_modules/unix-utils'`：

| 分发方式 | 安装动作 | 落位 |
| --- | --- | --- |
| 插件市场 | HBuilderX 导入插件 | 工程 `uni_modules/unix-utils/` |
| npm | `pnpm add @meng-xi/unix-utils` 后复制包内容 | 工程 `uni_modules/unix-utils/`（编译器不扫描 node_modules） |

## 1. 发布前置检查（每次发布必做）

- [ ] `changelog.md` 已补充本版本条目（插件市场展示依赖此文件）
- [ ] `package.json` 版本号已更新（`pnpm release` 走 bumpp 交互式选版本）
- [ ] 四门编译通过：web / mp-weixin / app-android（真 Kotlin）/ app-ios（Swift 生成）
- [ ] playground 真机回归通过（Mi 10 Pro，DoD 按运行日志取证）
- [ ] `pnpm sync:uni-modules:check` 确认 playground 插件副本与 core 同步

## 2. npm 发布

```bash
cd packages/core

# 2.1 发布前预检（可选）：确认 files 白名单内容
npm publish --dry-run

# 2.2 正式发布（首次发布需先 npm login）
npm publish --access public
```

要点：

- 包名 `@meng-xi/unix-utils`（scope 公开包，`--access public` 必带）；
- `files` 白名单含 `utssdk`、`changelog.md`、`README.md`，源码直发（UTS 源码分发，由业务侧编译链按端现场编译）；
- npm 版本与插件市场版本**保持一致**，以 `package.json` + `changelog.md` 为唯一事实源。

## 3. uni 插件市场发布

官方规范要点（已查证）：

- 提交物为**单个 uni_modules 模块目录**：HBuilderX 中右键该目录 → 「提交到插件市场」，或上传 zip（**zip 根目录 = 插件 id**，即 zip 内直接是 `utssdk/`、`package.json`、`changelog.md` 等文件，不得嵌套外层目录）；
- UTS 插件**免审核**，支持付费；
- 插件依赖在 `package.json` 的 `uni_modules.dependencies` 声明（本插件当前无依赖，空数组即可）；市场安装时自动装最新版依赖，**不锁版本**。

操作步骤：

1. HBuilderX 打开含 `packages/core` 的工程，右键 core 目录 → 提交到插件市场（或手动 zip：进入 `packages/core/` 目录内全选文件压缩，确保 zip 根即插件内容）；
2. 按 [插件市场发布页](https://ext.dcloud.net.cn/) 表单填写：插件 id `unix-utils`、名称、分类、价格（当前免费）；
3. 提交后在插件市场后台查看审核状态（UTS 插件免审核，通常即时上架）。

> 注意：`packages/core/package.json` 中的 `id: unix-utils` / `displayName` / `dcloudext` 字段即插件市场元数据，发布前勿改名；npm 的 `name`（`@meng-xi/unix-utils`）与插件市场 id（`unix-utils`）是两个体系的标识，靠 `uni_modules` 目录名约定对齐。

## 4. 版本发布顺序（建议）

```
changelog + 版本号 → 四门编译 → 真机回归 → npm publish → 插件市场提交 → README/docs 校对
```

先 npm 后市场：npm 包内容即市场 zip 内容，npm 发好后可直接复用同一份产物打 zip，避免两处源码漂移。

## 5. 业务侧升级说明（写入 README / 市场介绍）

- npm 轨道升级：重装包并重新复制到 `uni_modules/`；
- 市场轨道升级：HBuilderX 插件市场更新插件；
- 破坏性变更（如 0.8 的 import 路径变更）在 `changelog.md` 的 Breaking 区块明确标注迁移步骤。

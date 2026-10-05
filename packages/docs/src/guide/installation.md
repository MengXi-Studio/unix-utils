# 安装

## 前置要求

- **uni-app x** 项目（`.uvue` 页面 + `pages.json`）；
- **HBuilderX 4.41+**（微信小程序端 `uni.showToast` 的最低版本要求，也是全端基线）；
- 各端 `uni.showToast` 的可用版本：Web ≥ 4.0、Android ≥ 3.91、iOS ≥ 4.11、微信 ≥ 4.41、鸿蒙 ≥ 4.61（库内已按端处理，业务无需关心）。

## 安装方式

unix-utils 为标准 **uni_modules UTS 插件**，插件市场 + npm 双轨分发，二选一即可。

### 方式一：插件市场（推荐）

在 HBuilderX 中从 [插件市场](https://ext.dcloud.net.cn/) 搜索 `unix-utils`，导入到工程 `uni_modules/` 目录。

### 方式二：npm

npm 包安装后需将包内容复制到工程 `uni_modules/unix-utils/`——UTS 插件必须位于工程 `uni_modules/`，编译器**不扫描 node_modules**：

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

> 漏复制时 App 端编译期即报错（可发现性好），Web / 小程序端表现为模块找不到。

## 验证安装

安装完成后，在任意 `.uvue` 页面中导入并调用：

```ts
import { showToast } from '@/uni_modules/unix-utils'

showToast({ title: '安装成功' })
```

运行后看到提示即安装成功。如需查看当前命中的通道与降级情况，可在 `fail` 回调中读取结构化信息（见 [ToastFail](/api/type-toast-fail)）。

## 升级

- **插件市场轨道**：HBuilderX 插件市场更新插件；
- **npm 轨道**：重新安装并重新复制到 `uni_modules/`；
- 破坏性变更（如 v0.8 的 import 路径变更）在 [更新日志](/changelog) 的对应版本区块标注迁移步骤。

## 下一步

前往[快速开始](./getting-started)发出第一条 toast。

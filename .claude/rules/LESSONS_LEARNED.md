# 经验教训记录（Strict：仅记录经运行验证的坑）

## 2026-10-03 toast 真机验证（Mi 10 Pro / HBuilderX 5.26）

### 运行时坑
1. **openDialogPage 页面路径必须带前导 `/`**：不带斜杠的路径（如 `node_modules/.../dialog-page`）会被运行时按相对路径解析到当前页面目录下（errMsg 实例：`/pages/index/node_modules/...`），且 fail 回调默认静默——表现为"点击无反应"。已在 `resolveDialogPath()` 统一补斜杠 + fail 回调留痕。（v0.7 起 dialogPage 通道退役，本条保留给历史方案排查）
2. **pages.json 编译通过 ≠ 页面路由可用**：v0.6.2 只做了编译回归，此 bug 存活到真机运行才暴露。凡是"编译通过但运行静默无效"的问题，优先怀疑路径/路由解析。
3. **MIUI 真机 adb 限制**：安装基座需开「USB 安装」；`adb shell input` 注入触摸被 INJECT_EVENTS 拦截（需「USB 调试（安全设置）」，门槛高，改为人手点 + logcat 取证）；HBuilderX 自带 adb（`plugins/launcher-tools/tools/adbs/adb`）在多客户端访问时会瞬时 `Input/output error`，重试即可。
4. **设备端连拍截屏**：Mac 侧循环 `adb exec-out screencap` 不稳，改 `adb shell` 内 for 循环写 /sdcard 再 `adb pull` 批量拉回，用文件大小差异筛出含目标 UI 的帧。

### UTS 直挂窗口通道（Spike 结论，Q13 预留验证）
5. **原生 API 必须走 uni_modules uts 插件形态**：项目级 `.uts` 文件 `import android.*` 会 Rollup 解析失败；代码放 `uni_modules/<id>/utssdk/app-android|app-ios/index.uts`，非 App 平台由 `utssdk/index.uts` 兜底。
6. **~~`publish appResource` 只做 UTS 层检查~~（v0.7 修正）**：`launch --compile true` 官方语义是「编译模式运行（只编译代码）」= **仅前端编译，不触发 Kotlin 编译**（9-15s 结束是正常行为）。真 Kotlin 编译产物是 `unpackage/cache/vapor/uts_standard_android/app-android/uts/uni_modules/<id>/classes.dex`，在 launch 实际运行到设备（不带 --compile）时生成/复用；`publish appResource` 只产出 `.kt` 源码（Swift 同理）不产出 dex。Float 类型错误（error17）在 dex 编译阶段暴露。
7. **Double→Float 必须显式 `.toFloat()`**：字面量直接传 Float 参数报错，连 `let f: Float = 16.0` 声明都会被 Kotlin 拒绝（生成代码无 f 后缀）；DCloud 官方惯用法是 `num.toFloat()`。
8. **Swift 不对 var 可选做智能解包**：UTS 里 nil 检查后直接访问可选值，生成的 Swift 编译不过；UTS 侧要写显式 `existing!.text`。`UIColor` 用 Swift 名（`white`/`gray`，非 `whiteColor`）。
9. **TYPE_APPLICATION_PANEL + Activity window token 子窗口免悬浮窗权限**，`FLAG_NOT_TOUCHABLE` 穿透真机验证有效（toast 显示期间点击其下按钮正常触发）；`UTSiOS.getKeyWindow()` 返回非可空 UIWindow（官方文档）。

## 2026-10-03 toast v0.7 UTS 直挂重构（编译验证通过）

### 工具链坑
10. **uts-proxy 不转发 type 导出**：UTS 插件 API 若用对象类型签名（`options: WindowToastOptions`），业务侧 import 该 type 会触发编译 warning（`"X" is not exported by "uni_modules/<id>?uts-proxy"`）且运行时无类型信息。插件 API 必须用**原始类型参数签名**（`title: string, icon: string, ...`）。
11. **插件跨包导入路径**：core npm 包源码内写 `import { ... } from '@/uni_modules/unix-window'`，编译时解析到**工程** `uni_modules/` 下的插件（npm 源码与工程插件靠 id 约定解耦，UTS 插件必须由业务侧复制到工程 uni_modules/，node_modules 不被扫描）。
12. **HBuilderX cli 实际路径**：`/Applications/HBuilderX.app/Contents/MacOS/cli`（`Contents/HBuilderX/cli` 不存在）。cli 输出管道接 `| tail` / `| grep` 会让 exit code 失真（tee 也会掩盖命令 not found），**必须检查日志内容本身**判断成败（grep 精确成功/失败关键词）。
13. **判定 Kotlin 产物新旧**：`launch` 日志「uts插件[xxx]文件未发生变化，跳过编译」+ 缓存目录时间戳（cache/vapor/.../uni_modules/<id>）+ 基座 `dumpsys package io.dcloud.uniappx` 的 lastUpdateTime 三者结合判断；标准基座不随 UTS 插件更新（dex 随「同步手机端程序文件」下发），基座更新时间早于源码修改时间不代表插件没编译。

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

## 2026-10-03 toast v0.7.1 M3 真机验证通过（position 丢失 + mask 双档 bottom 不一致修复）

### 运行时坑
14. **`uni.getSystemInfoSync().uniPlatform` 实际返回 `'app'`**（Mi 10 Pro / HBuilderX 5.26 实测，官方值域不含 `app-android`/`app-ios` 后缀）：按字符串匹配 `'app-android'` 判端会把 App 端误判为非自绘平台，position / image 被静默降级。平台归属编译期即定，**通道判定必须用条件编译**（`#ifdef APP-ANDROID || APP-IOS || WEB`），不依赖运行时 API。
15. **UTS 平台类型必须显式 import，全限定名内联不识别**：参数类型写 `android.view.IBinder` 报「找不到名称 IBinder」（且 IBinder 实际在 `android.os` 包），正确写法 `import IBinder from 'android.os.IBinder'` + 类型标注 `token: IBinder`。
16. **Kotlin smart cast 限制穿透 UTS**：可变全局变量（`View | null`）判空后直接传参报 `Smart cast to 'View' is impossible`；必须先赋局部变量再判空使用（`const oldMask = maskRoot; if (oldMask != null) { fn(oldMask) }`）。iOS Swift 侧同类问题靠显式 `!` 断言（见第 8 条）。
17. **mask 蒙层与卡片定位基准差异**：mask=true 若用全屏 FrameLayout 内嵌卡片以 margin 定位，基准延伸到系统手势区，与 mask=false 的窗口 gravity 定位差 ≈ 系统手势区高度（~140px 实测差异明显）。**正确架构：蒙层与卡片拆成两个独立 TYPE_APPLICATION_PANEL 子窗口**——蒙层先挂（在下，MATCH_PARENT、不加 FLAG_NOT_TOUCHABLE 实现拦截），卡片后挂（在上，布局参数与 mask=false 完全一致 `buildCardParams()` 唯一来源，FLAG_NOT_TOUCHABLE 永远穿透）；同 type 同 token 后挂 z-order 更高，天然盖住蒙层。
18. **WindowManager BOTTOM gravity 的 y 以「向内（上）为正」**（Gravity.apply：底边 = 容器底 − y）：传负值会把窗口推到超屏方向，被系统 **clamp 后静默贴底显示**（无任何报错的位置错误）；TOP gravity 则正值向下（top = 容器顶 + y）。取证方式：`adb shell dumpsys window windows` 找 TYPE_APPLICATION_PANEL 子窗口的 `Frames: ... frame=[l,t][r,b]`，对照 display 区间判断实际贴边（实测贴底时 frame.bottom = display 底 2296）。偏移基准 heightPixels（2200）与 display 高（2206）基本一致，可直接做百分比换算。

## 2026-10-04 toast v0.8 uni_modules 单插件改造（四门编译 + 真机回归通过）

### UTS 插件 native 编译坑（符号重整真根因，b5a 攻坚定论）
19. **插件全部 .uts 合并同一 Kotlin package，同名 top-level 符号一律静默重整**：任何形式的同名冲突（实现函数与入口 API 同名、已删文件的悬空调用解析出的孤儿符号、跨文件重名的工具函数、内部常量与入口常量同名）都会让编译器对**导出符号**加 `__1` 后缀（`showToast` → `showToast__1`），业务侧 import 报 `"xxx" is not exported by ?uts-proxy`，且**编译全程无 error**。修复范式：实现函数全加 `Impl` 后缀、内部同语义常量改名 `BUILTIN_*/ERR_*` 前缀、删除残留桶文件、跨文件同名工具函数按通道命名（`iconToNativeString` / `iconToSelfDrawString`）。取证方式：grep 生成 `index.kt` 中的 `__1` 残留。
20. **同名 typealias 的重整是自洽无害的**：入口 `interface.uts` 与内部 `enums/` 双声明同一字面量联合类型（如 `ToastIcon`），产物出现 `ToastIcon__1` 等纯别名重整——引用自洽、uts-proxy 不转发 type 导出业务不可见、无运行时影响，不必消除（与第 19 条的「导出符号重整」严格区分）。
21. **uts-proxy 代理层对必填字段生成非空强转**：`ToastOptions` 若声明 `mask: boolean`（必填），代理函数生成 `options.get("mask") as Boolean`（非空 cast），业务漏传即 NPE（`null cannot be cast to non-null type kotlin.Boolean`，崩溃点 `createUTSToastOptions`）；可选字段（`?`）才生成 `as Boolean?` null-safe 编码。**对外 API 的 options 类型除真正必填项外一律声明可选**，实现层判空兜底。取证：grep 生成 index.kt 的 create 函数。

### 部署与工具链坑
22. **HBuilderX GUI「运行」不保证推送新资源**：M4/M5 两次真机回归中手机 www 时间戳停在旧版本（GUI 静默回退/未制作基座），改用 CLI 直部署稳定复现：`cli launch app-android --project <绝对路径> --deviceId <id> --cleanCache true`。**新包判定标准：console 日志的 at 路径**（新结构 = `uni_modules/unix-utils/utssdk/toast/channels/app/window-android.uts`，旧包显示 `uni_modules/unix-window/...`）。
23. **`rm -rf unpackage/dist` 偶发 "Directory not empty"**：HBuilderX/编辑器进程并发写入所致，直接重跑同一命令即可；发布前全清 `unpackage/cache` + `unpackage/dist` 防缓存污染。
24. **Agent 沙箱会干扰 adb exec（间歇 `Input/output error: adb`，exit 127）**：二进制本身完好（file 校验正常），疑似沙箱对 USB 设备访问的拦截；对 adb 类命令使用非沙箱模式（dangerouslyDisableSandbox）后稳定。同命令时好时坏时优先怀疑执行环境而非工具本身。

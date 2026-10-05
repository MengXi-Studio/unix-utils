# Toast 提示

toast 是 unix-utils 的首个模块：对 `uni.showToast` 的全端兼容封装。本页覆盖日常使用的全部姿势与注意点。

## 基本用法

```ts
showToast({
	title: '已复制到剪贴板',
	icon: 'success',
	duration: 2000
})
```

参数与 `uni.showToast` 完全同构（`title / icon / image / mask / duration / position / success / fail / complete`），迁移零成本。除 `title` 外均为可选字段，完整字段表见 [ToastOptions](/api/type-toast-options)。

## 图标

`icon` 为字符串字面量联合类型，直接传字面量即可：

```ts
showToast({ title: '成功', icon: 'success' })   // 成功图标（默认值）
showToast({ title: '失败', icon: 'error' })     // 错误图标
showToast({ title: '加载中', icon: 'loading' }) // 加载图标
showToast({ title: '纯文字', icon: 'none' })    // 不显示图标
showToast({ title: '警告', icon: 'warning' })   // 扩展值：unix-utils 新增
```

各端行为差异由库内归一化处理：

| icon 值 | App / Web 自绘通道 | 微信 / 鸿蒙原生通道 |
| --- | --- | --- |
| `success` / `error` / `loading` / `none` | ✅ 真实渲染 | ✅ 真实渲染 |
| `fail` / `exception` | ✅ 真实渲染 | 归一化为 `error`（原值多数端未定义） |
| `warning`（扩展） | ✅ 真实渲染 | 降级为 `none`，`fail` 回调留痕（errCode 2001） |

## 位置

`position` 支持三值，App / Web 自绘通道全支持：

```ts
showToast({ title: '顶部提示', position: 'top' })
showToast({ title: '居中提示', position: 'center' })
showToast({ title: '底部提示', position: 'bottom' })
```

位置语义（v0.7.2 定稿）：`top` 顶边距显示区顶 10%、`bottom` 底边距显示区底 10%（等效 Web `bottom: 10vh`）、`center` 居中。三端一致。

注意：

- 微信 / 鸿蒙原生通道不支持 position，自动降级为居中并经 `fail` 回调留痕（errCode 2001）；
- 自绘通道下 position 形态的 toast 仍可被 [hideToast()](/api/hide-toast) 可靠隐藏（原生通道做不到）。

## 蒙层与自定义图

```ts
// mask：显示透明蒙层，防止触摸穿透
showToast({ title: '提交中…', icon: 'loading', mask: true })

// image：自定义图标本地路径（Web 自绘通道支持 gif）
showToast({ title: '自定义图', image: '/static/custom.png' })
```

`image` 在 App 直挂通道暂不渲染（降级为无图标并经 `fail` 回调留痕）；微信 / 鸿蒙原生通道检测 `.gif` 后缀后降级为不展示。

## 全局默认配置

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})
```

- `showToast` 未传对应字段时使用全局默认；全局默认未设置时使用库内置默认（1500ms / `'success'` / `false`）；
- 全局默认只影响默认值，不改变任何降级行为。

## 连续调用

连续调用 `showToast` 的语义统一为**后者替换前者**（与微信一致）：

- App 直挂通道：同 mask 同 position 时复用窗口仅更新内容，mask / position 变化时整体重建；
- Web 自绘通道：DOM 单例替换内容；
- 原生通道：微信实测为替换行为。

## duration

不钳制、原样透传，自绘通道以计时器精确控制。原生通道端（微信 / 鸿蒙）实际粒度受平台约束（如 Android fallback 的系统 Toast 仅短/长两档）。

## title 长度

自绘通道（App / Web）无平台截断，全生效；微信 / 鸿蒙原生通道按端截断（微信 7 汉字、鸿蒙 20 字，超出加省略号），保证视觉不破。

## 生命周期

- App 直挂通道为系统窗口级，**跨页面存活**——页面关闭 toast 不消失；
- Web 自绘通道挂载于 body，SPA 内存活；
- 微信原生通道的 toast 与页面绑定，页面关闭即消失（表现层残余，详见[通道架构与降级](./channels)）。

## 下一步

- 了解每条降级何时发生、业务如何感知：[通道架构与降级](./channels)；
- 每个参数的完整类型定义：[ToastOptions](/api/type-toast-options)。

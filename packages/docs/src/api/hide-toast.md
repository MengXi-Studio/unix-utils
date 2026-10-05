# hideToast()

隐藏当前显示的 toast。

## 类型

```ts
export const hideToast: () => void
```

## 参数

无。

## 示例

```ts
import { showToast, hideToast } from '@/uni_modules/unix-utils'

showToast({ title: '正在处理…', icon: 'loading', duration: 0 })
// 业务完成后手动隐藏
hideToast()
```

## 各端行为

| 端 | 行为 |
| --- | --- |
| App 直挂通道 | 主动移除挂载视图，可靠隐藏 |
| Web 自绘通道 | DOM 单例淡出后复位蒙层，可靠隐藏 |
| 微信 / 鸿蒙原生通道 | 尽力而为（透传 `uni.hideToast()`） |

原生 `uni.showToast` 的 position 形态 toast 官方明确不支持隐藏；unix-utils 在自绘通道消除了该限制，position 形态亦可可靠隐藏。

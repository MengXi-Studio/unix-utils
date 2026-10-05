# configureToast()

设置 toast 的全局默认配置（项目级预设），未传字段的 `showToast` 调用将使用这里的默认值。

## 类型

```ts
export const configureToast: (defaults: ToastDefaults) => void
```

## 参数

### defaults: ToastDefaults

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `duration` | `number \| null` | 默认展示时长（毫秒）；`null` 表示沿用库内置默认（1500ms） |
| `icon` | [ToastIcon](/api/type-enums#toasticon) \| `null` | 默认图标；`null` 表示沿用库内置默认（`'success'`） |
| `mask` | `boolean \| null` | 默认是否显示蒙层；`null` 表示沿用库内置默认（`false`） |

## 示例

```ts
import { configureToast } from '@/uni_modules/unix-utils'

configureToast({
	duration: 2000,  // 默认展示时长
	icon: 'success', // 默认图标
	mask: false      // 默认是否显示蒙层
})

// 之后未传对应字段的调用使用全局默认
showToast({ title: '已保存' }) // icon=success duration=2000 mask=false
```

## 优先级

调用参数 > 全局默认（configureToast） > 库内置默认（1500ms / `'success'` / `false`）。

## 注意事项

- 全局默认只影响**默认值**，不改变任何降级行为；
- 对应导出常量 `DEFAULT_DURATION` / `DEFAULT_ICON` / `DEFAULT_MASK` 即库内置默认值。

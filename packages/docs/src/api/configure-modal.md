# configureModal()

设置 modal 的全局默认配置（项目级预设），未传对应字段的 `showModal` 调用将使用这里的默认值。

## 类型

```ts
export const configureModal: (defaults: ModalDefaults) => void
```

## 参数

### defaults: ModalDefaults

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `confirmText` | `string \| null` | 默认确认按钮文案；`null` 表示沿用库内置默认（`'确定'`） |
| `cancelText` | `string \| null` | 默认取消按钮文案；`null` 表示沿用库内置默认（`'取消'`） |
| `confirmColor` | `string \| null` | 默认确认按钮颜色；`null` 表示恢复「未设置」状态——透传平台默认色（Web 自绘回退 `'#007aff'`） |
| `cancelColor` | `string \| null` | 默认取消按钮颜色；`null` 表示恢复「未设置」状态——透传平台默认色（Web 自绘回退 `'#000000'`） |

## 示例

```ts
import { configureModal } from '@/uni_modules/unix-utils'

configureModal({
	confirmText: '知道了',
	confirmColor: '#00aa00',
	cancelText: null,    // 沿用库内置默认 '取消'
	cancelColor: null    // 恢复透传平台默认色
})

// 之后未传对应字段的调用使用全局默认
showModal({ title: '提示', content: '已同步' }) // 确认按钮显示「知道了」（#00aa00）
```

## 优先级

调用参数 > 全局默认（configureModal） > 库内置默认（`'确定'` / `'取消'`）/ 平台默认色。

## 注意事项

- 全局默认只影响**默认值**，不改变任何降级行为（非法颜色传入 `configureModal` 同样会在调用时降级留痕）；
- 颜色字段与调用参数的 `null` 语义一致：`null` = 透传平台默认色，而非设置某个颜色；
- 对应导出常量 `DEFAULT_CONFIRM_TEXT` / `DEFAULT_CANCEL_TEXT` / `DEFAULT_CONFIRM_COLOR` / `DEFAULT_CANCEL_COLOR` 即库内置默认值。

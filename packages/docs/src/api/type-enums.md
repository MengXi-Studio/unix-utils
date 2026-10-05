# ToastIcon / ToastPosition / ToastErrorCode

toast 模块的字面量联合类型。注意：这些是**字符串 / 数字字面量联合**（非 enum），直接传字面量即可——UTS enum 无法跨 UTS 插件代理边界（uts-proxy），故对外契约统一为字面量联合。

## ToastIcon

toast 图标，对齐 `uni.showToast` 官方 `icon` 参数并扩展 `warning`：

```ts
export type ToastIcon =
	| 'success'    // 成功图标（默认值）
	| 'error'      // 错误图标
	| 'fail'       // 错误图标（别名，title 无长度显示）
	| 'exception'  // 异常图标（title 无长度显示）
	| 'warning'    // 警告图标（unix-utils 扩展）
	| 'loading'    // 加载图标
	| 'none'       // 不显示图标
```

各端行为（详见[参数抹平矩阵](/guide/channels#参数抹平矩阵)）：

| 值 | App / Web 自绘通道 | 微信 / 鸿蒙原生通道 |
| --- | --- | --- |
| `success` | ✅ | ✅ |
| `error` | ✅ | ✅ |
| `fail` | ✅ 真实渲染 | 归一化为 `error`（原值仅支付宝、抖音生效，其余端未定义） |
| `exception` | ✅ 真实渲染 | 归一化为 `error`（原值仅支付宝生效） |
| `warning` | ✅ 真实渲染 | 降级为 `none` + fail 回调留痕（2001） |
| `loading` | ✅ | ✅ |
| `none` | ✅ | ✅ |

## ToastPosition

toast 位置：

```ts
export type ToastPosition = 'top' | 'center' | 'bottom'
```

- 自绘通道（App / Web）三值全支持，位置语义：`top` 顶边距显示区顶 10%、`bottom` 底边距显示区底 10%、`center` 居中（v0.7.2 定稿，三端一致）；
- 原生通道端（微信 / 鸿蒙）不支持，降级居中 + fail 回调留痕（2001）。

## ToastErrorCode

toast 失败码（数字字面量联合，对齐官方错误码模式）：

```ts
export type ToastErrorCode = 1001 | 2001
```

| 值 | 常量 | 含义 |
| --- | --- | --- |
| `1001` | `TOAST_ERR_PARAM_INVALID` | 参数非法（如 App 端 image 传 gif） |
| `2001` | `TOAST_ERR_PLATFORM_UNSUPPORTED` | 参数当前端不支持且已降级（信息级，toast 照常显示） |

## 相关

- [ToastOptions](/api/type-toast-options) —— 字段使用场景
- [ToastFail](/api/type-toast-fail) —— 错误码消费方

/**
 * RouteNameMap 字面量类型增强（由 @meng-xi/unix-router/vite-plugin 生成）
 * 供 WEB 端 RouteName 类型推导；原生端 UTS 不支持 keyof 组合，仍为 string。
 */
import '@/uni_modules/ux-router/utssdk/index.uts'

declare module '@/uni_modules/ux-router/utssdk/index.uts' {
	interface RouteNameMap {
		/** unix-utils */
		home: 'pages/index/index'
		/** Promise 异步 */
		'modal-async': 'pages-sub/modal-async/modal-async'
		/** 基础弹窗 */
		'modal-basic': 'pages-sub/modal-basic/modal-basic'
		/** 颜色体系 */
		'modal-color': 'pages-sub/modal-color/modal-color'
		/** 全局配置 */
		'modal-config': 'pages-sub/modal-config/modal-config'
		/** 校验与降级 */
		'modal-error': 'pages-sub/modal-error/modal-error'
		/** 输入能力 */
		'modal-input': 'pages-sub/modal-input/modal-input'
		/** 交互行为 */
		'modal-interact': 'pages-sub/modal-interact/modal-interact'
		/** 平台原生探针 */
		'modal-probe': 'pages-sub/modal-probe/modal-probe'
		/** 文案与滚动 */
		'modal-text': 'pages-sub/modal-text/modal-text'
		/** toast 快捷 API */
		'toast-basic': 'pages-sub/toast-basic/toast-basic'
		/** toast 交互与降级 */
		'toast-interact': 'pages-sub/toast-interact/toast-interact'
	}
}

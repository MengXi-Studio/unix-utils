import { defineConfig } from 'vitepress'

/** 网站部署基础路径（CI 可经 DOCS_BASE 注入，本地默认 /unix-utils/） */
export const base = process.env.DOCS_BASE || '/unix-utils/'

/** 将根路径资源拼接到当前 base 下，避免 favicon 等资源 404 */
const asset = (p: string) => base + p.replace(/^\//, '')

export const sharedConfig = defineConfig({
	/** 网站标题 */
	title: 'Unix Utils',

	lastUpdated: true,

	markdown: {
		/** 代码块高亮主题 */
		theme: {
			dark: 'one-dark-pro',
			light: 'github-light'
		},
		/** UTS 是 TypeScript 的超集，按 TypeScript 高亮 */
		languageAlias: { uts: 'typescript' }
	},

	/** 网站头标签 */
	head: [
		['link', { rel: 'icon', type: 'image/png', href: asset('logo.png') }],
		['link', { rel: 'icon', href: asset('favicon.ico') }],

		['meta', { property: 'og:type', content: 'website' }],
		['meta', { property: 'og:title', content: 'Unix Utils' }],

		['meta', { property: 'twitter:title', content: 'Unix Utils' }],
		['meta', { property: 'twitter:card', content: 'summary_large_image' }],
		['meta', { property: 'twitter:description', content: '为 uni-app x 提供便利工具的 UTS 工具库（插件市场 + npm 双轨分发）' }]
	],

	/** 网站主题配置 */
	themeConfig: {
		/** 主题 logo（VitePress 自动拼 base） */
		logo: '/logo.png',

		/** 本地搜索 */
		search: {
			provider: 'local',
			options: {
				translations: { button: { buttonText: '搜索文档', buttonAriaLabel: '搜索文档' } }
			}
		},

		/** 社交链接 */
		socialLinks: [
			{ icon: 'github', link: 'https://github.com/MengXi-Studio/unix-utils' },
			{ icon: 'npm', link: 'https://www.npmjs.com/package/@meng-xi/unix-utils' }
		],

		/** 页脚 */
		footer: {
			copyright: 'Copyright © 2026-present 梦曦工作室',
			message: 'Released under the MIT License.'
		}
	}
})

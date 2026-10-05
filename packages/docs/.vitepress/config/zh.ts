import type { DefaultTheme, LocaleSpecificConfig } from 'vitepress'

export const META_URL = 'https://mengxi-studio.github.io/unix-utils/'
export const META_TITLE = 'Unix Utils'
export const META_DESCRIPTION = '为 uni-app x 提供便利工具的 UTS 工具库'

export const zhConfig: LocaleSpecificConfig<DefaultTheme.Config> = {
	/** 网站配置 描述 */
	description: META_DESCRIPTION,

	/** 网站配置 头信息 */
	head: [
		['meta', { property: 'og:url', content: META_URL }],
		['meta', { property: 'og:description', content: META_DESCRIPTION }],
		['meta', { property: 'twitter:url', content: META_URL }],
		['meta', { property: 'twitter:title', content: META_TITLE }],
		['meta', { property: 'twitter:description', content: META_DESCRIPTION }]
	],

	/** 网站主题配置 */
	themeConfig: {
		/** 编辑链接 */
		editLink: {
			pattern: 'https://github.com/MengXi-Studio/unix-utils/edit/master/packages/docs/:path',
			text: '对本页提出修改建议'
		},

		/** 大纲标题 */
		outlineTitle: '本页内容',

		/** 导航栏 */
		nav: [
			{ text: '指南', link: '/guide/introduction' },
			{ text: 'API', link: '/api/show-toast' },
			{ text: '更新日志', link: '/changelog' },
			{
				text: '相关链接',
				items: [
					{ text: 'Discussions', link: 'https://github.com/MengXi-Studio/unix-utils/discussions' },
					{ text: 'Releases', link: 'https://github.com/MengXi-Studio/unix-utils/releases' }
				]
			}
		],

		sidebar: {
			'/guide/': [
				{
					text: '入门',
					items: [
						{ text: '介绍', link: '/guide/introduction' },
						{ text: '安装', link: '/guide/installation' },
						{ text: '快速开始', link: '/guide/getting-started' }
					]
				},
				{
					text: '核心功能',
					items: [
						{ text: 'Toast 提示', link: '/guide/toast' },
						{ text: '通道架构与降级', link: '/guide/channels' }
					]
				},
				{
					text: '维护者',
					items: [{ text: '发布指南', link: '/guide/publishing' }]
				}
			],
			'/api/': [
				{
					text: '核心 API',
					items: [
						{ text: 'showToast()', link: '/api/show-toast' },
						{ text: 'showToastAsync()', link: '/api/show-toast-async' },
						{ text: 'hideToast()', link: '/api/hide-toast' },
						{ text: 'configureToast()', link: '/api/configure-toast' },
						{ text: '语义化快捷 API', link: '/api/shortcuts' }
					]
				},
				{
					text: '类型',
					items: [
						{ text: 'ToastOptions', link: '/api/type-toast-options' },
						{ text: 'ToastFail', link: '/api/type-toast-fail' },
						{ text: 'ToastIcon / ToastPosition / ToastErrorCode', link: '/api/type-enums' }
					]
				}
			]
		}
	}
}

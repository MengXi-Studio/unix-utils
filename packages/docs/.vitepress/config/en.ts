import type { DefaultTheme, LocaleSpecificConfig } from 'vitepress'

export const META_URL = 'https://mengxi-studio.github.io/unix-utils/en/'
export const META_TITLE = 'Unix Utils'
export const META_DESCRIPTION = 'A UTS toolkit providing handy utilities for uni-app x'

export const enConfig: LocaleSpecificConfig<DefaultTheme.Config> = {
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
			text: 'Suggest changes to this page'
		},

		/** 大纲标题 */
		outlineTitle: 'Contents of this page',

		/** 导航栏 */
		nav: [
			{ text: 'Guide', link: '/en/guide/introduction' },
			{ text: 'API', link: '/en/api/show-toast' },
			{ text: 'Changelog', link: '/en/changelog' },
			{
				text: 'Links',
				items: [
					{ text: 'Discussions', link: 'https://github.com/MengXi-Studio/unix-utils/discussions' },
					{ text: 'Releases', link: 'https://github.com/MengXi-Studio/unix-utils/releases' }
				]
			}
		],

		sidebar: {
			'/en/guide/': [
				{
					text: 'Getting Started',
					items: [
						{ text: 'Introduction', link: '/en/guide/introduction' },
						{ text: 'Installation', link: '/en/guide/installation' },
						{ text: 'Quick Start', link: '/en/guide/getting-started' }
					]
				},
				{
					text: 'Core Features',
					items: [
						{ text: 'Toast', link: '/en/guide/toast' },
						{ text: 'Channel Architecture & Fallback', link: '/en/guide/channels' }
					]
				},
				{
					text: 'Maintainers',
					items: [{ text: 'Publishing Guide', link: '/en/guide/publishing' }]
				}
			],
			'/en/api/': [
				{
					text: 'Core API',
					items: [
						{ text: 'showToast()', link: '/en/api/show-toast' },
						{ text: 'showToastAsync()', link: '/en/api/show-toast-async' },
						{ text: 'hideToast()', link: '/en/api/hide-toast' },
						{ text: 'configureToast()', link: '/en/api/configure-toast' },
						{ text: 'Semantic Shortcuts', link: '/en/api/shortcuts' }
					]
				},
				{
					text: 'Types',
					items: [
						{ text: 'ToastOptions', link: '/en/api/type-toast-options' },
						{ text: 'ToastFail', link: '/en/api/type-toast-fail' },
						{ text: 'ToastIcon / ToastPosition / ToastErrorCode', link: '/en/api/type-enums' }
					]
				}
			]
		}
	}
}

import { defineConfig } from 'vitepress'
import { sharedConfig } from './shared'
import { zhConfig } from './zh'

export default defineConfig({
	...sharedConfig,

	/** 网站部署基础路径（CI 经 DOCS_BASE 环境变量注入，本地默认 /unix-utils/） */
	base: process.env.DOCS_BASE || '/unix-utils/',

	/** 文档源目录 */
	srcDir: './src',

	/** 网站语言：中文为默认（root）。目录结构预留 /en/ 扩展位，英文内容暂不建设 */
	locales: {
		root: { label: '简体中文', lang: 'zh-CN', link: '/', ...zhConfig }
	}
})

<script setup lang="ts">
import { computed } from 'vue'
import { useData } from 'vitepress'

/** 首页 hero 底部的徽章组（npm 版本 / npm 下载量 / GitHub stars / GitHub license） */

const { lang } = useData()

const isZh = computed(() => lang.value.startsWith('zh'))

const npmUrl = 'https://www.npmjs.com/package/@meng-xi/unix-utils'
const githubUrl = 'https://github.com/MengXi-Studio/unix-utils'
</script>

<template>
	<div class="home-badges">
		<a :href="npmUrl" target="_blank" rel="noopener">
			<img
				:alt="isZh ? 'npm 版本' : 'npm version'"
				src="https://img.shields.io/npm/v/@meng-xi/unix-utils.svg?style=flat-square&color=42b883"
			/>
		</a>
		<a :href="npmUrl" target="_blank" rel="noopener">
			<img
				:alt="isZh ? 'npm 下载量' : 'npm downloads'"
				src="https://img.shields.io/npm/dm/@meng-xi/unix-utils.svg?style=flat-square&color=35495e"
			/>
		</a>
		<a :href="githubUrl" target="_blank" rel="noopener">
			<img alt="GitHub stars" src="https://img.shields.io/github/stars/MengXi-Studio/unix-utils.svg?style=flat-square&color=42b883" />
		</a>
		<a :href="githubUrl" target="_blank" rel="noopener">
			<img
				:alt="isZh ? 'GitHub license' : 'GitHub license'"
				src="https://img.shields.io/github/license/MengXi-Studio/unix-utils.svg?style=flat-square&color=35495e"
			/>
		</a>
	</div>
</template>

<style scoped>
.home-badges {
	display: flex;
	flex-wrap: wrap;
	justify-content: center;
	align-items: center;
	gap: 8px;
	margin-top: 24px;
	margin-bottom: 8px;
}

.home-badges img {
	height: 20px;
	vertical-align: middle;
	transition: opacity 0.2s;
}

.home-badges a:hover img {
	opacity: 0.85;
}
</style>

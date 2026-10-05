/**
 * 同步 core 插件到 playground / 其他 uni-app x 工程
 *
 * 用法：
 *   node scripts/sync-uni-modules.mjs           # 复制（增量覆盖）
 *   node scripts/sync-uni-modules.mjs --check   # 仅校验一致性（CI / precommit）
 *
 * 原理：packages/core 本身就是标准 uni_modules 插件目录（utssdk/ 结构），
 * 直接复制为 playground/uni_modules/unix-utils；HBuilderX 编译只扫描
 * 工程 uni_modules/ 目录，node_modules 内的 UTS 插件不被识别。
 */
import { cpSync, existsSync, rmSync, readdirSync, statSync, readFileSync } from 'node:fs'
import { join, dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { createHash } from 'node:crypto'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const src = join(root, 'packages/core')
const dest = join(root, 'packages/playground/uni_modules/unix-utils')

/** 插件目录只需要这些内容（README-en 面向 npm 仓库浏览场景，playground 不需要） */
const INCLUDE = ['utssdk', 'package.json', 'README.md', 'changelog.md', 'license.md']

function listFiles(dir) {
	const out = []
	if (!existsSync(dir)) return out
	for (const name of readdirSync(dir)) {
		if (name === 'node_modules' || name === 'unpackage' || name === '.DS_Store') continue
		const p = join(dir, name)
		if (statSync(p).isDirectory()) out.push(...listFiles(p).map((f) => join(name, f)))
		else out.push(name)
	}
	return out.sort()
}

function hashTree(base) {
	const hash = createHash('sha256')
	for (const rel of listFiles(base)) {
		hash.update(rel)
		hash.update(readFileSync(join(base, rel)))
	}
	return hash.digest('hex')
}

const check = process.argv.includes('--check')
if (!existsSync(src)) {
	console.error(`[sync] 源目录不存在: ${src}`)
	process.exit(1)
}

if (check) {
	const same = existsSync(dest) && hashTree(src) === hashTree(dest)
	console.log(same ? '[sync] playground 插件与 core 一致' : '[sync] playground 插件与 core 不一致（需执行 pnpm sync:uni-modules）')
	process.exit(same ? 0 : 1)
}

rmSync(dest, { recursive: true, force: true })
cpSync(src, dest, {
	recursive: true,
	filter: (from) => {
		const rel = from.slice(src.length + 1)
		if (rel === '') return true
		return INCLUDE.includes(rel.split(/[\\/]/)[0])
	}
})
console.log(`[sync] 已同步 packages/core → packages/playground/uni_modules/unix-utils`)

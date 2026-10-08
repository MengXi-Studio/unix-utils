# Publishing Guide

::: tip Audience
This page is written for **unix-utils maintainers** and describes the dual-track release process: npm + the uni plugin market. Users can skip it.
:::

## 0. Dual-Track Overview

```
packages/core/  ──┬── published to npm as @meng-xi/unix-utils (main: utssdk/index.uts)
                  └── submitted to the plugin market as the uni_modules plugin "unix-utils" (zip root = plugin id)
```

The same source is distributed in two ways, and the business side uniformly uses `import { showToast } from '@/uni_modules/unix-utils'`:

| Distribution | Install action | Location |
| --- | --- | --- |
| Plugin market | Import the plugin in HBuilderX | Project `uni_modules/unix-utils/` |
| npm | `pnpm add @meng-xi/unix-utils`, then copy the package contents | Project `uni_modules/unix-utils/` (the compiler does not scan node_modules) |

## 1. Pre-Release Checklist (Required for Every Release)

- [ ] `packages/core/changelog.md` has an entry for this version (the plugin market listing depends on this file)
- [ ] The version number in `package.json` has been updated (`pnpm release` goes through bumpp's interactive version selection)
- [ ] Four-target compilation passes: web / mp-weixin / app-android (real Kotlin) / app-ios (Swift generation)
- [ ] Playground real-device regression passes (Mi 10 Pro; DoD evidenced by runtime logs)
- [ ] `pnpm sync:uni-modules:check` confirms the playground's plugin copy is in sync with core

## 2. npm Publishing

```bash
cd packages/core

# 2.1 Pre-publish check (optional): confirm the contents of the files whitelist
npm publish --dry-run

# 2.2 Official publish (run npm login first for the first release)
npm publish --access public
```

Key points:

- The package name is `@meng-xi/unix-utils` (a scoped public package — `--access public` is required);
- The `files` whitelist includes `utssdk`, `changelog.md`, and `README.md` — the source is published as-is (UTS source distribution; compiled on the fly per platform by the business side's build chain);
- Keep the npm version **consistent** with the plugin market version; `package.json` + `changelog.md` are the single source of truth.

## 3. uni Plugin Market Publishing

Key points from the official specification (verified in October 2026):

- The submission is a **single uni_modules module directory**: in HBuilderX, right-click the directory → "Submit to Plugin Market", or upload a zip (**the zip root = the plugin id** — the zip directly contains `utssdk/`, `package.json`, `changelog.md`, etc., with no nested outer directory);
- UTS plugins are **exempt from review** and support paid pricing;
- Plugin dependencies are declared in `uni_modules.dependencies` of `package.json` (this plugin currently has none — an empty array is fine); when installing from the market, the latest dependency versions are installed automatically and **versions are not locked**.

Steps:

1. Open the project containing `packages/core` in HBuilderX, right-click the core directory → Submit to Plugin Market (or zip manually: go inside the `packages/core/` directory, select all files and compress, making sure the zip root is the plugin content itself);
2. Fill in the form on the [plugin market publishing page](https://ext.dcloud.net.cn/): plugin id `unix-utils`, name, category, and price (currently free);
3. After submitting, check the status in the plugin market backend (UTS plugins are exempt from review and usually go live immediately).

> Note: the `id: unix-utils` / `displayName` / `dcloudext` fields in `packages/core/package.json` are the plugin market metadata — do not rename them before publishing. The npm `name` (`@meng-xi/unix-utils`) and the plugin market id (`unix-utils`) are identifiers in two separate systems, aligned by the `uni_modules` directory name convention.

## 4. Release Order (Recommended)

```
changelog + version bump → four-target compilation → real-device regression → npm publish → plugin market submission → README/docs proofreading
```

npm first, then the market: the npm package contents are exactly the market zip contents, so after publishing to npm you can reuse the same artifacts to build the zip, avoiding source drift between the two.

## 5. Upgrade Notes for the Business Side (to Be Written into README / the Market Listing)

- npm track upgrade: reinstall the package and copy it again into `uni_modules/`;
- Market track upgrade: update the plugin from the HBuilderX plugin market;
- Breaking changes (e.g., the v0.8 import path change) have their migration steps clearly annotated in the Breaking section of the [changelog](/en/changelog).

# Installation

## Requirements

- A **uni-app x** project (`.uvue` pages + `pages.json`);
- **HBuilderX 4.41+** (the minimum version required by `uni.showToast` on the WeChat Mini Program side, and thus the baseline for all platforms);
- Per-platform availability of `uni.showToast`: Web ≥ 4.0, Android ≥ 3.91, iOS ≥ 4.11, WeChat ≥ 4.41, HarmonyOS ≥ 4.61 (already handled per platform inside the library — business code need not care).

## Installation Methods

unix-utils is a standard **uni_modules UTS plugin** with dual-track distribution via the DCloud plugin market and npm — either one works.

### Option 1: DCloud Plugin Market (Recommended)

In HBuilderX, search for `unix-utils` in the [DCloud plugin market](https://ext.dcloud.net.cn/) and import it into your project's `uni_modules/` directory.

### Option 2: npm

After installing the npm package, copy the package contents into the project's `uni_modules/unix-utils/` — a UTS plugin must live in the project's `uni_modules/` directory; the compiler **does not scan node_modules**:

```bash
pnpm add @meng-xi/unix-utils
mkdir -p uni_modules && cp -R node_modules/@meng-xi/unix-utils uni_modules/unix-utils
```

> If you skip the copy, the App side fails at compile time (easy to discover), while on Web / Mini Program it shows up as "module not found".

## Verifying the Installation

After installation, import and call it in any `.uvue` page:

```ts
import { showToast } from '@/uni_modules/unix-utils'

showToast({ title: '安装成功' })
```

If you see the toast after running, the installation succeeded. To check which channel was hit and whether any fallback occurred, read the structured info in the `fail` callback (see [ToastFail](/en/api/type-toast-fail)).

## Upgrading

- **Plugin market track**: update the plugin from the HBuilderX plugin market;
- **npm track**: reinstall and copy again into `uni_modules/`;
- Breaking changes (e.g., the v0.8 import path change) have their migration steps annotated in the corresponding version section of the [changelog](/en/changelog).

## Next Steps

Head to [Getting Started](./getting-started) to show your first toast.

---
layout: home

title: '@meng-xi/unix-utils'
titleTemplate: Unix Utils Toolkit

hero:
  name: '@meng-xi/unix-utils'
  text: Utilities for uni-app x
  tagline: 'A cross-platform UTS utility library for uni-app x (dual-track distribution via the DCloud plugin market + npm); current module: toast — a cross-platform wrapper around uni.showToast'
  image:
    src: /logo.svg
    alt: Unix Utils
  actions:
    - theme: brand
      text: Get Started
      link: /en/guide/getting-started
    - theme: alt
      text: Learning Path
      link: /en/guide/introduction
    - theme: alt
      text: GitHub
      link: https://github.com/MengXi-Studio/unix-utils

features:
  - icon: 🔄
    title: Cross-Platform Compatibility
    details: Android / iOS / Web / WeChat / HarmonyOS — five platforms covered with a per-platform hybrid implementation; App attaches directly to system windows, Web self-draws via a DOM singleton, Mini Programs use the native channel — dispatch is automatic with zero configuration for business code
  - icon: 🪟
    title: UTS Direct System-Window Attachment
    details: Registration-free window attachment on App (Android WindowManager / iOS UIWindow); position / warning / mask / precise duration all take effect; the system-window-level lifecycle survives across pages; automatic fallback to uni.showToast on failure
  - icon: 🎯
    title: Parameter Normalization
    details: Icon alias normalization (fail / exception are ineffective on most platforms); all three position values supported (native support is App-only, with Android missing two); per-platform title truncation strategy; parameters fully isomorphic to uni.showToast for zero-cost migration
  - icon: 🧯
    title: Structured Fallback
    details: Unsupported parameters fall back automatically with a trace left via the fail callback — ToastFail carries errCode (1001 invalid parameter / 2001 platform not supported), param (the triggering parameter name), and platform (platform identifier), so fallbacks are observable
  - icon: ⚡
    title: Dual-Track API + Semantic Shortcuts
    details: Callback-style showToast (isomorphic with the uni API) + Promise-style showToastAsync; showToastSuccess / Error / Info in a single call; hideToast hides reliably, including position variants that native platforms cannot hide
  - icon: 🛠️
    title: Global Default Configuration
    details: configureToast presets duration / icon / mask at project level for a consistent toast style across pages; pass null to a field to keep the library built-in default
  - icon: 💪
    title: Strongly-Typed UTS
    details: All ToastOptions fields are optional except title; icon / position / error codes are literal union types; UTS source distribution is compiled on the fly by each platform's toolchain (JS / Kotlin / Swift)
  - icon: 📦
    title: Dual-Track Distribution
    details: A standard uni_modules UTS plugin — import directly from the DCloud plugin market without review, or install via npm and sync into your project's uni_modules/ with a one-line cp; introduces no third-party UI dependencies
---

## Quick Start Path

[Introduction](/en/guide/introduction) → [Installation](/en/guide/installation) → [Getting Started](/en/guide/getting-started) → [Toast](/en/guide/toast) → [Channel Architecture & Fallback](/en/guide/channels) → [API Reference](/en/api/show-toast)

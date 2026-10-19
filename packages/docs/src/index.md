---
layout: home

title: '@meng-xi/unix-utils'
titleTemplate: Unix Utils 工具集

hero:
  name: '@meng-xi/unix-utils'
  text: uni-app x 便利工具集
  tagline: 为 uni-app x 提供全端兼容的 UTS 工具库（插件市场 + npm 双轨分发），当前模块 toast（uni.showToast 全端兼容封装）与 modal（uni.showModal 全端兼容封装）
  image:
    src: /logo.svg
    alt: Unix Utils
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/getting-started
    - theme: alt
      text: 学习路径
      link: /guide/introduction
    - theme: alt
      text: GitHub
      link: https://github.com/MengXi-Studio/unix-utils

features:
  - icon: 🔄
    title: 全端兼容
    details: Android / iOS / Web / 微信 / 鸿蒙五端覆盖，分端混合实现——App 直挂系统窗口、Web DOM 单例自绘、小程序原生通道，业务零配置自动分发
  - icon: 🪟
    title: UTS 直挂系统窗口
    details: App 端免注册挂窗（Android WindowManager / iOS UIWindow），position / warning / mask / 精确 duration 全生效，系统窗口级生命周期跨页面存活，失败自动降级 uni.showToast
  - icon: 🎯
    title: 参数抹平
    details: icon 别名归一化（fail / exception 多数端无效）、position 三值全支持（原生仅 App 且 Android 缺二）、title 按端截断策略、参数与 uni.showToast 完全同构迁移零成本
  - icon: 🧯
    title: 结构化降级
    details: 不支持的参数自动降级并经 fail 回调留痕——ToastFail 携带 errCode（1001 参数非法 / 2001 平台不支持）、param（触发参数名）、platform（端标识），降级可感知
  - icon: ⚡
    title: 双轨 API + 语义化快捷
    details: 回调式 showToast（与 uni API 同构）+ Promise 式 showToastAsync；showToastSuccess / Error / Info 一行调用；hideToast 含 position 形态可靠隐藏
  - icon: 🛠️
    title: 全局默认配置
    details: configureToast / configureModal 项目级预设，多页面提示风格统一；字段传 null 沿用库内置默认
  - icon: 🪟
    title: Modal 弹窗（v0.2.0）
    details: showModal 与 uni.showModal 同构迁移零成本，confirm / cancel 恒存在互斥；App / Web 自绘通道（editable 真实输入框、alpha 色全生效、蒙层点击不关闭），微信 / 鸿蒙原生通道自动降级经 fail 回调留痕
  - icon: 💪
    title: 强类型 UTS
    details: ToastOptions / ModalOptions 除回调外全可选字段，icon / position / 错误码为字面量联合类型；UTS 源分发由各端编译链现场编译（JS / Kotlin / Swift）
  - icon: 📦
    title: 双轨分发
    details: 标准 uni_modules UTS 插件——插件市场免审核直接导入，或 npm 安装后一行 cp 同步到工程 uni_modules/，不引入任何第三方 UI 依赖
---

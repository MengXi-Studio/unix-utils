const { registerUTSInterface, initUTSProxyClass, initUTSElementProxyClass, initUTSProxyFunction } = uni

const moduleName = 'unix-utils'
export const showToast = initUTSProxyFunction(moduleName, {name: "showToast", methodId: 0, type: "function", keepAlive: false, async: false})
export const hideToast = initUTSProxyFunction(moduleName, {name: "hideToast", methodId: 1, type: "function", keepAlive: false, async: false})
export const showToastAsync = initUTSProxyFunction(moduleName, {name: "showToastAsync", methodId: 2, type: "function", keepAlive: false, async: true})
export const configureToast = initUTSProxyFunction(moduleName, {name: "configureToast", methodId: 3, type: "function", keepAlive: false, async: false})
export const showToastSuccess = initUTSProxyFunction(moduleName, {name: "showToastSuccess", methodId: 4, type: "function", keepAlive: false, async: false})
export const showToastError = initUTSProxyFunction(moduleName, {name: "showToastError", methodId: 5, type: "function", keepAlive: false, async: false})
export const showToastInfo = initUTSProxyFunction(moduleName, {name: "showToastInfo", methodId: 6, type: "function", keepAlive: false, async: false})
export const DEFAULT_DURATION = 1500
export const DEFAULT_ICON = "success"
export const DEFAULT_MASK = false
export const TOAST_ERR_PARAM_INVALID = 1001
export const TOAST_ERR_PLATFORM_UNSUPPORTED = 2001

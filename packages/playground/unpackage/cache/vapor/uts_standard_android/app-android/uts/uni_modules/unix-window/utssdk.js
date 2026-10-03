const { registerUTSInterface, initUTSProxyClass, initUTSElementProxyClass, initUTSProxyFunction } = uni

const moduleName = 'unix-window'
export const showWindowToast = initUTSProxyFunction(moduleName, {name: "showWindowToast", methodId: 0, type: "function", keepAlive: false, async: false})
export const hideWindowToast = initUTSProxyFunction(moduleName, {name: "hideWindowToast", methodId: 1, type: "function", keepAlive: false, async: false})

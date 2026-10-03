const { registerUTSInterface, initUTSProxyClass, initUTSElementProxyClass, initUTSProxyFunction } = uni

const moduleName = 'spike-overlay'
export const showSpikeOverlay = initUTSProxyFunction(moduleName, {name: "showSpikeOverlay", methodId: 0, type: "function", keepAlive: false, async: false})
export const hideSpikeOverlay = initUTSProxyFunction(moduleName, {name: "hideSpikeOverlay", methodId: 1, type: "function", keepAlive: false, async: false})

const __uniConfig = {"pages":[],"globalStyle":{"navigationBarTextStyle":"black","navigationBarTitleText":"unix-utils","navigationBarBackgroundColor":"#F8F8F8","backgroundColor":"#F8F8F8"},"appname":"unix-utils-playground","compilerVersion":"5.24","entryPagePath":"pages/index/index","entryPageQuery":"","realEntryPagePath":"","themeConfig":{}};
__uniConfig.getTabBarConfig = () =>  {return undefined};
__uniConfig.tabBar = __uniConfig.getTabBarConfig();
const __uniRoutes = [{"path":"pages/index/index","meta":{"isQuit":true,"isEntry":true,"navigationBarTitleText":"unix-utils"}},{"path":"pages/toast/dialog-page","meta":{"navigationStyle":"custom","backgroundColor":"transparent","backgroundColorTop":"transparent","backgroundColorBottom":"transparent"}}].map(uniRoute=>(uniRoute.meta.route=uniRoute.path,__uniConfig.pages.push(uniRoute.path),uniRoute.path='/'+uniRoute.path,uniRoute)).concat(typeof __uniSystemRoutes !== 'undefined' ? __uniSystemRoutes : []);


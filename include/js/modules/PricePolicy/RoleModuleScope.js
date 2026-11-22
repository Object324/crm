function RoleModuleScope() {
    var that = this;
    this.show = function (module) {
        
    }
}
/**
 * 获取单例
 * @param {CrmPopup} popupObj 父元素DOM的jQuery对象
 * @return {RoleModuleScope} ChooseScope实例
 */
RoleModuleScope.getInstance = function (popupObj) {
    if(!popupObj) {
        popupObj = CrmPopup.getPopupObj('last');
    }
    if(popupObj && popupObj.divid) {
        return popupObj.RoleModuleScopeInstance ? popupObj.RoleModuleScopeInstance : (popupObj.RoleModuleScopeInstance = new RoleModuleScope())
    }
    return new RoleModuleScope();
}
/**
 * @class  ChooseScope
 * @author  xll
 * @date  2024/08/30 - 初始版本
 * - 选择成员类
 * @description  选择成员设置类
 */
function ChooseScope() {
    let that = this;
    this.lastScopeVal = '';
    this.inputtype = 'checkbox';
    /**
     * 设置父元素jQuery对象
     * @param conJqObj
     * @return {ChooseScope}
     */
    this.setConJqObj = function (conJqObj) {
        this.conJqObj = conJqObj;
        return that;
    }
    this.init = function (option) {
        let list = option.btnList,
            btns;
        if(!Array.isArray(list) && typeof list === "object") {
            btns = [];
            (list.all) && btns.push(list.all);
            (list.user) && btns.push(list.user);
            (list.group) && btns.push(list.group);
            (list.role) && btns.push(list.role);
            btns = ld(btns);
        }
        else if(typeof list === "string") {
            btns = that.conJqObj.find(list);
        }
        else {
            btns = that.conJqObj.find('input[type="radio"]');
        }
        if(!btns instanceof ld || option.module === undefined || option.data === undefined) {
            console.error(new Error('error!'));
        }
        that.confirm = option.confirm
        that.module = option.module
        that.data = option.data
        if (option.inputtype){
            that.setInputType(option.inputtype);
        }
        AjaxJSPage('ScopePopupObj_js','include/js/ScopePopup/ScopePopupObj.js');
        ld.each(btns, function(i, btn) {
            ld(btn).bind('click', () => that.btnClick(ld(this)) );
        })
        return that;
    }
    this.btnClick = function (btnJqObj) {
        let scope = btnJqObj.val() || btnJqObj.attr('value') || btnJqObj.data('value') || 'util';
        if(scope === 'all') {
            // todo 记住历史值
            that.lastScope = that.data.scope;
            that.lastScopeVal = that.data.scopeVal;
            that.data.scope = scope;
            that.data.scopeVal = '';
            return
        }
        let scopePop = new ScopePopupObj(that.module);
        scopePop.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];
        scopePop.popup_header = that.getScopePopHead(scope,scopePop);
        scopePop.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];

        cls_ScopePopup.prop.popup_url = that.getScopeUrl(scope)
        cls_ScopePopup.popup_selecttype = scope;
        cls_ScopePopup.prop.popup_module = that.module;//模块
        cls_ScopePopup.prop.popup_value = (scope === that.data.scope) ? that.data.scopeVal : '';

        let cls_ScopePopupObj = new cls_ScopePopup(scopePop);
        //重写确认按钮事件
        scopePop.setEventBtnOk = function() {
            let scopePopJqBtn = ld(`#${cls_ScopePopup.popup_divid}`).find('.E_pbtn');
            scopePopJqBtn.find('.E_pbtnok').unbind('click').on('click',function(){
                let res = cls_ScopePopup.return_obj,
                    scopeVal = res.return_id,
                    scopeValLabel = res.return_name;
                if(empty(scopeVal)){
                    let comfirm;
                    if(scope === 'group'){
                        comfirm = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                    }else{
                        comfirm = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                    }
                    RemindsMsg("","LdPopWidth400px","","yes","yes",comfirm);
                    return false;
                }
                scopePopJqBtn.find('.E_pbtncancel').click();
                that.data.scope = scope;
                that.data.scopeVal = scopeVal;
                that.data.scopeValLabel = scopeValLabel;
                (typeof that.confirm === "function") && ( that.confirm() )
            });
        }
    }

    this.getScopePopHead = function (scope,scopePop) {
        return that.scopePopHead[scope](scopePop);
    }
    this.scopePopHead = {
        util: function (scopePop,other = '') {
            return '' +
                `<div class="select-input" style="display: flex;align-items: center;">` +
                    `<label class="padL0">${arrJsPopLabel['LBL_SEARCHCHOOSE']}</label>` +
                    `<input type="text" class="ld-input-inner width150 marLR10" id="popup_locationdiv" placeholder="${scopePop.popup_searchvalue}">` +
                    `${other}` +
                '</div>';
        },
        disableUser: function () {
            return '' +
                `<input id="viewuser_disableuser" type="checkbox">` +
                `<label for="viewuser_disableuser" >${arrJsPopLabel['LBL_VIEWDISABLEUSER']}</label>`;
        },
        unFoldSubGroup: function () {
            return '' +
                `<input id="viewuser_unfoldsubgroup" type="checkbox" style="margin-left: 10px">` +
                `<label for="viewuser_unfoldsubgroup">${arrJsPopLabel['SUBGROUPUNFOLD']}</label>`;
        },
        other: function (others) {
            return others.join('');
        },
        user : function (scopePop) {
            scopePop.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];
            return this.util(scopePop,this.other([
                this.disableUser(),
                this.unFoldSubGroup()
            ]));
        },
        group: function (scopePop) {
            scopePop.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
            return this.util(scopePop,this.other([
                this.unFoldSubGroup()
            ]));
        },
        role: function (scopePop) {
            scopePop.popup_searchvalue = arrJsPopLabel['pleaseenterprofile'];
            return this.util(scopePop);
        },
    }

    this.getScopeUrl = function (scope) {
        let info = that.scopeUrl[scope] || that.scopeUrl.user;
        return `module=Users&action=UsersAjax&file=${info.file}&${scope === 'user' ? 'popup_module' : 'fld_module'}=${that.module}` +
            `&popup_inputtype=${that.inputtype}${info.other}`;
    }
    this.setInputType = function (inputtype){
        that.inputtype = inputtype;
    }
    this.scopeUrl = {
        user: {
            file: 'viewuserinfo',
            other: '&popup_scopetype=private&checkprivilege=no&popup_selecttype=user',
        },
        group: {
            file: 'viewuserinfo',
            other: '&view=private&selecttype=group&popup_selecttype=group',
        },
        role: {
            file: 'viewprofileinfo',
            other: '&view=private&popup_selecttype=profile',
        },
    }
}
ChooseScope.prototype.constructor = ChooseScope;

ChooseScope.prototype._instanceList = {};

/**
 * 获取单例
 * @param {jQuery} conJqObj 父元素DOM的jQuery对象
 * @return {ChooseScope} ChooseScope实例
 */
ChooseScope.getInstance = function (conJqObj) {
    conJqObj instanceof HTMLElement && ( conJqObj = ld(conJqObj) )
    if(!(conJqObj instanceof ld)) {
        console.error(new Error('conJqObj must be jQuery Obj'),conJqObj);
    }
    let instanceId = conJqObj.attr('_scope_instance_');
    if(instanceId === null || typeof instanceId === "undefined"){
        instanceId = 'scope_' + (new Date - 0);
        ChooseScope.prototype._instanceList[instanceId] = (new ChooseScope()).setConJqObj(conJqObj);
        conJqObj.attr('_scope_instance_',instanceId);
    }
    return ChooseScope.prototype._instanceList[instanceId];
}
/**
 * 初始化
 * @param {jQuery} conJqObj 父元素DOM的jQuery对象
 * @param {Object} option 配置项
 * @return {ChooseScope} ChooseScope实例
 * @example
 * - NavBar.ShowNavBar(LayoutObj,NavBarList)
 * - NavBar.ShowNavBar(LayoutObj,NavBarList,{ OnClick : function(){} })
 */
ChooseScope.init = function (conJqObj,option) {
    return ChooseScope.getInstance(conJqObj).init(option);
}
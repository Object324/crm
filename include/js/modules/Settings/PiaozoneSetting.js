var PiaozoneSetting = function(){
    this.commonUrl = 'index.php?module=Settings&action=SettingsAjax&file=PiaozoneSetting';
    var that = this;

    //参数设置 编辑按钮
    this.editSetting = function () {
        var url = that.commonUrl;
        url += '&mode=editSetting';
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.saveSetting,'','LdPopWidth600px','Settings','',data.result.oktext,'',data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);

                popupobj.fixedLabelArr = data.result.fixedLabelArr;
                var divobj = ld('#'+popupobj.divid);
                divobj.find('[tag=required]').on('input propertychange',function () {
                    if (!empty(ld(this).val())){
                        ld(this).css('border-color','');
                    }
                });
                tooltip(divobj.find('[tag=edit]'),{transition: true, time: 200});
                // 需要去掉的给高度
                popupobj.reduceBodyHeight = 0;
                // 设置内容最大高度
                popupobj.setPopBodyMaxHeight("#"+popupobj.divid+'_scroll');
            }
            DelProgressObjs();
        })

    }

    //参数设置 保存
    this.saveSetting = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        var fixedLabelArr = popupobj.fixedLabelArr;
        var divobj = ld('#'+popupobj.divid);
        var paramobj = {};
        paramobj['service_url'] = divobj.find('#service_url').val();
        paramobj['user'] = divobj.find('#user').val();
        paramobj['appId'] = divobj.find('#appId').val();
        paramobj['appSecret'] = divobj.find('#appSecret').val();
        paramobj['accountId'] = divobj.find('#accountId').val();
        paramobj['orgNumber'] = divobj.find('#orgNumber').val();
        var isempty = false;
        ld.each(paramobj,function (tmp_key,tmp_value) {
            if (empty(tmp_value)){
                isempty = true;
                divobj.find('#'+tmp_key).css('border-color','#FF5762');
                MessagePopup.TipOne_warning(fixedLabelArr[tmp_key] + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
        });
        if (isempty) return false;
        var url = that.commonUrl;
        url += '&mode=saveSetting';
        ldAjax(url,{'data':paramobj},function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                ld('#SettingRightContent').html(data.result.content);
            }
            DelProgressObjs();
        })


    }

    //注销
    this.clearSetting = function () {
        MessagePopup.TipTwo_warning(arrJsPopLabel['ClearPiaozoneSettingTip']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]').on('click',function (){
            var url = that.commonUrl;
            url += '&mode=saveSetting&clear=yes';
            var paramobj = {};
            paramobj['service_url'] = '';
            paramobj['user'] = '';
            paramobj['appId'] = '';
            paramobj['appSecret'] = '';
            paramobj['accountId'] = '';
            paramobj['orgNumber'] = '';
            ldAjax(url,{'data':paramobj},function (data) {
                if (data.code == 1){
                    ld('#SettingRightContent').html(data.result.content);
                }
                DelProgressObjs();
            });
        });

    }

    //新增发票抬头
    this.createTax = function (obj,taxNo) {
        var tag = ld(obj).attr('tag');
        var url = that.commonUrl;
        url += '&mode=createTax&taxNo='+taxNo;
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.saveTax,'','LdPopWidth800px','Settings',[tag,taxNo],data.result.oktext,'',data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);
                popupobj.currentTaxNo = taxNo;
                popupobj.fixedLabelArr = data.result.fixedLabelArr;
                var divobj = ld('#'+popupobj.divid);
                divobj.find('[tag=required]').on('input propertychange',function () {
                    if (!empty(ld(this).val())){
                        ld(this).css('border-color','');
                    }
                });
            }
            DelProgressObjs();
        })

    }

    //保存发票抬头
    this.saveTax = function (type,taxNo){
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        var fixedLabelArr = popupobj.fixedLabelArr;
        var paramobj = {};
        paramobj['name'] = divobj.find('#name').val();
        paramobj['taxNo'] = divobj.find('#taxNo').val();
        var isempty = false;
        ld.each(paramobj,function (tmp_key,tmp_value) {
            if (empty(tmp_value)){
                isempty = true;
                divobj.find('#'+tmp_key).css('border-color','#FF5762');
                MessagePopup.TipOne_warning(fixedLabelArr[tmp_key] + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
        });
        if (isempty) return false;
        paramobj['scopeType'] = divobj.find('#scopeType').val();
        paramobj['scopeValue'] = divobj.find('#scopeValue').val();
        paramobj['oldTaxNo'] = taxNo;

        var url = that.commonUrl;
        url += '&mode=saveTax&refreshtype='+type;
        ldAjax(url,{'data':paramobj},function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                if (type == 'edit'){
                    var crmPopupobj = CrmPopup.getPopupObj('last');
                    var divobj = ld('#'+crmPopupobj.divid);
                    divobj.find('#edit_companyInfo').html(data.result.content);
                    tooltip(divobj.find('[tag=edit]'),{transition: true, time: 200});
                }else if (type == 'view'){
                    ld('#view_companyInfo').html(data.result.content);
                }
            }else {
                MessagePopup.TipOne_warning(data.msg);
            }
            DelProgressObjs();
        });

    }

    //删除发票抬头
    this.deleteTax = function (obj,taxNo) {
        MessagePopup.TipTwo_warning(arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]').on('click',function (){
            var type = ld(obj).attr('tag');
            var url = that.commonUrl;
            url += '&mode=deleteTax&taxNo='+taxNo+'&refreshtype='+type;
            ldAjax(url,'',function (data) {
                if (data.code == 1){
                    if (type == 'edit'){
                        var crmPopupobj = CrmPopup.getPopupObj('last');
                        var divobj = ld('#'+crmPopupobj.divid);
                        divobj.find('#edit_companyInfo').html(data.result.content);
                        tooltip(divobj.find('[tag=edit]'),{transition: true, time: 200});
                    }else if (type == 'view'){
                        ld('#view_companyInfo').html(data.result.content);
                    }
                }
                DelProgressObjs();
            });
        })
    }

    //设置发票抬头的适用范围 分配按钮
    this.setTaxScope = function (obj,taxNo) {
        var type = ld(obj).attr('tag');
        var url = that.commonUrl;
        url += '&mode=setTaxScope&taxNo='+taxNo;
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.saveTaxScope,'','LdPopWidth600px','Settings',[type,taxNo],data.result.oktext,'',data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);
            }
            DelProgressObjs();
        })
    }

    //保存分配
    this.saveTaxScope = function (type,taxNo){
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        var url = that.commonUrl;
        url += '&mode=saveTaxScope&taxNo='+taxNo;
        url += '&refreshtype='+type;
        url += '&scopeType='+divobj.find('#scopeType').val();
        url += '&scopeValue='+divobj.find('#scopeValue').val();
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                if (type == 'edit'){
                    var crmPopupobj = CrmPopup.getPopupObj('last');
                    var divobj = ld('#'+crmPopupobj.divid);
                    divobj.find('#edit_companyInfo').html(data.result.content);
                    tooltip(divobj.find('[tag=edit]'),{transition: true, time: 200});
                }else if (type == 'view'){
                    ld('#view_companyInfo').html(data.result.content);
                }
            }
            DelProgressObjs();
        });
    }


    //指定成员 指定角色 指定部门 点击事件
    this.setScopeValue = function(obj,type){
        var popupobj = CrmPopup.getPopupObj('last');
        var module='Settings';
        var arrJsPopLabel_str = arrJsPopLabel['APPLICABLESCOPE'];
        var popup_user_inputtype = 'checkbox';
        var tag = ld(obj).attr('tag');

        var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype='+popup_user_inputtype+'&popup_selecttype=user&checkprivilege=no';
        var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
        var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';

        if(type=='user'||type=='group'||type=='role' || type == 'select')
        {
            getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
            {
                scopepopupobj = new ScopePopupObj(module);
                scopepopupobj.popup_caption_value = arrJsPopLabel_str;//标题title
                scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
                getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                {
                    cls_ScopePopup.popup_selecttype = type;
                    cls_ScopePopup.prop.popup_module = module;//模块

                    if (ld('#'+popupobj.divid).find('#scopeType').val() == type){
                        cls_ScopePopup.prop.popup_value = ld('#'+popupobj.divid).find('#scopeValue').val();
                    }else {
                        cls_ScopePopup.prop.popup_value = '';
                    }

                    if(type=='user')
                    {
                        cls_ScopePopup.prop.popup_url = popup_user_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                    }
                    else if(type=='group')
                    {
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
                        cls_ScopePopup.prop.popup_url = popup_groups_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }
                    else
                    {
                        cls_ScopePopup.prop.popup_url = popup_role_url
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['pleaseenterprofile'];
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div>';
                    }
                    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                    var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
                    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk=function(){
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                            var selected_groupid = cls_ScopePopup.return_obj.return_id;
                            if(empty(selected_groupid)){
                                if(type == 'group'){
                                    confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                    MessagePopup.TipOne_warning(confirm_str);
                                    return false;
                                }else{
                                    confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                    MessagePopup.TipOne_warning(confirm_str);
                                    return false;
                                }
                            }
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            var selected_array = cls_ScopePopup.return_obj.return_array;
                            var selected_name = cls_ScopePopup.return_obj.return_name;

                            var scopeType = ld('#'+popupobj.divid).find('#scopeType').val();
                            var scopeValue = ld('#'+popupobj.divid).find('#scopeValue').val();
                            ld('#'+popupobj.divid).find('#view_scope [name=radioUser][value='+scopeType+']').prop('check',false);

                            ld('#'+popupobj.divid).find('#scopeType').val(type);
                            ld('#'+popupobj.divid).find('#scopeValue').val(selected_user);
                            msgConfirm();
                            return false;
                        });

                    }
                });
            });
        }else if (type == 'all'){
            ld('#'+popupobj.divid).find('#scopeType').val('all');
            ld('#'+popupobj.divid).find('#scopeValue').val('-1');
        }
    }
}


PiaozoneSetting.curobj = '';
PiaozoneSetting.getInstance=function(){
    if(!empty(PiaozoneSetting.curobj)){
    }else{
        PiaozoneSetting.curobj=new PiaozoneSetting();
    }
    return PiaozoneSetting.curobj;
}
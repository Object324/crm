function Entry_Fields_Access(){
    let that = this;
    this.module = ld('#frommodule').val();
    this.popupobj = CrmPopup.getPopupObj('last');
    //this.divid = 'dvProductToolEditField';
    this.divid = this.popupobj.divid;


    //应用范围
    this.setchooseScopePopup=function(selectvalue,tmp_scope_label){
        var module=that.module;
        var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
        var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
        var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';
        if(selectvalue=='user'||selectvalue=='group'||selectvalue=='role')
        {
            getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
            {
                scopepopupobj =  new ScopePopupObj(module);
                scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
                scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
                getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                {
                    cls_ScopePopup.popup_selecttype = selectvalue;
                    cls_ScopePopup.prop.popup_module = module;//模块
                    if(ld("#"+that.divid+" #hidden_pro_profilefieldtype").val() == selectvalue){
                        cls_ScopePopup.prop.popup_value = ld("#"+that.divid+" #hidden_pro_profile_value").val();
                    }else{
                        cls_ScopePopup.prop.popup_value = '';
                    }
                    if(selectvalue=='user')
                    {
                        cls_ScopePopup.prop.popup_url = popup_user_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                    }
                    else if(selectvalue=='group')
                    {
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
                        cls_ScopePopup.prop.popup_url = popup_groups_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
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
                                if(selectvalue == 'group'){
                                    confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }else{
                                    confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }
                            }
                            ld('#'+that.divid+' #entry_scope_label').html('<b>'+tmp_scope_label+'</b>');

                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                            ld("#"+that.divid+" #entry_field_scope_list_top").show();
                            ld("#"+that.divid+" #entry_field_scope_list").show();
                            ld("#"+that.divid+" #entry_field_scope_list_foot").show();
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            var selected_array = cls_ScopePopup.return_obj.return_array;
                            if(ld("#"+that.divid+" #hidden_pro_profilefieldtype").val() == selectvalue){
                                var old_selectvalue = ld("#"+that.divid+" #hidden_pro_profile_value").val().split(",");
                                var selected_user_array = selected_user.split(",");

                                for(let i = 0; i<old_selectvalue.length;i++){
                                    var old_index = ld.inArray(old_selectvalue[i],selected_user_array);
                                    if(old_index < 0){
                                        ld("#"+that.divid+" #entry_field_scope_list table tbody tr[name=selectid_"+old_selectvalue[i]+"]").remove();
                                    }
                                }

                                for(selectindex in selected_array){
                                    var index = ld.inArray(selectindex,old_selectvalue);
                                    if(index >= 0){
                                        delete selected_array[selectindex];
                                    }
                                }

                            }else{
                                ld('#'+that.divid+' #entry_field_scope_list tr[name*=selectid_]').remove();
                                ld('#'+that.divid+' #entry_field_scope_list tr input[name*=all]').prop('checked',true);
                            }
                            ld("#"+that.divid+" #hidden_pro_profile_value").val(selected_user);
                            ld("#"+that.divid+" #hidden_pro_profilefieldtype").val(selectvalue);
                            var fieldaccess_trhtml = '';
                            for(selectobj in selected_array){
                                var tmpobj = selected_array[selectobj]
                                fieldaccess_trhtml += '<tr name="selectid_'+selectobj+'" data-relatedid="'+selectobj+'">' +
                                    '<td align="left" width="20%" class="tabtdboard"><label>'+tmpobj.name+'</label></td>' +
                                    '<td align="center" width="20%" class="tabtdboard"><div class="entrycopetabinput select-input">\n' +
                                    '<label><input name="createview_visible" data-relatedid="'+selectobj+'" type="checkbox" checked /><span>' + arrJsPopLabel['VISIBLE'] +'</span></label> '+
                                    '<label><input name="createview_edit" data-relatedid="'+selectobj+'" type="checkbox" checked style="margin-left: 10px;"/><span>' + arrJsPopLabel['EDITABLE'] +'</span></label>'+
                                    '</div></td>' +
                                    '<td align="center" width="20%" class="tabtdboard"><div class="entrycopetabinput select-input">\n' +
                                    '<label><input name="editview_visible" data-relatedid="'+selectobj+'" type="checkbox" checked/><span>' + arrJsPopLabel['VISIBLE'] +'</span></label> '+
                                    '<label><input name="editview_edit" data-relatedid="'+selectobj+'" type="checkbox" checked style="margin-left: 10px;"/><span>' + arrJsPopLabel['EDITABLE'] +'</span></label>'+
                                    '</div></td>' +
                                    '<td align="center" width="15%" class="tabtdboard"><div class="entrycopetabinput select-input">\n' +
                                    '<label><input name="detailsview_visible" data-relatedid="'+selectobj+'" type="checkbox" checked /><span>' + arrJsPopLabel['VISIBLE'] +'</span></label>'+
                                    '</div></td>' +
                                    '<td align="center" width="15%" class="tabtdboard"><a class="Anu3_a redFont" onclick="Entry_Fields_Accessobj.Deleteline_scop(\''+selectobj+'\')">'+arrJsPopLabel['DELETE']+'</a></td>' +
                                    '</tr>';
                            }
                            ld("#"+that.divid+" #entry_field_scope_list table tbody").append(fieldaccess_trhtml);
                            that.bindchoosefieldprofile();
                            that.isAllchecked();
                            that.fieldattribute_edit();
                            return false;
                        });
                    }
                });
            });
        }
    }

    //绑定选择权限
    this.bindchoosefieldprofile = function (){
        ld('#'+that.divid+' #entry_field_scope_list input[type=checkbox]').change(function(){
            var checkboxname = ld(this).attr('name');
            if (checkboxname.split('_')[1] == 'visible' && ld(this).prop('checked') == false && checkboxname.split('_')[0] != 'details') {
                ld('#' + that.divid + ' #entry_field_scope_list tr[data-relatedid=' + ld(this).data('relatedid') + '] input[name=' + checkboxname.split('_')[0] + '_edit]').prop('checked', false);
            }
            if (checkboxname.split('_')[1] == 'edit' && ld(this).prop('checked') == true) {
                ld('#' + that.divid + ' #entry_field_scope_list tr[data-relatedid=' + ld(this).data('relatedid') + '] input[name=' + checkboxname.split('_')[0] + '_visible]').prop('checked', true);
            }
            that.isAllchecked();
        });
        ld('#'+that.divid+' #entry_field_scope_list_top input[type=checkbox]').change(function(){
            var checkboxname = ld(this).attr('name');
            if((checkboxname.split('_')[2] == 'visible' && ld(this).prop('checked') == false) || (checkboxname.split('_')[2] == 'edit' && ld(this).prop('checked') == true)){
                ld('#' + that.divid + ' #entry_field_scope_list input[name*='+checkboxname.split('_')[1]+']').prop('checked',ld(this).prop('checked'));
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name*='+checkboxname.split('_')[1]+']').prop('checked',ld(this).prop('checked'));
            }else{
                ld('#' + that.divid + ' #entry_field_scope_list input[name*='+checkboxname.split('_')[1]+'_'+checkboxname.split('_')[2]+']').prop('checked',ld(this).prop('checked'));
            }
        });
    }

    //是否全选
    this.isAllchecked = function (){
        if(ld('#'+that.divid+' #hidden_pro_profilefieldtype').val() != 'all') {
            if (ld('#' + that.divid + ' #entry_field_scope_list input[name=createview_visible]:checked').length == ld('#' + that.divid + ' #entry_field_scope_list tr[name*=selectid_]').length) {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_createview_visible]').prop('checked', true);
            } else {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_createview_visible]').prop('checked', false);
            }
            if (ld('#' + that.divid + ' #entry_field_scope_list input[name=createview_edit]:checked').length == ld('#' + that.divid + ' #entry_field_scope_list tr[name*=selectid_]').length) {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_createview_edit]').prop('checked', true);
            } else {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_createview_edit]').prop('checked', false);
            }
            if (ld('#' + that.divid + ' #entry_field_scope_list input[name=editview_visible]:checked').length == ld('#' + that.divid + ' #entry_field_scope_list tr[name*=selectid_]').length) {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_editview_visible]').prop('checked', true);
            } else {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_editview_visible]').prop('checked', false);
            }
            if (ld('#' + that.divid + ' #entry_field_scope_list input[name=editview_edit]:checked').length == ld('#' + that.divid + ' #entry_field_scope_list tr[name*=selectid_]').length) {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_editview_edit]').prop('checked', true);
            } else {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_editview_edit]').prop('checked', false);
            }
            if (ld('#' + that.divid + ' #entry_field_scope_list input[name=detailsview_visible]:checked').length == ld('#' + that.divid + ' #entry_field_scope_list tr[name*=selectid_]').length) {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_detailsview_visible]').prop('checked', true);
            } else {
                ld('#' + that.divid + ' #entry_field_scope_list_top input[name=all_detailsview_visible]').prop('checked', false);
            }
        }
    }

    //删除行
    this.Deleteline_scop = function (selectedid){
        var delete_str = arrJsPopLabel['SUREWANTDELETE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            ld('#'+that.divid+' #entry_field_scope_list tr[data-relatedid='+selectedid+']').remove();
            var selectedid_array = ld('#'+that.divid+' #hidden_pro_profile_value').val().split(',');
            var new_set = new Set(selectedid_array);
            new_set.delete(selectedid);
            var new_selectedid_array = [...new_set];
            var selectedid_array = ld('#'+that.divid+' #hidden_pro_profile_value').val(new_selectedid_array.toString());
        })
    }

    //新增行
    this.Addline_scope = function (){
        var selectvalue = ld('#hidden_pro_profilefieldtype').val();
        var tmp_scope_label = arrJsPopLabel['ALL'];
        if(selectvalue == 'all'){
            tmp_scope_label = arrJsPopLabel['ALL'];
        }else if(selectvalue == 'group'){
            tmp_scope_label = arrJsPopLabel['SETBYDEPARTMENT'];
        }else if(selectvalue == 'role'){
            tmp_scope_label = arrJsPopLabel['SetByRole'];
        }else if(selectvalue == 'user'){
            tmp_scope_label = arrJsPopLabel['SETBYUSERS'];
        }
        that.setchooseScopePopup(selectvalue,tmp_scope_label);
    }

    //清空
    this.empty_scop_table = function (){
        var delete_str = arrJsPopLabel['SUREWANTTOEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            ld('#'+that.divid+' #entry_field_scope_list tr[name*=selectid_]').remove();
            ld('#'+that.divid+' #hidden_pro_profile_value').val('');
        })
    }

    //字段属性
    this.fieldattribute_edit = function(){
        if(ld('#'+that.divid+' #basicDiv #is_edit').prop('checked') == false){
            ld('#'+that.divid+' #fields_access_div table input[type=checkbox][name$=_edit]').prop('checked',false);
            ld('#'+that.divid+' #fields_access_div table input[type=checkbox][name$=_edit]').attr('disabled','');
            ld('#'+that.divid+' #fields_access_div table input[type=checkbox][name$=_edit]').parent().find('span').addClass('cursorNotAllowed');
        }else{
            ld('#'+that.divid+' #fields_access_div table input[type=checkbox][name$=_edit]').removeAttr('disabled');
            ld('#'+that.divid+' #fields_access_div table input[type=checkbox][name$=_edit]').parent().find('span').removeClass('cursorNotAllowed');
        }
    }

    //下拉框
    this.changescopeselect = function (selectobj){
        var scopetype = ld(selectobj).val();

        var tmp_scope_label = arrJsPopLabel['ALL'];
        if(scopetype == 'all'){
            tmp_scope_label = arrJsPopLabel['ALL'];
        }else if(scopetype == 'group'){
            tmp_scope_label = arrJsPopLabel['SETBYDEPARTMENT'];
        }else if(scopetype == 'role'){
            tmp_scope_label = arrJsPopLabel['SetByRole'];
        }else if(scopetype == 'user'){
            tmp_scope_label = arrJsPopLabel['SETBYUSERS'];
        }
        //ld('#'+that.divid+' #entry_scope_label').html('<b>'+tmp_scope_label+'</b>');

        if(scopetype == 'all'){
            //ld('#' + that.divid + ' #entry_field_scope_list_top').hide();
            ld('#' + that.divid + ' #entry_field_scope_list').hide();
            ld('#' + that.divid + ' #entry_field_scope_list_foot').hide();
            ld("#"+that.divid+" #hidden_pro_profile_value").val('');
            ld("#"+that.divid+" #hidden_pro_profilefieldtype").val('all');
            ld('#'+that.divid+' #entry_scope_label').html('<b>'+tmp_scope_label+'</b>');
            that.fieldattribute_edit();
        }else{
            that.setchooseScopePopup(scopetype,tmp_scope_label);
        }
    }

    var selectobj=ld('#'+that.divid+' #entry_fields_scope');
    if(selectobj.length>0&&selectobj!=undefined){
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
        var popupobj=CrmPopup.getPopupObj('last');
        cls_resetComboxHtmlobj.setPopupObj(popupobj);
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
    }
    that.isAllchecked();
    that.bindchoosefieldprofile();
    that.fieldattribute_edit();
}
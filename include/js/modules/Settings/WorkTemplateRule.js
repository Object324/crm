function WorkTemplateRule() {
    var that = this;
    this.url = 'index.php?module=Settings&action=SettingsAjax&file=WorkTemplate&setype=WorkTemplateRule';

    //新建编辑界面
    this.create = function (id){
        var url = that.url + '&option=editview';
        url += '&ruleid='+id;
        var reporttype = ld('#workTemplateRule').attr('reporttype');
        url += '&reporttype='+reporttype;
        var popupobj=CrmPopup.load('',"","",'LdPopWidth800px',"WorkTemplateRule","","","","");
        popupobj.prevshow();
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                DelProgressObjs();
                popupobj.setParams(data.result.title,WorkTemplateRule.getInstance().saveRule,"",'LdPopWidth800px',"WorkTemplateRule",id,data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);

                // 设置内容最大高度
                popupobj.setPopBodyMaxHeight(".dvpopupsroll");

                popupobj.reporttype = reporttype;
                //适用范围 分配
                // var allocateinfo = data.result.allocateinfo;
                // getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function (){
                //     ScopePopup_Details.getInstance().allocateTemplate(this,allocateinfo.tabid,allocateinfo.ruleid,allocateinfo.rule_value,allocateinfo.rule_range,'WorkTemplateRule');
                // });
                that.setEvent();
            }
        });

    }
    this.setEvent = function (){
        var popupobj = CrmPopup.getPopupObj('last');
        //点评人和抄送范围按钮change事件
        var userpresenceobj = ld('#'+popupobj.divid+' #reuser_presence,#ccuser_presence');
        ld.each(userpresenceobj,function (index,obj) {
            ld(obj).unbind('change').bind('change',function (event) {
                var changename = ld(this).attr('changename');
                var checked = ld(this).prop('checked');
                var popupobj = CrmPopup.getPopupObj('last');
                if (checked){
                    ld('#'+popupobj.divid + ' tr[name='+changename+']').css('display','');
                }else {
                    ld('#'+popupobj.divid + ' tr[name='+changename+']').css('display','none');
                }
                popupobj.center();
            })
        });
        //提醒次数change事件
        ld('#'+popupobj.divid+' [name=remind_num]').unbind('change').bind('change',function (event) {
            var remind_num = parseInt(ld(this).val());
            var reporttype = popupobj.reporttype;
            var trobj = ld('#'+popupobj.divid + ' tr[name=remind_time_value_tr]');
            if (remind_num == 0){
                trobj.css('display','none');
                if (reporttype != 'day'){
                    ld('#'+popupobj.divid + ' tr[name=remind_time_tr]').css('display','none')
                }
            }else {
                trobj.css('display','');
                if (reporttype != 'day'){
                    ld('#'+popupobj.divid + ' tr[name=remind_time_tr]').css('display','')
                }
                for (var i = 1;i < 4;i++){
                    if (i<=remind_num){
                        trobj.find(' [name='+i+'_value_div]').css('display','');
                        trobj.find(' [name='+i+'_value_div]  [name='+i+'_value]').val(remind_num+1-i);
                    }else {
                        trobj.find(' [name='+i+'_value_div]').css('display','none');
                    }
                }
            }
            popupobj.center();
        });

    }

    //新建/编辑保存时间
    this.saveRule = function (id){
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        //基本信息
        var rule_name = divobj.find('#rule_name').val();
        if (empty(rule_name)){
            divobj.find('#rule_name').css('border-color','red');
            MessagePopup.TipOne_warning(arrJsPopLabel['RULENAMECANOTEMPTY']);
            return false;
        }else {
            divobj.find('#rule_name').css('border-color','');
        }
        var data = {};
        data.name = rule_name;
        var status_checked= divobj.find('#status').prop('checked');
        data.status = status_checked == true?'yes':'no';
        //适用范围
        data.rule_range = divobj.find('#rule_range').val();
        var rule_value = divobj.find('#rule_value').val();
        if (empty(rule_value)){
            MessagePopup.TipOne_warning(arrJsPopLabel['UserRangeCanNotBeEmpty']);
            return false;
        }
        data.rule_value = rule_value;
        //固定点评人
        var reuser_presence_checked = divobj.find('#reuser_presence').prop('checked');
        data.reuser_presence = reuser_presence_checked == true?'yes':'no';
        var reuser_type = divobj.find('#reuser_select').val();
        var reuser_value = divobj.find('#reuser_input').attr('value_str');
        if (reuser_type == 'Users'){
            reuser_value = divobj.find('#reuser_select  option:selected').attr('columnname');
        }
        if (reuser_type == 'user' && empty(reuser_value) && reuser_presence_checked){
            divobj.find('#reuser_input').css('border-color','red');
            MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEUSER']);
            return false;
        }else {
            divobj.find('#reuser_input').css('border-color','');
        }
        data.reuser_type = reuser_type;
        data.reuser_value = reuser_value;
        var ccuser_presence_checked = divobj.find('#ccuser_presence').prop('checked');
        //XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华） wsh
        var auto_generate_checked = divobj.find('#auto_gene_brief_presence').prop('checked');
        var auto_generate_brief = auto_generate_checked ? 'yes' : 'no';

        data.ccuser_presence = ccuser_presence_checked == true?'yes':'no';
        var ccuser_type = divobj.find('#ccuser_select').val();
        var ccuser_value = divobj.find('#ccuser_input').attr('value_str');
        if (ccuser_type == 'Users'){
            ccuser_value = divobj.find('#ccuser_select option:selected').attr('columnname');
        }else {
            if (ccuser_presence_checked && empty(ccuser_value)){
                divobj.find('#ccuser_input').css('border-color','red');
                MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEUSER']);
                return false;
            }else {
                divobj.find('#ccuser_input').css('border-color','');
            }
        }
        data.ccuser_type = ccuser_type;
        data.ccuser_value = ccuser_value;
        data.deadline_date = divobj.find('#deadline_date').val();
        data.remind_time = divobj.find('#remind_time').val();
        data.remind_num = divobj.find('#remind_num').val();
        data.first_value = divobj.find('#1_value').val();
        data.second_value = divobj.find('#2_value').val();
        data.third_value = divobj.find('#3_value').val();
        data.report_date = divobj.find('#report_date').val();
        data.edit_date = divobj.find('#edit_date').val();
        data.auto_generate_brief = auto_generate_brief;
       //console.log(data);
        var url = that.url +'&option=save&ruleid='+id;
        var reporttype = popupobj.reporttype;
        url +='&reporttype='+reporttype;
        ldAjax(url,{'data':data},function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                var list_popupobj = CrmPopup.getPopupObj('last');
                ld('#'+list_popupobj.divid+' #workTemplateRuleDiv').html(data.result.content);
                that.moveTable();
                DelProgressObjs()
            }
        })

    }

    //列表设置的启用按钮
    this.changeStatus = function (obj,id){
        var url = that.url + '&option=changeRuleStatus';
        var checked = ld(obj).prop('checked');
        var status = checked == true?'yes':'no';
        url += '&status='+status;
        url += '&ruleid='+id;
        ldAjax(url,'',function (data) {
            if (data.code == 1 ){
                DelProgressObjs()
            }
        })
    }

    //列表规则的启用按钮
    this.changeSettingStatus = function (obj){
        var url = that.url + '&option=changeSettingStatus';
        var checked = ld(obj).prop('checked');
        var status = checked == true?'yes':'no';
        url += '&status='+status;
        var reporttype = ld('#workTemplateRule').attr('reporttype');
        url += '&reporttype='+reporttype;
        ldAjax(url,'',function (data) {
            if (data.code == 1 ){
                DelProgressObjs()
            }
        })
    }

    //删除规则
    this.delete = function (id){
        MessagePopup.TipTwo_warning(arrJsPopLabel['SUREWANTDELETE']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        var confirm_button = ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]');
        confirm_button.bind('click',function () {
            var url = that.url + '&option=deleteRule';
            url += '&ruleid='+id;
            var reporttype = ld('#workTemplateRule').attr('reporttype');
            url += '&reporttype='+reporttype;
            ldAjax(url,'',function (data) {
                if (data.code == 1 ){
                    DelProgressObjs();
                    var popupobj = CrmPopup.getPopupObj('last');
                    ld('#'+popupobj.divid+' #workTemplateRuleDiv').html(data.result.content);
                    if (data.result.length > 1){
                        that.moveTable();
                    }
                }
            })
        });
    }

    //指定成员 指定角色 指定部门 点击事件
    this.setScopeValue = function(obj,selectvalue){
        var popupobj = CrmPopup.getPopupObj('last');
        // var entry_Fields_Access = new Entry_Fields_Access();
        var module='Settings';
        var changeType = ld(obj).attr('changeType');
        var changeValueName = ld(obj).attr('changeValue');
        var arrJsPopLabel_str = arrJsPopLabel['APPLICABLESCOPE'];
        if (changeType == 'select'){
            arrJsPopLabel_str = ld(obj).find('option:selected').text();
        }

        var popup_user_inputtype = 'checkbox';
        //console.log(changeValueName);
        if (changeValueName == 'reuser_input'){
            popup_user_inputtype = 'radio';
        }
        var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype='+popup_user_inputtype+'&popup_selecttype=user&checkprivilege=no';
        var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
        var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';

        if(selectvalue=='user'||selectvalue=='group'||selectvalue=='role' || selectvalue == 'select')
        {
            getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
            {
                scopepopupobj =  new ScopePopupObj(module);
                scopepopupobj.popup_caption_value = arrJsPopLabel_str;//标题title
                scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
                getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                {
                    cls_ScopePopup.popup_selecttype = selectvalue;
                    cls_ScopePopup.prop.popup_module = module;//模块

                    if(changeType == 'select'){
                        cls_ScopePopup.prop.popup_value = ld("#"+popupobj.divid+" #"+changeValueName).attr('value_str');
                    }else if(ld("#"+popupobj.divid+" #"+changeType).val() == selectvalue){
                        cls_ScopePopup.prop.popup_value = ld("#"+popupobj.divid+" #"+changeValueName).val();
                    }else{
                        cls_ScopePopup.prop.popup_value = '';
                    }

                    if(selectvalue=='user')
                    {
                        cls_ScopePopup.prop.popup_url = popup_user_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                    }
                    else if(selectvalue=='group')
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
                                if(selectvalue == 'group'){
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
                            // ld("#"+popupobj.divid+" #view_scope").data('selectvalue',selectvalue);
                            // ld("#"+popupobj.divid+" #view_scope").data('selected_user',selected_user);
                            if (changeType != 'select'){
                                ld("#"+popupobj.divid+" #"+changeType).val(selectvalue);
                                ld("#"+popupobj.divid+" #"+changeValueName).val(selected_user);
                            }else {
                                ld("#"+popupobj.divid+" #"+changeValueName).html(selected_name);
                                ld("#"+popupobj.divid+" #"+changeValueName).attr('value_str',selected_user);
                            }
                            msgConfirm();
                            return false;
                        });

                    }
                });
            });
        }else if (selectvalue == 'all'){
            ld("#"+popupobj.divid+" #"+changeType).val('all');
            ld("#"+popupobj.divid+" #"+changeValueName).val('-1');
        }
    }

    //固定点评人 最小抄送范围 下拉框change事件
    this.changeSelect = function (obj){
        var popupobj = CrmPopup.getPopupObj('last');
        var select_value = ld(obj).val();
        var changeValueName = ld(obj).attr('changeValue');
        //console.log(select_value);
        if (select_value == 'user' || select_value == 'role' || select_value == 'group'){
            ld('#'+popupobj.divid + ' #'+changeValueName).css('display','inline-block');
            ld(obj).parent().find('[name=add]').css('display','');
            ld(obj).parent().find('[name=clear]').css('display','');
            if (changeValueName == 'reuser_input'){
                ld(obj).parent().find('[name=field_select_tip]').css('display','none');
            }
        }else {
            ld('#'+popupobj.divid + ' #'+changeValueName).css('display','none');
            ld(obj).parent().find('[name=add]').css('display','none');
            ld(obj).parent().find('[name=clear]').css('display','none');
            if (changeValueName == 'reuser_input'){
                ld(obj).parent().find('[name=field_select_tip]').css('display','');
            }
        }
        ld('#'+popupobj.divid + ' #'+changeValueName).attr('value_str','');
        ld('#'+popupobj.divid + ' #'+changeValueName).val();
    }

    //固定点评人 最小抄送范围 获取角色 部门 成员 +符号点击事件
    this.addEvent = function (obj){
        var selectobj_id = ld(obj).attr('addselect');
        var popupobj = CrmPopup.getPopupObj('last');
        var selectobj = ld('#'+popupobj.divid).find('#'+selectobj_id);
        var selectvalue = selectobj.val();
        that.setScopeValue(selectobj[0],selectvalue);

    }

    this.clearEvent = function (obj){
        var clearinput = ld(obj).attr('clearinput');
        var popupobj = CrmPopup.getPopupObj('last');
        var inputobj = ld('#'+popupobj.divid).find('#'+clearinput);
        inputobj.val('');
        inputobj.html('');
        inputobj.attr('value','');
        inputobj.attr('value_str','');

    }

    this.moveTable=function (){
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var trobj = ld('#'+divid+' [name=workTemplateRuleDiv] tr[sort=yes]');
        var length=trobj.length;
        if (length < 2){
            return false;
        }
        tooltip("#"+divid+" [tag=dragsort]", {transition: true, time: 200});
        trobj.hover(function(){
            ld('#'+divid+' [tag=dragsort]').hide()
            ld(this).find('[tag=dragsort]').show();
        });
        var dragobj = ld('#'+divid+" [name=workTemplateRuleDiv]").find("tbody").get(0);
        Sortable.create(dragobj, {
            draggable: ".workTemplateRule",
            handle: ".drag-handle",
            onEnd: function (evt){
                var sort_arr=[];
                var ruleid = '';
                var newtrobj = ld('#'+divid+' [name=workTemplateRuleDiv] tr[sort=yes]');
                newtrobj.attr('onmouseover','');
                newtrobj.attr('onmouseout','');
                newtrobj.removeClass('lvtColData');
                newtrobj.removeClass('lvtColDataBj');
                newtrobj.removeClass('lvtColDataHover');
                ld.each(newtrobj,function(index,tmpobj){
                    if(index%2 == 0){
                        ld(tmpobj).addClass('lvtColDataBj');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                        ld(tmpobj.childNodes[1]).html(parseInt(index)+1);
                        ruleid=ld(tmpobj).attr('ruleid');
                        sort_arr.push(ruleid);
                    }else{
                        ld(tmpobj).addClass('lvtColData');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                        ld(tmpobj.childNodes[1]).html(parseInt(index)+1);
                        ruleid=ld(tmpobj).attr('ruleid');
                        sort_arr.push(ruleid);
                    }
                });
                if (sort_arr,length  > 0) {
                    var reporttype = popupobj.reporttype;
                    var url = that.url+'&option=changeSequence'+'&reporttype='+reporttype+'&sort_str=' + sort_arr.join(',');
                    ldAjax(url, '', function (data) {
                        if (data.code == 1) {
                            ld("#"+popupobj.divid).find('[name=workTemplateRuleDiv]').html(data.result.content);
                            that.moveTable();
                            DelProgressObjs();
                        }
                    })
                }
            }

        })
    }



}
WorkTemplateRule.curobj = '';
WorkTemplateRule.getInstance = function(){
    if(empty(WorkTemplateRule.curobj)){
        WorkTemplateRule.curobj = new WorkTemplateRule();
    }
    return WorkTemplateRule.curobj;
}

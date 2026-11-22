/**
 * Created by gyq_14 on 2016/7/12.
 */
var ScopePopup_Details = (function () {
    function entrance() {
        this.cur_radiovalue = '';
        this.form_name = 'templatename';
        this.firstpop_id = 'allocate_div';  // 第一层弹框id    allocate_divcontent
        this.selectradiotype=['all','group','user']; //单选框类型 user按用户  group按部门
        this.selectradiotype_opposite={'all':0,'group':1,'user':2}; //单选框类型 user按用户  group按部门
        this.selecetids = 'selectallocateid';
        this.selecettype = 'selectallocatetype';
        this.module = '';
        this.treeobj = {} ;
        this.functiontype = '';
    }
    /*
    *  定制报表  Customreport.js
    *                    建立报表   ScopePopup_Details.getInstance().allocateTemplate('',-5,-5,'','','createCustomreport');
    *                    列表分配   ScopePopup_Details.getInstance().allocateTemplate(this,'Settings',report_id,allocateids,allocatetype,'Customreport',folder_id);
    *  帮我吧接口设置   Settings.js
    *                   ScopePopup_Details.getInstance().allocateTemplate('',-5,bangwo8supportnameid,'','','settingsBangwo8info');
    *  打印模板定制   tpl
    *  审批流程管理 tpl
    *  日程模板 tpl
    * */
    // 分配按钮
    entrance.prototype.allocateTemplate = function(obj,approvetabid,approveid,approveallocateid,approveallocatetype,functiontype,extra){
        var jself = this;
        jself.functiontype = functiontype;
        if(functiontype == 'settingsBangwo8info'){
            approveallocateid = ld('#selectallocateid_default').val();
            approveallocatetype = ld('#selectallocatetype_default').val();
            approveallocatetype = jself.selectradiotype_opposite[approveallocatetype];
        }
      
        //初始化弹框所在模块
        if(functiontype == 'createCustomreport' || functiontype == 'Customreport'){
            jself.module = 'Customreport';
        }else{
            jself.module = 'Settings';
        }
        jself.cur_radiovalue=approveallocatetype;
        var input_radio_content = '<input type=radio class="templateprintRadio"  name="radiotype" value="0" >'+arrJsPopLabel['ALLTHEUSERS']+''
            +'<input type=radio name="radiotype" value="1" class="templateprintRadio"  >'+arrJsPopLabel['SETBYDEPARTMENT']+''
            +'<input type=radio name="radiotype" value="2"  class="templateprintRadio"  >'+arrJsPopLabel['SETBYUSERS']+''
            +'<input type="hidden" id="'+jself.selecetids+'" name="'+jself.selecetids+'" class="templateprintuser" value="'+approveallocateid+'">'
            +'<input type="hidden" id="'+jself.selecettype+'" name="'+jself.selecettype+'" class="templateprintuser" value="'+approveallocatetype+'">';
        //定制报表出现的特殊情况：一个页面包含两种分配情况，且第一种弹出框只是隐藏，导致第二种分配失效。
        if(!empty(ld('#allocate_divcontent').html())){
            ld('#allocate_divcontent').remove();
        }
        if(ld('#allocate_divcontent').val() != undefined){
            jself.firstpop_id = 'allocate_div';

            ld('#'+jself.firstpop_id+'content').html(input_radio_content);
            jself.AllocateApplicationType_RadioClick(approveid,approveallocatetype,approvetabid);
        }else {
            getJsScript('include/js/ldcrm.base.js',function() {
                createElementDivs(jself.firstpop_id);//创建DIVallocate_pop_divtitlename
                ld('#'+jself.firstpop_id+'titlename').html(arrJsPopLabel['DISTRIBUT']);
                ld('#'+jself.firstpop_id+'content').html('<div class="divPeople-Title">' + arrJsPopLabel['APPLICABLESCOPE'] + '<div>' +
                    '<div style="margin-top: 5px;">' + input_radio_content + '</div>');

                ld('#'+jself.firstpop_id+' .D_pbtn .D_pbtnok').unbind('click').on('click', function () {
                    if (jself.validate(null)) {
                        if(functiontype == 'Customreport'){
                            jself.validate_url_Customreport(approveid,extra);
                        }else{
                            jself.validate_url(functiontype, approveid, approvetabid);
                        }
                    }
                });
                ld('#'+jself.firstpop_id+' .D_pbtn .D_pbtncancel').on('click',function(){
                    ld('#'+jself.firstpop_id).remove();
                });

                jself.AllocateApplicationType_RadioClick(approveid,approveallocatetype,approvetabid);

            });
        }
    }
    // 三个单选按钮事件
    entrance.prototype.AllocateApplicationType_RadioClick = function(approveid,approveallocatetype,approvetabid){
        var jself = this;
        ld('#'+jself.firstpop_id+'content').find('input[name="radiotype"]').each(function(i){
            if(i > 0){
                ld(this).click(function(){
                    ld('#'+jself.firstpop_id).hide();

                    var fieldobj = {'selecttype':i,'module':jself.module,'functiontype':'normal'};
                    jself.AllocateApplicationRange_Public(fieldobj);
                });
            }
            if(approvetabid == '-5' && approveid == '-5'){
                ld('#'+jself.firstpop_id+'content').find('input[name="radiotype"][value="0"]').prop('checked',true);
            }else{
                if(approveallocatetype==ld(this).val()){
                    ld(this).prop('checked',true);
                }
            }
        });
    }
    // 复选树弹框生成公共方法
    entrance.prototype.AllocateApplicationRange_Public = function (fieldobj,saveback,callback){
        var jself = this;
        var popup_user_url = '';
        var popup_groups_url = '';
        var popup_selectvalue = '';
        var approveallocatetype = '';
        var popup_caption_value;//弹框标题
        var pop_url;
        var searchremind;
      
        /*
         *  用户管理授权范围
         *  轨迹定位组
         * */
        if(fieldobj.functiontype == 'selectScope'){
            popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=user';
            popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+fieldobj.module+'&selecttype=group&popup_inputtype=checkbox';
        
            popup_selectvalue = fieldobj.value;//默认选中值
            approveallocatetype = fieldobj.selecttype;
            if(!empty(popup_selectvalue) && approveallocatetype==fieldobj.selecttype){
            }else{
                popup_selectvalue = '';
            }
            if(fieldobj.selecttype == '2'){
                pop_url = popup_user_url;
                searchremind = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
            }else if(fieldobj.selecttype == '1'){
                pop_url = popup_groups_url;
                searchremind = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
            }
            fieldobj.btnOk = function(selected_id){
                if (ld('#'+fieldobj.field).val() == undefined) {   // tpl隐藏元素暂存选中的值
                    ld('#' + cls_ScopePopup.popup_divid).before('<input type="hidden" id="'+fieldobj.field+'" value="'+selected_id+'" allotype="'+fieldobj.selecttype+'" />');
                } else {
                    ld('#'+fieldobj.field).val(selected_id);
                }
                fieldobj.value = selected_id;
                if(selectUserCallBack.callback){
                    selectUserCallBack.callback(fieldobj);
                }
                saveback();
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
            }
            fieldobj.btnCancel = function(){
               
                if(!empty(callback)){
                    callback(divid);
                }
            }
        }else if(fieldobj.functiontype == 'normal'){
            popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=user';
            popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+fieldobj.module+'&selecttype=group&popup_inputtype=checkbox';
            var approveallocateid = ld('#'+this.selecetids).val();
            approveallocatetype = ld('#'+this.selecettype).val();
            if(!empty(approveallocateid) && approveallocatetype==fieldobj.selecttype){
                popup_selectvalue = approveallocateid;//默认选中值
            }else{
                popup_selectvalue = '';
            }
            if(fieldobj.selecttype == '2'){
                pop_url = popup_user_url;
                searchremind = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
            }else if(fieldobj.selecttype == '1'){
                pop_url = popup_groups_url;
                searchremind = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
            }
            fieldobj.btnOk = function(selected_id){
               
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                ld('#'+jself.selecetids).val(selected_id);
                ld('#'+jself.selecettype).val(fieldobj.selecttype);
            }
            fieldobj.btnCancel = function(){
                ld('#'+jself.firstpop_id).show();
            }
            // 范围查看-高级
        }else if(fieldobj.functiontype == 'SmOwnerSearchSenior'){

            pop_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=user';
            if(ld('#scope_senioruserids').val() != undefined){
                popup_selectvalue = ld('#scope_senioruserids').val();
            }
            popup_caption_value = arrJsPopLabel['VIEWRANGESENIOR'];

            fieldobj.btnOk = function(selected_id){
                if (ld('#scope_senioruserids').val() == undefined) {   // tpl隐藏元素暂存选中的值
                    ld('#' + cls_ScopePopup.popup_divid).before('<input type="hidden" id="scope_senioruserids" value="' + selected_id + '"/>');
                } else {
                    ld('#scope_senioruserids').val(selected_id);
                }
                ld('.D_pbtn .D_pbtncancel').click();

                jself.SmOwnerSearchSeniorBtnOk(fieldobj.module,fieldobj.searchview,selected_id,fieldobj.functype2);
            }
            fieldobj.btnCancel = function(){
                /* 范围查找高级中，若无选中值，则跳转全部 */
                var selectids = ld('#scope_senioruserids').val();
                if(selectids == undefined || empty(cls_ScopePopup.return_obj.return_id)){
                    ld('#SmOwnerSearchScope').val('SmOwner_Search_All');
                    ld('#cmb_span_optiontext_SmOwnerSearchScope').text(ld('#SmOwnerSearchScope').find("option:selected").text());
                    if(fieldobj.functype2!='home')
                        ld('#SmOwnerSearchScope').change();////Liver 20170214注释原因：0026633: 首页>组件视图：查看范围，选择高级弹出层，点击弹出层的“×”或者取消按钮时，不应该刷新界面
                }
            }
            /* 仓库管理部分用户\审批步骤指定审批人 ,不对可查看范围进行权限限制*/
        }else if(fieldobj.functiontype == 'wareHouseselectUser'){

            pop_url = 'module=Users&action=UsersAjax&file=viewuserinfo&' +
                'popup_inputtype=checkbox&popup_selecttype=user&filterown=0';
            popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];
            if(ld('#'+fieldobj.selecetids).val() != undefined){
                popup_selectvalue = ld('#' +fieldobj.selecetids).val();
            }
            fieldobj.btnOk = function(){
                var selected_id2 = cls_ScopePopup.return_obj.return_id;//选中的部门id
                var selected_name = cls_ScopePopup.return_obj.return_name;//选中的名
                ld('#'+fieldobj.selecetids).val(selected_id2);
                if(fieldobj.functype2 == 'approvestep'){
                    ld('#'+fieldobj.selecetids2).val(selected_name);
                }else{
                    ld('#'+fieldobj.selecetids2).val(selected_id2);
                }
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                return false;
            }
            fieldobj.btnCancel = function(){}
        }

        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            var scopepopupobj =  new ScopePopupObj(fieldobj.module);
            if(!empty(popup_caption_value)){
                scopepopupobj.popup_caption_value = popup_caption_value;//标题title
            }else{
                scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
            }
            if(!empty(searchremind)){
                scopepopupobj.popup_searchvalue = searchremind;//查询框默认值
            }else{
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
            }
            scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                cls_ScopePopup.prop.popup_module = fieldobj.module;//模块
                cls_ScopePopup.prop.popup_value = popup_selectvalue;
                cls_ScopePopup.return_obj.return_id = '';  // 切换类型时初始化选中值
                cls_ScopePopup.prop.popup_url = pop_url;
                cls_ScopePopup.popup_selecttype = jself.selectradiotype[fieldobj.selecttype] ;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                ld('#'+cls_ScopePopup.popup_divid).css('z-index',"9999");
                //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                        //没有选择任何用户，则给出提示
                        if(empty(cls_ScopePopup.return_obj.return_id)){
                            if(jself.selectradiotype[fieldobj.selecttype] == 'user'){
                                alert(arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                            }else{
                                alert(arrJsPopLabel['Pleaseselectatleastonedepartment']);
                            }
                        }else{

                            var selected_id = cls_ScopePopup.return_obj.return_id;//选中的部门id
                            fieldobj.btnOk(selected_id);
                        }
                        return false;
                    });
                }
                scopepopupobj.setEventBtnCancel=function(divid){
                    //关闭事件
                    divid = cls_ScopePopup.popup_divid;
                    ld('#'+divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
                        ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
                        fieldobj.btnCancel();
                        return false;
                    });
                    //取消事件
                    ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
                        ld('#'+divid+' .D_pbtn .D_pbtncancel').trigger('closediv');
                        fieldobj.btnCancel();
                    });
                    // ld('#'+divid+' .D_pbtn .D_pbtncancel').unbind('closediv').on('closediv',function(){
					// 	alert(fieldobj.functype2);
					// 	if(fieldobj.functype2 != undefined && (fieldobj.functype2 == 'listview' || fieldobj.functype2 == 'home')){
					// 		fninvshnew(divid);
					// 	}
                    //     if(ld('#'+divid).length > 0){
                    //         //删除div
                    //         var divobj = ld('#'+divid).get(0);
                    //         divobj.parentNode.removeChild(divobj);
                    //     }
                    //
                    //    fieldobj.btnCancel();
                    // });
                    return true;
                }
            });
        });
    }

    /* 保存事件 */
    entrance.prototype.validate = function(functiontype)
    {
        /* allocate_pop_divcontent
         * funtiontype:
         *       CalendarTemplate:日程模板  MultiApproveList：审批流程管理  TemplateprintList:打印模板
         *       Bangwo8info：帮我吧设置   EditCalendarTemplate   EditMultiApprove
         * */
        var jself = this;
        if(!empty(jself.functiontype) && empty(functiontype)){
            functiontype = jself.functiontype;
        }
        var approveallocatetype = ld('#'+jself.selecettype).val();
        var selectedtype = ld('#'+jself.firstpop_id+'content input[name="radiotype"]:checked ').val();
        //请至少选择一个部门。
        if (selectedtype != approveallocatetype && selectedtype == 1 ){
            alert(arrJsPopLabel['Pleaseselectatleastonedepartment']);
            return false;
        }
        //请至少选择一个用户。
        if (selectedtype != approveallocatetype && selectedtype == 2 ) {
            alert(arrJsPopLabel['PLEASESELECTLESTONEUSER']);
            return false;
        }
        /* 日程模板详情页保存按钮事件：模板主题不为空 */
        if(functiontype == 'EditCalendarTemplate'){
            var name = ld('form input[name='+this.form_name+']').val();
            if (name.replace(/^\s+/g, '').replace(/\s+$/g, '').length == 0) {
                alert(arrJsPopLabel['TEMPLATENAME']+arrJsPopLabel['CANOTEMPTY']);
                ld('form input[name='+this.form_name+']').focus();
                return false;
            }
            /* 审批流程编辑流程基本信息 */
        }else if(functiontype == 'EditMultiApprove'){
            var name = document.forms['form'].name.value;
            if (name.replace(/^\s+/g, '').replace(/\s+$/g, '').length == 0) {
                alert(arrJsPopLabel['PROCESSNAMECANOTEMPTY']);
                document.forms['form'].name.focus();
                return false;
            }
        }

        return true;
    }
    /* 保存前操作,嵌入旧代码 */
    entrance.prototype.saveAction_before = function(){
        switch (this.functiontype){
            case 'createCustomreport':
                var svalue = ld('#'+this.selecetids).val();
                var tvalue = ld('#'+this.selecettype).val();
                ld('#allocate_divcontent').before('<input type="hidden" name="radioUser" value="'+tvalue+'"  />' +
                    '<input type="hidden" name="create_selectuser" value="'+svalue+'"  />');
                break;
        }
    }
    //定制报表
    entrance.prototype.validate_url_Customreport = function(approveid,extra){
        var jself = this;
        var approveallocateid = ld('#'+jself.selecetids).val();
        var approveallocatetype = ld('#'+jself.selecettype).val();
        var selectedtype = ld('#'+jself.firstpop_id+'content input[name="radiotype"]:checked ').val();
        if(selectedtype == 0){
            approveallocatetype = 0;
        }
        var url = 'module=Customreport&action=CustomreportAjax&file=ReportFolder&type=editReport&report_id='+approveid+'&allocatetype='+approveallocatetype+'&selectUser='+encodeURIComponent(approveallocateid)+'&ajax=true';
        RequestAjax(url,function(rests){
            var url = 'module=Customreport&action=CustomreportAjax&file=ListView&ajax=true';
            if(extra != ''){
                url += '&folder_id='+extra;
            }
            RequestAjax(url,function(rest){
                if(extra != ''){
                    ld('#report-list-div-'+extra).html(rest);
                }else{
                    ld('#report-list').html(rest);
                }
                ld('#'+jself.firstpop_id+' .D_pbtn .D_pbtncancel').click();
				DelProgressObjs();
            });
        });
    }
    entrance.prototype.validate_url = function(functiontype,recordid,tabid){

        /*
        * funtiontype:
        *       CalendarTemplate:日程模板  MultiApproveList：审批流程管理  TemplateprintList:打印模板
        *       Bangwo8info：帮我吧设置
        * */
        var jself = this;
        var approveallocateid = ld('#'+jself.selecetids).val();
        var approveallocatetype = ld('#'+jself.selecettype).val();
        var selectedtype = ld('#'+jself.firstpop_id+'content input[name="radiotype"]:checked ').val();
        if(selectedtype == 0){
            approveallocatetype = 0;
        }
        if(functiontype == 'Bangwo8info'){
            approveallocatetype = jself.selectradiotype[approveallocatetype];
            var operate_smownerid=document.getElementById('operate_smownerid').value;
			var blockidsetting=document.getElementById('blockidsetting').value;
            var fieldidsetting=document.getElementById('fieldidsetting').value;
        }else{
            var blockidsetting=document.getElementById('blockidsetting').value;
            var fieldidsetting=document.getElementById('fieldidsetting').value;
        }

        var url_ajax ={'CalendarTemplate':'module=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=save_allocate&mode=edit&record=' + recordid + '&' +
        'selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype ,
            'MultiApproveList':'module=Settings&action=SettingsAjax&file=SaveMultiApproveList&approveid=' + recordid + '&approvetabid=' + tabid + '&' +
            'selectallocateid=' + approveallocateid + '&radioTypeValue=' + approveallocatetype ,
            'TemplateprintList':'module=Settings&action=SettingsAjax&file=SaveTemplatePrint&templateprintid='+recordid+'&printtabid='+tabid+'&' +
            'selectuser='+approveallocateid+'&radioUserValue='+approveallocatetype+'&allocatetype='+approveallocatetype,
            'Bangwo8info':'module=Settings&action=SaveBangwo8info&bangwo8supportnameid='+recordid+'&operate_smownerid='
            +operate_smownerid+'&selectmember='+approveallocateid+'&supportname='+tabid+'&allocatetype='+approveallocatetype
        };
        var url_location = {'CalendarTemplate':'index.php?module=Settings&action=CalendarTemplate&template_showtype=listview&parenttab=Calendar' +
        '&blockid=' + tabid + '&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'MultiApproveList':'index.php?module=Settings&action=MultiApproveList&parenttab=Settings&blockid=' + tabid + '&' +
            'blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'TemplateprintList':'index.php?module=Settings&action=TemplateprintList&parenttab=Settings&printtab='+tabid+'&' +
            'blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'Bangwo8info':'index.php?module=Settings&action=bangwo8interface&parenttab=Settings&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting
        };
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: url_ajax[functiontype],
                onComplete: function (response) {
                    window.location = url_location[functiontype];
                }
            }
        );
    }

    /* 帮我吧设置保存 */
    entrance.prototype.SaveBangwo8info = function(bangwo8supportnameid,supportname){
        if(this.validate(null)){
            this.validate_url('Bangwo8info',bangwo8supportnameid,supportname);
        }
    };
    // 范围查看-高级 
    entrance.prototype.SmOwnerSearchSenior = function(module,searchview,functiontype){
        /*
        * functiontype:
        *       listview：序时簿 ; home:首页视图
        * */
        var fieldobj = {'selecttype':2,'module':module,'searchview':searchview,'functiontype':'SmOwnerSearchSenior','functype2':functiontype};
        this.AllocateApplicationRange_Public(fieldobj);
    }
    entrance.prototype.SmOwnerSearchSeniorBtnOk = function(module,searchview,senioruserid,functiontype){
        if(functiontype == 'listview') {
            var urlstring = 'module=' + module + '&action=' + module + 'Ajax';
            urlstring += '&file=ListView&ajax=true&start=1&query=true';
            var customtype = '';
            if (module == 'SalesGoal') {

                var actionname = document.getElementById('actionname').value;
                var editresult = document.getElementById('editresult').value;
                window.location.href = "index.php?module=" + module + "&action=" + actionname + "&query=" + editresult + "&SmOwnerSearchScope=" + searchview + "&show=" + 'yes&senioruserid=' + senioruserid;
                return;
            }

            urlstring += '&SearchScope=' + searchview + '&senioruserid=' + senioruserid + '&accounttype=' + customtype + '';

			//审批中心  - 查看范围
			if(module == 'Approve'){
				if(ld('#fromapprovemodule') != undefined){
					urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
				}
				if(ld('#approvestatus') != undefined){
					urlstring += '&approvestatus='+ld('#approvestatus').val();
				}
			}
            RequestAjax(urlstring, function (rest) {
                var result = rest.split('&#&#&#');
                if (empty(rest)) {
                    ld('#ListViewContents').html('');
                    return false;
                }
                if ("undefined" != typeof(result[2])) {
                    ld('#ListViewContents').html(result[2]);
                } else {
                    ld('#ListViewContents').html(arrJsPopLabel['DATAERROR']);
                }
                if (ld('#servicechargeleft').length > 0) {
                    ld('#servicechargeleft').html(result[3]);//服务收费管理
                }
                if (result[1] != '') {
                    ld('#basicsearchcolumns_real').html(ld('#basicsearchcolumns').html());
                    ld('#basicsearchcolumns').html('');
                    document.basicSearch.search_text.value = '';
                }
				DelProgressObjs();
            });
        }else if(functiontype == 'home'){
            document.getElementById('selectuid').value= senioruserid;
            document.getElementById('hiddenscope').value = searchview;
            UnifiedScope.submit();
        }
    }

    /* 仓库管理部分用户\审批步骤指定审批人 ,不对可查看范围进行权限限制*/
    entrance.prototype.wareHouseselectUser = function(selecetids,selecetids2,functiontype){

        var fieldobj = {'selecttype':2,'selecetids':selecetids,'selecetids2':selecetids2,'functiontype':'wareHouseselectUser','functype2':functiontype};
        this.AllocateApplicationRange_Public(fieldobj);
    }
    var instance;
    var _static = {
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }
            
            return instance;
        }
    };
    return _static;
})()

/**
 * Created by gyq_14 on 2016/7/12.
 */
var ScopePopup_Details = (function () {
    function entrance() {
        this.cur_radiovalue = '';
        this.form_name = 'templatename';
        this.firstpop_id = 'allocate_div';  // 第一层弹框id    allocate_divcontent
        this.selectradiotype=['all','group','user','role']; //单选框类型 user按用户  group按部门
        this.selectradiotype_opposite={'all':0,'group':1,'user':2,'role':3}; //单选框类型 user按用户  group按部门
        this.selecetids = 'selectallocateid';
        this.selecettype = 'selectallocatetype';
        this.module = '';
        this.treeobj = {} ;
        this.functiontype = '';
        this.showemptytype = 'no';
        this.title = arrJsPopLabel['DISTRIBUT'];
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

        if(functiontype == 'MobileList' || functiontype == 'MenuList' || functiontype == 'reportMenuCustomization'|| functiontype == 'ProductToolField'|| functiontype == 'ListWareHouse'){
            approveallocatetype = jself.selectradiotype_opposite[approveallocatetype];
        }
        jself.cur_radiovalue=approveallocatetype;
        //wyt 221123 BUG0058971 系统设置分配弹出层，点击后面文字无法选中前面选择框，建议优化，例如：链接模块定制-操作列-分配 添加id、for
        var input_radio_content = ''
            +'<input type="radio" name="radiotype" value="0" id="set_alluser" ><label class="padR10" for="set_alluser">'+arrJsPopLabel['ALLTHEUSERS']+'</label>'
            +'<input type="radio" name="radiotype" value="1" id="set_department" ><label class="padR10" for="set_department">'+arrJsPopLabel['SETBYDEPARTMENT']+'</label>'
            +'<input type="radio" name="radiotype" value="2" id="set_user" ><label class="padR10" for="set_user">'+arrJsPopLabel['SETBYUSERS']+'</label>';
        if(functiontype=='Approve'||functiontype=='MultiApproveList'||functiontype=='MobileList'||functiontype=='Homeboard'||functiontype=='MenuList' || functiontype == 'reportMenuCustomization'|| functiontype == 'LinkModuleCustom'|| functiontype == 'ProductToolField' || functiontype == 'TemplateprintList' || functiontype == 'CalendarTemplate' || functiontype == 'ListWareHouse'|| functiontype == 'SalesGoal')
            input_radio_content+='<input type="radio" name="radiotype" value="3" id="set_role" ><label class="padR10"  for="set_role">'+arrJsPopLabel['SetByRole']+'</label>';

        if(jself.showemptytype=='yes'){
            input_radio_content+='<input type="radio" name="radiotype" value="-10" id="emptytype" ><label class="padR10"  for="emptytype">'+arrJsPopLabel['NONE']+'</label>';
        }

        input_radio_content+='<input type="hidden" id="'+jself.selecetids+'" name="'+jself.selecetids+'" class="templateprintuser" value="'+approveallocateid+'">'
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

                var popupobj = CrmPopup.load(jself.title,'','','LdPopWidth600px',jself.module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL']);

                var contect_html = '<div id="'+jself.firstpop_id+'content">';
                contect_html += '<table class="ld-pop-container" cellspacing="0" cellpadding="0" border="0" width="100%"><tbody><tr>';
                contect_html += '<td class="select-input"><label class="padL0 padR10">'+arrJsPopLabel['APPLICABLESCOPE'] + '</label>' + input_radio_content + '</td>';
                contect_html += '</tr></tbody></table>';
                contect_html += jself.get_bottom_content();
                contect_html += '</div>';
                popupobj.show(contect_html);


                ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click', function () {
                    //保存
                    if (jself.validate(null)) {
                        if(functiontype == 'Customreport'){
                            jself.validate_url_Customreport(approveid,extra);
                        }else{
                            jself.validate_url(functiontype, approveid, approvetabid,extra);
                        }
                        popupobj.CancelEvent();
                    }
                });

                jself.AllocateApplicationType_RadioClick(approveid,approveallocatetype,approvetabid);

            });
        }
    }
    // 三个单选按钮事件
    entrance.prototype.AllocateApplicationType_RadioClick = function(approveid,approveallocatetype,approvetabid){
        var jself = this;
        ld('#'+jself.firstpop_id+'content').find('input[name="radiotype"]').each(function(i){
            var selecttype = ld(this).val();
            if(i > 0 && selecttype >0){

                ld(this).click(function(){

                    ld('#'+jself.firstpop_id).hide();
                    var InactiveUser = 'yes';	//是否显示  启用停用用户 选项
                    //alert(jself.functiontype);
                    if(ld.inArray(jself.functiontype,Array('TemplateprintList','CalendarTemplate','MultiApproveList','settingsBangwo8info',"LinkModuleCustom")) > 0){
                        InactiveUser = 'yes';
                    }
                    var fieldobj = {'selecttype':i,'module':jself.module,'functiontype':'normal','fninvshnew_div':'yes','InactiveUser':InactiveUser};
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
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                fieldobj.value = selected_id;
                if(selectUserCallBack.callback){
                    selectUserCallBack.callback(fieldobj);
                }
                saveback();
            }
            fieldobj.btnCancel = function(){

                if(!empty(callback)){
                    callback(divid);
                }
            }
        }
        else if(fieldobj.functiontype == 'normal'){

            //chj 2021/5/18 45948: （61mis.com/ldcrm）系统设置-审批流程定制；审批流程列表操作栏处，点击分配，按角色分配时，关闭或取消弹出层后；分配弹出层后的遮罩层消失了
            popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
            popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+fieldobj.module+'&selecttype=group&popup_inputtype=checkbox';
            popup_profile_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=profile';
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
            }else if(fieldobj.selecttype == '3'){
                pop_url = popup_profile_url;
                searchremind = arrJsPopLabel['pleaseenterprofile'];
            }
            fieldobj.btnOk = function(selected_id){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                ld('#'+jself.selecetids).val(selected_id);
                ld('#'+jself.selecettype).val(fieldobj.selecttype);
            }
            fieldobj.btnCancel = function(){
                ld('#'+jself.firstpop_id).show();
            }
            // 范围查看-高级
        }
        else if(fieldobj.functiontype == 'SmOwnerSearchSenior'){
            pop_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+fieldobj.module+'&popup_inputtype=checkbox&popup_selecttype=user&popup_type=listselecthigher';
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
                //231031 wym XUQIU1002054 点击确认,保存当前是否勾选显示离职成员
                if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
                    var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
                    var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.popup_module+'&value='+displayinactiv;
                    ldAjaxNoProgresssync(tmpurlsting,'',function(data){})
                }
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

                jself.SmOwnerSearchSeniorBtnOk(fieldobj.module,fieldobj.searchview,selected_id,fieldobj.functype2);
            }
            fieldobj.btnCancel = function(){
                /* 范围查找高级中，若无选中值，则跳转全部 */
                var selectids = ld('#scope_senioruserids').val();
                if(selectids == undefined || empty(cls_ScopePopup.return_obj.return_id)){
                    //ld('#SmOwnerSearchScope').val('SmOwner_Search_All');
                    //ld('#cmb_span_optiontext_SmOwnerSearchScope').val(ld('#SmOwnerSearchScope').find("option:selected").text());
                    //ld('#scope_senioruserids').val('');
                    //if(fieldobj.functype2!='home')
                    //ld('#SmOwnerSearchScope').change();////Liver 20170214注释原因：0026633: 首页>组件视图：查看范围，选择高级弹出层，点击弹出层的“×”或者取消按钮时，不应该刷新界面
                }
            }
            /* 仓库管理部分用户\审批步骤指定审批人 ,不对可查看范围进行权限限制*/
        }
        else if(fieldobj.functiontype == 'wareHouseselectUser'){

            pop_url = 'module=Users&action=UsersAjax&file=viewuserinfo&' +
                'popup_inputtype=checkbox&popup_selecttype=user&filterown=0';
            popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];
            var tmpdivid = '';
            if(!empty(jself.popupobj) && !empty(jself.popupobj.divid)){
                tmpdivid = '#'+jself.popupobj.divid+' ';
            }
            if(ld('#'+fieldobj.selecetids).val() != undefined){
                popup_selectvalue = ld(tmpdivid+'#' +fieldobj.selecetids).val();
            }
            if(fieldobj.functype2 == 'approvestep' || fieldobj.functype2 == 'augmentsinger_approvestep'){
                //duan 20221107 选择审批人不需要判断权限
                pop_url += '&checkprivilege=no';
            }

            fieldobj.btnOk = function(){
                var selected_id2 = cls_ScopePopup.return_obj.return_id;//选中的部门id
                var selected_name = cls_ScopePopup.return_obj.return_name;//选中的名

                ld(tmpdivid+'#'+fieldobj.selecetids).val(selected_id2);
                if(fieldobj.functype2 == 'approvestep' || fieldobj.functype2 == 'augmentsinger_approvestep'){
                    ld(tmpdivid+'#'+fieldobj.selecetids2).html(selected_name);
                    //edit:can 收款单->导入：导入已批准的单据成功后，（GR172）反审批时使用新的审批流程流转，审批人再添加一个成员点击确认时，弹出层没有关闭
                    ld(tmpdivid+'#'+fieldobj.selecetids2).val(selected_name);
                    var tmparr = fieldobj.selecetids.split('_');


                    //edit:zkt 【审批，审批人添加框样式优化】--审批提交审批、审批界面修改审批人使用
                    if(fieldobj.functype2 == 'augmentsinger_approvestep'||(tmparr.length>=2&&ld("#approvestep_selecttr_"+tmparr[tmparr.length-1]).length>0)){
                        if(fieldobj.functype2 == 'augmentsinger_approvestep'){
                            var stepindex = 'augmentsinger';
                        }
                        else{
                            var stepindex = tmparr[tmparr.length-1];
                        }
                        var selected_arr = cls_ScopePopup.return_obj.return_array;//选择id和name对应关系数组
                        //var ulhtml = '<ul class="reader-bar-list">';
                        var ulhtml = '';
                        ld.each(selected_arr,function(id,tmpobj){
                            ulhtml += '<li class="ld-input-inner-div-item" itemid="approver_'+stepindex+'_'+id+'"><span class="item-name">'+tmpobj.name+'</span><span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,\''+fieldobj.selecetids+'\',\''+fieldobj.selecetids2+'\')">×</span></li>';

                        });
                        //ulhtml += '</ul>';
                        var approverdivobj =ld(tmpdivid+'#before_approve_selectdiv_'+stepindex).find('div[name=approvers_div_'+stepindex+']');
                        if(ld(approverdivobj).find('ul').length>0){
                            ld(approverdivobj).find('ul').html(ulhtml);
                        }
                    }


                    /*
                    *edit: chj
                    *date: 2020/9/27
                    *reason: 审批加签
                    */
                    if(fieldobj.functype2 == 'augmentsinger_approvestep'){
                        ld(tmpdivid+"[name='approvestatus'][value=6]").prop("checked", "checked");
                    }
                }else if(fieldobj.functype2 == 'autoreminds'){
                    ld(tmpdivid+'#'+fieldobj.selecetids2).val(selected_name);
                }else{
                    ld(tmpdivid+'#'+fieldobj.selecetids2).val(selected_id2);
                }
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }
                return false;
            }
            fieldobj.btnCancel = function(){}
        }
        else if(fieldobj.functiontype == 'wx_user'){

            pop_url = 'module=Users&action=UsersAjax&file=viewuserinfo&' +
                'popup_inputtype=checkbox&popup_selecttype=user&filterown=0&wx_user=yes';
            popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];
            if(ld('#'+fieldobj.selecetids).val() != undefined){
                popup_selectvalue = ld('#' +fieldobj.selecetids).val();
            }
            fieldobj.btnOk = function(){

                var selected_id2 = cls_ScopePopup.return_obj.return_id;//选中的部门id
                var selected_name = cls_ScopePopup.return_obj.return_name;//选中的名

                ld('#'+fieldobj.selecetids).val(selected_id2);
                ld('#'+fieldobj.selecetids2).html(selected_name);
                ld('#'+fieldobj.selecetids2).val(selected_name);
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                fninvshnew(cls_ScopePopup.popup_divid);
                return false;
            }
            fieldobj.btnCancel = function(){
                divid = cls_ScopePopup.popup_divid;
                fninvshnew(divid);
            }
        }
        else if (fieldobj.functiontype == 'shareCustomrule'){
            popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+fieldobj.module+'&selecttype=group&popup_inputtype=checkbox';
            var approveallocateid = ld('#'+fieldobj.selecetids).val();
            if(!empty(approveallocateid)){
                popup_selectvalue = approveallocateid;//默认选中值
            }else{
                popup_selectvalue = '';
            }
            pop_url = popup_groups_url;
            searchremind = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
            fieldobj.btnOk = function(selected_id){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                ld('#'+fieldobj.selecetids).val(selected_id);
                var selected_name = cls_ScopePopup.return_obj.return_name;
                ld('#'+fieldobj.selecetids2).val(selected_name);
            }
            fieldobj.btnCancel = function(){
                ld('#'+jself.firstpop_id).show();
            }
        }

        getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
            if(fieldobj.functiontype == 'SmOwnerSearchSenior'){
                var methodObj = {'module':fieldobj.module,'popup_check_nogroupuser':'no','functiontype':'SmOwnerSearchSenior'};
                var scopepopupobj =  new ScopePopupObj(methodObj);
            }else{
                var scopepopupobj =  new ScopePopupObj(fieldobj.module);
            }
            //edit:can 20220928 审批流程定制中按成员显示乱码且审批工作流这个地方， 选择审批人， 就不应该勾选这个“显示离职成员” 
            /* scopepopupobj.setInactiveNoShow=function(obj)
             {
                 ld('#viewuser_disableuser').prop('checked',false);
                 ld(obj).css("display",'none')
             }*/
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
            if(fieldobj.selecttype == 2){
                fieldobj.InactiveUser = 'yes';
                if(fieldobj.InactiveUser != 'no'){
                    if(fieldobj.functiontype == 'SmOwnerSearchSenior'){
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label><input id=\'viewuser_unfoldsubgroup\' class="marL10" type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }else{
                        //zkt 0046536: （81mis.com/kfbcrm）系统设置-模板设置-打印模板定制-分配-按部门、按成员，弹出层中没有“子部门默认收起”的控制按钮   成员
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label><input id=\'viewuser_unfoldsubgroup\' class="marL10" type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }

                }else{
                    scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div>';
                }
            }else if(fieldobj.selecttype == 1){
                //zkt 0046536: （81mis.com/kfbcrm）系统设置-模板设置-打印模板定制-分配-按部门、按成员，弹出层中没有“子部门默认收起”的控制按钮  部门
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
            }else{
                //zkt	0046573: （81mis.com/kfbcrm）系统设置-审批流程定制，审批列表界面，操作分配，按角色时，弹窗中不需要显示“子部门默认收起”  添加判断
                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'></div>';
            }
            getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                cls_ScopePopup.prop.popup_module = fieldobj.module;//模块
                cls_ScopePopup.prop.popup_value = popup_selectvalue;
                cls_ScopePopup.return_obj.return_id = '';  // 切换类型时初始化选中值
                cls_ScopePopup.prop.popup_url = pop_url;
                cls_ScopePopup.popup_selecttype = jself.selectradiotype[fieldobj.selecttype] ;
				//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
                scopepopupobj.displayinactiv = jself.displayinactiv;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                ld('#'+cls_ScopePopup.popup_divid).css('z-index',"9999");
                //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){

                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        //没有选择任何用户，则给出提示
                        if(empty(cls_ScopePopup.return_obj.return_id)){
                            if(jself.selectradiotype[fieldobj.selecttype] == 'user'){
                                var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                MessagePopup.TipOne_warning(confirm_str);
                            }else if(jself.selectradiotype[fieldobj.selecttype] == 'role'){
                                var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
                                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                MessagePopup.TipOne_warning(confirm_str);
                            }else{
                                var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                MessagePopup.TipOne_warning(confirm_str);
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
                    ld('#'+divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
                        ld('#'+divid+' .E_pbtn .E_pbtncancel').click();
                        fieldobj.btnCancel();
                        return false;
                    });
                    //取消事件
                    ld('#'+divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
                        ld('#'+divid+' .E_pbtn .E_pbtncancel').trigger('closediv');
                        fieldobj.btnCancel();
                    });
                    // ld('#'+divid+' .E_pbtn .E_pbtncancel').unbind('closediv').on('closediv',function(){
                    // 	if((fieldobj.functype2 != undefined && (fieldobj.functype2 == 'listview' || fieldobj.functype2 == 'home'))){
                    // 		fninvshnew(divid);
                    // 	}
                    // 	if(fieldobj.functiontype != undefined && (fieldobj.functiontype == 'normal' || fieldobj.functiontype == 'wareHouseselectUser') && document.getElementById('allocate_div') == undefined && document.getElementById('createreport_content_div') == undefined){
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
            var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        //请至少选择一个用户。
        if (selectedtype != approveallocatetype && selectedtype == 2 ) {
            var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        //请至少选择一个角色。
        if (selectedtype != approveallocatetype && selectedtype == 3 ) {
            var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        if (selectedtype != approveallocatetype && selectedtype == 3 ) {
            //edit:can 20210510 45810: （61mis.com/kfbcrm）系统设置-审批流程定制-客户审批流；“客户审批测试”，适用范围选择按角色时，但没有选择角色，点击了取消，点击保存未出现“请至少选择一个角色！”的提示；
            var confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        /* 日程模板详情页保存按钮事件：模板主题不为空 */
        if(functiontype == 'EditCalendarTemplate'){
            var name = ld('form input[name='+this.form_name+']').val();
            if (name.replace(/^\s+/g, '').replace(/\s+$/g, '').length == 0) {
                var confirm_str = arrJsPopLabel['TEMPLATENAME']+arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ld('form input[name='+this.form_name+']').focus();
                return false;
            }
            /* 审批流程编辑流程基本信息 */
        }else if(functiontype == 'EditMultiApprove'){
            var name = ld('form input[name=name]').val();
            if (name.replace(/^\s+/g, '').replace(/\s+$/g, '').length == 0) {
                var confirm_str = arrJsPopLabel['PROCESSNAMECANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                ld('form input[name=name]').focus();
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
                ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                DelProgressObjs();
            });
            DelProgressObjs();
        });
    }
    entrance.prototype.validate_url = function(functiontype,recordid,tabid,extra){

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
        if(functiontype == 'MobileList' || functiontype == 'MenuList' || functiontype == 'settingsBangwo8info' || functiontype == 'reportMenuCustomization'|| functiontype == 'LinkModuleCustom'|| functiontype == 'ProductToolField' || functiontype == 'TemplateprintList'|| functiontype == 'ListWareHouse'){
            if(approveallocateid == undefined || approveallocateid == 'undefined'){
                approveallocatetype = 'all';
                approveallocateid = -1;
            }else{
                if(approveallocatetype == 2){
                    approveallocatetype = 'user'
                }else if(approveallocatetype == 1){
                    approveallocatetype = 'group'
                }else if(approveallocatetype == 3){
                    approveallocatetype = 'role'
                }else{
                    approveallocatetype = 'all';
                }
            }
        }
        if(functiontype == 'settingsBangwo8info'){
            //approveallocatetype = jself.selectradiotype[approveallocatetype];
            var operate_smownerid=ld('#operate_smownerid').val();
            var blockidsetting='';
            var fieldidsetting='';
        }else{
            var blockidsetting='';
            var fieldidsetting='';
        }

        //获取选择的源单类型（收款单、付款单）
        var selectsourcetype = '';
        if(functiontype == 'ProductToolField'){
            var selecttypeobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=selecttype]");
            if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                selectsourcetype = ld(selecttypeobj).find("option:selected").val();
            }
        }
        var url_ajax ={
            'CalendarTemplate':'index.php?module=Settings&action=SettingsAjax&file=CalendarTemplate&template_showtype=save_allocate&mode=edit&record=' + recordid + '&' + 'selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype ,
            'MultiApproveList':'index.php?module=Settings&action=SettingsAjax&file=SaveMultiApproveList&approveid=' + recordid + '&approvetabid=' + tabid + '&' +'selectallocateid=' + approveallocateid + '&radioTypeValue=' + approveallocatetype ,
            'TemplateprintList':'index.php?module=Settings&action=SettingsAjax&file=SaveTemplatePrint&templateprintid='+recordid+'&printtabid='+tabid+'&' + 'selectuser='+approveallocateid+'&radioUserValue='+approveallocatetype+'&allocatetype='+approveallocatetype,
            'settingsBangwo8info':'index.php?module=Settings&action=SettingsAjax&file=SaveBangwo8info&bangwo8supportnameid='+recordid+'&operate_smownerid='+operate_smownerid+'&selectmember='+approveallocateid+'&supportname='+tabid+'&allocatetype='+approveallocatetype,
            'LinkModuleCustom':"index.php?module=Settings&action=SettingsAjax&file=LinkModuleCustom&userid="+approveallocateid+'&allocatetype='+approveallocatetype+"&mode=allocate&id="+recordid,
            'ReportAnalysis':'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=ListView&is_ajax=yes&function_name=saveReportAnalysis2user'+ '&' +'selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&report_id='+recordid+'&parent_id='+tabid+'&modulename='+extra ,
            'MobileList':'index.php?module=Settings&action=SettingsAjax&file=MobileList&ajax=true&type=allocate&selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&record='+recordid ,
            'MenuList':'index.php?module=Settings&action=SettingsAjax&file=MenuList&ajax=true&type=allocate&selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&record='+recordid ,
            'reportMenuCustomization':'index.php?module=Settings&action=SettingsAjax&file=reportMenuCustomization&ajax=true&type=allocate&selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&record='+recordid ,
            'ProductToolField':'index.php?module=Settings&action=SettingsAjax&file=ProductToolField&ajax=true&submode=allocate&selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&record='+recordid+'&tabid='+tabid+"&selectsourcetype="+selectsourcetype ,
            'ListWareHouse':'index.php?module=Settings&action=SettingsAjax&file=ListWareHouse&ajax=true&type=allocate&selectallocateid=' + approveallocateid + '&radiotype=' + approveallocatetype+'&record='+recordid ,
        };
        var url_location = {'CalendarTemplate':'index.php?module=Settings&action=CalendarTemplate&template_showtype=listview&parenttab=Calendar' +
                '&blockid=' + tabid + '&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'MultiApproveList':'index.php?module=Settings&action=MultiApproveList&parenttab=Settings&blockid=' + tabid + '&' +
                'blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'TemplateprintList':'index.php?module=Settings&action=TemplateprintList&parenttab=Settings&printtab='+tabid+'&' +
                'blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'settingsBangwo8info':'index.php?module=Settings&action=SettingsAjax&file=bangwo8interface&parenttab=Settings&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
            'LinkModuleCustom':'index.php?module=Settings&action=LinkModuleCustom&parenttab=Settings&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting,
        };

        var surl = url_ajax[functiontype];
        //alert(surl);
        ldAjax(surl,"",function(data){
            if(data.code==1){
                //控制面板 - 打印模板定制
                if('TemplateprintList' == functiontype){
                    ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                    TemplateprintList.refresh();
                }else if('CalendarTemplate' == functiontype){
                    ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                    TemplateCalendar.getInstance().refresh();
                }else if('settingsBangwo8info' == functiontype){
                    ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                    bangwo8interface.refresh();
                }else if('LinkModuleCustom' == functiontype){
                    ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                    LinkModuleCustom.refresh();
                }else if('ReportAnalysis' == functiontype){
                    //zxm  20221110 报表分析 ReportAnalysis
                    ReportAnalysisObj.updateReportHtmlInfo(data.result.reportinfo);
                }else if('MobileList' == functiontype){	//移动端功能菜单定制
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=MobileList&ajax=true';
                    ld.ajax(surl).done(function(response){
                        document.getElementById('cfList').innerHTML = response;
                    })
                }else if('reportMenuCustomization' == functiontype){
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=reportMenuCustomization&ajax=true';
                    ld.ajax(surl).done(function(response){
                        document.getElementById('cfList').innerHTML = response;
                    })
                }else if('MenuList' == functiontype){	//移动端功能菜单定制
                    var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=MenuList&ajax=yes';
                    ld.ajax({
                        url: urlstring,
                        type: 'POST',
                        dataType:'json',
                        success: function(data)
                        {
                            if(data.code==1)
                            {
                                ld("div[name=menulistcontent]").html(data.result.content);
                            }
                        }
                    })
                }else if('ProductToolField' == functiontype){	//单据分录定制
                    var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=ProductToolField&ajax=true&tabid='+tabid;
                    if(!empty(selectsourcetype)){
                        urlstring += "&selectsourcetype="+selectsourcetype;
                    }
                    ld.ajax({
                        url: urlstring,
                        type: 'POST',
                        dataType:'json',
                        success: function(data)
                        {
                            if(data.code==1)
                            {
                                ld("div[name=producttoofieldlist]").html(data.result.content);
                            }
                        }
                    })
                }else if('ListWareHouse' == functiontype){	//仓库
                    var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=ListWareHouse&ajax=true';
                    ld.ajax({
                        url: urlstring,
                        type: 'POST',
                        dataType:'json',
                        success: function(data)
                        {
                            if(data.code==1)
                            {
                                ld(" [name=SettingRightContent]").html(data.result.content);
                            }
                        }
                    })
                }else{
                    ld('#'+jself.firstpop_id+' .E_pbtn .E_pbtncancel').click();
                    getCustomBlockList(document.getElementById('pick_module'),'','');
                    //	ld(' [name=SettingRightContent]').html(data.result.content);
                }
            }else{

            }
            DelProgressObjs();
        })
        /* new Ajax.Request(
             'index.php',
             {
                 queue: {position: 'end', scope: 'command'},
                 method: 'post',
                 postBody: url_ajax[functiontype],
                 onComplete: function (response) {
                     window.location = url_location[functiontype];
                 }
             }
         );*/
    }

    /* 帮我吧设置保存 */
    entrance.prototype.SaveBangwo8info = function(bangwo8supportnameid,supportname){
        if(this.validate(null)){
            this.validate_url('settingsBangwo8info',bangwo8supportnameid,supportname);
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
        var popupobj=CrmPopup.getPopupObj("last");
        // @edit:liushuai,2021-07-22,reason:【ID1000477】PC端：日程管理日历视图界面增加人员查看范围(高级)
        if (module == 'Calendar' && popupobj.type == 'calendarview') {
            updateEventData();
            return false;
        }
        if(functiontype == 'listview') {

            var urlstring = 'module=' + module + '&action=' + module + 'Ajax';
            urlstring += '&file=ListView&ajax=true&start=1&query=true&query_session=1';
            var customtype = '';
            if (module == 'SalesGoal') {

                var actionname = document.getElementById('actionname').value;
                var editresult = document.getElementById('editresult').value;
                ld("#SmOwnerSearchScope").val('smowner_search_senior');
                ld("[name=cmb_span_optiontext_SmOwnerSearchScope]").val(ld("#SmOwnerSearchScope").find("option:selected").text());
                if(global_var.salesgoal==undefined){
                    global_var.salesgoal=[];
                    global_var.salesgoal.push('');
                    global_var.salesgoal.push('');
                }
                var tableindex=ld(".ld-ui-tabs-active").attr('tabindex');
                global_var.salesgoal[tableindex]=senioruserid;
                SalesGoalListClickSearch();
                //window.location.href = "index.php?module=" + module + "&action=" + actionname + "&query=" + editresult + "&SmOwnerSearchScope=" + searchview + "&show=" + 'yes&senioruserid=' + senioruserid;
                return;
            }

            urlstring += '&SearchScope=' + searchview + '&senioruserid=' + senioruserid + '&accounttype=' + customtype + '';
            //zkt 模块树结构显示增加条件，获取树结构点击条件
            if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
                urlstring += '&isshowModuleListTree=yes';
            }
            //审批中心  - 查看范围
            if(module == 'Approve'){
                if(ld('#fromapprovemodule') != undefined){
                    urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
                }
                if(ld('#approvestatus') != undefined){
                    urlstring += '&approvestatus='+ld('#approvestatus').val();
                }
            }
            var viewid = ld('#'+popupobj.divid+' #viewname').val();
            if(viewid>0){
                urlstring += '&viewname='+viewid;
            }
            // RequestAjax(urlstring, function (rest) {
            //     var result = rest.split('&#&#&#');
            //     if (empty(rest)) {
            //         ld('#ListViewContents').html('');
            //         return false;
            //     }
            //     if ("undefined" != typeof(result[2])) {
            //         ld('#ListViewContents').html(result[2]);
            //     } else {
            //         ld('#ListViewContents').html(arrJsPopLabel['DATAERROR']);
            //     }
            //     if (ld('#servicechargeleft').length > 0) {
            //         ld('#servicechargeleft').html(result[3]);//服务收费管理
            //     }
            //     if (result[1] != '') {
            //         ld('#basicsearchcolumns_real').html(ld('#basicsearchcolumns').html());
            //         ld('#basicsearchcolumns').html('');
            //         document.basicSearch.search_text.value = '';
            //     }
            //     if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
            //     {
            //              //通讯录(pc端企业微信)
            //             cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
            //     }
            //     var popupobj=CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            //      popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
            //      setContentHeight(popupobj.module);//计算内容高度
            //      IsFrameElement();
            // 	DelProgressObjs();
            //
            // });
            // BUG0070432 销售目标-看板视图-点击高级查找图标，弹出层中勾选后 点击确定后会跳转到列表界面 hzx 2023-08-02
            var listview_page=new ListView_Page(module,urlstring,"ListViewContents");
            listview_page.callback_fun=function()
            {
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                }
                var popupobj=CrmPopup.getlastPopupObjByType(ListPagePopup.type);
                popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
                setContentHeight(popupobj.module);//计算内容高度
                IsFrameElement();
                DelProgressObjs();
            }
            listview_page.http_page();
        }else if(functiontype == 'home'){
            document.getElementById('selectuid').value= senioruserid;
            document.getElementById('hiddenscope').value = searchview;
            var add_url = '&scope=true'+'&hiddenscope='+ld('#hiddenscope').val()+'&selectuid='+ld('#selectuid').val()+'&homecontrol='+ld('#homecontrol').val();
            if(ld('#module').val() != undefined){
                module = ld('#module').val();
            }
            var surl = "index.php?pageto_action=index&pageto_module="+module+"&page_addurl="+encodeURIComponent(add_url);
            window.location.href=surl;

            // UnifiedScope.submit();
        }
    }

    /* 仓库管理部分用户\审批步骤指定审批人 ,不对可查看范围进行权限限制*/
    entrance.prototype.wareHouseselectUser = function(selecetids,selecetids2,functiontype){
        var fieldobj = {'selecttype':2,'selecetids':selecetids,'selecetids2':selecetids2,'functiontype':'wareHouseselectUser','functype2':functiontype,'InactiveUser':'no'};
        this.AllocateApplicationRange_Public(fieldobj);
    }
    entrance.prototype.shareCustomruleselectGroup = function(selecetids,selecetids2){
        var fieldobj = {'selecttype':1,'selecetids':selecetids,'selecetids2':selecetids2,'functiontype':'shareCustomrule','InactiveUser':'yes'};
        this.AllocateApplicationRange_Public(fieldobj);
    }
    /*获取所有已经绑定过企业微信的用户*/
    entrance.prototype.wx_user = function(selecetids,selecetids2,functiontype){
        var fieldobj = {'selecttype':2,'selecetids':selecetids,'selecetids2':selecetids2,'functiontype':'wx_user','functype2':functiontype,'InactiveUser':'no'};
        this.AllocateApplicationRange_Public(fieldobj);
    }
    //设置底部的内容，空方法用于重写
    entrance.prototype.get_bottom_content = function () {
        return '';
    }

    var instance;
    var _static = {
        getInstance: function () {
            if (instance === undefined) {
                instance = new entrance();
            }

            return instance;
        },
        getSingleInstance: function () {
            return new entrance();
        }
    };
    return _static;
})()

function InsertRemindField(obj)
{
    if(trim(document.getElementById("selField").value )=="") {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];   
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return false;
    }
    var popupobj=CrmPopup.getPopupObj("last");
    var str=ld("#"+popupobj.divid+" [name=CKcontent]").val();
    str+= document.getElementById("selField").value;
    ld("#"+popupobj.divid+" [name=CKcontent]").val(str);
    ld("#"+popupobj.divid+" [name=CKcontent]").focus();
}
function approveSelectModuleField(module,popupmodule,methodtaggroup)
{
    //type:before_approve_email,before_approve_sms,after_approve_sms,after_approve_email,refuse_approve_sms,refuse_approve_email
    var that=this;
    this.setselectfieldvalue=function(methodtaggroup)
    {
        var popupobj=CrmPopup.getPopupObj("last");
        var selectfields="";
        ld.each( ld("#"+popupobj.divid+" [name=moduleselectfield]"),function(){
            if(ld(this).prop("checked")){
                selectfields+=ld(this).val()+",";
            }
        });
        var remindmethod="";
        if(methodtaggroup.indexOf("email")>=0) {
            remindmethod='email';
        }
        else{
            remindmethod='sms';
        }
        // ld("#"+popupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"_hidden]").val(selectfields);
        popupobj.CancelEvent();//关闭选择邮箱或选择手机字段的弹出层
        popupobj=CrmPopup.getPopupObj("last");
        //before_approve_email_accountsfield
        if(selectfields!=""){
            //设置选择的客户或联系人的checkbox选中
            ld("#"+popupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"]").prop("checked",true);
            var methodtaggroup= ld("#"+popupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"]").attr("methodtaggroup");
            //设置提醒方式选中
            ld("#"+popupobj.divid+" [name="+methodtaggroup+"_method]").prop("checked",true);
            //存储选中邮箱字段或短信字段的columnanme
            ld("#"+popupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"_hidden]").val(selectfields);
        }
    };
    this.setselectfieldvalue.funname="setselectfieldvalue";
    var remindmethod='';
	if(methodtaggroup.indexOf("email")>=0 ){
        remindmethod='email';
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth350px",'Emails',"","","","");
    }
    else {
        remindmethod='sms';
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth350px",'sms',"","","","");
    }
	crmPopupobj.prevshow();

	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var popuptype = '';    
	if(prevpopupobj != undefined){
		prevdivid=prevpopupobj.divid;
        if(methodtaggroup.indexOf("email")>=0 ){
            fieldtype = '&fieldtype=email';
        }
		else{
			fieldtype =  '&fieldtype=sms';
		}
	}
    //refuse_approve_email_contactsfield
    var selectcolumname=ld("#"+prevpopupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"_hidden]").val();
    //alert('index.php?module='+ popupmodule +'&action='+popupmodule+'Ajax&file=moduleselectfield&fieldtype='+fieldtype+"&selectcolumname="+selectcolumname);
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxNoProgress('index.php?module='+ popupmodule +'&action='+popupmodule+'Ajax&file=moduleselectfield&fieldtype='+fieldtype+"&selectcolumname="+selectcolumname,'',function(data)
    {
        if(data.code==1) {
            crmPopupobj.setParams(data.result.title,that.setselectfieldvalue,"","LdPopWidth350px",'Emails',[methodtaggroup],data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
        }
        else{
            cancelCrmPopup();
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.result.msg);
            return false;
        }
    });
}
function getCustomBlockList(customField)
{
    var modulename = customField.options[customField.options.selectedIndex].value;
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=MultiApproveList&blockid='+modulename+'&parenttab=Settings&directmode=ajax';
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
            ld("[name=multiapprovelist]").html(data.result.content);
            if(data.result.module_approve==0){//根据模块切换单选框状态
                ld("input[name=module_approve]").prop("checked",true);
            }
            else{
                ld("input[name=module_approve]").prop("checked",false);
            }
            if(data.result.quick_submit==0){
                ld("input[name=quick_submit]").prop("checked",true);
            }
            else{
                ld("input[name=quick_submit]").prop("checked",false);
            }
            if(data.result.again_submit==0){
                ld("input[name=again_submit]").prop("checked",true);
            }
            else{
                ld("input[name=again_submit]").prop("checked",false);
            }
            if(data.result.showdisabledapprove==0){
                ld("input[name=showdisabledapprove]").prop("checked",true);
            }
            else{
                ld("input[name=showdisabledapprove]").prop("checked",false);
            }
            if(data.result.noapprovalshowempty == 'yes'){
                ld("input[name=noapprovalshowempty]").prop("checked",true);
            }
            else{
                ld("input[name=noapprovalshowempty]").prop("checked",false);
            }
		}
	})
}
function ChecksubmitremarkChange() //提交意见为否时不显示“提交意见是否必填”选项
{
    var popupobj=CrmPopup.getPopupObj('last');
    var remarkobj = ld("#"+popupobj.divid+" [name=showsubmitremark]");
    var requiredobj = ld("#"+popupobj.divid+" [name=submitremarkrequire]");
    var td_requiredobj = ld("#"+popupobj.divid+" [id=td_require]");
    var value = ld(remarkobj).prop('checked')?'yes':'no'; 
    if (value == 'yes' ) {
        ld(requiredobj).parent().css("display",'');
        ld(td_requiredobj).css("display",'');
    }
    else {
        ld(requiredobj).parent().css("display",'none');
        ld(td_requiredobj).css("display",'none');
    }
}

//模块 “已批准/拒绝的单据允许再次提交审批” 勾选，且“审批结束是否允许编辑单据”勾选，才显示“审批结束编辑单据保存，自动提交审批时默认审批流程”选项
function CheckfinishedalloweditChange()
{
    var popupobj=CrmPopup.getPopupObj('last');
    var again_submit_status = ld("#"+popupobj.divid+" [name=again_submit_status]").val();
    var finishedalloweditobj = ld("#"+popupobj.divid+" [name=finishedallowedit]");
    var allowagainsubmitobj = ld("#"+popupobj.divid+" [name=allowagainsubmit]");
    var editresetobj = ld("#"+popupobj.divid+" [tag=editresettag]");
    var value = ld(finishedalloweditobj).prop('checked')?'yes':'no';
    if (value == 'yes' && again_submit_status == 'yes') {
        ld(allowagainsubmitobj).parent().css("display",'');
        ld(allowagainsubmitobj).parent().prev().css("display",'');
    }
    else {
        ld(allowagainsubmitobj).parent().css("display",'none');
        ld(allowagainsubmitobj).parent().prev().css("display",'none');
    }

    if(value == 'yes'){
        editresetobj.css("display",'');
    }
    else{
        editresetobj.css("display",'none');
    }
}
function getEditNewApprove(approveid,tabid,approvename){
    //先这样吧，不做代码公用了，没有那么多时间
    var surl = 'index.php?module=Settings&action=SettingsAjax&file=ApproveDelete&delete=false&record='+approveid+'&blockid='+tabid;
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            //编辑新的审批流程
            getJsScript('include/js/modules/Approve/cls_newApproveSet.js',function(){
                var obj= cls_newApproveSet.getObj();
                obj.setApproveId(approveid);
                obj.showapproveinfo();
                obj.approveused = 'no';
                var popupobj=CrmPopup.getPopupObj('last');
                popupobj.approveused = 'no';
            });
        }
        else{
            //该流程正在被使用，是否继续？
            var confirm_str = arrJsPopLabel['PROCESSUSEDWHETHERCONTINUE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                //编辑新的审批流程
                getJsScript('include/js/modules/Approve/cls_newApproveSet.js',function(){
                    var obj= cls_newApproveSet.getObj();
                    obj.setApproveId(approveid);
                    obj.showapproveinfo();
                    obj.approveused = 'yes';
                    var popupobj=CrmPopup.getPopupObj('last');
                    popupobj.approveused = 'yes';
                });
            });
        }
    });
    return false;
}
function CopyNewApprove(approveid,tabid,approvename){
    //复制新的审批流程
    CopyApproveForm('',approveid,tabid,approvename)
}
//审批流程序时簿新增流程
function getCreateApproveForm(customModule,blockid,record)
{
    if(record<=0) {
        getJsScript('include/js/modules/Approve/cls_newApproveSet.js',function(){
        var obj= cls_newApproveSet.getObj();
            obj.showapproveinfo();
        });
        return false;
    }
    blockid=ld(' select[name=pick_module]').val();
	var surl = "index.php?module=Settings&parenttab=Settings&action=SettingsAjax&file=EditMultiApprove&blockid="+blockid;
	if(record > 0){
		surl += '&record='+record+'&mode=edit';
	}
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveAppriveForm,"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext);
            // crmPopupobj.show(data.result.content);
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            ChecksubmitremarkChange();
            CheckfinishedalloweditChange();
            crmPopupobj.blockid=blockid;
            crmPopupobj.record=record;
            crmPopupobj.isnewapprove='no';
            //审批结束是否允许编辑单据
            ld("#"+crmPopupobj.divid+" [name=fininsedselectfieldtype]").unbind("change").bind("change",function(){
                if(ld(this).val()=='all') {
                    ld("#"+crmPopupobj.divid+' [name=tr_FinishedApproveAllowEditFieldSet]').css("display",'none');  
                }
                else{
                    ld("#"+crmPopupobj.divid+' [name=tr_FinishedApproveAllowEditFieldSet]').css("display",'');
                }
            })
            ld("#"+crmPopupobj.divid+" [name=finishedallowedit]").unbind("change").bind("change",function(){
                ld("#"+crmPopupobj.divid+" [tag=tr_FinishedApproveAllowEditFieldSet]").css("display",'none');
                if(ld(this).prop("checked")) {
                    ld("#"+crmPopupobj.divid+" [tag=tr_FinishedApproveAllowEditFieldSet]").css("display",'');
                    ld("#"+crmPopupobj.divid+' [name=finishededittype][value="all"]').attr("checked",true);  
                }
            })
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined") {
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
            }
            var module=customModule;
            ld("#"+crmPopupobj.divid+" [name=finishededittype]").unbind("click").bind("click",function(){
                //设置已批准可编辑字段的适用范围
                var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
                var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox';
                var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';
        
                if(ld(this).val()=='user'||ld(this).val()=='group'||ld(this).val()=='role')
                {
                    var that=this;
                    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function() {
                        scopepopupobj = new ScopePopupObj(module);
                        scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];;//标题title
                        scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck" class="select-input"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                        scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容

                        getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                        {
                            // 0050605: (https://81mis.com/kfbcrm/index.php? [^])系统设置》审批流程定制，合同订单，编辑审批流程设置可编辑字段范围时，部门选择后仍提示让选择部门
                            cls_ScopePopup.popup_selecttype = ld(that).val();
                            cls_ScopePopup.prop.popup_module = module;//模块
                            cls_ScopePopup.prop.popup_value = ld("#"+crmPopupobj.divid+" [name=selectfinishededitid]").val();
                            if(ld(that).val()=='user') {
                                cls_ScopePopup.prop.popup_url = popup_user_url
                                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                            }
                            else if(ld(that).val()=='group') {
                                scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
                                cls_ScopePopup.prop.popup_url = popup_groups_url
                                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                            }
                            else {
                                cls_ScopePopup.prop.popup_url = popup_role_url
                                scopepopupobj.popup_searchvalue=arrJsPopLabel['pleaseenterprofile'];
                                scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div>';
                            }
                            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                            var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
                            //重写确认按钮事件
                            scopepopupobj.setEventBtnOk=function(){
                                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                                    //ls 2022-02-07 0049886: 系统设置》审批流程定制》合同订单，新增审批流，设置可编辑字段的适用范围时，弹窗中直接点击确认，没有提醒“至少选择一个部门/成员”
                                    var selected_groupid = cls_ScopePopup.return_obj.return_id;//选中的部门id
                                    if(empty(selected_groupid)){
                                        if(ld(that).val() == 'group'){
                                            confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                        else{
                                            confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            return false;
                                        }
                                    }
                                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                                    var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                                    ld('#'+crmPopupobj.divid+" [name=selectfinishededitid]").val(selected_user);
                                    ld('#'+crmPopupobj.divid+" [name=selectfinishededittype]").val(ld(that).val());
                                    return false;
                                });
                            }
                		});
                 	});
                }
            })
            //设置审批适用范围
			ScopePopup_Details.getInstance().allocateTemplate(this,data.result.approve[0].tabid,data.result.approve[0].id,data.result.userlist,data.result.approve[0].approveallocatetype,'Approve');
		}
	})
}
//保存审批流程
function saveAppriveForm(){
    var validate = ScopePopup_Details.getInstance().validate('EditMultiApprove');
    if(validate){
        dup_validation();
        return false;
    }
}
saveAppriveForm.funname='saveAppriveForm';
//保存
function dup_validation(){
	var popupobj=CrmPopup.getPopupObj("last");
	var mode = ld("#"+popupobj.divid+" [name=mode]").val();
	var name = ld("#"+popupobj.divid+" [name=name]").val();
	var blockid = popupobj.blockid;
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	if(mode == 'edit'){
        var reminstr = '&mode='+mode+'&name='+encodeURIComponent(name)+'&blockid='+blockid+'&record='+record;
    }
	else{
        var reminstr = '&name='+encodeURIComponent(name)+'&blockid='+blockid+'&record='+record;
    }
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=SaveMultiApprove&ajax=true'+reminstr;
    //surl+="&name="+encodeURIComponent(name);
    surl+= '&status='+(ld("#"+popupobj.divid+" [name=status]").prop('checked')?0:1);	//是否启用
	surl+= '&finishedallowedit='+(ld("#"+popupobj.divid+" [name=finishedallowedit]").prop('checked')?'yes':'no');	//审批结束是否允许编辑单据
	surl+= '&allowantiapproval='+(ld("#"+popupobj.divid+" [name=allowantiapproval]").prop('checked')?1:0);	//是否允许反审批单据
	surl+= '&allowagainsubmit='+(ld("#"+popupobj.divid+" [name=allowagainsubmit]").prop('checked')?'yes':'no');	//审批结束编辑单据保存，自动提交审批时默认审批流程
	surl+= '&default_on_new='+(ld("#"+popupobj.divid+" [name=default_on_new]").prop('checked')?'yes':'no');	//是否移动端新建时默认流程
	surl+= '&default_on_submit='+(ld("#"+popupobj.divid+" [name=default_on_submit]").prop('checked')?'yes':'no');	//是否提交审批时默认流程
    surl+= '&showsubmitremark='+(ld("#"+popupobj.divid+" [name=showsubmitremark]").prop('checked')?'yes':'no');	//提交意见是否显示
    surl+= '&submitremarkrequire='+(ld("#"+popupobj.divid+" [name=submitremarkrequire]").prop('checked')?'yes':'no');	//是否提交意见必填
	surl+= '&description='+ld("#"+popupobj.divid+" [name=description]").val();	//备注
	surl+= '&radiotype='+ld("#"+popupobj.divid+" [name=radiotype]:checked").val();	//是否启用
	surl+= '&selectallocateid='+ld("#"+popupobj.divid+" [name=selectallocateid]").val();	//是否启用
	surl+= '&showurgent='+(ld("#"+popupobj.divid+" [name=showurgent]").prop('checked')?'yes':'no');	//提交审批时是否显示加急选项
    surl+= '&enableexpediting='+(ld("#"+popupobj.divid+" [name=enableexpediting]").prop('checked')?'yes':'no');	//是否启用催审功能
    surl+= '&editresetapprove='+(ld("#"+popupobj.divid+" [name=editresetapprove]").prop('checked')?'yes':'no'); //编辑单据后是否重置其审批状态

    var finishededittype='all';
    var fininsedselectfield_arr=[];
    var selectfinishededitid=-1;
    if(ld("#"+popupobj.divid+" [name=finishedallowedit]").prop("checked"))
    {
        finishededittype=ld("#"+popupobj.divid+" [name=finishededittype]:checked" ).val();
        if(finishededittype=='all') {
            selectfinishededitid='-1';
        }
        else{
            selectfinishededitid=ld("#"+popupobj.divid+" [name=selectfinishededitid]" ).val();
        }
        var selectoptionobjs=ld("#"+popupobj.divid+" [name=selectedAssmablyColumns]").find("option");
        if(ld(selectoptionobjs).length>0) {
            ld.each(ld(selectoptionobjs),function(){
                fininsedselectfield_arr.push(ld(this).val());
            })
        }
    }
    var fininsedselectfieldtype=ld("#"+popupobj.divid+" [name=fininsedselectfieldtype]:checked" ).val();//审批结束编辑字段类型（all,part);
    
	ldAjax(surl,{"fininsedselectfieldtype":fininsedselectfieldtype,"finishededittype":finishededittype,"fininsedselectfield":JSON.stringify(fininsedselectfield_arr),'selectfinishededitid':selectfinishededitid},function(data){
		if(data.code==1){
            popupobj=CrmPopup.getPopupObj("last");
            popupobj.CancelEvent();
            var detailpopupobj=CrmPopup.getPopupObj('last');
            if(detailpopupobj!=undefined&&detailpopupobj.pagetype==PageRecordPopup.pagetype) {
                //查看界面刷新
                record=detailpopupobj.record;
                blockid=detailpopupobj.blockid;
                var surl = "index.php?module=Settings&action=SettingsAjax&file=EditMultiApproveList&record="+record+"&blockid="+blockid;
                ldAjaxNoProgress(surl,"",function(data){
                    if(data.code==1){
                      ld("#"+detailpopupobj.divid+"_scroll").html(data.result.content);
                      ld("#"+detailpopupobj.divid+" .E_ptita").html(name);
                    }
                })
            }

            //zkt 0046755: （81mis.com/kfbcrm）系统设置-审批流程定制，操作新建/编辑，保存审批流后，选择模块错位了；会变为之前选择模块样式
            //仅更新下方列表内容，directmode=ajax作为判断条件
            var surl = 'index.php?module=Settings&action=MultiApproveList&parenttab=Settings&ReportHeader=dheader&blockid='+blockid+"&directmode=ajax";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=multiapprovelist]').html(data.result.content);
                    initRightContentHeight();//加载右侧内容中菜单和详细内容高度
                }
                DelProgressObjs();
            })
            DelProgressObjs();
		}
        else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return false;
		}
	})
}
//复制审批流程
var iscopy='yes';
function CopyApproveForm(customModule,record,tabid,label)
{   
    var modulename = customModule;
    if(iscopy=='no') {
        return ;
    }
    iscopy='no';
    ldAjaxHtmlNoProgress('index.php?','module=Approve&action=ApproveAjax&file=CopyApproveSave&record='+record,function(response) {
        getCustomBlockList(document.getElementById('pick_module'));
        iscopy='yes';
    });
}
//编辑审批流程
function getEditApproveForm(customModule,record,tabid,label)
{    
    var modulename = customModule;
	//getCreateApproveForm(customModule,blockid,record)
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=ApproveDelete&delete=false&record='+record+'&blockid='+tabid;
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			getCreateApproveForm(customModule,tabid,record);
		}
        else{
			//该流程正在被使用，是否继续？
            var confirm_str = arrJsPopLabel['PROCESSUSEDWHETHERCONTINUE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				getCreateApproveForm(customModule,tabid,record);
            });
		}
	});
	return false;
}

//删除审批流程
function deleteApprove(record,tabid)
{
    var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=ApproveDelete&record='+record+'&blockid='+tabid;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				 getCustomBlockList($("pick_module"));
			}
            else{
				//该流程正在被使用，无法删除！
				var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTDELETED'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			}
            DelProgressObjs();
		});
    });
    return ;
}

/**
新增并发步骤
**/
var addconcurrentbol='no';
function AddConcurrentStep(stepid,approveid,tabid)
{   
    addconcurrentbol='yes';
    getCreateApproveStepForm(approveid,stepid,tabid,'','','create','','');
}
//新增编辑审批步骤
function getCreateApproveStepForm(record,stepid,tabid,label,order,mode,BLOCKIDSETTING,FIELDIDSETTING)
{
	$("status").style.display="inline";
	var surl='';
    var popupobj=CrmPopup.getPopupObj("last");
	if(mode=='create')
	{
	   surl="module=Settings&parenttab=Settings&action=SettingsAjax&file=EditApproveStep&record="+record+"&blockid="+tabid;
    }
	else
		surl="module=Settings&parenttab=Settings&action=SettingsAjax&file=EditApproveStep&mode=edit&record="+record+"&stepid="+stepid+"&blockid="+tabid;
	if(popupobj.type="EditMultiApprove")//审批流程的编辑和新增界面
    {
        surl+="&frompage=edit";
    }
    else
    {
        surl+="&frompage=detail";
    }
    var concurrentstepid=0;
    if(addconcurrentbol=='yes')
    {
        surl+='&concurrentstepid='+stepid;//并发步骤的ID
        concurrentstepid=stepid;
    }
    addconcurrentbol='no';
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Emails',"","","","");
	crmPopupobj.prevshow();
    //duan 2022-3-30 隐藏旧版进度条
    $("status").style.display="none";
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxNoProgress('index.php?'+surl,'',function(data)
    {
        if(data.code==1)
        {
            //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
            //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
            //$("status").style.display="none";
            crmPopupobj.setParams(data.result.title,validate_approvestep_remind,"","LdPopWidth800px",'Emails',"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.createScrollDiv();//创建滚动条
            crmPopupobj.show(data.result.content);
            crmPopupobj.groupinfo=data.result.groupinfo;
            crmPopupobj.userlevelarr=data.result.userlevelarr;
            crmPopupobj.tipsetreminder=data.result.tipsetreminder;
            crmPopupobj.approvereminds=data.result.approvereminds;
            crmPopupobj.remindusertext=data.result.remindusertext;
            crmPopupobj.showvalues=data.result.showvalues;
            crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
            crmPopupobj.viewnamelabel=data.result.viewnamelabel;
            crmPopupobj.modulelabel=data.result.modulelabel;
            crmPopupobj.module = data.result.modulename;
            crmPopupobj.concurrentstepid=concurrentstepid;
            crmPopupobj.isused = data.result.isused; //当前步骤是否在使用
            crmPopupobj.isnewapprove = popupobj.isnewapprove; //是否是新版审批

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = data.result.columns_block;
            params.fLabels = data.result.flabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.foption;
            params.criteria_groups_arr = data.result.criteria_groups;
            params.module = 'Settings';
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.showAdvanceFilter(crmPopupobj,params);

            crmPopupobj.setScrollDivMaxHeight();
            crmPopupobj.center();
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml('positiondepartment1');
            cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
            cls_resetComboxHtmlobj.setPickListContent(crmPopupobj.groupinfo);
            cls_resetComboxHtmlobj.searchhtmltype='div';
            cls_resetComboxHtmlobj.setComboxObjHtml();
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
            {
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
            }
            //设置审批必填字段设置界面
            getJsScript('include/js/modules/Approve/cls_approve_mandatoryfield.js',function(){
                var mandatoryfieldobj = new cls_approve_mandatoryfield(crmPopupobj.module);
                var parent_obj = ld("#"+crmPopupobj.divid+" #countrycontainer4");
                var augmentsingerobj = ld("#"+crmPopupobj.divid+" [name=is_augmentsinger]");
                mandatoryfieldobj.addsign = ld(augmentsingerobj).prop('checked')?'yes':'no';
                mandatoryfieldobj.setPopupobj(crmPopupobj);
                mandatoryfieldobj.setMandatoryFieldlabelArr(data.result.all_fieldlabel_arr);
                mandatoryfieldobj.setMandatoryField(data.result.mandatoryfield);
                mandatoryfieldobj.CreateTableHtml(parent_obj);
                crmPopupobj.mandatoryfieldobj = mandatoryfieldobj;

                augmentsingerobj.on('change',function () {
                    mandatoryfieldobj.after_change_sign(this,parent_obj);
                })
            })

            document.getElementById("pass").onchange();
            document.getElementById("nopass").onchange();
        }
        else if(data.code == 2){
            //该流程正在被使用，无法修改！
            var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            $("status").style.display="none";
            return false;
        }
    });
}
/**
勾选提醒方式
**/
function approveremindchkbox(remindusername)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var methodtaggroup= ld("#"+popupobj.divid+" [name="+remindusername+"]").attr("methodtaggroup");
    if(ld("#"+popupobj.divid+" [name="+remindusername+"]").prop("checked")){
        ld("#"+popupobj.divid+" [name="+methodtaggroup+"_method]").prop("checked",true);
    }
}
//指定用户 - 选择用户
var approveSelectUser = function(module,methodtaggroup,type='selectuser'){
	var scopepopupobj;
	var input_value;
    var popupobj=CrmPopup.getPopupObj("last");
	if(ld('#'+methodtaggroup+'_'+type+'_hidden') != undefined){
		input_value = ld('#'+methodtaggroup+'_'+type+'_hidden').val()
	}
    if(type == 'selectrole'){// 指定角色
        var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
        var popup_title = arrJsPopLabel['SELECTROLES'];
    }
    else{
    	var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
        var popup_title = arrJsPopLabel['LBL_SELECTUSER'];
    }
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_title;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_url = popup_url;//popup_url
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = input_value;
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					//没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }
                    else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						var selected_username = cls_ScopePopup.return_obj.return_name;//选中的用户
					}
			
					if(ld('#'+methodtaggroup+'_'+type+'_hidden') != undefined){
						ld('#'+methodtaggroup+'_'+type+'_hidden').val(selected_user);
					}
                    ld("#"+popupobj.divid+" [name="+methodtaggroup+'_'+type+']').prop("checked",true);
                    ld("#"+popupobj.divid+" [name="+methodtaggroup+'_method]').prop("checked",true);
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                });
            }
		});
	});
}
//删除审批步骤
function deleteApproveStep(stepid,approveid,blockid,BLOCKIDSETTING,FIELDIDSETTING)
{
    var confirm = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);

    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=StepDelete&stepid='+stepid+'&record='+approveid+'&blockid='+blockid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,function(response) {
            if(response.indexOf('SUCCESS')>-1){
                getStepList(approveid,blockid,BLOCKIDSETTING,FIELDIDSETTING);
            }
            else if(response.indexOf('USED')>-1){
                //该流程正在被使用，无法删除！
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PROCESSUSEDCANOTDELETED']);
            }
            else if(response.indexOf('HAVELOG')>-1){
                //该步骤已被使用过，无法删除！
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PROCESSHAVEUSEDCANOTDELETED']);
            }
        });
    });
} 
function getStepList(record,blockid,BLOCKIDSETTING,FIELDIDSETTING)
{ 
    ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=EditMultiApproveList&record="+record+"&blockid="+blockid+"&ajax="+true,{},function(data){
        ld("#approvestepdetaillist").html(data.result.content);
    })
} 
//上下移
function gotomove(stepid,approveid,blockid,operation){
    var confirm = '';
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=ChangeStepSeq&operation='+operation+'&stepid='+stepid+'&record='+approveid+"&blockid="+blockid,function(response) {
        if(response.indexOf("SUCCESS")>-1){
            getStepList(approveid,blockid);
        }
        else if(response.indexOf("USED")>-1){
            //该流程正在被使用，无法修改！
            confirm = arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
        }
        else if(response.indexOf("ALREADY_FIRST")>-1){
            //该步骤已经是第一步了！
            confirm = arrJsPopLabel['STEPISFIRSTSTEP'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
        }
        else if(response.indexOf("ALREADY_LAST")>-1){
            //该步骤已经是最后一步了！
            confirm = arrJsPopLabel['STEPISLASTSTEP'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
        }
    });
}

//新增步骤标签页切换
/*editor:gyq_05 reason:新增审批通知标签页 date:2016 2 23*/
function clicktab(id){
    ld('#thetab1,#thetab2,#thetab3,#thetab4').removeClass('ld-ui-tabs-active');
    ld('#countrycontainer1,#countrycontainer2,#countrycontainer3,#countrycontainer4').hide();
    if(id==1){
        ld('#thetab1').addClass('ld-ui-tabs-active');
        ld('#countrycontainer1').show();
        ld('#countrytabs p').css('display','block');
    }
    else if(id==2){
        ld('#thetab2').addClass('ld-ui-tabs-active');
        ld('#countrycontainer2').show();
        ld('#countrytabs p').css('display','block');
    }
    else if(id==3){
        ld('#thetab3').addClass('ld-ui-tabs-active');
        ld('#countrycontainer3').show();
        ld('#countrytabs p').css('display','block');
    }
    else if(id==4){
        ld('#thetab4').addClass('ld-ui-tabs-active');
        ld('#countrycontainer4').show();
        ld('#countrytabs p').css('display','block');
    }
}
 
//审批人类型
function getChangeApproveType(obj)
{
    var popupobj=CrmPopup.getPopupObj('last');
    var index=parseInt(obj.options[obj.selectedIndex].value);
    document.forms['stepform'].approve_type.value=index;
    // document.forms['stepform'].userid_name.value='';
    ld("#"+popupobj.divid+" [name=userid_name]").html('');
    document.forms['stepform'].userid.value='';
    document.forms['stepform'].role_name.value='';
    document.forms['stepform'].user_role.value='';
    ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','');//显示（多人审批/多人审批）
    switch(index){
        case 0://指定成员
            $('role_name_tr').style.display='none';
            $('username_tr').style.display='';
            $('username_tr2').style.display='';
            $('position_tr').style.display='none';
            $('positionlevel_tr').style.display='none';

            $('positiondepartment_tr1').style.display='none';
            $('positiondepartment_tr2').style.display='none';
            //edit:can 20200716 42011: （https://61mis.com/kfbtest/ [^]）审批步骤中，切换审批人类型为“指定成员”后，成员为空或者只有一个时，应该不显示审批方式
            ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','none');
            break;
        case 1://指定角色
            $('role_name_tr').style.display='';
            $('username_tr').style.display='none';
            $('username_tr2').style.display='';//20995: 控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后，下一步审批控制区块中没有显示参数“是否允许指定下一步处理人”
                                                //说明	控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后
            $('position_tr').style.display='none';
            $('positionlevel_tr').style.display='none';

            $('positiondepartment_tr1').style.display='none';
            $('positiondepartment_tr2').style.display='none';
            break;
        case 2://单据负责人部门成员的职位级别
            $('role_name_tr').style.display='none';
            $('username_tr').style.display='none';
            $('username_tr2').style.display='';
            $('position_tr').style.display='';
            $('positionlevel_tr').style.display='none';

            $('positiondepartment_tr1').style.display='none';
            $('positiondepartment_tr2').style.display='none';
            break;
		case 3://单据负责人直属上级部门成员的职位级别
            $('role_name_tr').style.display='none';
            $('username_tr').style.display='none';
            $('username_tr2').style.display='';
            $('position_tr').style.display='none';
            $('positionlevel_tr').style.display='';

            $('positiondepartment_tr1').style.display='none';
            $('positiondepartment_tr2').style.display='none';
            break;
		case 4://指定部门成员的职位级别
            $('role_name_tr').style.display='none';
            $('username_tr').style.display='none';
            $('username_tr2').style.display='';
            $('position_tr').style.display='none';
            $('positionlevel_tr').style.display='none';

            $('positiondepartment_tr1').style.display='';
            $('positiondepartment_tr2').style.display='';
            break;
        case 5://单据创建人
        case 6://单据负责人
            $('role_name_tr').style.display='none';
            $('username_tr').style.display='none';
            // $('username_tr2').style.display='none';
            $('position_tr').style.display='none';
            $('positionlevel_tr').style.display='none';
            ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','none');
            $('positiondepartment_tr1').style.display='none';
            $('positiondepartment_tr2').style.display='none';
            break;
    }
	if(index > 6){
		$('role_name_tr').style.display='none';
		$('username_tr').style.display='none';
		// $('username_tr2').style.display='none';
		$('position_tr').style.display='none';
		$('positionlevel_tr').style.display='none';
		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
        
        //duan 20221123 多选用户字段允许选择或签和会签
        var uitype=parseInt(ld(obj).find('option:selected').attr('uitype'));
        if(uitype == 154){
            ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','');
        }
        else{
            ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','none');
        }
	}
    //根据审批人类型判断是否需要显示’审批人为空时‘的判断
    var appovertype_arr = new Array(1,2,3,4);
    if(index>6|| appovertype_arr.indexOf(index)>=0){
		ld("#"+popupobj.divid+" [name=when_approver_empty]").show();
        //如果选择为'指定成员审批',则显示选择用户输入框
        if(ld("#"+popupobj.divid+" [name=transfertouser]").length>0&&ld("#"+popupobj.divid+" [name=transfertouser]").prop('checked')){
            ld("#"+popupobj.divid+" [name=transferusername_tr]").show();
            //获取选中的成员个数，用于隐藏显示多人审批
    		var strhtml=ld("#"+popupobj.divid+" [name=transfer_userid_name]").html();
    		if(!empty(strhtml)){
    			var tmps=strhtml.split(",");
    			if(tmps.length>1&&tmps[1]!=''&&tmps[1]!=',')
    			{
    				//选择多个，显示多人审批
    				ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','');
    			}
    		}
        }
	}
    else{
        ld("#"+popupobj.divid+" [name=when_approver_empty]").hide();
        ld("#"+popupobj.divid+" [name=transferusername_tr]").hide();
	}
    
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml('positiondepartment1');
    cls_resetComboxHtmlobj.setPopupObj(popupobj);
    cls_resetComboxHtmlobj.setPickListContent(popupobj.groupinfo);
    cls_resetComboxHtmlobj.searchhtmltype='div';
    cls_resetComboxHtmlobj.setComboxObjHtml();
    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined") {
        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
    }
}

function openPopup(){
    //zkt 20231013 XUQIU1001341 SQL注入
    var urlsting = "index.php?module=Users&action=UsersAjax&file=RolePopup&parenttab=Settings";
    urlstring= cls_encryptyurl.Puyoung_Encryptyurl(urlstring,'');
    window.open(urlsting,"roles_popup_window","height=425,width=640,toolbar=no,menubar=no,dependent=yes,resizable=yes");
}
//duan 2022-4-22 使用中的审批步骤修改时，保存时增加提示 
function validate_approvestep_remind(){
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.isused == 'yes'){
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['UPDATEAPPROVEDRECORD']);
        var new_remind_popupobj = CrmPopup.getPopupObj("last");
        ld("#"+new_remind_popupobj.divid).find('input[tagclick="msgConfirm"').on('click',function(){
            validate_approvestep();
        });
    }
    else{
        validate_approvestep();
    }
}
//var btncount=0;

function validate_approvestep()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var stepform=document.forms['stepform'];
    var stepname=stepform.stepname.value;
	var approvetype = stepform.approvetype.value;
    if(stepname.length>0){}
    else{
         //步骤名称不能为空！
         var confirm_str = arrJsPopLabel['STEPNAMECANOTEMPTY'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
         if(stepform.stepname.offsetWidth>0) {
            stepform.stepname.focus();
            //btncount=0;
         }
         return false;
    }
	//审批必填字段
	var approve_module_field = '';
	if(ld("#"+popupobj.divid+" [name=module_fldname]") != undefined){
		ld.each(ld("#"+popupobj.divid+" [name=module_fldname]"),function(skey,jobj){
			if(ld(jobj).is(':checked') == true){
				if(approve_module_field == ''){
					approve_module_field += ld(jobj).val();
				}
                else{
					approve_module_field += ','+ld(jobj).val();
				}
			}
		})
	}
    if(popupobj.advanceFilterObj.checkAdvancedFilter()==false) {
        return false;
    }
   
    var approve_type=stepform.approve_type.value;
    
    if(approve_type==0){
        var userid=stepform.userid.value;
       
        if(userid.length>0){}
        else{
            //用户不能为空！
            var confirm_str = arrJsPopLabel['USERCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //btncount=0;
            if(stepform.userid_name.offsetWidth>0) {
                stepform.userid_name.focus();
            }
            return false;
        }       
    }
    else if(approve_type==1){
        var rolename=stepform.role_name.value;
        if(rolename.length>0){}
        else{
            //角色不能为空！
            var confirm_str = arrJsPopLabel['ROLECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            // btncount=0;
            if(stepform.role_name.offsetWidth>0)
            {
                stepform.role_name.focus();
            }
            return false;
        }      
    }
  
    var blockstatus_pass=stepform.pass.options[stepform.pass.selectedIndex].value;
    var blockstatus_nopass=stepform.nopass.options[stepform.nopass.selectedIndex].value;
    if(blockstatus_pass.length>0) {
        var pass_value=stepform.passvalue.value;
    }
    if(blockstatus_nopass.length>0) {
        var nopass_value=stepform.nopassvalue.value;
    }
	if(approvetype > 1){
		if(approvetype == 2){
			var levelposition = stepform.position.value;
		}
        else if(approvetype == 3){
			var levelposition = stepform.positionlevel.value;
		}
        else if(approvetype == 4){
			var levelposition = stepform.positiondepartment2.value;
		}
		if(levelposition == ''){
            var confirm_str = arrJsPopLabel['POSTITIONLEVELCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			//btncount = 0;
			return false;
		}
	}
   
    // 判断用户操作是否有误，若出错successtype = -5
    var successtype = 1;
    //一些判断代码，被我删除了，等测试提bug我在添加
    if(successtype == 1){
        var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    
        var record=CrmPopup.getHtmlobjval(popupobj.divid,"record");
        if(prevpopupobj.type=='EditMultiApprove'){
            //新增/编辑审批流程界面
            if(record<=0) {
                record=CrmPopup.getHtmlobjval(prevpopupobj.divid,"record");
            }
        }
        var blockid=CrmPopup.getHtmlobjval(popupobj.divid,"blockid");
        var stepname=CrmPopup.getHtmlobjval(popupobj.divid,"stepname");
        var alloweditbill= ld("#"+popupobj.divid+" [name=alloweditbill]").prop('checked')?'yes':'no'; //当前审批人是否许编辑
        var approveremarkrequire= ld("#"+popupobj.divid+" [name=approveremarkrequire]").prop('checked')?'yes':'no';
        var ended= ld("#"+popupobj.divid+" [name=ended]").prop('checked')?0:1;
        var step= ld("#"+popupobj.divid+" [name=step]").prop('checked')?0:1;
        var description=CrmPopup.getHtmlobjval(popupobj.divid,"description");
        var approve_type=CrmPopup.getHtmlobjval(popupobj.divid,"approve_type");
        var advft_criteria=popupobj.advanceFilterObj.advft_criteria;
        var advft_criteria_groups=popupobj.advanceFilterObj.advft_criteria_groups;
        var selectapproveuser=ld("#"+popupobj.divid+" [name=selectapproveuser]").prop('checked')?0:1;
        var userid=CrmPopup.getHtmlobjval(popupobj.divid,"userid");
        var user_role=CrmPopup.getHtmlobjval(popupobj.divid,"user_role");
        var position=CrmPopup.getHtmlobjval(popupobj.divid,"position");
        var positionlevel=CrmPopup.getHtmlobjval(popupobj.divid,"positionlevel");
        var positiondepartment1=CrmPopup.getHtmlobjval(popupobj.divid,"positiondepartment1");
        var positiondepartment2=CrmPopup.getHtmlobjval(popupobj.divid,"positiondepartment2");
        var passvalue=CrmPopup.getHtmlobjval(popupobj.divid,"passvalue");
        if (passvalue == 'undefined' || typeof passvalue === 'undefined') passvalue = '';
        var nopassvalue=CrmPopup.getHtmlobjval(popupobj.divid,"nopassvalue");
        if (nopassvalue == 'undefined' || typeof nopassvalue === 'undefined') nopassvalue = '';
        var pass=CrmPopup.getHtmlobjval(popupobj.divid,"pass");
        var nopass=CrmPopup.getHtmlobjval(popupobj.divid,"nopass");
        //如果审批类型为
        if(ld("#"+popupobj.divid+" [name=tr_countersigner]").css("display")=='none') {
            //edit:can 2021-03-25 45143: （61mis.com/kfbcrm）客户管理-客户；单据客户名称SCG
            var countersigner='no';
        }
        else{
            var countersigner=ld("#"+popupobj.divid+" [name=countersigner]:checked").val();//CrmPopup.getHtmlobjval(popupobj.divid,"countersigner");//是否会签（yes ,no)
        }
        var is_augmentsinger = ld("#"+popupobj.divid+" [name=is_augmentsinger]").prop('checked')?'yes':'no';//本步骤审批时是否允许加签
		var augmentsinger = '';
		if(is_augmentsinger == 'yes'){
			augmentsinger=ld("#"+popupobj.divid+" [name=augmentsinger]:checked").val();
		}
        if(countersigner=='yes') {
            //会签审批
            // selectapproveuser='1';//是否允许修改本步骤审批人
            step='1';//是否允许指定审批步骤
        }
        //保存’审批人为空时‘的参数
        var emptyapproverdeal = ld("#"+popupobj.divid+" [tag=emptyapproverdeal]:checked").attr('name');
        if(emptyapproverdeal == 'transfertouser'){
            var emptyapproverdeal = ld("#"+popupobj.divid+" [name=transfer_userid]").val();
            if(empty(emptyapproverdeal)){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTLESTONEUSER']);
                return false;
            }
        }
        var stepid=CrmPopup.getHtmlobjval(popupobj.divid,"stepid");
        var  tmpurl="";
        tmpurl+="&record="+record+"&blockid="+blockid+'&stepname='+stepname+"&ended="+ended+"&step="+step+"&description="+description;
        tmpurl+="&approve_type="+approve_type+"&advft_criteria="+advft_criteria+"&advft_criteria_groups="+advft_criteria_groups;
        tmpurl+="&userid="+userid+"&user_role="+user_role+"&position="+position+"&positionlevel="+positionlevel+"&positiondepartment1="+positiondepartment1;
        tmpurl+="&positiondepartment2="+encodeURIComponent(positiondepartment2)+"&passvalue="+passvalue+"&nopassvalue="+nopassvalue+"&pass="+pass+"&nopass="+nopass;
        tmpurl+="&stepid="+stepid+"&selectapproveuser="+selectapproveuser;
        tmpurl+="&alloweditbill="+alloweditbill+"&countersigner="+countersigner+"&augmentsinger="+augmentsinger;
        tmpurl+="&approveremarkrequire="+approveremarkrequire;
        tmpurl+="&approve_module_field="+approve_module_field;
        tmpurl+='&concurrentstepid='+popupobj.concurrentstepid;
        tmpurl+='&emptyapproverdeal='+emptyapproverdeal;

        var mandatoryfield = popupobj.mandatoryfieldobj.getMandatoryField();
        tmpurl+='&mandatoryfield='+mandatoryfield;

        for(var i=0;i<popupobj.approvereminds.groups.length;i++)
        {
            var groupname=popupobj.approvereminds.groups[i];
            for(var j=0;j<popupobj.approvereminds[groupname].method.length;j++)
            {
                var remindmethod=popupobj.approvereminds[groupname].method[j];
                //提醒方式
                if(ld("#"+popupobj.divid+' [name='+groupname+'_'+remindmethod+"_method]").prop("checked")){
                    tmpurl+="&"+groupname+'_'+remindmethod+"_method=1";
                }
                else{
                    tmpurl+="&"+groupname+'_'+remindmethod+"_method=0";
                }
                //提醒人
                for(var k=0;k<popupobj.approvereminds[groupname][remindmethod].reminduser.length;k++)
                {
                    //提醒人(remindusertag:approver,sms,smcreator,accountsfield,contactsfield)
                    var remindusertag=popupobj.approvereminds[groupname][remindmethod].reminduser[k];
                    var reminduserchkname=groupname+'_'+remindmethod+"_"+remindusertag;
                    if(ld("#"+popupobj.divid+' [name='+reminduserchkname+"]").prop("checked"))
                    {
                        tmpurl+="&"+reminduserchkname+"=1";
                        if(ld("#"+popupobj.divid+' [name='+reminduserchkname+"]").attr("chkselect")=='yes')
                        {
                            //可以选择：指定用户，指定客户邮箱，指定联系人邮箱,指定客户手机，联系人手机
                             tmpurl+="&"+reminduserchkname+"_hidden"+"="+ld("#"+popupobj.divid+' [name='+reminduserchkname+"_hidden]").val();;
                        }
                    }
                    else {
                         tmpurl+="&"+reminduserchkname+"=0";
                    }
                    //提醒内容
                    //before_approve_sms_selectuser_remindconent 
                    var remindcontentname=groupname+'_'+remindmethod+"_"+remindusertag+"_remindcontent";
                    tmpurl+="&"+remindcontentname+"="+ld("#"+popupobj.divid+' [name='+remindcontentname+"]").val();
                    //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                    //提醒标题
                    var remindtitlename=groupname+'_'+remindmethod+"_"+remindusertag+"_remindtitle";
                    tmpurl+="&"+remindtitlename+"="+ld("#"+popupobj.divid+' [name='+remindtitlename+"]").val();
                }
            }
        }
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=SaveApproveStep",tmpurl,function(data)
        {
            if(data.code==1) {
                ld("#approvestepdetaillist").html(data.result.content);
                var isused = popupobj.isused;
                popupobj.CancelEvent();
                popupobj=CrmPopup.getPopupObj("last");
                //新增审批流程的时候，当先新增审批步骤，默认生成新的审批流程id,所以要把获得审批流程id赋值到新增界面上
                if(popupobj.type=='EditMultiApprove'){
                    ld("#"+popupobj.divid+" [name=record]").val(data.result.record);
                }
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                }
                //duan 2022-4-13 审批步骤设置更新之后，需要对所有正在使用当前步骤的单据进行更新
                if(isused == 'yes'&&data.result.updaterecord == 'yes'){
                    UpdateRecordApproveby(data.result.stepid,0,'',blockid);
                }
            }
            else if(data.msg=='used') {
                var confirm_str=arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
        });
        return true;
    }
    else {
        return false;
    }
}
validate_approvestep.funname = 'validate_approvestep';
//审批步骤高级功能
function passStatus(obj,modulename){
    if(obj==undefined ||obj.id==undefined) {
        return false;
    }
    if(obj.id=='nopass') {
        ld("#nopassvalue").empty();
    }
    else {
        ld("#passvalue").empty();
    }
    if(obj.selectedIndex<=0) {
        return false;
    }
    var columnname=obj.options[obj.selectedIndex].value;
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=getpicklistContent&fld_module="+modulename+"&columnname="+columnname,{"namename": "uname", "namenameage": 18},function(data)
    {
        if(data.code==1) {
            if(obj.id=='nopass') {
                var hiddennopassvalue=ld("#hiddennopassvalue").val();
                ld.each(data.result.picklist,function(value,text){
                    if(value==hiddennopassvalue) {
                        ld("#nopassvalue").append("<option value='"+value+"' selected=''>"+text+"</option>");
                    }
                    else {
                        ld("#nopassvalue").append("<option value='"+value+"'>"+text+"</option>");
                    }
                });
            }
            else {
                var hiddenpassvalue=ld("#hiddenpassvalue").val();
                ld.each(data.result.picklist,function(value,text){
                    if(value==hiddenpassvalue) {
                        ld("#passvalue").append("<option value='"+value+"' selected=''>"+text+"</option>");
                    }
                    else {
                        ld("#passvalue").append("<option value='"+value+"'>"+text+"</option>");
                    }
                });
            }
        }
    });
}

function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('username');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}
//强制返回提交审批
function forceApproveRetStart(tabid,approveid)
{
    var confirm_str = arrJsPopLabel['PERSONCHARGEWHETHERCONTINUE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //执行该操作后，所有使用本流程审批的单据将自动返回负责人，是否继续？
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=ForceApproveRetStart&record='+approveid+"&blockid="+tabid,function(response) {
            if(response.indexOf("SUCCESS")>-1){
                //强制驳回后，审批流程使用状态变更为no
                var popupobj = CrmPopup.getPopupObj('last');
                popupobj.approveused = 'no';
                //操作成功！
                var confirm_str = arrJsPopLabel['SUCCESSFULOPERATION'];
                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                MessagePopup.TipOne_success(confirm_str);
                //点击确认
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    //location.reload();
                })
            }
            else if(response.indexOf("FAILED")>-1){
                //操作失败！
                var confirm_str = arrJsPopLabel['OPERATIONFAILED'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
        });
    })
    return false;
}

function getSelectedPhone(txtidText,txtid,tabname){
    cbobj=document.getElementsByName('cb_select_'+tabname);
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById(txtidText);
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+tabname+'_'+i);
                txt_obj=document.getElementById('txt_user_'+tabname+'_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}

/**
 * 批量审批点击事件，弹出批量审批层之后，绑定保存按钮点击事件
 * @param Object Event对象
 * @returns 执行批量审批操作
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-26
 */
function approve_batchapproved(obj){
	var count = 0;
	var searchurl = ld('#search_url').val();
    var selectobj = document.getElementsByName("selected_id");
	var selectlen = selectobj.length;selectid = '';
	var confirm_status = true;
	if(selectlen > 0){
		var select_id = document.getElementById('allselectedboxes').value;
		if(select_id == 'all'){
			//获取全选数量
			selectlen = document.getElementById('numOfRows').value;
            excludedRecords = document.getElementById('excludedRecords').value;
			if(parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',selectlen,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
					confirm_status = true;
				}
                else {
					return false;
				}
			}
			selectid = select_id;
		}
        else{
			var x = select_id.split(';');
			var count = x.length;
			if(0 == ld('input[name=selected_id]:checked').length){
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                MessagePopup.TipOne_warning(confirm_str);
				return false;
			}
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
					confirm_status = true;
				} else {
					return false;
				}
			}
			selectid = x.join(',');
            selectlen = count - 1;
		}
	}

	if(confirm_status){
        var popupobj = CrmPopup.load(arrJsPopLabel['APPROVE_BATCHAPPROVED'],'','','LdPopWidth600px','Approve','',arrJsPopLabel['Confirm'],'',arrJsPopLabel['CANCEL']);
        var middle_html = '<div id="subappcontent" class="ld-public-content-small">' +
            '            <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">' +
            '                <tbody>' +
            '                    <tr>' +
            '                      <td class="ld-form-item-content select-input padL0">' +
            '                        <input type="radio" value="1" name="approvedtype" class="tablink" id="tablink_1" checked>' +
            '                           <label for="tablink_1">'+arrJsPopLabel["CONTINUEAPPROVALSTEP"]+'</label>' +
            '                      </td>' +
            '                    </tr>' +
            '                    <tr>' +
            '                      <td class="ld-form-item-content select-input padL0">' +
            '                        <input type="radio" value="0" name="approvedtype" class="tablink" id="tablink_0"/>' +
            '                           <label for="tablink_0">'+arrJsPopLabel["NOTPASSRETURNCHARGE"]+'</label>\n' +
            '                      </td>' +
            '                 </tr>' +
            '                    <tr>' +
            '                <td class="ld-form-item-content padT28 padL0"><b>' +
            '                '+arrJsPopLabel["APPROVALSUGGESTION"]+'</b><br>' +
            '                <textarea class="ld-textarea-inner marT16" name="approveddescri" id="approveddescri" rows="4"></textarea>' +
            '                </td>' +
            '                    </tr>' +
            '                </tbody>' +
            '            </table>' +
            '        </div>';
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,middle_html);
        ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click',function () {
            var popupobj = CrmPopup.getPopupObj('last');
            var divobj = ld('#'+popupobj.divid);
            ld(this).css('disabled','true');
            var approvedtype = divobj.find('[name=approvedtype]');
            var approvetypelen = approvedtype.length;
            var approvetype = 0;
            for(var i=0; i<approvetypelen; i++){//获取当前反审批状态
                if(approvedtype[i].checked){
                    approvetype = approvedtype[i].value;
                }
            }
            var approveddescri = divobj.find('#approveddescri').val();
            /**
             * 批量审批点击事件，弹出批量审批层之后，绑定保存按钮点击事件
             * @0013756: 审批中心-待审批：不能全选所有单据，只能选中当页的
             * @author Tujt 2015-05-11
             */
            if('inline' == ld('#deSelectAllRec').css('display')){
                selectid = 'All';//全选所有
            }

            // @edit:liushuai,2021-03-08,reason:【ID1001390】审批中心-》批量审批增加显示进度条
            var intervalrow = 4;
            if (selectlen > 50){
                intervalrow = Math.ceil(selectlen / 5); //向上取整
            }
            intervalrow=6;
            popupobj.CancelEvent();
            start_approve_batchapproved(approvetype, selectid, selectlen, approveddescri, searchurl,  0, intervalrow);
        })
	}
}

function start_approve_batchapproved(approvetype, selectid, selectlen, approveddescri, searchurl, startrow, intervalrow) {
    var endrow = startrow+intervalrow;
    if (endrow > selectlen){
        endrow = selectlen;
    }

    var urlstring = 'module=Approve&action=ApproveAjax&file=SaveApproveLog';
    urlstring += '&approvedtype='+approvetype+'&batckapproved=1';
    urlstring += '&selectid='+selectid+'&selectlen='+selectlen;
    urlstring += '&description='+approveddescri;

    if(document.getElementById('is_approve_module') != undefined && document.getElementById('is_approve_module').value != ''){
        urlstring += '&fromapprovemodule='+document.getElementById('is_approve_module').value;
    }
    if(document.getElementById('is_approve_status') != undefined && document.getElementById('is_approve_status').value != ''){
        urlstring += '&approvestatus='+document.getElementById('is_approve_status').value;
    }
    urlstring += searchurl;
    var tmppopupobjobj;
    if(startrow==0) {
        tmppopupobjobj=ProgressPopup.load(arrJsPopLabel['APPROVE_BATCHAPPROVED'],"","",'LdPopWidth600px','Users',"","","","");
        tmppopupobjobj.show();
        var maxrows=parseInt(selectlen);
        var percent=parseInt((0/maxrows*100));
        tmppopupobjobj.setPercentWidth(percent);
        tmppopupobjobj.setTotalNum(maxrows);
        tmppopupobjobj.setCurNum(1);
    }
    urlstring += "&startrow="+startrow+"&endrow="+endrow;
    //edit:can BUG20240830-30
    ldAjaxHtmlNoProgress('index.php?',urlstring,function (rest) {
        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
        //批量审批进度条
        tmppopupobjobj=CrmPopup.getPopupObj('last');
        var maxrows=parseInt(restobj.maxrows);
        var percent=parseInt(((startrow+intervalrow)/maxrows*100));
        // var percent=parseInt((startrow/maxrows*100));
        tmppopupobjobj.setPercentWidth(percent);
        tmppopupobjobj.setTotalNum(restobj.selectrows);
        tmppopupobjobj.setCurNum(startrow+intervalrow);
        if(maxrows!=restobj.selectrows) {
            tmppopupobjobj.setValidataNum(maxrows);
        }
        if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows)) {
            start_approve_batchapproved(approvetype, selectid, selectlen, approveddescri, searchurl, startrow + intervalrow, intervalrow);
            return false;
        }
        else{
            tmppopupobjobj.CancelEvent();
        }
        var new_popupobj = CrmPopup.load(restobj.title,"","",'LdPopWidth600px','Approve','',arrJsPopLabel['Confirm'],'',arrJsPopLabel['CANCEL']);
        var submitlog = '<div id="batchapprove_divcontent" class="pop_remind_content">'
        submitlog += '<div style="width: 100%;display:block;word-break: break-all;word-wrap: break-word;font-size:14px;">';
        submitlog += '<span>'+restobj.content+'</span>';//批量提交日志
        submitlog += '</div>';
        submitlog += '</div>';
        CrmPopup.setPopupobjHtmlContent_scroll(new_popupobj,submitlog);
        var divobj = ld('#'+new_popupobj.divid);
        ld('#'+new_popupobj.divid+'_btnok').unbind('click').on('click',function(){
            new_popupobj.CancelEvent();
            getListViewEntries_js('Approve',searchurl+'start=1');//刷新页面
        });
        //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
        ModelDataBindobj.setButtonName='batchapprove';
        ModelDataBindobj.setpropertyname='approvesavebutton';
        DelProgressObjs();
    });
}

//审批中心 - 我提交的（重新提交）
function approve_resubmitapproved(obj){
	var count = 0;
	var searchurl = ld('#search_url').val();
    var selectobj = document.getElementsByName("selected_id");
	var selectlen = selectobj.length;selectid = '';
	var confirm_status = true;
	if(selectlen > 0){
		var select_id = document.getElementById('allselectedboxes').value;
		if(select_id == 'all'){
			//获取全选数量
			selectlen = document.getElementById('numOfRows').value;
            excludedRecords = document.getElementById('excludedRecords').value;
			if(parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',selectlen,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
					confirm_status = true;
				}
                else {
					return false;
				}
			}
			selectid = select_id;
		}
        else{
			var x = select_id.split(';');
			var count = x.length;
			if(0 == ld('input[name=selected_id]:checked').length){
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                MessagePopup.TipOne_warning(confirm_str);
				return false;
			}
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
					confirm_status = true;
				} else {
					return false;
				}
			}
			selectid = x.join(',');
		}
	}
	
	if(document.getElementById('is_approve_module') != undefined && document.getElementById('is_approve_module').value != ''){
		approvemodule = document.getElementById('is_approve_module').value;
	}
	if(confirm_status){
		var urlstring = 'module=Approve&action=ApproveAjax&file=ReSubmitApprove&save=false&fld_module='+approvemodule+'&selectid='+selectid;
		if(ld('#fromapprovemodule') != undefined){
			urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
		}
		if(ld('#approvestatus') != undefined){
			urlstring += '&approvestatus='+ld('#approvestatus').val();
		}
		RequestAjax(urlstring,function(rest){//获取当前模块的审批流程
			if(rest == ''){
				DelProgressObjs();
				return false;
			}
			if(rest.indexOf('###NO###') > -1){//没有可用的审批流程
			  var div_text = '<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
				 +'<div class="msgDlg">'
				 +'<div class="msgDlg_right">'   
				 +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+arrJsPopLabel['NOPROCESSPLEASESETPROCESS']
				 +'</div>'
				 +'</div>'
				 +'</div>'
				 +'</div>';

				var divobj = createElementDivs('friendlyreminder');
				var title = arrJsPopLabel['WARMPROMPT'];
				ld(divobj).find('.D_pop_tit .D_ptita').html(title);
				ld('#friendlyremindercontent').html(div_text);
				ld(divobj).css('max-height','500px');
				ld(divobj).css('width','400px');
				ld(divobj).css('background','#FDFDFD');
				ld('#friendlyremindercontent').css('max-height','400px');
				ld('#friendlyremindercontent').css('border','none');
				ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
				ld(divobj).find('span').remove();
				ld(divobj).find('.D_pbtncancel').remove();
				ld(divobj).find('div.D_pop_tit a').attr("onclick","fninvshnew('friendlyreminder');");
				ld(divobj).find('div.D_pbtn .D_pbtnok').attr("onclick","fninvshnew('friendlyreminder');");
				fnvshobj(this,'friendlyreminder');
				return false;
			}
			var results = rest.split("###SUCCESS###");
			var approveobj = document.getElementById('SubmitApprove');
			sethtml(approveobj,results[1]);
			fnvshobj('','SubmitApprove');
			ld('#SubmitApprove').css('top','30%');
			//获取保存按钮，重新绑定点击事件
			var appinput = approveobj.getElementsByTagName('input');
			var applen = appinput.length;var submitobj;var cancelobj;
			for(var i=0; i<applen; i++){
				if('D_pbtnok' == appinput[i].className){
					submitobj = appinput[i];//保存按钮对象
				}
                else if('D_pbtncancel' == appinput[i].className){
					cancelobj = appinput[i];//取消按钮对象
				}
			}

			if(submitobj){
				var issubmit = 1;
				//批量审批后，保存按钮会被修改为下载文本，再次绑定按钮时，需要把文本重新修改为保存
				if(approve_subbtn_val != '') submitobj.value = approve_subbtn_val;
				submitobj.onclick = function(){//给保存按钮绑定点击事件
					if(issubmit != 1) return false;issubmit = 2;//防止重复点击
					var approvevalue = ld('#SubmitApprove form[name=frmsubmitapprove]').find('[name=approvevalue]').val();
					var nextstepapprover = ld('#SubmitApprove form[name=frmsubmitapprove]').find('[name=nextstepapprover]').val().length;
					if(nextstepapprover == 0){
						issubmit=1;
                        var confirm_str = arrJsPopLabel['NONEXTAPPROVER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
					}
					var urlstring = 'module=Approve&action=ApproveAjax&file=ReSubmitApprove';
					urlstring += '&fld_module='+module+'&approvevalue='+approvevalue;
					urlstring += '&selectid='+selectid+'&batchsubmit=1&save=true&selectlen='+selectlen;
					if(ld('#fromapprovemodule') != undefined){
						urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
					}
					if(ld('#approvestatus') != undefined){
						urlstring += '&approvestatus='+ld('#approvestatus').val();
					}
					RequestAjax(urlstring,function(rest){//批量提交保存
						if(rest == '') return false;
						var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
						var submitlog = '<div class="pop_remind_content">';
						submitlog += restobj.log.value;//批量提交失败日志
						submitlog += '</div>';
						sethtml(document.getElementById('subappcontent'),submitlog);
						approve_subbtn_val = submitobj.value;
						var inputs = submitobj.parentNode.getElementsByTagName('input');
						inputs[1].value = restobj.download.value;
						submitobj.style.display = 'none';//隐藏提交按钮
						cancelobj.className="D_pbtnok";
						ld('#SubmitApprove').find('span').remove();//删除span，不然确认按钮没有居中
						cancelobj.onclick = function(){//取消按钮
							fninvshnew('SubmitApprove');puyoungJS_DialogBox.unblock();
							getId('allselectedboxes').value = '';
							getListViewEntries_js('Approve',searchurl+'start=1');//刷新页面
						}
						DelProgressObjs();
					});
				}
			}
			DelProgressObjs();
		});
	}
}
/**
 * 审批中心查找事件
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-29
 */
function approve_searchList(){
	var searchdiv = document.getElementById('approvesearch');
	var searchfld = document.getElementById('approve_search_field');
	var searchtxt = document.getElementById('approve_search_text');
    searchdiv.style.display = (searchdiv.style.display=='none')?'inline':'none';
	searchfld.selectedIndex = 0;
	searchtxt.value = '';
}
/**
 * 审批中心，搜索按钮，执行搜索操作
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-30
 */
function approve_search_click(){
	var searchdiv = document.getElementById('approvesearch');
	var searchfld = document.getElementById('approve_search_field');
	var searchtxt = document.getElementById('approve_search_text');
	searchtxt.value = trim(searchtxt.value);
	var urlstring = '&search_field='+searchfld.value;
	urlstring += '&search_text='+searchtxt.value;
	getListViewEntries_js('Approve','start=1'+urlstring);//刷新页面
}
/**
 * Enter键激发搜索事件
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-30
 */
function approve_searchtxt_keydown(event){
    var e = window.event||event;
	if(13 == e.keyCode){
		document.getElementById('approve_search_btn').onclick();
	}
}

/**
 * 切换页数的时候，需要把搜索的条件也带上
 * @param String module 模块名
 * @param String url 传递过去的值
 * @returns 切换页数
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-30
 */
function getApproveEntries_js(module,url){
	if(document.getElementById('fromapprovemodule') != undefined){
		url += '&fromapprovemodule='+document.getElementById('fromapprovemodule').value;
	}
	if(document.getElementById('approvestatus') != undefined){
		url += '&approvestatus='+document.getElementById('approvestatus').value;
	}
    getListViewEntries_js(module,url);
}
/**
 * 全选、隐藏所有多选框的同时，显示隐藏全选全部链接
 * @project 0013756: 审批中心-待审批：不能全选所有单据，只能选中当页的
 * @author Tujt 2015-05-11
 */
function approveselect_click(obj,relCheckName){   
    approveallselect(obj,'selected_id');
    if(obj.checked){
	    ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataSelected');
	}
    else{
	    var checkObj = document.getElementsByName(relCheckName);
        for(var i=0;i<checkObj.length;i++){
            var rows = "row_"+checkObj[i].value;
            if((i+1)%2==1){
                document.getElementById(rows).className = "lvtColData";    
            }
            else{
                document.getElementById(rows).className = "lvtColDataBj";
            }   
        }	    
	}
    if(parseInt(ld('#listcountrows').val()) > parseInt(ld('#maxperpagelist').val())){
		if(obj.checked){
			ld('#linkForSelectAll').css('display','');
		}
        else{
			ld('#linkForSelectAll').css('display','none');
		}
	}
}
/**
 * 点击全选全部、取消选择所有点击事件
 * @project 0013756: 审批中心-待审批：不能全选所有单据，只能选中当页的
 * @author Tujt 2015-05-11
 */
function apprpveSelectAll_Records(isall){
    if(isall){
        ld('#selectAllRec').css('display','none');
        ld('#deSelectAllRec').css('display','');
        ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataSelected');
    }
    else
    {
        ld('#selectAllRec').css('display','');
        ld('#deSelectAllRec').css('display','none');
         //ld('#selectCurrentPageRec').click();
         /**审批中心>待处理，勾选全部再取消仍然选中整个页面的行
         * @0021138:
         * @author cyb
         * @2016-05-26
         */
         approveselect_click(ld('#selectCurrentPageRec').prop('checked',false)[0]);
        ld('#linkForSelectAll').css('display','none');
        ld('input[name=selected_id]').parent().parent().attr('class','lvtColData');
    }
}
/**
 * 重写审批中心列表全选方法
 * @project PROT144 审批功能改进
 * @author Tujt 2015-01-06
 */
function approveallselect(obj,col){   
    ld('input[name='+col+']').prop('checked',obj.checked);
}

/**
 * 重写多选框反选全部选择框方法
 * @author Tujt 2015-01-23
 */
function approvecheck_object(obj,col){
    var inputs = document.getElementsByName(obj.name);
	var inputlen = inputs.length;
	var check = 0;
	for(var i=0; i<inputlen; i++){
		if(inputs[i].checked){
			check ++;//计算选中的次数
		}
	}
	var allcheck = getId('mentallselect');
	if(check == inputlen){//全选
		allcheck.checked = true;
	}
    else if(0 == check){//一个没选中
		allcheck.checked = false;
	}
}

/**
 * 选单审批
 * @author Tujt 2015-01-22
 */
function approve_menuapproval(obj){        
    fnvshobj(obj,'menuapprovaldiv');
	//1、绑定文本事件            
	var inputs = document.menuapprovalform;//form表单对象
	var searchmod = inputs.menuapproval_search_mod;//模块对象
	var searchfield = inputs.menuapproval_search_field;//搜索字段对象
	var searchbtn = getId('menuapproval_searchbtn');//搜索按钮对象
	var searchtxt = getId('menuapproval_search_text');//搜索文本对象
	//给搜索文本添加haver属性
	searchtxt.className = 'detailedViewTextBox';
	searchtxt.onfocus = function(){searchtxt.className = 'commonDetailedTextBox gwidth70 bgcolordh';}
	searchtxt.onblur = function(){searchtxt.className = 'detailedViewTextBox';}
	searchtxt.onkeydown = function(event){//搜索文本框绑定Enter事件
		var e = window.event||event;
		if(13 == e.keyCode){
			searchbtn.onclick();//触发搜索按钮点击事件
			return false;
		}
	}
	//每次点击按钮，都初始化模块、字段为第一位，清除搜索文本
	searchmod.selectedIndex = 0;
	searchfield.selectedIndex = 0;
	searchtxt.value = '';
	var oldsearchmod = '';
	searchmod.onclick = function(){
		oldsearchmod = searchmod.value;
	}
	//2、相关模块切换事件
	searchmod.onchange = function(){
		var tableobj = getId('menuapprovallistTab');
		var tablen = tableobj.rows.length;
		if(tablen > 0){
			if(confirm(arrJsPopLabel['SWITCHINGMODULEEMPTYLIST'])){
				var menuselect = document.getElementsByName('menuselectid');
				var menuselectlen = menuselect.length;
				var selectid = '';var selectobj = {};
				for(var i=0; i<menuselectlen; i++){//循环多选框对象
					selectid += menuselect[i].value+',';
				}
				var trobj = tableobj.getElementsByTagName('tr');
				var trlen = trobj.length;
				var tr,tbody;var i=0;
				while(i<trlen){//从第二行开始删除所有的行
					tr = trobj[0];
					tbody = tr.parentNode;
					tbody.removeChild(tr);
					i++;
				}
				//然后通过ajax异步移除该条数据
				var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
				urlstring += '&selectid='+selectid+'&setype=2';
				RequestAjax(urlstring,function(rest){
					DelProgressObjs();
					//不需要回传值
				});
			}
            else{//还原模块
				searchmod.value = oldsearchmod;
			}
		}
	}
	//3、搜索按钮点击事件
	searchbtn.onclick = function(){
		var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
		urlstring += '&search_tabid='+searchmod.value+'&setype=1';
		urlstring += '&search_field='+searchfield.value+'&search_text='+searchtxt.value;
		RequestAjax(urlstring,function(rest){//Ajax获取搜索的结果
			searchtxt.value = '';//搜索后，清空搜索框
			if('' == rest) return false;
			var restlist = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			var restobj;
			var tableobj = getId('menuapprovallistTab');
			var tablen = tableobj.rows.length;
            if(tablen > 0){//已经有数据，删除对应的行
				var trobj = tableobj.getElementsByTagName('tr');
				var trlen = trobj.length;
				var tr,tbody;var i=0;
				while(i<trlen){//从第二行开始删除所有的行
					tr = trobj[0];
					tbody = tr.parentNode;
					tbody.removeChild(tr);
					i++;
				}
			}
			var count = 0;
			var row,cnt,colone,selecttabid;
			for (var i in restlist) {//循环结果集
				if('' == restlist[i]) break;//判断非空
				for (var k in restlist[i]) {//循环添加数据到列表中
					restobj = restlist[i][k];
					cnt = 0;
					row = tableobj.insertRow(count);//新增行
                    ++ count;
					row.id = "menurow"+count;
					colone = row.insertCell(cnt);//新增列
					colone.align = 'center';
					colone.innerHTML = '<input type="checkbox" value="'+k+'" name="menuselectid" onclick="approvecheck_object(this,\'approveallselect\')" forcount="'+count+'" tabid="'+restobj['tabid']+'">';
					++ cnt;//审批对象
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['subject'];
					++ cnt;//客户名称
					colone = row.insertCell(cnt);
					if(!empty(restobj['accountname']))
						colone.innerHTML = restobj['accountname'];
					else
						colone.innerHTML = '';
					++ cnt;//单据编号
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['num'];
					++ cnt;//相关模块
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['tabname'];
					++ cnt;//审批流程
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['approvename'];
					++ cnt;//审批步骤
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['stepname'];
					++ cnt;//审批人
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['approveby'];
					++ cnt;//发起人
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['smawnername'];
					++ cnt;//发起时间
					colone = row.insertCell(cnt);
					colone.innerHTML = restobj['createdtime'];
					//相关模块
					selecttabid = restobj['tabid'];
				}
			}
			if(selecttabid > 0){
				searchmod.value = selecttabid;
			}
			DelProgressObjs();
		});
	}
	searchbtn.onclick();//初次加载，初始化数据
	//4、移除按钮点击事件
	var removebtn = getId('menuappruval_removebtn');
	var isconfirm = 1;
	removebtn.onclick = function(){
		var tableobj = getId('menuapprovallistTab');
		var tablen = tableobj.rows.length;
		if(tablen < 1) return false;
		var menuselect = document.getElementsByName('menuselectid');
		var menuselectlen = menuselect.length;
		var selectid = '';var selectobj = {};
		for(var i=0; i<menuselectlen; i++){//循环多选框对象
			if(menuselect[i].checked){
				selectid += menuselect[i].value+',';
				selectobj[menuselect[i].value] = menuselect[i].getAttribute('forcount');
			}
		}
		if('' == selectid){//请至少选择一条记录
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		var isremove = 0;
		if(2 == isconfirm){//批量审批调用清除方法
			isremove = isconfirm = 1;
		}
        else if(confirm(arrJsPopLabel['PLEASECONFIRMWHETHERREMOVE'])){
			isremove = 1;
		}
		if(1 == isremove){
			var tr,tbody;
			for (var i in selectobj) {//先删除tr对象
				tr = getId('menurow'+selectobj[i]);
				tbody = tr.parentNode;
				tbody.removeChild(tr);
			}
			//然后通过ajax异步移除该条数据
			var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
			urlstring += '&selectid='+selectid+'&setype=2';
			RequestAjax(urlstring,function(rest){
				DelProgressObjs();
				//不需要回传值
			});
            //bug:23107当弹出层列表没有单据时，则全选框不选中；edit:cyb date:2016-06-30
            var tablehtml=ld('#menuapprovallistTab tbody').html();
            if(tablehtml=='')  
            ld('#mentallselect').attr("checked",false);
		}
	}
	//5、批量审批按钮
	var approvebtn = getId('menuappruval_approvebtn');
	approvebtn.onclick = function(){
	    document.getElementById('approveddescri2').value='';//每次都清空审批备注框信息；
		var tableobj = getId('menuapprovallistTab');
		var tablen = tableobj.rows.length;
		if(tablen < 1) return false;
		var menuselect = document.getElementsByName('menuselectid');
		var menuselectlen = menuselect.length;
		var selectid = '';var selectobj = {};
		var select_tabid = 0;var menutabid = 0;
		for(var i=0; i<menuselectlen; i++){
			if(menuselect[i].checked){
				//判断所选单据是不是一个模块
				menutabid = menuselect[i].getAttribute('tabid');
				if(0 == select_tabid){
					select_tabid = menutabid;
				}
                else if(menutabid != select_tabid){
					select_tabid = -1;
					break;
				}
				selectid += menuselect[i].value+',';
				selectobj[menuselect[i].value] = menuselect[i].getAttribute('forcount');
			}
		}
		if('' == selectid){//请至少选择一条记录
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		if(-1 == select_tabid){//请选择一个模块的单据进行审批
            var confirm_str = arrJsPopLabel['PLEASESELECTDAPPROVALOCUMENTS'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}                    
		var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
		urlstring += '&selectid='+selectid+'&select_tabid='+select_tabid+'&setype=3';
		RequestAjax(urlstring,function(rest){
			if('' == rest) return false;
			if(rest.indexOf('###APPROVE###') > -1){//没有可用审批流程
                var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			var restlist = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
			//加载审批流程下拉框
			var approve = restlist.approve;
			var approvelen = approve.length;
			var approveopts = getId('menu_approveid');
			approveopts.length = 0;
			var optsindex = 0;
			for(var i=0; i<approvelen; i++){
				approveopts.options[optsindex] = new Option(approve[i]['approvename'],approve[i]['approveid']);
				optsindex ++;
			}
			//加载审批人下拉框
			var user = restlist.user;
			var nextuserid = getId('menu_nextuserid');
			nextuserid.length = optsindex = 1;
			for (var i in user) {
				nextuserid.options[optsindex] = new Option(user[i],i);
				optsindex ++;
			}
			//审批流程下拉框事件
			approveopts.onchange = function(){
				var approveid = approveopts.value;
				var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
				urlstring += '&approveid='+approveid+'&setype=4';
				RequestAjax(urlstring,function(rest){
					if('' == rest) return false;//没有取到审批步骤
					var restlist = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					var menustepid = getId('menu_stepid');
					menustepid.length = optsindex = 1;
					for (var i in restlist) {
						menustepid.options[optsindex] = new Option(restlist[i]['stepname'],i);
						optsindex ++;
					}
					DelProgressObjs();
				});
			}
            /*
             * editor:gyq_05
             * reason:初始化单选按钮，选中第一个
             * */
            ld('td input[name="menubatchapptype"][class!="last2param"]').eq(0).attr("checked","checked");;
			approveopts.onchange();
			//绑定显示 or 隐藏 超链接点击事件，实现审批成功、失败行显示或隐藏

			var displayobj = getId('displayorhidden');
			displayobj.onclick = function(){
				var setype = displayobj.getAttribute('setype');
				/*
				* editor:gyq_05
				* reason:将input单选框显隐范围限制为后两个单选框
				* */
                /*var inputs = document.getElementsByName('menubatchapptype');*/
				var inputs = ld('td[nowrap="nowrap"] input[name="menubatchapptype"][class="last2param"]');
				var inputlen = inputs.length;
				var parentobj;
				if(1 == setype){//显示
					for(var i=0; i<inputlen; i++){
						parentobj = inputs[i].parentNode;
						while('tr' != parentobj.tagName.toLowerCase()){
							parentobj = parentobj.parentNode;
						}
						parentobj.style.display = 'none';
					}
					displayobj.setAttribute('setype','2');
					displayobj.innerHTML = displayobj.getAttribute('disp');
				}
                else{//隐藏
					for(var i=0; i<inputlen; i++){
						parentobj = inputs[i].parentNode;
						while('tr' != parentobj.tagName.toLowerCase()){
							parentobj = parentobj.parentNode;
						}
						parentobj.style.display = '';
						inputs[i].checked = false;//每次隐藏都取消所有选择
					}
					displayobj.setAttribute('setype','1');
					displayobj.innerHTML = displayobj.getAttribute('hidd');
				}
				return false;
			}

			displayobj.onclick();
			//绑定批量审批按钮事件
			var approvedbtn = getId('batchmenuapprovedbtn');
			var issubmit = 1;
			approvedbtn.onclick = function(){
				//获取审批流程ID
				var approveid = getId('menu_approveid').value;
				var descri = getId('approveddescri2').value;
				if(!approveid) return false;
				//首先判断是否选中审批成功、审批失败单选框
				var inputs = document.getElementsByName('menubatchapptype');
				var inputlen = inputs.length;
				var menutype = 0;
				for(var i=0; i<inputlen; i++){
					if(inputs[i].checked){
						menutype = inputs[i].value;break;
					}
				}
				var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
				urlstring += '&menutype='+menutype+'&approveid='+approveid;
				urlstring += '&selectid='+selectid+'&descri='+descri;
				urlstring += '&select_tabid='+select_tabid+'&setype=5';
				if(0 == menutype){//直接批量审批成功、审批失败所选单据
					//指定审批步骤和审批人
					var menu_stepid = getId('menu_stepid').value;
					var menu_userid = getId('menu_nextuserid').value;
					if('' == menu_stepid || menu_stepid < 1){
						var confirm_str = lbl_please_select+' '+lbl_approvalstep;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
					}
                    else if('' == menu_userid || menu_userid < 1){
                        var confirm_str = lbl_please_select+' '+lbl_nextoperator;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
					}
					urlstring += '&stepid='+menu_stepid+'&userid='+menu_userid;
				}
				if(1 != issubmit) return false;
				issubmit = 2;//防止重复点击提交
				RequestAjax(urlstring,function(rest){
					issubmit = 1;isconfirm = 2;                                        
					removebtn.onclick();//调用清除按钮事件，清除已审批单据
					getId('cencalmenuapprovedbtn').onclick();//关闭批量审批弹出层
					DelProgressObjs();
				});
			}
			fnvshobj(obj,'menubatchapproved');//显示批量审批弹出层
			DelProgressObjs();
		});
	}
}

function CloseTheWindow(ids){
	getId(ids).style.display = 'none';
}

/**
 *并发步骤选择审批人
 *edit:can 2020-12-08
 */
function concurrentstepapprove_selectuser(rowindex){
    /* editor:gyq_14 */
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        var detailsobj = ScopePopup_Details.getInstance();
        detailsobj.popupobj = popupobj;
        detailsobj.wareHouseselectUser('userid_'+rowindex,'userid_name_'+rowindex,'approvestep');
    });
}

function concurrentstepapprove_cancel_selectuser(rowindex){
    /* editor:gyq_14 */
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        var detailsobj = ScopePopup_Details.getInstance();
        detailsobj.popupobj = popupobj;
        detailsobj.wareHouseselectUser('userid_cancel_'+rowindex,'userid_name_cancel_'+rowindex,'approvestep');
    });
}


/**
 * 选择审批步骤指定审批人
 * @author Tujt 2015-04-29
 */
function approve_selectuser(){
    /* editor:gyq_14 */
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().wareHouseselectUser('userid','userid_name','approvestep');
    });
    
	ld("#"+popupobj.divid+" [name=userid_name]").unbind("DOMNodeInserted").bind("DOMNodeInserted", function(){
		//edit:can 20200715 获取选中的成员个数，用于隐藏显示多人审批
		var strhtml=ld(this).html();
		if(strhtml==''){
			//没有选择，隐藏多人审批
			ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','none');
			ld("#"+popupobj.divid+" [name=countersigner]:first").prop("checked",true);
		}
		else {
			var tmps=strhtml.split(",");
			if(tmps.length>1&&tmps[1]!=''&&tmps[1]!=',') {
				//选择多个，显示多人审批
				ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','');
			}
			else{
                //选择一个，隐藏多人审批
				ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','none');
			    ld("#"+popupobj.divid+" [name=countersigner]:first").prop("checked",true);
			}
		}
	});
}

/**
 * 选择部门（自定义共享规则调用）
 */
function approve_selectgroup(){
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().shareCustomruleselectGroup('groupid','groupid_name','shareCustomrule');
    });
}
/**
 * 通过并增加本步骤审批人
 * @author chj 2020/9/24
 */
function approve_augmentsinger_selectuser(){
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().wareHouseselectUser('augmentsinger_userid','augmentsinger_username','augmentsinger_approvestep');
    });
}
//审批参数设置
function set_approve_system(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=SystemSet&parenttab=Settings&blockidsetting=2&fieldidsetting=45&setparamsforapprove=1';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}
/**
 * 反审批
 * @author Tujt 2015-07-17
 */
function unApprove_click(record,fld_module,obj){
    getJsScript('include/js/DetailButtons.js',function(){
		unApprove(record,fld_module,obj);
	});
}

/**
 * 数据分类
 * @author Chj  2016-11-23
 */
function approve_showDefaultCustomView(selectView,module,parenttab,viewid){
	var fromapprovemodule = '';
    if(viewid=='')viewid = 0;
    if(document.getElementById("SmOwnerSearchScope")!=null)
        var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    else
        var searchScope='';
    document.getElementById("viewname").value=viewid;
	if(ld('#fromapprovemodule') != undefined){
		fromapprovemodule = ld('#fromapprovemodule').val();
	}
     //分页
    var listview_page=new ListView_Page(module,"module=Approve&action=ApproveAjax&file=ListView&ajax=true&customview=yes&start=1&fromapprovemodule="+fromapprovemodule+"&approvestatus="+viewid+"&parenttab="+parenttab+"&SearchScope="+searchScope,"ListViewContents");
    listview_page.callback_fun=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
         popupobj.listresizeobj.setReiszeTable_Init('Approve','ajax');
        setContentHeight(module);//计算内容高度              
    }
    listview_page.page();
}

//type:before_approve,after_approve,refuse_approve
//remindmethod:sms,email,dialog,accountsfield,contactsfield,weixin
function SetApproveRemindContent(frommodule,groupname,remindmethod) {
    var approveremindcontent=[];//提醒内容下拉框
    var approveremindtitle = [];//提醒标题下拉框
    var that=this;
    
    this.setInputHiddenRemindContent=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        if(remindmethod == 'dialog'||remindmethod == 'weixin') {
            //点击保存后获取提醒标题
            var tmpremindtitle = ld("#"+popupobj.divid+" [name=approveRemindtitle]").val();
            if(tmpremindtitle == '') {
                var confirm_str = arrJsPopLabel['ReminderTitleCannotEmpty'];//提醒标题不能为空
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
            //remindstatus:提醒标题标题超过预定长度时是否允许保存
            if(tmpremindtitle.length>30&&popupobj.remindstatus != 'yes' ) {
                var confirm_str = arrJsPopLabel['ReminderTitleMoreThan30IsSave'];//您设置的提醒标题字数已超过30个，超出部分将不会保存，是否继续？
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                var remindsPopupobj = CrmPopup.getPopupObj("last");
                ld("#"+remindsPopupobj.divid).find(' .E_pbtnok').unbind('click').on('click',function(){
                    var tmppopupobj=CrmPopup.getPopupObj("last");//设置提醒内容弹窗
                    tmppopupobj.remindstatus = 'yes';
                    that.setInputHiddenRemindContent();
                });
                return false;
            }
            else if(tmpremindtitle.length>30&&popupobj.remindstatus == 'yes') {
                //提醒标题长度超过30时，截断为30长度
                tmpremindtitle = tmpremindtitle.substring(0,29);
            }
            approveremindtitle[ld("#"+popupobj.divid+" [name=selectapprovereminduser]").val()]=tmpremindtitle;
            var lastpopupobj=CrmPopup.getPopupObj("lastprev");
            var remindusertags=lastpopupobj.approvereminds[groupname][remindmethod]['reminduser'];
             
            for(var i=0;i<remindusertags.length;i++){
                var remindtitletextname=groupname+"_"+remindmethod+"_"+remindusertags[i]+"_remindtitle";
                ld("#"+lastpopupobj.divid+" [name="+remindtitletextname+"]").val(approveremindtitle[remindusertags[i]]);
            }
            approveremindtitle=[];
        }
        //点击保存后获取提醒内容
        approveremindcontent[ld("#"+popupobj.divid+" [name=selectapprovereminduser]").val()]=ld("#"+popupobj.divid+" [name=CKcontent]").val();
        var lastpopupobj=CrmPopup.getPopupObj("lastprev");
        var remindusertags=lastpopupobj.approvereminds[groupname][remindmethod]['reminduser'];
        for(var i=0;i<remindusertags.length;i++) {
            var remindcontenttextname=groupname+"_"+remindmethod+"_"+remindusertags[i]+"_remindcontent";
            ld("#"+lastpopupobj.divid+" [name="+remindcontenttextname+"]").val(approveremindcontent[remindusertags[i]]);
        }
        approveremindcontent=[];
        popupobj.CancelEvent();
    }
    this.setInputHiddenRemindContent.funname='setInputHiddenRemindContent';
    $("status").style.display="inline";
    var popupobj=CrmPopup.getPopupObj("last");
    var stepid=CrmPopup.getHtmlobjval(popupobj.divid,"stepid");
    var postbody = '';
    var methodtaggroup=groupname+"_"+remindmethod;
    //before_approve_dialog_selectuser_remindconent
    //after_approve_dialog_selectuser_remindcontent
    var remindusertags=popupobj.approvereminds[groupname][remindmethod]['reminduser'];
    var methodtaggroup=groupname+"_"+remindmethod;
    var selectremindusercount=0;
    //判断是否选中了提醒人
    ld("#"+popupobj.divid+" [methodtaggroup="+methodtaggroup+"]") .each(function(){
        //不是提醒方式选中
        if(ld(this).attr("name")!=methodtaggroup+"_method"&&ld(this).prop("checked")){
            selectremindusercount++;
            return false;
        }
    });
    if(selectremindusercount==0){
        var confirm_str = popupobj.tipsetreminder;
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    for(var i=0;i<remindusertags.length;i++) {
        //初始化提醒人的提醒内容
        var hiddenremindcontenttextname=groupname+"_"+remindmethod+"_"+remindusertags[i]+"_remindcontent";

        if(ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val()==undefined){
            ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val("");
        }
        if(ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val()!=""){
            approveremindcontent[remindusertags[i]]=ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val();
        }
        else{
            var remindercontent=popupobj.approvereminds[groupname]['defaultremind'][remindusertags[i]];
            remindercontent=remindercontent.replace('{$MODULE$}',popupobj.modulelabel);
            approveremindcontent[remindusertags[i]]=remindercontent;
        }
        //zkt 20220426 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
        ////初始化提醒人的提醒提醒标题
        var hiddenremindtitletextname=groupname+"_"+remindmethod+"_"+remindusertags[i]+"_remindtitle";
        if(ld("#"+popupobj.divid+" [name="+hiddenremindtitletextname+"]").val()==undefined){
            ld("#"+popupobj.divid+" [name="+hiddenremindtitletextname+"]").val("");
        }
        if( ld("#"+popupobj.divid+" [name="+hiddenremindtitletextname+"]").val()!=""){
            approveremindtitle[remindusertags[i]]=ld("#"+popupobj.divid+" [name="+hiddenremindtitletextname+"]").val();
        }
        else{
            var tmpremindertitle=popupobj.approvereminds[groupname]['defaultremindtitle'][remindusertags[i]];
            //zkt 20220520 51935(https://81mis.com/kfbcrm/index.php)(审批通知)（系统设置》审批流程设置》审批步骤》审批通知》提醒方式选择“邮箱”和“短信”，点击设置提醒内容没有反应）
            if(!empty(tmpremindertitle)){
                tmpremindertitle=tmpremindertitle.replace('{$MODULE$}',popupobj.modulelabel);
                approveremindtitle[remindusertags[i]]=tmpremindertitle;
            }
        }
    }
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth950px",frommodule,"","","","");
	crmPopupobj.prevshow();   
	postbody = "module=Users&action=UsersAjax&file=setApproveRemindContent&frommodule="
            +frommodule+"&groupname="+groupname+"&stepid="+stepid+"&remindmethod="+remindmethod;
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxNoProgress('index.php?'+postbody,'',function(data) {
        if(data.code==1) {
            $("status").style.display="none";
            var jspopup=[];
            crmPopupobj.setParams(data.result.title,that.setInputHiddenRemindContent,"","LdPopWidth950px",frommodule,"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            //填充下拉字段
            var urlstring = '&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&printtabid='+ld("#"+popupobj.divid+" [name=tabid]").val();

            ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
                //   var results=response.responseText.split("##SUCCESS##");
                document.getElementById("tabField").innerHTML=data.result.fieldsel;
            });

            var lastpopupobj=CrmPopup.getPopupObj("lastprev");
            //获取需要提醒的审批人
            //type:before_approve,after_approve,refuse_approve
            //remindmethod:sms,email,dialog,accountsfield,contactsfield,weixin
            var remindusertags=lastpopupobj.approvereminds[groupname][remindmethod]['reminduser'];
            for(var i=0;i<remindusertags.length;i++) {
                var remindusername=groupname+"_"+remindmethod+"_"+remindusertags[i];
                if(ld("#"+lastpopupobj.divid+" [name="+remindusername+"]").prop("checked")) {
                    var optionhtml="<option value='"+remindusertags[i]+"'>"+lastpopupobj.remindusertext[remindusertags[i]]+"</option>";
                    ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").append(optionhtml);
                }
            }

            ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(approveremindcontent[ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").val()]);
            var before_select_user_tag=ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").val();
            approveremindcontent[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
            //zkt 20220425 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
            //对话框、微信类型的审批提醒才设置提醒标题
            if(remindmethod == 'dialog'||remindmethod == 'weixin') {
                ld("#"+crmPopupobj.divid+" [name=approveRemindtitle_tr]").css('display','');
                ld("#"+crmPopupobj.divid+" [name=approveRemindtitle]").val(approveremindtitle[ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").val()]);
                approveremindtitle[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=approveRemindtitle]").val();
            }
            ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").bind('change',function(){
                var remindusertag=ld(this).val();
                approveremindcontent[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
                if(approveremindcontent[remindusertag]!=undefined) {
                    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(approveremindcontent[remindusertag]);
                }
                else {
                    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val("");
                }
                //提醒标题变化,对话框、微信类型的审批提醒才设置提醒标题
                if(remindmethod == 'dialog'||remindmethod == 'weixin') {
                    approveremindtitle[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=approveRemindtitle]").val();
                    if(approveremindtitle[remindusertag]!=undefined) {
                        ld("#"+crmPopupobj.divid+" [name=approveRemindtitle]").val(approveremindtitle[remindusertag]);
                    }
                    else{
                        ld("#"+crmPopupobj.divid+" [name=approveRemindtitle]").val("");
                    }
                }
                before_select_user_tag=remindusertag;
            });
        }
    });
}
/*查看审批流程*/
function viewApprove(jqueryobj,event){
    EmptyProgressObjs();
    var record=ld(jqueryobj).attr("approveid");
    var blockid=ld(jqueryobj).attr("approvetabid");
    ldAjax("index.php?module=Settings&action=SettingsAjax&file=EditMultiApproveList&record="+record+"&blockid="+blockid,{},function(data){
        var popupobj= CrmPopup.load(data.result.title,"","","1200",'Approve',"","","","");
        CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
        popupobj.pagetype=PageRecordPopup.pagetype;
        popupobj.record=record;
        popupobj.blockid=blockid;
        DelProgressObjs();
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined") {
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }
    })
}
//点击多人会签
function countersignerclick(jqueryobj,event){
    var popupobj=CrmPopup.getPopupObj('last');
    if(ld(jqueryobj).val()=='no'){
        ld("#"+popupobj.divid+" [name=table_nextstep]").css('display','');
    }
    else{
        ld("#"+popupobj.divid+" [name=table_nextstep]").css('display','none');
    }
}

//本步骤是否允许加签
function augmentsingerclick(jqueryobj,event){
    var popupobj=CrmPopup.getPopupObj('last');
    if(ld(jqueryobj).prop('checked')){
        ld("#"+popupobj.divid+" [name=tr_augmentsinger]").css('display','');
    }
    else{
        ld("#"+popupobj.divid+" [name=tr_augmentsinger]").css('display','none');
    }
}

function set_module_approve(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    var type = ld(obj).attr('name');
    var value = 1;  //0表示启用；1表示不启用
    if(ld(obj).is(':checked')){
        value = 0;
    }
    var tabid = ld("#"+popupobj.divid+" [name=pick_module]").val();
    var selectobj = ld("#"+popupobj.divid+" [name=pick_module]");
    var tabid = selectobj.val();
    surl = 'index.php?module=Approve&action=ApproveAjax&file=module_approve';
    surl += '&type='+type+'&value='+value+'&tabid='+tabid;
    ldAjax(surl,"",function(data){
        if(data.code==1){
            if(type == 'showdisabledapprove'){
                getCustomBlockList(selectobj.get(0),'','');
            }
        }
        else if(data.code==-1){
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['OPERATIONFAILED']);
        }
        DelProgressObjs();     
    });
}
//选中‘审批人为空时’类型,
function emptyapproverdeal(obj,event){
    var popupobj=CrmPopup.getPopupObj('last');
    var tagname = ld(obj).attr('tag');
    var divname = ld(obj).attr('name');
    //控制其他选择项取消选中
    var radio_objs = ld("#"+popupobj.divid+" [tag="+tagname+"]");
    radio_objs.prop('checked',false);
    ld(obj).prop('checked',true);
    //选择'转交指定人审批'时，出现选择用户框
    var user_trobj = ld("#"+popupobj.divid+" [name=transferusername_tr]");
    if(divname == 'transfertouser'){
        user_trobj.show();
    }
    else{
        user_trobj.hide();
    }
}

//审批人为空时，另外指定审批人
function transfer_approve_selectuser(){
    var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().wareHouseselectUser('transfer_userid','transfer_userid_name','approvestep');
    });
	ld("#"+popupobj.divid+" [name=transfer_userid_name]").unbind("DOMNodeInserted").bind("DOMNodeInserted", function(){
		//获取选中的成员个数，用于显示多人审批
		var strhtml=ld(this).html();
		if(!empty(strhtml)){
			var tmps=strhtml.split(",");
			if(tmps.length>1&&tmps[1]!=''&&tmps[1]!=','){
				//选择多个，显示多人审批
				ld("#"+popupobj.divid+" [name=tr_countersigner]").css('display','');
			}
		}
	});
}
//审批设置变更后，修改对应单据的审批人
function UpdateRecordApproveby(stepid,start,id_str,tabid){
    //批量增加进度条，样式根据导出进度条
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.type != 'progress'){
        var popupobj = CrmPopup.load("", "", "", "LdPopWidth500px",'', "",'', "", "");
        popupobj.prevshow();
        popupobj.type = 'progress';
    }
    
    var url = 'index.php?module=Approve&action=ApproveAjax&file=UpdateRecordApproveby';
    url += '&stepid='+stepid+'&start='+start+'&id_str='+id_str+'&tabid='+tabid;
    ldAjax(url,'',function(data){
        if(!empty(data.result.content)&&data.result.content!=undefined){
            popupobj.setParams(data.result.title, "", "", "LdPopWidth500px",'', "", "", "", "");
            popupobj.show(data.result.content);
        }
        //更新进度条百分比
        ld("#dvExportprogress").css("width", data.result.width + "%");
        if(data.code == 1){
            if(data.result.end != 'yes'){
                UpdateRecordApproveby(stepid,data.result.start,data.result.id_str,tabid);
            }
            else{//操作完成,关闭进度条给出提示
                //增加延时操作，否则进度条消失太快，看不到效果
                setTimeout(function(){
                    popupobj.CancelEvent();
                    MessagePopup.TipOne_success(arrJsPopLabel['SUCCESSFULOPERATION']);
                },500);
            }
        }
        else if(data.code == -1){
            setTimeout(function(){
                popupobj.CancelEvent();
                MessagePopup.TipOne_success(arrJsPopLabel['SUCCESSFULOPERATION']);
            },500);
        }    
    })
}
//修改审批历史相关个性化参数设置
function ChangeApproveLogSet(obj){
    var checked_obj = ld(obj);
    var label = ld(obj).attr('name');
    var record = ld(obj).attr('record');
    var modulename = ld(obj).attr('modulename');
    var popupobj=CrmPopup.getPopupObj("last");
    var urlstring = 'module=Users&action=UsersAjax&file=getDetailBlock&modulename='+modulename+'&recordid='+record;
    urlstring += '&setype=Approvelog'+'&'+label+'=';
    if(checked_obj.prop('checked')){
        urlstring += 'yes';
    }
    else{
        urlstring += 'no';
    }
    var pre_hidden_btnobj = ld('#'+popupobj.divid+' [name=pre_hidden_btn]');
    var next_hidden_btnobj = ld('#'+popupobj.divid+' [name=next_hidden_btn]');
    if(pre_hidden_btnobj.length>0&& pre_hidden_btnobj.val() == 'no'){
        urlstring += '&pre_hidden_btn=no';
    }
    if(next_hidden_btnobj.length>0&& next_hidden_btnobj.val() == 'no'){
        urlstring += '&next_hidden_btn=no';
    }
    //zkt 20231013 XUQIU1001341 SQL注入
    ldAjaxHtmlNoProgress('index.php?',urlstring,function(response) {
        var rest = response;
        if(trim(rest) != ''){
            ld("#"+popupobj.divid+" [name=approveStaus]").html(rest);
            ld("#"+popupobj.divid+" [name=approvelogtr]").css('display','');
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined") {
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
            }
        }
    });
}

//展开或收起审批日志
function ChangeApprovelogShowtype(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    var show_type = ld(obj).attr('show_type');
    var hiden_type = ld(obj).attr('hiden_type');
    
    ld("#"+popupobj.divid+" [name=approvelog_view] [tag="+show_type+"]").show();
    ld("#"+popupobj.divid+" [name=approvelog_view] [tag="+hiden_type+"]").hide();
    ld('#'+popupobj.divid+' [name='+show_type+']').val('yes');
    ld('#'+popupobj.divid+' [name='+hiden_type+']').val('no');

    var record = ld(obj).attr('record');
    var modulename = ld(obj).attr('modulename');
    var showtype = '';
    var showvalue = '';
    if(show_type == 'pre_hidden' || show_type == 'next_hidden'){
        showtype = show_type;
        showvalue = 'show';
    }
    else{
        showtype = hiden_type;
        showvalue = 'hidden';
    }
    var urlstring = 'module=Users&action=UsersAjax&file=getDetailBlock&setype=Approvelog&modulename='+modulename+'&recordid='+record;
    urlstring += '&showtype='+showtype+'&showvalue='+showvalue;
    ldAjaxHtmlNoProgress('index.php?',urlstring,function(response) {
        var rest = response;
        if(trim(rest) == ''){
            MessagePopup.TipZero_warning(arrJsPopLabel['OPERATIONFAILED']);
        }
    });
}

function approveSelectUserByType(module,methodtaggroup,type){
    if(type=='selectuser' || type=='selectrole'){
        approveSelectUser(module,methodtaggroup,type);
    }
    else{
        approveSelectPosition(methodtaggroup,type);
    }
}
// 选择职位级别
function approveSelectPosition(methodtaggroup,type){
    var popupobj = CrmPopup.getPopupObj("last");
    var input_value = ld("#"+popupobj.divid).find('#'+methodtaggroup+'_'+type+'_hidden').val();// 已选值
    var title = arrJsPopLabel['pleaseselect'] + ld("#"+popupobj.divid).find('label[for='+methodtaggroup+'_'+type+']').text();

    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'',"","","","");
    crmPopupobj.prevshow();
    crmPopupobj.setParams(title,approveSavePosition,"","LdPopWidth600px",'',[methodtaggroup,type],arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
    
    var content_html = `<div style="overflow-x: auto;">`
                        +`<table class="ld-public-content-paddingright" id="" border="0" cellpadding="0" cellspacing="0" width="100%">`;
    
    if(type == 'departmentuser'){// 指定部门
        input_value = input_value.split('::');
        var select_groupid = input_value[0];
        input_value = input_value[1];
        content_html += '<tr><td class="ld-form-item-label">'
                        + arrJsPopLabel['USERGROUPLIST']
                    +`</td>`;
        content_html += '<td class="ld-form-item-content">'
                        +'<select class="ld-select-inner" name="departmentuser" >';
        ld.each(popupobj.groupinfo,function(groupname,groupid){
            if(select_groupid == groupid){
                content_html += '<option value="'+groupid+'" selected>'+groupname+'</option>'
            }else{
                content_html += '<option value="'+groupid+'">'+groupname+'</option>'
            }
        })
        content_html += "</select>"
                    +`</td></tr>`;
    }
    // 职位级别
    content_html += '<tr><td class="ld-form-item-label">'
                        + arrJsPopLabel['POSITIONLEVEL']
                    +`</td>`;
    content_html += '<td class="ld-form-item-content">'
                    +`<select class="ld-select-inner" name="selectposition" >`;
    ld.each(popupobj.userlevelarr, function(index, level) {
        if(level == input_value){
            content_html += '<option value="'+level+'" selected>'+level+'</option>';
        }
        else{
            content_html += '<option value="'+level+'" >'+level+'</option>';
        }
    });
    content_html +=`</select>`
                +`</td></tr>`;
    content_html += `</table></div>`;
    crmPopupobj.show(content_html);
    crmPopupobj.center();
}
// 保存职位级别
function approveSavePosition(methodtaggroup,type){
    var position_popupobj = CrmPopup.getPopupObj('last');
    var departmentuser = ld('#'+position_popupobj.divid).find("[name=departmentuser]").val();
    var position = ld('#'+position_popupobj.divid).find("[name=selectposition]").val();
    var remindselectfield = '';
    if(ld('#'+position_popupobj.divid).find("[name=departmentuser]").length>0 && !empty(departmentuser)){
        remindselectfield += departmentuser + '::'
    }
    remindselectfield += position;
    position_popupobj.CancelEvent();
    var popupobj = CrmPopup.getPopupObj("last");
    ld("#"+popupobj.divid).find('#'+methodtaggroup+'_'+type+'_hidden').val(remindselectfield);
}
//edit:duan date:2024/11/15 reason:审批状态设置
function ApproveStatusSet() {
    TranslatedFieldSet('lingdang','approvestatus')
}
//edit:duan date:2024/12/17 reason:反审批权限设置
function CancelApproveProfileSet() {
    var that = this;
    this.tabid=ld(' select[name=pick_module]').val();
    this.baseurl = "index.php?module=Settings&parenttab=Settings&action=SettingsAjax&file=CancelApproveProfile";
    this.setEditPage = function () {
        var param = {};
        param['mode'] = 'edit';
        param['tabid'] = this.tabid;
        ldAjaxNoProgress(this.baseurl,param,function(data) {
            if(data.code == 1){
                getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function () {
                    var scopepopupobj = ScopePopup_Details.getSingleInstance();
                    var selectedtype = data.result.scopetype;
                    var selectedid = data.result.scopeid;
                    scopepopupobj.showemptytype='yes';//显示'无'选项
                    scopepopupobj.title = data.result.title;
                    scopepopupobj.get_bottom_content = function (){
                        return '<div style="padding:0 24px 20px;float:inherit;">'+data.result.bottom_label+'</div>';
                    }
                    //生成弹窗
                    scopepopupobj.allocateTemplate(this, 0, 0,selectedid ,selectedtype , 'Approve');
                    //重写保存后事件
                    scopepopupobj.validate_url = function (){
                        selectedtype = ld('#'+scopepopupobj.firstpop_id+'content input[name="radiotype"]:checked ').val();
                        that.after_save(selectedtype,cls_ScopePopup.return_obj.return_id);
                    }
                })
            }
            else{
                MessagePopup.TipOne_warning(data.msg);
            }
        });
    }
    this.after_save = function (selectedtype,selectedid) {
        var param = {};
        param['scopetype'] = selectedtype;
        param['scopeid'] = selectedid;
        param['tabid'] = this.tabid;
        param['mode'] = 'save';
        ldAjaxNoProgress(this.baseurl,param,function(data){
            if(data.code == 1){
                var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
                MessagePopup.TipZero_success(confirm_str);
            }
            else{
                MessagePopup.TipOne_warning(data.msg);
            }
        })
    }
    this.setEditPage();
}
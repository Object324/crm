function InsertRemindField(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        var confirm_str = arrJsPopLabel['PLEASESELECTFIELD'];   
        RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
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
                            
    						if(ld(this).prop("checked"))
                            {
                               selectfields+=ld(this).val()+",";
                               
                            }
                            
           });
           var remindmethod="";
            if(methodtaggroup.indexOf("email")>=0)
            {
                remindmethod='email';
                
            }
            else
            {
                remindmethod='sms';
                
            }
           // ld("#"+popupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"_hidden]").val(selectfields);
             popupobj.CancelEvent();//关闭选择邮箱或选择手机字段的弹出层
             popupobj=CrmPopup.getPopupObj("last");
             //before_approve_email_accountsfield
            if(selectfields!="")
            {
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
    else
    {
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

	}//
    //refuse_approve_email_contactsfield
    var selectcolumname=ld("#"+prevpopupobj.divid+" [name="+methodtaggroup+"_"+popupmodule+"_"+remindmethod+"_hidden]").val();
    //alert('index.php?module='+ popupmodule +'&action='+popupmodule+'Ajax&file=moduleselectfield&fieldtype='+fieldtype+"&selectcolumname="+selectcolumname);
	ld.ajax({
		url: 'index.php?module='+ popupmodule +'&action='+popupmodule+'Ajax&file=moduleselectfield&fieldtype='+fieldtype+"&selectcolumname="+selectcolumname,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				crmPopupobj.setParams(data.result.title,that.setselectfieldvalue,"","LdPopWidth350px",'Emails',[methodtaggroup],data.result.oktext,"",data.result.canceltext);  
				crmPopupobj.show(data.result.content);
                
			}else{
				cancelCrmPopup();
				RemindsMsg("","LdPopWidth400px","","","",data.result.msg);
				return false;
			}
		}
	})
}
function getCustomBlockList(customField,BLOCKIDSETTING,FIELDIDSETTING)
{
    var modulename = customField.options[customField.options.selectedIndex].value;
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=MultiApproveList&blockid='+modulename+'&parenttab=Settings&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
            onComplete: function(response) {
                $("cfList").innerHTML=response.responseText;
            }
        }
    );
    
}
//审批流程序时簿新增流程
function getCreateApproveForm(customModule,blockid,tabid,label,order,BLOCKIDSETTING,FIELDIDSETTING)
{
    var modulename = customModule;
    document.location.href="index.php?module=Settings&parenttab=Settings&action=EditMultiApprove&blockid="+blockid+"&fld_module="+customModule+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
}
//编辑审批流程
function getEditApproveForm(customModule,record,tabid,label,order,BLOCKIDSETTING,FIELDIDSETTING)
{    
    var modulename = customModule;
    new Ajax.Request(
    'index.php',
    {queue: {position: 'end', scope: 'command'},
    method: 'post',
    postBody: 'module=Settings&action=SettingsAjax&file=ApproveDelete&delete=false&record='+record+'&blockid='+tabid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
    onComplete: function(response) {      
        if(response.responseText.indexOf('SUCCESS')>-1){
            document.location.href="index.php?module=Settings&action=EditMultiApprove&mode=edit&parenttab=Settings&record="+record+"&blockid="+tabid+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
        }else if(response.responseText.indexOf('USED')>-1){
            //该流程正在被使用，是否继续？
            var confirm_str = arrJsPopLabel['PROCESSUSEDWHETHERCONTINUE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                document.location.href="index.php?module=Settings&action=EditMultiApprove&mode=edit&parenttab=Settings&record="+record+"&blockid="+tabid+"&blockidsetting="+BLOCKIDSETTING+"&fieldidsetting="+FIELDIDSETTING;
            });
        }
    }
    });
}

//删除审批流程
function deleteApprove(record,tabid,BLOCKIDSETTING,FIELDIDSETTING)
{
    var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=ApproveDelete&record='+record+'&blockid='+tabid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
            onComplete: function(response) {
                if(response.responseText.indexOf('SUCCESS')>-1){
                    getCustomBlockList($("pick_module"),BLOCKIDSETTING,FIELDIDSETTING);
                }else if(response.responseText.indexOf('USED')>-1){
                    //该流程正在被使用，无法删除！
                    var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTDELETED'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                }
            }
        });
    });
    return ;
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
 
       
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Emails',"","","","");
    
 
	crmPopupobj.prevshow();
    ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
                //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
				$("status").style.display="none";
                crmPopupobj.setParams(data.result.title,validate_approvestep,"","LdPopWidth800px",'Emails',"",data.result.oktext,"",data.result.canceltext);  
					crmPopupobj.createScrollDiv();//创建滚动条
                crmPopupobj.show(data.result.content);
			     crmPopupobj.tipsetreminder=data.result.tipsetreminder;
                crmPopupobj.approvereminds=data.result.approvereminds;
                crmPopupobj.remindusertext=data.result.remindusertext;
                crmPopupobj.highersearchobj=new HigherSearchGroup("adv_filter_div");
                crmPopupobj.highersearchobj.tabletitle=data.result.tabletitle;
                crmPopupobj.highersearchobj.columns_block=data.result.columns_block;//查询字段
                crmPopupobj.highersearchobj.fLabels=data.result.flabels;//查询条件下拉框（等于，不等于，区间 ，大于)
                crmPopupobj.highersearchobj.source=data.result.source;
                crmPopupobj.highersearchobj.foption=data.result.foption;//查询条件下拉框的html
                crmPopupobj.highersearchobj.criteria_groups=data.result.criteria_groups;//高级查询
                crmPopupobj.highersearchobj.mandatorycheck=data.result.mandatorycheck;
                crmPopupobj.showvalues=data.result.showvalues;
                crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel=data.result.viewnamelabel;
                 crmPopupobj.modulelabel=data.result.modulelabel;     
                crmPopupobj.highersearchobj.btn_addnewcondtiontext=data.result.btn_addnewcondtiontext;//高级查询 新条件 按钮文字
                crmPopupobj.highersearchobj.btn_addnewcombinationtext=data.result.btn_addnewcombinationtext;//高级查询　“新组合"按钮文字
                var  fori=0;
                if(data.result.criteria_groups)
           	    {
                   	      
                   	         ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
                           	         
                                		 var GROUP_COLUMNS=GROUP_CRITERIA.columns;
                                	
                              			crmPopupobj.highersearchobj.addConditionGroup();
                                	    ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
                                	  
                                			crmPopupobj.highersearchobj.addConditionRow(GROUP_ID);
                                           var advft_column_index_count=crmPopupobj.highersearchobj.advft_column_index_count;
                                			var conditionColumnRowElement = CrmPopup.findHtmlobj(crmPopupobj.divid,'fcol'+advft_column_index_count);
                                			conditionColumnRowElement.val(COLUMN_CRITERIA.columnname) ;
                                            
                                			crmPopupobj.highersearchobj.updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count);
                                			CrmPopup.findHtmlobj(crmPopupobj.divid, 'fop'+advft_column_index_count).val(COLUMN_CRITERIA.comparator);
                                			crmPopupobj.highersearchobj.addRequiredElements(advft_column_index_count);
                                			if ( data.result.source == 'reports'|| data.result.source == 'usereports')
                                				crmPopupobj.highersearchobj.updateRelFieldOptions(conditionColumnRowElement, 'fval_'+advft_column_index_count);
                                		
                                
                                			var columnvalue = COLUMN_CRITERIA.value;
                                			if(COLUMN_CRITERIA.comparator == 'bw' && columnvalue != '') {
                                				var values = columnvalue.split(",");
                                				CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(values[0]) ;
                                				if(values.length == 2 && CrmPopup.isExistsObj(crmPopupobj.divid,'fval_ext'+advft_column_index_count))
                                					CrmPopup.findHtmlobj(crmPopupobj.divid,'fval_ext'+advft_column_index_count).val(values[1]) ;
                                			}
                                            else 
                                            {
                                           
                                                if(columnvalue =='Accepted')
                                				        CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Accepted);
                                                else if(columnvalue =='Rejected')
                                                     CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Rejected);
                                                else{
                                                    var values = columnvalue.split(",");
                                    				CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val( values[0]);
                                                }
                                			}
                                	    });
                                        
                                		ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
                                		   //查询字段下拉框
                                           
                                			if(CrmPopup.isExistsObj(crmPopupobj.divid,'fcon'+fori)) 
                                                CrmPopup.findHtmlobj(crmPopupobj.divid,'fcon'+fori).val(COLUMN_CRITERIA.column_condition);
                                	
                                		      fori=fori+1;
                                		});
                                		
                           	   });
                               ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
                                 //组 且/或
                                       var GROUP_CRITERIA=data.result.criteria_groups[GROUP_ID];
                                  		if(CrmPopup.isExistsObj(crmPopupobj.divid,'gpcon'+GROUP_ID)) 
                                            CrmPopup.findHtmlobj(crmPopupobj.divid,'gpcon'+GROUP_ID).val(GROUP_CRITERIA.condition);
                               });
                               
                   	    }
                        else
                    		crmPopupobj.highersearchobj.addNewConditionGroup();
                crmPopupobj.setScrollDivMaxHeight();
                crmPopupobj.center();
                if(data.result.isused=='yes')
                {
                    //流程如果已经被使用，那么不能修改查询条件
                    ld("#"+crmPopupobj.divid+" .addConditionRow").hide();
                    ld("#"+crmPopupobj.divid+" .createauto").hide();
                    //createauto
                }
				if(mode=='edit'){
                  
                    if(data.result.isused=='yes')
                    {
                        //32413: 系统设置 > 审批流程管理
                        clicktab(3);
                    }
                    
                }
                document.getElementById("pass").onchange();
                document.getElementById("nopass").onchange();

			
            }else if(data.code == 2){
                //该流程正在被使用，无法修改！
                var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				$("status").style.display="none";
				return false;
            }
        
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
 
   if(ld("#"+popupobj.divid+" [name="+remindusername+"]").prop("checked"))
        ld("#"+popupobj.divid+" [name="+methodtaggroup+"_method]").prop("checked",true);
}
//指定用户 - 选择用户
var approveSelectUser = function(module,methodtaggroup){
	var scopepopupobj;
	var input_value;
    var popupobj=CrmPopup.getPopupObj("last");
	if(ld('#'+methodtaggroup+'_selectuser_hidden') != undefined){
		input_value = ld('#'+methodtaggroup+'_selectuser_hidden').val()
	}
	var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
	  
       
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = input_value;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					//没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						var selected_username = cls_ScopePopup.return_obj.return_name;//选中的用户
					}
			
					if(ld('#'+methodtaggroup+'_selectuser_hidden') != undefined){
						ld('#'+methodtaggroup+'_selectuser_hidden').val(selected_user);
					}
                   
                    ld("#"+popupobj.divid+" [name="+methodtaggroup+'_selectuser]').prop("checked",true);
                    ld("#"+popupobj.divid+" [name="+methodtaggroup+'_method]').prop("checked",true);
			
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
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
        new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=StepDelete&stepid='+stepid+'&record='+approveid+'&blockid='+blockid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
            onComplete: function(response) {
                if(response.responseText.indexOf('SUCCESS')>-1){
                    getStepList(approveid,blockid,BLOCKIDSETTING,FIELDIDSETTING);
                }else if(response.responseText.indexOf('USED')>-1){
                    //该流程正在被使用，无法删除！
                    RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PROCESSUSEDCANOTDELETED']);
                }
            }
        });
    });
} 
function getStepList(record,blockid,BLOCKIDSETTING,FIELDIDSETTING)
{ 
    new Ajax.Request(
    'index.php',
    {queue: {position: 'end', scope: 'command'},
    method: 'post',
    postBody: 'module=Settings&action=SettingsAjax&file=EditMultiApproveList&record='+record+'&blockid='+blockid+'&parenttab=Settings&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
    onComplete: function(response) {
        ld("#approvestepdetaillist").html(response.responseText);
    }
    }
    );
} 
//上下移
function gotomove(stepid,approveid,blockid,operation){
    var confirm = '';
    new Ajax.Request(
    'index.php',
    {queue: {position: 'end', scope: 'command'},
    method: 'post',
    postBody: 'module=Settings&action=SettingsAjax&file=ChangeStepSeq&operation='+operation+'&stepid='+stepid+'&record='+approveid+"&blockid="+blockid,
    onComplete: function(response) {
        if(response.responseText.indexOf("SUCCESS")>-1){
            getStepList(approveid,blockid);
        }else if(response.responseText.indexOf("USED")>-1){
            //该流程正在被使用，无法修改！
            confirm = arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm); 
        }else if(response.responseText.indexOf("ALREADY_FIRST")>-1){
            //该步骤已经是第一步了！
            confirm = arrJsPopLabel['STEPISFIRSTSTEP'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm); 
        }else if(response.responseText.indexOf("ALREADY_LAST")>-1){
            //该步骤已经是最后一步了！
            confirm = arrJsPopLabel['STEPISLASTSTEP'];  
            RemindsMsg("","LdPopWidth400px","","yes","",confirm); 
        }
    }
    });
}


//新增步骤标签页切换
/*editor:gyq_05 reason:新增审批通知标签页 date:2016 2 23*/
function clicktab(id){
    if(id==1){
        $('thetab1').addClassName('On');
        $('thetab2').removeClassName('On');
        $('thetab3').removeClassName('On');
        $('countrycontainer1').style.display='';
        $('countrycontainer2').style.display='none';
        $('countrycontainer3').style.display='none';
        ld('#countrytabs p').css('display','block');
    }else if(id==2){
        $('thetab2').addClassName('On');
        $('thetab1').removeClassName('On');
        $('thetab3').removeClassName('On');
        $('countrycontainer2').style.display='';
        $('countrycontainer1').style.display='none';
        $('countrycontainer3').style.display='none';
        ld('#countrytabs p').css('display','block');
    }else if(id==3){

        $('thetab3').addClassName('On');
        $('thetab2').removeClassName('On');
        $('thetab1').removeClassName('On');
        $('countrycontainer3').style.display='';
        $('countrycontainer2').style.display='none';
        $('countrycontainer1').style.display='none';
        ld('#countrytabs p').css('display','block');
    }
}
 
//审批人类型
function getChangeApproveType(obj)
{
    var index=parseInt(obj.options[obj.selectedIndex].value);
    document.forms['stepform'].approve_type.value=index;
    document.forms['stepform'].userid_name.value='';
    document.forms['stepform'].userid.value='';
    document.forms['stepform'].role_name.value='';
    document.forms['stepform'].user_role.value='';
    
    
    switch(index){
        case 0:
        $('role_name_tr').style.display='none';
        $('username_tr').style.display='';
        $('username_tr2').style.display='';
        $('position_tr').style.display='none';
		$('positionlevel_tr').style.display='none';

		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
        break;
        case 1:
        $('role_name_tr').style.display='';
        $('username_tr').style.display='none';
        $('username_tr2').style.display='';//20995: 控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后，下一步审批控制区块中没有显示参数“是否允许指定下一步处理人”
                                            //说明	控制面板>新建审批步骤弹出层：审批人类型选择【指定角色】后
        $('position_tr').style.display='none';
		$('positionlevel_tr').style.display='none';

		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
        break;
        case 2:
        $('role_name_tr').style.display='none';
        $('username_tr').style.display='none';
        $('username_tr2').style.display='';
        $('position_tr').style.display='';
		$('positionlevel_tr').style.display='none';

		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
        break;
		case 3:
        $('role_name_tr').style.display='none';
        $('username_tr').style.display='none';
        $('username_tr2').style.display='';
        $('position_tr').style.display='none';
		$('positionlevel_tr').style.display='';

		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
		break;
		case 4:
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

		$('positiondepartment_tr1').style.display='none';
		$('positiondepartment_tr2').style.display='none';
       
        break;
        
    }
}

function openPopup(){
		window.open("index.php?module=Users&action=UsersAjax&file=RolePopup&parenttab=Settings","roles_popup_window","height=425,width=640,toolbar=no,menubar=no,dependent=yes,resizable=yes");
	}
    
//var btncount=0;

function validate_approvestep()
{

   var popupobj=CrmPopup.getPopupObj("last");
    var stepform=document.forms['stepform'];
    var stepname=stepform.stepname.value;
	var approvetype = stepform.approvetype.value;
    if(stepname.length>0);
    else{
         //步骤名称不能为空！
        var confirm_str = arrJsPopLabel['STEPNAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
         if(stepform.stepname.offsetWidth>0)
         {
            stepform.stepname.focus();
            //btncount=0;
         }
         return false;
    }   
    if(popupobj.highersearchobj.checkAdvancedFilter()==false) 
    {
            return false;
    }
   
    var approve_type=stepform.approve_type.value;
    
    if(approve_type==0){
        var userid=stepform.userid.value;
       
        if(userid.length>0);
        else{
            //用户不能为空！
             
            var confirm_str = arrJsPopLabel['USERCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            //btncount=0;
            if(stepform.userid_name.offsetWidth>0)
            {
                stepform.userid_name.focus();
            }
            return false;
        }       
    }
    else if(approve_type==1){
        var rolename=stepform.role_name.value;
        if(rolename.length>0);
        else{
            //角色不能为空！
            var confirm_str = arrJsPopLabel['ROLECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
    if(blockstatus_pass.length>0)
    {
        var pass_value=stepform.passvalue.value;
        if(pass_value.length>0);
        else{
            //赋值不能为空！
            var confirm_str = arrJsPopLabel['ASSIGNMENTCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
           // btncount=0;
            stepform.passvalue.focus();
            return false;
        }        
    }
    if(blockstatus_nopass.length>0)
    {
        var nopass_value=stepform.nopassvalue.value;
        if(nopass_value.length>0);
        else{
            //赋值不能为空！
            var confirm_str = arrJsPopLabel['ASSIGNMENTCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
           // btncount=0;
            stepform.nopassvalue.focus();
            return false;
        }        
    }
	if(approvetype > 1){
		if(approvetype == 2){
			var levelposition = stepform.position.value;
		}else if(approvetype == 3){
			var levelposition = stepform.positionlevel.value;
		}else if(approvetype == 4){
			var levelposition = stepform.positiondepartment2.value;
		}
		if(levelposition == ''){
            var confirm_str = arrJsPopLabel['POSTITIONLEVELCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			//btncount = 0;
			return false;
		}
		
	}

    
   
    // 判断用户操作是否有误，若出错successtype = -5
    var successtype = 1;
    
    //一些判断代码，被我删除了，等测试提bug我在添加
   

    if(successtype == 1){
         //0024721: 控制面板>审批流程管理>费用报销:新增审批步骤时点几次保存就保存几个审批步骤
       // ld(".D_pbtnok").attr("disabled","disabled");
		//var form=document.forms['stepform'];
	//	form.submit();
        var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    
         var record=CrmPopup.getHtmlobjval(popupobj.divid,"record");
         if(prevpopupobj.type=='EditMultiApprove')
         {
            //新增/编辑审批流程界面
            if(record<=0)
            {
                record=document.getElementById("form").record.value;
            }
         }
         var blockid=CrmPopup.getHtmlobjval(popupobj.divid,"blockid");
         var stepname=CrmPopup.getHtmlobjval(popupobj.divid,"stepname");
         var alloweditbill=CrmPopup.getHtmlobjval(popupobj.divid,"alloweditbill");//当前审批人是否允许编辑
         var ended=CrmPopup.getHtmlobjval(popupobj.divid,"ended");
         var step=CrmPopup.getHtmlobjval(popupobj.divid,"step");
         var description=CrmPopup.getHtmlobjval(popupobj.divid,"description");
         var approve_type=CrmPopup.getHtmlobjval(popupobj.divid,"approve_type");
         var advft_criteria=CrmPopup.getHtmlobjval(popupobj.divid,"advft_criteria");
         var advft_criteria_groups=CrmPopup.getHtmlobjval(popupobj.divid,"advft_criteria_groups");
         var selectapproveuser=CrmPopup.getHtmlobjval(popupobj.divid,"selectapproveuser");
         var userid=CrmPopup.getHtmlobjval(popupobj.divid,"userid");
         var user_role=CrmPopup.getHtmlobjval(popupobj.divid,"user_role");
         var position=CrmPopup.getHtmlobjval(popupobj.divid,"position");
         var positionlevel=CrmPopup.getHtmlobjval(popupobj.divid,"positionlevel");
         var positiondepartment1=CrmPopup.getHtmlobjval(popupobj.divid,"positiondepartment1");
         var positiondepartment2=CrmPopup.getHtmlobjval(popupobj.divid,"positiondepartment2");
         var passvalue=CrmPopup.getHtmlobjval(popupobj.divid,"passvalue");
         var nopassvalue=CrmPopup.getHtmlobjval(popupobj.divid,"nopassvalue"); 
         var pass=CrmPopup.getHtmlobjval(popupobj.divid,"pass");
         var nopass=CrmPopup.getHtmlobjval(popupobj.divid,"nopass");
    
         var stepid=CrmPopup.getHtmlobjval(popupobj.divid,"stepid");
         var  tmpurl="";
         
        /* var datas={"record": record, "blockid": blockid,"stepname":stepname,"ended":ended,"step":step,"description":description,
                    "approve_type":approve_type,"advft_criteria":advft_criteria,"advft_criteria_groups":advft_criteria_groups
                        ,"userid":userid,"user_role":user_role,"position":position,"positionlevel":positionlevel,"positiondepartment1":positiondepartment1
                        ,"positiondepartment2":positiondepartment2,"passvalue":passvalue,"nopassvalue":nopassvalue,"pass":pass,"nopass":nopass
                        
                        ,"stepid":stepid,"selectapproveuser":selectapproveuser};*/
                        
                        
       
         tmpurl+="&record="+record+"&blockid="+blockid+'&stepname='+stepname+"&ended="+ended+"&step="+step+"&description="+description;
         tmpurl+="&approve_type="+approve_type+"&advft_criteria="+advft_criteria+"&advft_criteria_groups="+advft_criteria_groups;
         tmpurl+="&userid="+userid+"&user_role="+user_role+"&position="+position+"&positionlevel="+positionlevel+"&positiondepartment1="+positiondepartment1;
         tmpurl+="&positiondepartment2="+positiondepartment2+"&passvalue="+passvalue+"&nopassvalue="+nopassvalue+"&pass="+pass+"&nopass="+nopass;
         tmpurl+="&stepid="+stepid+"&selectapproveuser="+selectapproveuser;
         tmpurl+="&alloweditbill="+alloweditbill;
         
         
         for(var i=0;i<popupobj.approvereminds.groups.length;i++)
         {
            var groupname=popupobj.approvereminds.groups[i];
            for(var j=0;j<popupobj.approvereminds[groupname].method.length;j++)
             {
                var remindmethod=popupobj.approvereminds[groupname].method[j];
                //提醒方式
               
                if(ld("#"+popupobj.divid+' [name='+groupname+'_'+remindmethod+"_method]").prop("checked"))
                    tmpurl+="&"+groupname+'_'+remindmethod+"_method=1";
                else
                    tmpurl+="&"+groupname+'_'+remindmethod+"_method=0";
               
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
                    else
                    {
                         tmpurl+="&"+reminduserchkname+"=0";
                    }
                    //提醒内容
                    //before_approve_sms_selectuser_remindconent 
                    var remindcontentname=groupname+'_'+remindmethod+"_"+remindusertag+"_remindcontent";
                    
                      
                    tmpurl+="&"+remindcontentname+"="+ld("#"+popupobj.divid+' [name='+remindcontentname+"]").val();
                    
                }
            
                
               
             }
         }
           //
     
        ld.ajax({
            url: "index.php?module=Settings&action=SettingsAjax&file=SaveApproveStep",
            type: 'POST',
            data:tmpurl,
            dataType:'json',
            async: true,//
            timeout: 10000,
           
            success:function(data)
            {
             
                if(data.code==1)
                {
                    
                    ld("#approvestepdetaillist").html(data.result.content);
                
                    popupobj.CancelEvent();
                    popupobj=CrmPopup.getPopupObj("last");
                    //新增审批流程的时候，当先新增审批步骤，默认生成新的审批流程id,所以要把获得审批流程id赋值到新增界面上
                    if(popupobj.type=='EditMultiApprove')
                       document.getElementById("form").record.value=data.result.record;
                }
                else if(data.msg=='used')
                {
                    var confirm_str=arrJsPopLabel['PROCESSUSEDCANOTMODIFIED'];
                    RemindsMsg("","LdPopupWidth400px","","yes","",confirm_str);
                    
                }
            
            },
            error:function(data)
            {
             
            }
            
        });
        return true;
    }else {
        return false;
    }

}
validate_approvestep.funname = 'validate_approvestep';
//审批步骤高级功能
function passStatus(obj,modulename){
    if(obj==undefined ||obj.id==undefined)
    {
        return false;
    }
     if(obj.id=='nopass')
        {
            ld("#nopassvalue").empty();
        }
        else
        {
           
            ld("#passvalue").empty();
        }
    if(obj.selectedIndex<=0)
    {
       
        return false;
    }
    var columnname=obj.options[obj.selectedIndex].value;
   
    ld.ajax({
        url: "index.php?module=Settings&action=SettingsAjax&file=getpicklistContent&fld_module="+modulename+"&columnname="+columnname,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
       dataType:'json',
        async: true,//
        timeout: 10000,
       
        success: function(data)
        {
         
            if(data.code==1)
            {
                 if(obj.id=='nopass')
                 {
                     var hiddennopassvalue=ld("#hiddennopassvalue").val();
                      ld.each(data.result.picklist,function(value,text){
                        if(value==hiddennopassvalue)
						{
						  ld("#nopassvalue").append("<option value='"+value+"' selected=''>"+text+"</option>");
						}
                        else
                        {
                            ld("#nopassvalue").append("<option value='"+value+"'>"+text+"</option>");
                        }
                     });
                 }
                 else
                 {
                    var hiddenpassvalue=ld("#hiddenpassvalue").val();
                    ld.each(data.result.picklist,function(value,text){
                       
						if(value==hiddenpassvalue)
						{
						  ld("#passvalue").append("<option value='"+value+"' selected=''>"+text+"</option>");
						}
                        else
                        {
                            ld("#passvalue").append("<option value='"+value+"'>"+text+"</option>");
                        }
                     });
                
                 }
                 
                    //     
                
            }
           
        
        },
        error:function(data)
        {
         
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
        new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=ForceApproveRetStart&record='+approveid+"&blockid="+tabid,
            onComplete: function(response) {
            if(response.responseText.indexOf("SUCCESS")>-1){
                //操作成功！
                var confirm_str = arrJsPopLabel['SUCCESSFULOPERATION'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                //点击确认
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    location.reload();
                })   
            }else if(response.responseText.indexOf("FAILED")>-1){
                //操作失败！
                var confirm_str = arrJsPopLabel['OPERATIONFAILED'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            }
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
				} else {
					return false;
				}
			}
			selectid = select_id;
		}else{
			var x = select_id.split(';');
			var count = x.length;
			if(0 == ld('input[name=selected_id]:checked').length){
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
	
	/*for(var i=0; i<selectlen; i++){
		if(selectobj[i].checked){//获取选中的ID
			selectid += selectobj[i].value+',';
			count++;
		}
	}
	if(selectid == ''){//请至少选择一条记录
		alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
		return false;
	}*/
	//选择条目数超过系统参数批量操作数上线时  给出提示
	/*if(count > getMaxMassOperationLimit()) {
		var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
		if(confirm(confirm_str)) {
			confirm_status = true;
		} else {
			return false;
		}
	}*/
	if(confirm_status){
	
		document.frmbatchapproved.approvedtype.value = 1;//初始化为通过并执行下一步
		document.frmbatchapproved.approveddescri.value = '';//清空审批备注
		fnvshobj(obj,'batchapproved');
		var batchbtn = document.getElementById('batchapprovedbtn');
		batchbtn.onclick = function(){//批量审批点击事件
			var approvedtype = document.getElementsByName('approvedtype');
			var approvetypelen = approvedtype.length;var approvetype = 0;
			for(var i=0; i<approvetypelen; i++){//获取当前反审批状态
				if(approvedtype[i].checked){
					approvetype = approvedtype[i].value;
				}
			}
			var approveddescri = document.frmbatchapproved.approveddescri.value;
			/**
			 * 批量审批点击事件，弹出批量审批层之后，绑定保存按钮点击事件
			 * @0013756: 审批中心-待审批：不能全选所有单据，只能选中当页的
			 * @author Tujt 2015-05-11
			 */
			if('inline' == ld('#deSelectAllRec').css('display')){
				selectid = 'All';//全选所有
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
			RequestAjax(urlstring,function(rest){//获取当前模块的审批流程
				var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				document.getElementById('cencalapprovedbtn').click();
				var divobj = createElementDivs('batchapprove_div');
				ld(divobj).css('max-height','340px');
                ld(divobj).css('width','500px');
				var submitlog = '<div style="width: 100%;display:block;word-break: break-all;word-wrap: break-word;font-size:13px;">';
				submitlog += '<span>'+restobj.content+'</span>';//批量提交日志
				submitlog += '</div>';
				ld(divobj).find('.D_pbtn .D_pbtncancel').css('display','none');
				ld(divobj).find('div.D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_CLOSE']);
				ld(divobj).find('div.D_pop_tit .D_ptita').html(restobj.title);
				// ld('#batchapprove_divcontent').css('max-height','200px');
				// ld('#batchapprove_divcontent').css('overflow-y','auto');
				ld('#batchapprove_divcontent').html(submitlog);
				fnvshobj('', 'batchapprove_div');
				ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					getListViewEntries_js('Approve',searchurl+'start=1');//刷新页面
					fninvshnew('batchapprove_div');lingdangJS_DialogBox.unblock();
				});
			});
		}
	}
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
				} else {
					return false;
				}
			}
			selectid = select_id;
		}else{
			var x = select_id.split(';');
			var count = x.length;
			if(0 == ld('input[name=selected_id]:checked').length){
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
			if(rest == '') return false;
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
				}else if('D_pbtncancel' == appinput[i].className){
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
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
							fninvshnew('SubmitApprove');lingdangJS_DialogBox.unblock();
							getId('allselectedboxes').value = '';
							getListViewEntries_js('Approve',searchurl+'start=1');//刷新页面
						}
					});
				}
			}
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
	}else{
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
		}else{
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
    }else{
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
	}else if(0 == check){//一个没选中
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
					//不需要回传值
				});
			}else{//还原模块
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
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var isremove = 0;
		if(2 == isconfirm){//批量审批调用清除方法
			isremove = isconfirm = 1;
		}else if(confirm(arrJsPopLabel['PLEASECONFIRMWHETHERREMOVE'])){
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
				}else if(menutabid != select_tabid){
					select_tabid = -1;
					break;
				}
				selectid += menuselect[i].value+',';
				selectobj[menuselect[i].value] = menuselect[i].getAttribute('forcount');
			}
		}
		if('' == selectid){//请至少选择一条记录
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		if(-1 == select_tabid){//请选择一个模块的单据进行审批
            var confirm_str = arrJsPopLabel['PLEASESELECTDAPPROVALOCUMENTS'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}                    
		var urlstring = 'module=Approve&action=ApproveAjax&file=menuapproval';
		urlstring += '&selectid='+selectid+'&select_tabid='+select_tabid+'&setype=3';
		RequestAjax(urlstring,function(rest){

			if('' == rest) return false;
			if(rest.indexOf('###APPROVE###') > -1){//没有可用审批流程
                var confirm_str = arrJsPopLabel['NOPROCESSPLEASESETPROCESS'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
				}else{//隐藏
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
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						return false;
					}else if('' == menu_userid || menu_userid < 1){
                        var confirm_str = lbl_please_select+' '+lbl_nextoperator;
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
				});
			}
			fnvshobj(obj,'menubatchapproved');//显示批量审批弹出层
		});
	}
}

function CloseTheWindow(ids){
	getId(ids).style.display = 'none';
}

/**
 * 审批流程分配功能
 * @project PROT195 审批管理改进  
 * @author Tujt 2015-04-15
 */
/* gyq_14XX ApproveAllocate(obj,approvetabid,approveid,approveallocateid,approveallocatetype 已删*/


/**
 * 选择审批步骤指定审批人
 * @author Tujt 2015-04-29
 */
function approve_selectuser(){
    /* editor:gyq_14 */
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        ScopePopup_Details.getInstance().wareHouseselectUser('userid','userid_name','approvestep');
    });
   
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
        setReiszeTable_Init('Approve','ajax');
        setContentHeight(module);//计算内容高度              
    }
    listview_page.page();
}

 //type:before_approve,after_approve,refuse_approve 
//remindmethod:sms,email,dialog,accountsfield,contactsfield,weixin
function SetApproveRemindContent(frommodule,groupname,remindmethod)
{
    var approveremindcontent=[];//提醒内容下拉框
    var that=this;
    this.setInputHiddenRemindContent=function(){
        
        var popupobj=CrmPopup.getPopupObj("last");
        //点击保存后获取提醒内容
         approveremindcontent[ld("#"+popupobj.divid+" [name=selectapprovereminduser]").val()]=ld("#"+popupobj.divid+" [name=CKcontent]").val();
         
         
         var lastpopupobj=CrmPopup.getPopupObj("lastprev");
         var remindusertags=lastpopupobj.approvereminds[groupname][remindmethod]['reminduser'];
         
         for(var i=0;i<remindusertags.length;i++)
        {
            //before_approve_dialog_selectuser_remindconent
            //after_approve_dialog_selectuser_remindcontent
            
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
            
            if(ld(this).attr("name")!=methodtaggroup+"_method"&&ld(this).prop("checked"))//不是提醒方式选中
            {
                selectremindusercount++;
               return false;
            }
        });
      if(selectremindusercount==0)
      {
            var confirm_str = popupobj.tipsetreminder;
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
      }
   	
    //初始化提醒人的提醒内容
      
        for(var i=0;i<remindusertags.length;i++)
        {
            
                
            
          
                var hiddenremindcontenttextname=groupname+"_"+remindmethod+"_"+remindusertags[i]+"_remindcontent";
           
              if(ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val()==undefined)
              {
                ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val("");
                
                
              }
              if( ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val()!="")
               approveremindcontent[remindusertags[i]]=ld("#"+popupobj.divid+" [name="+hiddenremindcontenttextname+"]").val();   
              else
              {
                var remindercontent=popupobj.approvereminds[groupname]['defaultremind'][remindusertags[i]];
                remindercontent=remindercontent.replace('{$MODULE$}',popupobj.modulelabel);
                
                approveremindcontent[remindusertags[i]]=remindercontent;   
              }
              
                       
                            
        }
  
   
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth950px",frommodule,"","","","");
    
	crmPopupobj.prevshow();   
	postbody = "module=Users&action=UsersAjax&file=setApproveRemindContent&frommodule="
            +frommodule+"&groupname="+groupname+"&stepid="+stepid+"&remindmethod="+remindmethod;
      ld.ajax({
            url: 'index.php?'+postbody,
            type: 'POST',
            data:'',
           dataType:'json',
            async: true,//
            timeout: 5000,
           
            success: function(data)
            {
                if(data.code==1)
                {
                    
                     $("status").style.display="none";
                     var jspopup=[];
                    crmPopupobj.setParams(data.result.title,that.setInputHiddenRemindContent,"","LdPopWidth950px",frommodule,"",data.result.oktext,"",data.result.canceltext);  
				    crmPopupobj.show(data.result.content);
                    
                    //填充下拉字段
                   var urlstring = '&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&printtabid='+ld("#"+popupobj.divid+" [name=tabid]").val();
                	new Ajax.Request(
                		'index.php',
                		{
                			queue: {
                				position: 'end',
                				scope: 'command'
                			},
                			method: 'post',
                			postBody: 'module=Settings&action=TemplatePrintField'+urlstring,
                			onComplete: function(response) {
                			 
                				if(response.responseText.indexOf("SUCCESS")>-1){
                				  var results=response.responseText.split("##SUCCESS##");
                				  document.getElementById("tabField").innerHTML=results[1];
                				}else
                                {
                                    var confirm_str = alert_arr.ERROR_WHILE_EDITING;
                                     RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str);
                                }
                					
                			}
                		}
                	);
                      var lastpopupobj=CrmPopup.getPopupObj("lastprev");
                      //获取需要提醒的审批人
                      //type:before_approve,after_approve,refuse_approve 
                      //remindmethod:sms,email,dialog,accountsfield,contactsfield,weixin
                      var remindusertags=lastpopupobj.approvereminds[groupname][remindmethod]['reminduser'];
                      
                      for(var i=0;i<remindusertags.length;i++)
                      {
                             var remindusername=groupname+"_"+remindmethod+"_"+remindusertags[i];
                             if(ld("#"+lastpopupobj.divid+" [name="+remindusername+"]").prop("checked"))
                             {
                               
                                var optionhtml="<option value='"+remindusertags[i]+"'>"+lastpopupobj.remindusertext[remindusertags[i]]+"</option>";
                        
                                ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").append(optionhtml);
                             }

                      }
                     
                      ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(approveremindcontent[ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").val()]);
                    var before_select_user_tag=ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").val();
                    
                    approveremindcontent[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
                      ld("#"+crmPopupobj.divid+" [name=selectapprovereminduser]").bind('change',function(){
                                var remindusertag=ld(this).val();
                                approveremindcontent[before_select_user_tag]=ld("#"+crmPopupobj.divid+" [name=CKcontent]").val();
                                if(approveremindcontent[remindusertag]!=undefined)
                                {
                                    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(approveremindcontent[remindusertag]);
                                    
                                }
                                else
                                {
                                    ld("#"+crmPopupobj.divid+" [name=CKcontent]").val("");
                                    
                                }
                                before_select_user_tag=remindusertag;
                         
                      });
                     
    
                }
            
            }
        });
    
}

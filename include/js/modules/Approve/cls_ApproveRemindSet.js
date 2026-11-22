function cls_ApproveRemindSet(approvestepobj)
{
	//提醒
	var that=this;
	this.approvestepobj=approvestepobj;
	this.divid=this.approvestepobj.divid;
	this.remindinfo=this.approvestepobj.remindinfo;
	this.remindlabel=this.approvestepobj.remindlabel;
	this.sms_platform=this.approvestepobj.remindinfo.sms_platform;

	this.InitHtml=function(tag){
		that.tag=tag;
		ld('.first-drawer-body-content').append('<div class="first-drawer-content-items" style="display:none" tag="'+tag+'"></div>');

		var thead_html = '<tr class="thead"><td width="15%">'+that.remindlabel.tablethlabel.remindmethod+'</td>'+
							'<td width="25%">'+that.remindlabel.tablethlabel.remindperson+'</td>'+
							'<td width="23%">'+that.remindlabel.tablethlabel.remindtitle+'</td>'+
							'<td width="33%">'+that.remindlabel.tablethlabel.remindcontent+'</td>'+
							'<td style="min-width:35px;">'+that.remindlabel.tablethlabel.operating+'</td></tr>';

		//审批处理前的提醒
		var html=' <table class="ld-approve-tablecontent lasttdbordernon" width="100%" cellspacing="0" cellpadding="0" border="0"><tbody>' +
			'<tr>' +
			'<th  class="ld-from-headblock" width="90%"><div class="ld-from-headblock-title">'+that.remindlabel.grouplabel.before_approve+'<input class="ld-button ld-button-primary" style="margin-top: -6px;float:right" type="button" name="btn_addbefore" value="'+that.remindlabel.tablethlabel.new+'"></div></th>'+
			'</tr>'+
			'</tbody></table>';
		html+='<table class="DetailContentTable" remindtype="before_approve" name="beforeremindtable" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">';
		html+=thead_html;
		html+='</table>';

		//审批通过提醒
		html+='<table class="ld-approve-tablecontent lasttdbordernon" width="100%" cellspacing="0" cellpadding="0" border="0"><tbody>' +
			'<tr>' +
			'<th class="ld-from-headblock" width="90%"><div class="ld-from-headblock-title">'+that.remindlabel.grouplabel.after_approve+'<input class="ld-button ld-button-primary" style="margin-bottom: 5px;float:right" type="button" name="btn_addafter" value="'+that.remindlabel.tablethlabel.new+'"></div></th>'+
			'</tr>'+
			'</tbody></table>';
		html+='<table class="DetailContentTable" remindtype="after_approve" name="afteremindtable" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">';
		html+=thead_html;
		html+='</table>';

		//审批失败提醒
		html+='<table class="ld-approve-tablecontent lasttdbordernon" width="100%" cellspacing="0" cellpadding="0" border="0"><tbody>' +
			'<tr>' +
			'<th class="ld-from-headblock" width="90%"><div class="ld-from-headblock-title">'+that.remindlabel.grouplabel.refuse_approve+'<input class="ld-button ld-button-primary" style="margin-top: -6px;float:right" type="button" name="btn_addfail" value="'+that.remindlabel.tablethlabel.new+'"></div></th>'+
			'</tr>'+
			'</tbody></table>';
		html+='<table class="DetailContentTable" remindtype="refuse_approve" name="failremindtable" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">';
		html+=thead_html;
		html+='</table>';

		//审批作废后提醒
		html+='<table class="ld-approve-tablecontent lasttdbordernon" width="100%" cellspacing="0" cellpadding="0" border="0"><tbody>' +
			'<tr>' +
			'<th class="ld-from-headblock" width="90%"><div class="ld-from-headblock-title">'+that.remindlabel.grouplabel.cancel_approve+'<input class="ld-button ld-button-primary" style="margin-top: -6px;float:right" type="button" name="btn_addcancel" value="'+that.remindlabel.tablethlabel.new+'"></div></th>'+
			'</tr>'+
			'</tbody></table>';
		html+='<table class="DetailContentTable" remindtype="cancel_approve" name="cancelremindtable" width="100%" cellspacing="0" cellpadding="0" border="0" align="center">';
		html+=thead_html;
		html+='</table>';
		ld('.first-drawer-content-items[tag='+tag+']').append(html);
		var obj=ld('.first-drawer-body-content').find(" [tag="+that.tag+"]");
		// console.log(this.approvestepobj.reminddata);

		ld.each(this.approvestepobj.remindinfo['groups'],function(remindindex,remindtype)
		{
			//初始化赋值

			var reminddatainfo_arr=that.approvestepobj.reminddata[remindtype];
			if(reminddatainfo_arr==undefined)
				return true;
			var tableobj=ld(obj).find(" table[remindtype="+remindtype+"]");
			reminddatainfo_arr.forEach(function(tmpinfo,tmpindex )
			{
				//增加行
				that.addTr(tableobj);
				var trobj=ld(tableobj).find(" tr[deleted=no]:last");
				//提醒方式
				ld(trobj).find(" [name=remindmethod]").val(tmpinfo.method);

				ld(trobj).data("stage_smstemplate_arr",tmpinfo);//将行信息暂存 编辑时根据审批提醒表主键id弹窗数据
				console.log(ld(trobj).data("stage_smstemplate_arr"));
				ld(trobj).find(" [name=remindmethod]").change();//编辑时需要初始化

				that.changeremindmethod(trobj,tmpinfo.method);//修改提醒人的下拉框
				ld(trobj).find(" [name=remindapprover]").val(tmpinfo.users);//提醒人
				that.changeremindapprover(trobj,tmpinfo.users);//改变提醒人
				ld(trobj).find(" [name=title]").val(tmpinfo.title);//提醒标题
				ld(trobj).find(" [name=content]").val(tmpinfo.content);//提醒内容
				if(['selectuser','selectrole','departmentposition','topposition','departmentuser'].includes(tmpinfo.users)){
					ld(trobj).find(" [name=remindselectfield]").val(tmpinfo.reminduserid)
				}
				else if(tmpinfo.remindcolumnname!='')
				{
					ld(trobj).find(" [name=remindselectfield]").val(tmpinfo.remindcolumnname)
				}

			})
			
		})
		 
		that.setRemindEvent();
	}

	that.setRemindEvent=function(){

		 var obj=ld('.first-drawer-body-content').find(" [tag="+that.tag+"]");

		ld(obj).find(" [name=btn_addbefore]").unbind("click").bind("click",function(){
			//处理前新增行
			that.addTr(	ld(obj).find(" table[name=beforeremindtable]"));
            //重设提醒内容文本区域高度
            that.set_textarea_autosize();
		})
		ld(obj).find(" [name=btn_addafter]").unbind("click").bind("click",function(){
			//审批通过新增行
			that.addTr(	ld(obj).find(" table[name=afteremindtable]"));
            //重设提醒内容文本区域高度
            that.set_textarea_autosize();
		})

		ld(obj).find(" [name=btn_addfail]").unbind("click").bind("click",function(){
			//审批失败新增行
			that.addTr(	ld(obj).find(" table[name=failremindtable]"));
            //重设提醒内容文本区域高度
            that.set_textarea_autosize();
		})

		ld(obj).find(" [name=btn_addcancel]").unbind("click").bind("click",function(){
			//审批作废新增行
			that.addTr(	ld(obj).find(" table[name=cancelremindtable]"));
            //重设提醒内容文本区域高度
            that.set_textarea_autosize();
		})

		ld(obj).find(" [name=btn_deleterow]").unbind("click").bind("click",function(){
			//删除行
			that.deletetr(Tools.getParentobjByChild(ld(this),'tr'));
		})
		ld(obj).find(" [name=remindmethod]").unbind("change").bind("change",function(){

			//改变提醒方式
			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			ld(trobj).find(" [name=remindselectfield]").val();//清空选择成员 选择邮箱，手机
			that.changeremindmethod(trobj,ld(this).val());

			if (ld(this).val() == 'sms' && that.sms_platform == 'aliyun') {
				ld(trobj).find(" [name=content]").attr("disabled",true);
				if (empty(ld(trobj).data("stage_smstemplate_arr"))) {//新增且没有设置过时清空内容
					ld(trobj).find(" [name=content]").val("");
				}else{//还原
					ld(trobj).find(" [name=content]").val(ld(trobj).data("stage_smstemplate_arr").templatecontent);
				}

			}else{
				ld(trobj).find(" [name=content]").attr("disabled",false);

				//切回默认值
				var tableobj=Tools.getParentobjByChild(ld(trobj),'table');
				var remindapproverobj=ld(trobj).find(" [name=remindapprover]");
				var remindtype=ld(tableobj).attr("remindtype");

				var defaultcontent=that.remindinfo[remindtype]['defaultremind'][ld(remindapproverobj).val()];
				ld(trobj).find(" [name=content]").val(defaultcontent);
			}

		})

		ld(obj).find(" [name=remindapprover]").unbind("change").bind("change",function(){

			//改变提醒人
			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			ld(trobj).find(" [name=remindselectfield]").val('');//清空选择成员 选择邮箱，手机
			that.changeremindapprover(trobj,ld(this).val());

		})
		ld(obj).find(" [name=btn_editremindcontent]").unbind("click").bind("click",function(){
			//修改提醒内容
			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			that.SetApproveRemindContent(trobj);
            //重设提醒内容文本区域高度
            that.set_textarea_autosize();
		})
		ld(obj).find(" [tag=chooseapprover]").unbind("click").bind("click",function(){
			//选择指定成员，选择邮箱，选择手机
			var trobj=Tools.getParentobjByChild(ld(this),'tr');
			var approver=ld(trobj).find(" [name=remindapprover]").val();
			if(approver=='selectuser' || approver=='selectrole')
			{
				that.selectuser(trobj)
			}
			else if(approver=='departmentposition' || approver=='topposition' || approver=='departmentuser'){// 选择职位级别
				that.selectPosition(trobj)
			}
			else
				that.approveSelectModuleField(trobj);
		})
	}

	that.changeremindmethod=function(trobj,methodvalue){
		//改变提醒方式
		that.addApproverRemindHtml(trobj,methodvalue)
	}
	this.changeremindapprover=function(trobj,approvervalue)
	{
		//改变提醒人
		ld(trobj).find(" [tag=chooseapprover]").css('display','none');

		var approver=ld(trobj).find(" [name=remindapprover]").val();
		if(approver=='departmentposition' || approver=='topposition' || approver=='departmentuser'){
			ld(trobj).find(" .selectposition").css("display",'');
		}else{
			ld(trobj).find(" ."+approvervalue).css("display",'');
		}
	}
	that.addTr=function(tableobj){

		var trhtml='<tr deleted="no">';
		trhtml+='<td><select class="ld-select-inner" name="remindmethod">';
		for(let key in that.remindlabel.methodlabel) {
			trhtml+='<option value="'+key+'">'+that.remindlabel.methodlabel[key]+'</option>';
		}
		trhtml+='</select></td>';
		trhtml+='<td><select class="ld-select-inner" name="remindapprover" style="width: 80%;">';
		trhtml+='</select><a class="icon-little icon-pepole selectuser"  tag="chooseapprover" href="javascript:;" title="指定成员"></a>';
		trhtml+='<a class="icon-little icon-pepole selectrole" tag="chooseapprover" href="javascript:;" title="指定角色"></a>';
		trhtml+='<a class="icon-little icon-pepole selectposition" tag="chooseapprover" href="javascript:;" title="指定角色"></a>';
		trhtml+='<a class="icon-little icon-email Accounts_email" tag="chooseapprover" href="javascript:;" title="指定客户邮箱"></a>';
		trhtml+='<a class="icon-little icon-email Contacts_email" tag="chooseapprover" title="指定联系人邮箱" href="javascript:;"></a>';
		trhtml+='<a class="icon-little icon-mob Accounts_sms" tag="chooseapprover" href="javascript:;" title="指定客户手机2"></a>';
		trhtml+='<a class="icon-little icon-mob Contacts_sms" tag="chooseapprover" href="javascript:;" title="指定联系人手机"></a>';
		trhtml+='<input type="hidden" name="remindselectfield"/>';
		trhtml+='</td>';
		trhtml+='<td><input class="ld-input-inner" type="text" name="title" style="width:100%"></td>';
		trhtml+='<td style="position: relative;">' +
			'<textarea class="ld-textarea-inner" style="flex:1" rows="2" cols="30" name="content" ></textarea>' +
			'<i class="ld-fonticon ld-fonticon-edit" name="btn_editremindcontent" style="position: absolute;right: 14px;bottom: 8px;" title="'+ arrJsPopLabel['EDIT']+'"></i>' +
			'</td>';
		trhtml+='<td>' +
			'<i class="ld-fonticon ld-fonticon-del" name="btn_deleterow" title="'+ arrJsPopLabel['DELETE']+'"></i></td>';
		trhtml+='</tr>';
		ld(tableobj).append(trhtml);
		
		var trobj=ld(tableobj).find(" tr[deleted=no]:last");
		that.addApproverRemindHtml(trobj,ld(trobj).find(" [name=remindmethod]").val());
		that.setDefaultvalue(trobj);
		that.setRemindEvent();
	}
	that.deletetr=function(trobj){

		ld(trobj).remove();
	}
	this.addApproverRemindHtml=function(trobj,methodvalue){
		//增加提醒人下拉框
		var tableobj=Tools.getParentobjByChild(ld(trobj),'table');
		var remindtype=ld(tableobj).attr("remindtype");
		var remindapproverobj=ld(trobj).find(" [name=remindapprover]");
		ld(remindapproverobj).empty();
		var selectapprover_arr=[];
		var remindmethod=ld(trobj).find(" [name=remindmethod]").val();

		var trobj_arr=ld(tableobj).find(" tr[deleted=no]");
		ld.each(trobj_arr,function(){
				 if(ld(this).find(" [name=remindmethod]").val()==remindmethod)
						selectapprover_arr.push(ld(this).find(" [name=remindapprover]").val());
		})
		
		var notAllowdup_arr=['approver','smowner','smcreator'];

		ld.each(that.remindinfo[remindtype][methodvalue]['reminduser'],function(tmpindex,tmpvalue){
			//同一个提醒方式下，只能有一个审批人，负责人，创建人的下拉选项
			  if(selectapprover_arr.includes(tmpvalue)&&
			  	notAllowdup_arr.includes(tmpvalue))
			 	 		return true;
				remindapproverobj.append("<option value='"+tmpvalue+"'>"+that.remindlabel.reminduserlabel[tmpvalue]+"</option>")
		})
		//模块的选择用户字段
		ld.each(this.approvestepobj.ajaxdata.result.approverfield,function(tmpindex,tmpinfo){
			remindapproverobj.append('<option value="'+tmpinfo.fieldid+'" uitype="'+tmpinfo.uitype+'" >'+tmpinfo.label+"</option>");
		});
		that.changeremindapprover(trobj,ld(remindapproverobj).val());
	}
	this.setDefaultvalue=function(trobj){
		//增加默认的提醒标题
		var tableobj=Tools.getParentobjByChild(ld(trobj),'table');
		var remindapproverobj=ld(trobj).find(" [name=remindapprover]");
		var remindtype=ld(tableobj).attr("remindtype");
		var defaulttitle=that.remindinfo[remindtype]['defaultremindtitle'][ld(remindapproverobj).val()]
		ld(trobj).find(" [name=title]").val(defaulttitle);
		var defaultcontent=that.remindinfo[remindtype]['defaultremind'][ld(remindapproverobj).val()];
		ld(trobj).find(" [name=content]").val(defaultcontent);

	}

	this.setselectfieldvalue=function(trobj)
     {
        var  popupobj=CrmPopup.getPopupObj("last");
    	
        var selectfields="";
        ld.each( ld("#"+popupobj.divid).find(" [name=moduleselectfield]"),function(){
                            
    		if(ld(this).prop("checked"))		 
          		selectfields+=ld(this).val()+",";
                                            
       });
      
		popupobj.CancelEvent();//关闭选择邮箱或选择手机字段的弹出层
         
        ld(trobj).find(" [name=remindselectfield]").val(selectfields);
           
        
     };
     this.setselectfieldvalue.funname="setselectfieldvalue";
	that.approveSelectModuleField=function (trobj)
	{
		    //type:before_approve_email,before_approve_sms,after_approve_sms,after_approve_email,refuse_approve_sms,refuse_approve_email
		     
		    var approveruser=ld(trobj).find(" [name=remindapprover]").val();
		     
		     var remindmethod='';
			if(approveruser.indexOf("email")>=0 ){
			       var remindmethod='email';
			       var crmPopupobj=CrmPopup.load("","","","LdPopWidth350px",'Emails',"","","","");
			       fieldtype = '&fieldtype=email';
		    }
		    else
		    {
		        var remindmethod='sms';
		        var crmPopupobj=CrmPopup.load("","","","LdPopWidth350px",'sms',"","","","");
		        fieldtype =  '&fieldtype=sms';
		    }
			crmPopupobj.prevshow();

		 	var popupmodule=approveruser.split("_")[0];
		 	var selectcolumname=ld(trobj).find(" [name=remindselectfield]").val();
		
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
						crmPopupobj.setParams(data.result.title,that.setselectfieldvalue,"","LdPopWidth350px",'Emails',[trobj],data.result.oktext,"",data.result.canceltext);  
						crmPopupobj.show(data.result.content);
		                
					}else{
						cancelCrmPopup();
						RemindsMsg("","LdPopWidth400px","","yes","yes",data.result.msg);
						return false;
					}
				}
			})
	}

	// 选择成员，角色
	this.selectuser=function(trobj){
		var scopepopupobj;
		var input_value;
		
		input_value = ld(trobj).find(" [name=remindselectfield]").val()
		var module=that.approvestepobj.approvestepflowobj.module;

		var approver = ld(trobj).find("[name=remindapprover]").val();
		if(approver == 'selectrole'){// 指定角色
			var popup_url = 'module=Users&action=UsersAjax&file=viewprofileinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=profile';
			var popup_title = arrJsPopLabel['SELECTROLES'];
		}else{
			var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
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
						}else{
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_username = cls_ScopePopup.return_obj.return_name;//选中的用户
						}


						ld(trobj).find(" [name=remindselectfield]").val(selected_user)       
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					});
				}
			});
		});
	}
	this.settrRemindContentValue=function(trobj){

		var popupobj=CrmPopup.getPopupObj('last');
		var templateparamconf = {};
		if (that.sms_platform == 'aliyun' && ld(trobj).find(" [name=remindmethod]").val() == 'sms') {
			var select_smstemplateid = ld("#"+popupobj.divid+" [name=smstemplatelist]").val();
			if (select_smstemplateid < 1) {
				var confirm_str = arrJsPopLabel["TEMPLATE"]+arrJsPopLabel["CANOTEMPTY"];//"模板不能为空！";
				MessagePopup.TipZero_warning(confirm_str);
				return false;
			}

			try {
				ld.each(SmsContentSetting.getInstance().smsTemplateList,function(tmpindex,tmpsmstemplateinfo){
					if (select_smstemplateid == tmpsmstemplateinfo.templateid) {
						var templateparaminfo = JSON.parse(tmpsmstemplateinfo.templateparaminfo) || eval('('+tmpsmstemplateinfo.templateparaminfo+')');
						if (!empty(templateparaminfo)) {

							ld.each(templateparaminfo,function(tmp_varname,tmp_crmvarname){
								var tmp_crmvarname_value = trim(ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").val());
								if (tmp_crmvarname_value.length == 0) {
									ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").focus();
									var confirm_str = 'CRM' + arrJsPopLabel['VAR'] + arrJsPopLabel['CANOTEMPTY'] + '!';
									MessagePopup.TipZero_warning(confirm_str);
									throw 'ExitLoops';
								}
								templateparamconf[tmp_varname] = tmp_crmvarname_value;

							})

							//将选择的模板数据通过data方法暂存到tr上
							if (empty(ld(trobj).data("stage_smstemplate_arr"))) {//新增提醒行时 需要初始化才能赋值
								ld(trobj).data("stage_smstemplate_arr",{});
							}
							ld(trobj).data("stage_smstemplate_arr").templateid = select_smstemplateid;
							ld(trobj).data("stage_smstemplate_arr").templateparamconf = templateparamconf;
							ld(trobj).data("stage_smstemplate_arr").templatecontent = tmpsmstemplateinfo.templatecontent;
							console.log(ld(trobj).data("stage_smstemplate_arr"));


							ld(trobj).find(" [name=content]").val(ld("#"+popupobj.divid+" span[name=smstemplate_content]").text());
						}
						return false;//跳出循环
					}

				})
			}catch(e){
				if (e === 'ExitLoops') {
					console.log('退出循环');
					return false;
				}
				// else {
				//     throw e;  // 如果不是我们自定义的异常，重新抛出
				// }
			}


		}else{
			ld(trobj).find(" [name=content]").val(ld("#"+popupobj.divid+" [name=CKcontent]").val());
		}

		popupobj.CancelEvent();
	}

	//修改提醒内容
	this.SetApproveRemindContent = function(trobj){
		var frommodule=that.approvestepobj.approvestepflowobj.module;
		$("status").style.display="inline";
		var popupobj=CrmPopup.getPopupObj("last");
		var remindcontent=ld(trobj).find(" [name=content]").val();
		var postbody = '';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",frommodule,"","","","");
		crmPopupobj.prevshow();   
		postbody = "module=Users&action=UsersAjax&file=setnewApproveRemindContent&frommodule="+frommodule;

		var remindmethod=ld(trobj).find(" [name=remindmethod]").val();
		postbody += "&remindmethod="+remindmethod;

		ld.ajax({
			url: 'index.php?'+postbody,
			type: 'POST',
			data:'',
			dataType:'json',
			async: true,//
			timeout: 5000,
			success: function(data){
				if(data.code==1){
					$("status").style.display="none";
					var jspopup=[];
					crmPopupobj.setParams(data.result.title,that.settrRemindContentValue,"","LdPopWidth800px",frommodule,[trobj],data.result.oktext,"",data.result.canceltext);
					crmPopupobj.show(data.result.content);
					//填充下拉字段
					var urlstring = '&tabid='+data.result.tabid+'&printtabid='+data.result.tabid;
					
					ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
						document.getElementById("tabField").innerHTML=data.result.fieldsel;
					});
					ld("#"+crmPopupobj.divid+" [name=CKcontent]").val(remindcontent);

					//如果是编辑  或者有设置过，则从暂存信息里取数据
					var stage_smstemplate_arr = ld(trobj).data("stage_smstemplate_arr");
					// console.log(stage_smstemplate_arr);
					if (!empty(stage_smstemplate_arr) && !empty(stage_smstemplate_arr.templateid)) {
						//赋值
						ld("#"+crmPopupobj.divid+" [name=smstemplatelist]").val(stage_smstemplate_arr.templateid);

						//设置内容
						SmsContentSetting.getInstance().ShowSmsTemplateEvent(crmPopupobj,stage_smstemplate_arr.templateparamconf);

					}else{
						ld("#"+crmPopupobj.divid+" [name=smstemplatelist]").change();// 将提醒内容和输入变量搞出来
					}
				}
			}
		});
	}
    this.set_textarea_autosize = function(){
        ld.each(ld('textarea[name=content]'),function(){
            var ori_height = ld(this).height();
            if(ori_height<34)ori_height = 34;//默认内容高度
            ld(this).autosize();
            ld(this).height(ori_height+'px');
            var style_str = ld(this).attr('style');
            if(style_str.indexOf('resize:none')==-1){
                ld(this).attr('style','resize:none !important;'+style_str);
            }
        });
    }
	// 选择职位级别
	this.selectPosition = function(trobj){
		var input_value = ld(trobj).find("[name=remindselectfield]").val();
		var approver = ld(trobj).find("[name=remindapprover]").val();
        var title = arrJsPopLabel['pleaseselect'] + ld(trobj).find("[name=remindapprover]").find('option:selected').text();

		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'',"","","","");
        crmPopupobj.prevshow();
        crmPopupobj.setParams(title,that.savePosition,"","LdPopWidth600px",'',trobj,arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
        
        var content_html = `<div style="overflow-x: auto;">`
                            +`<table class="ld-public-content-small" id="" border="0" cellpadding="0" cellspacing="0" width="100%">`;
        
		if(approver == 'departmentuser'){// 指定部门
			input_value = input_value.split('::');
			var select_groupid = input_value[0];
			input_value = input_value[1];
			content_html += '<tr><td class="ld-form-item-label">'
							+ arrJsPopLabel['USERGROUPLIST']
						+`</td>`;
			content_html += '<td class="ld-form-item-content">'
							+'<select class="ld-select-inner" name="departmentuser" >';
			ld.each(this.approvestepobj.ajaxdata.result.group,function(groupname,groupid){
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
							+ this.approvestepobj.ajaxdata.result.userlevellabel
						+`</td>`;
		content_html += '<td class="ld-form-item-content">'
						+`<select class="ld-select-inner" name="selectposition" >`;
		ld.each(this.approvestepobj.ajaxdata.result.userlevel, function(index, level) {
			if(level == input_value){
				content_html += '<option value="'+level+'" selected>'+level+'</option>';
			}else{
				content_html += '<option value="'+level+'" >'+level+'</option>';
			}
		});
		content_html +=`</select>`
					+`</td></tr>`;

        content_html += `</table></div>`;
        crmPopupobj.show(content_html);
		ld("#"+crmPopupobj.divid+"_olayernodeid").css('z-index',CrmPopup.zIndex+1);
		ld("#"+crmPopupobj.divid).css('z-index',CrmPopup.zIndex+2);
        crmPopupobj.center();
	}
	// 保存职位级别
	this.savePosition = function(trobj){
		var position_popupobj = CrmPopup.getPopupObj('last');
		var departmentuser = ld('#'+position_popupobj.divid).find("[name=departmentuser]").val();
        var position = ld('#'+position_popupobj.divid).find("[name=selectposition]").val();
		var remindselectfield = '';
		if(ld('#'+position_popupobj.divid).find("[name=departmentuser]").length>0 && !empty(departmentuser)){
			remindselectfield += departmentuser + '::'
		}
		remindselectfield += position;
		position_popupobj.CancelEvent();
		ld(trobj).find("[name=remindselectfield]").val(remindselectfield);
	}
}
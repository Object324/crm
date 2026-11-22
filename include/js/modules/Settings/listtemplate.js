function settings_listtemplate(){
   var that=this;
}
//刷新
settings_listtemplate.refresh = function(){
	var from_module = this.from_module;
	var surl = 'index.php?module=Settings&action=listtemplate&parenttab=Settings&ReportHeader=dheader&from_module='+from_module;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			//@edit:liushuai,2020-09-10,reason:0042620: （61mis.com/kfbcrm）首页：点击“首页模板组件设置按钮”，弹出层删除“666”，需要手动刷新浏览器才会不显示
			var popupobj=CrmPopup.getPopupObj("last");
            if(popupobj!=undefined)//edit:can 2020-09-11 42641: （61mis.com/kfbcrm）系统设置→模板设置→首页组件模板定制→进行编辑或新建操作→保存 之后一直转圈缓冲
			    popupobj.show(data.result.content);

			ld(' [name=SettingRightContent]').html(data.result.content);

			// @edit:diony,2021-01-07,
			// 0044123: 首页组件->组件模板定制：建议修改组件模板定制之后，首页自动刷新
			if(from_module == 'home'){
				var popupobj=CrmPopup.getPopupObj("last");
				ld('#'+popupobj.divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
					window.location.reload();
					return false;
				});
			}
		}
        DelProgressObjs();
	})
}

//首页组件模板 - 编辑 - 查看 - 新增
settings_listtemplate.editListTemplate=function(templateid, from_module){
	// $("status").style.display="inline";
	//chj 2022/3/15 首页组件模板无法打开的问题
	var mode = 'create';
	if(templateid > 0){
		mode = 'edit';
	}
	this.from_module = from_module;
	var surl='index.php?module=Settings&action=SettingsAjax&file=createtemplate&returnaction=listtemplate&parenttab=Settings&mode=edit&templateid='+templateid+'&mode='+mode+'&from_module='+from_module;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,settings_listtemplate.saveListTemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
		}
	})
	return false;
	// @edit:diony,2021-01-07,
	// 0044123: 首页组件->组件模板定制：建议修改组件模板定制之后，首页自动刷新
	this.from_module = from_module;
	var surl='module=Settings&action=SettingsAjax&file=createtemplate&returnaction=listtemplate&parenttab=Settings&mode=edit&templateid='+templateid+'&mode='+mode+'&from_module='+from_module;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	//alert(surl);
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
    success: function(data){
      if(data.code==1){
        //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
        //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
        // $("status").style.display="none";
        crmPopupobj.setParams(data.result.title,settings_listtemplate.saveListTemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
        //crmPopupobj.createScrollDiv();//创建滚动条
        //  crmPopupobj.show(data.result.content);
        CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
      }
		}
	});
	//index.php?module=Settings&action=createtemplate&returnaction=listtemplate&parenttab=Settings&mode=edit&templateid={$templatevalues.templateid}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}
}

//保存
settings_listtemplate.saveListTemplate=function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var templatename_label = CrmPopup.findHtmlobj(divid,'templatename_label').val();
	if(ld('#templatename') != undefined && ld('#templatename').val() == ''){
		var confirm_str = templatename_label+arrJsPopLabel['CANOTEMPTYGTH'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	//组件
	var selectedAssmablyColumnsObj=getObj("selectedAssmablyColumns")
	var selectedAssmablyColumnsString = "";
	for (i=0;i<selectedAssmablyColumnsObj.options.length;i++) 
	{
		selectedAssmablyColumnsString += selectedAssmablyColumnsObj.options[i].value+";";
	}
	//alert(selecttemplate);
	//角色
	var selectedColStr = "";
	var selectedColumnsObj=getObj("selectedRoleColumns");
	for (i=0;i<selectedColumnsObj.options.length;i++) 
	{
		selectedColStr += selectedColumnsObj.options[i].value + ";";
	}
	var TemplateId = CrmPopup.findHtmlobj(divid,'templateid').val();
	var mode = CrmPopup.findHtmlobj(divid,'mode').val();
	var templatename = CrmPopup.findHtmlobj(divid,'templatename').val();
	if(mode == 'edit')
		var reminstr = '&mode='+mode+'&templatename='+templatename+'&templateid='+TemplateId;
	else
		var reminstr = '&templatename='+templatename+'&mode=create';
	var urlstring = 'module=Settings&action=SaveTemplate&ajax=true&dup_check=true'+reminstr;
	urlstring += '&selectedAssmablyColumnsString='+selectedAssmablyColumnsString+'&selectedRoleColumnsString='+selectedColStr;
	//alert(urlstring);

	RequestAjax(urlstring,function(rest){
		if(empty(rest)){
			popupobj.CancelEvent();
			DelProgressObjs();
			settings_listtemplate.refresh();
		}else{
			RemindsMsg("","LdPopWidth400px","","","",rest);
			DelProgressObjs();
			return false;
		}
	})
}

//删除
settings_listtemplate.deletetemplate=function(obj,templateid,deleted){
	//BUG20240826-21  	首页数据看板，对于管理旧看板，给一下删除旧看板权限
	// if(deleted==0){
	// 	//该模板是默认模板，不能删除!
	// 	var confirm_str = arrJsPopLabel['DEFAULTTEMPLATECANOTDELETED'];
	// 	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	// 	return false;
	// }else{

		var confirm_str = arrJsPopLabel['DELETETHETEMPLATE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module=Settings&action=DeleteTemplate&templateid='+templateid;
			ldAjax(surl,"",function(data){
				if(data.code==1){
					settings_listtemplate.refresh();
				}
                DelProgressObjs();
			})
		});
        return false;
	// }
}
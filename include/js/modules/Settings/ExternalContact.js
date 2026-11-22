function settings_ExternalContact(){
   var that=this;
}
//刷新
settings_ExternalContact.refresh = function(){
	var surl = "index.php?module=Settings&action=ExternalContact&parenttab=Settings&ReportHeader=dheader";
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
             initRightContentHeight();//加载右侧内容中菜单和详细内容高度
		}
	})
}

//系统设置 - 接口设置 - 企业微信客户联系设置
settings_ExternalContact.edit=function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=ExternalContactEdit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,settings_ExternalContact.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 企业微信客户联系设置 - 保存
settings_ExternalContact.save=function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=ExternalContactEdit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var _switch = 'close';
	if( ld("#"+popupobj.divid+" [name=switch]").is(':checked') == true){
		 _switch = 'open';
	}
	var customscope_type = ld("#"+popupobj.divid+" [name=customscope_type]").val();
	var customscope_ids = ld("#"+popupobj.divid+" [name=customscope_ids]").val();
	surl += '&switch='+_switch+'&customscope_type='+customscope_type+'&customscope_ids='+customscope_ids;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			settings_ExternalContact.refresh();
		}
        DelProgressObjs();
	})
}
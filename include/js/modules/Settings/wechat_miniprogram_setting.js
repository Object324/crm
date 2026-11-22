function wechat_miniprogram_setting(){
   var that=this;
}
//刷新
wechat_miniprogram_setting.refresh = function(){
	var surl = 'index.php?module=Settings&action=wechat_miniprogram_setting&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}

//编辑
wechat_miniprogram_setting.edit=function(codetype){
	var surl='index.php?module=Settings&action=SettingsAjax&file=wechat_miniprogram_setting_edit&parenttab=Settings&ReportHeader=dheader';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjax(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,wechat_miniprogram_setting.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			crmPopupobj.codetype = codetype;

			// 需要去掉的给高度
			crmPopupobj.reduceBodyHeight = 0;
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".dvpopupsroll");
		}
        DelProgressObjs();
	})
}
//注销 BUG0074202
wechat_miniprogram_setting.logout=function(){
	var surl='index.php?module=Settings&action=SettingsAjax&file=wechat_miniprogram_setting_edit&parenttab=Settings&ReportHeader=dheader&mode=logout';
	RemindsMsg("", "LdPopWidth400px",'Settings',"yes","yes", arrJsPopLabel['CONFIRMLOGOUTCRM']);
	//确定按钮
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
		ldAjax(surl,"",function(data){
			DelProgressObjs();
			if(data.code==1){
				MessagePopup.TipOne_success(data.msg);
			}else{
				MessagePopup.TipOne_warning(data.msg);
			}
			wechat_miniprogram_setting.refresh();
		})
	})
}
//zxm 20221013 判断消息通知发送方式 切换
wechat_miniprogram_setting.msgsend_typechange = function(obj){
	var msgsend_type = ld(obj).val();
	if(msgsend_type=="msgsend_typeld"){
		Tools.getParentobjByChild(ld('#mini_appid'),'tr').hide();
		Tools.getParentobjByChild(ld('#mini_secret'),'tr').hide();
		Tools.getParentobjByChild(ld('#offiaccount_appid'),'tr').hide();
		Tools.getParentobjByChild(ld('#offiaccount_secret'),'tr').hide();
		ld('.oemtops').hide();
	}
	else{
		Tools.getParentobjByChild(ld('#mini_appid'),'tr').show();
		Tools.getParentobjByChild(ld('#mini_secret'),'tr').show();
		Tools.getParentobjByChild(ld('#offiaccount_appid'),'tr').show();
		Tools.getParentobjByChild(ld('#offiaccount_secret'),'tr').show();
		ld('.oemtops').show();
	}
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.center();
}
//保存
wechat_miniprogram_setting.save=function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var rCorpid = ld("#"+popupobj.divid+" [name=corpid]").val();
	 if(rCorpid > 0){
		var remind_str = arrJsPopLabel['MINIPROFRAMEREMINDDEC'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",remind_str);
		//点击确认
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			wechat_miniprogram_setting.minisetting_save_real();
		});
	}else{
		wechat_miniprogram_setting.minisetting_save_real();
	}
}

wechat_miniprogram_setting.minisetting_save_real = function(){
	var mini_switch = ld('#switch').val();
	var mini_account = ld('#mini_account').val();
	var mini_url = ld('#mini_url').val();
	//zxm  20220728 系统设置增加小程序消息提醒设置
	var msgsend_type = ld('#msgsend_type').val();
	var mini_appid = ld('#mini_appid').val();
	var mini_secret = ld('#mini_secret').val();
	var offiaccount_appid = ld('#offiaccount_appid').val();
	var offiaccount_secret = ld('#offiaccount_secret').val();
	ld('#rptContentLoading').show();
	ld.get("index.php", {
		mini_account: mini_account,
		mini_url: mini_url,
		mini_switch: mini_switch,
		msgsend_type: msgsend_type,
		mini_appid: mini_appid,
		mini_secret: mini_secret,
		offiaccount_appid: offiaccount_appid,
		offiaccount_secret: offiaccount_secret,
		module: "Settings",
		file: "wechat_miniprogram_setting_edit",
		action: "SettingsAjax",
		mode:'save'
	}, function (response) {
		ld('#rptContentLoading').hide();
		var result_obj = eval("(" + response + ")") ? eval("(" + response + ")") : json.parse(response);
		if(result_obj.code < 0){
			RemindsMsg("","LdPopWidth400px","","yes","",result_obj.msg);
		}else{
			var popupobj=CrmPopup.getPopupObj("last");

            //不同的按钮点击保存完，打开不同的弹窗
            if(popupobj.codetype == 'order'){
                detailbutton_click('','Users','SELFORDERQRCODE','');
            }else if(popupobj.codetype == 'service'){
                detailbutton_click('','Users','SELFSERVICEQRCODE','');
            }else if(popupobj.codetype == 'weixin'){
                detailbutton_click('','Users','WECHATQRCODE','');
            }else {
				wechat_miniprogram_setting.refresh();
			}
            popupobj.CancelEvent();
		}
	});
}

//是否启用按钮事件
wechat_miniprogram_setting.minisetting_switch = function() {
	if(ld('#switch').prop('checked')){
		ld('#switch').val('open')
	}else{
		ld('#switch').val('close')
	}
}
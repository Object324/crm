function wechat_minimall_setting(){
   var that=this;
}
//刷新
wechat_minimall_setting.refresh = function(){
	var surl = 'index.php?module=Settings&action=wechat_minimall_top_setting&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}

//编辑
wechat_minimall_setting.edit=function(){
	var surl='index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_top_setting_edit&parenttab=Settings&ReportHeader=dheader';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjax(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,wechat_minimall_setting.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
		}
        DelProgressObjs();
	})
}

//保存
wechat_minimall_setting.save=function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var rCorpid = ld("#"+popupobj.divid+" [name=corpid]").val();
	 if(rCorpid > 0){
		var remind_str = arrJsPopLabel['MINIPROFRAMEREMINDDEC'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",remind_str);
		//点击确认
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			wechat_minimall_setting.minisetting_save_real();
		});
	}else{
		wechat_minimall_setting.minisetting_save_real();
	}
}

wechat_minimall_setting.minisetting_save_real = function(){
	 var miniprogram_title = ld('#miniprogram_title').val();
	var top_nav_text_color = ld('#top_nav_text_color').val();
	var top_nav_back_color = ld('#top_nav_back_color').val();
	ld('#rptContentLoading').show();
	ld.get("index.php", {
		miniprogram_title: miniprogram_title,
		top_nav_text_color: top_nav_text_color,
		top_nav_background_color: top_nav_back_color,
		module: "Settings",
		file: "wechat_minimall_top_setting_edit",
		action: "SettingsAjax",
		mode:'save'
	}, function (response) {
		ld('#rptContentLoading').hide();
		var result_obj = eval("(" + response + ")") ? eval("(" + response + ")") : json.parse(response);
		if(result_obj.code < 0){
			RemindsMsg("","LdPopWidth400px","","yes","",result_obj.msg);
		}else{
			var popupobj=CrmPopup.getPopupObj("last");
			popupobj.CancelEvent();
			wechat_minimall_setting.refresh();
		}
	});
}

//是否启用按钮事件
wechat_minimall_setting.minisetting_switch = function() {
	if(ld('#switch').prop('checked')){
		ld('#switch').val('open')
	}else{
		ld('#switch').val('close')
	}
}

/**
 * 选择颜色
 * @param css_type
 */
wechat_minimall_setting.SetColpick=function(css_type){
	ld('#rptContentLoading').show();
	var surl='module=Settings&action=SettingsAjax&file=SelectColppick&css_type='+css_type;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'SocialPromotion',"","","","");
	var divid = popupobj.divid;
	var _css_type = CrmPopup.findHtmlobj(divid,css_type).val();
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
				ld('#rptContentLoading').hide();
				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth350px",'Settings',"",'',"",'');
				crmPopupobj.show(data.result.content);
				var _color = '';
				var divid = crmPopupobj.divid;
				CrmPopup.findHtmlobj(divid,'picker').colpick({
					color:_css_type,
					flat:true,
					layout:'RGB',
					submitText:'确认',
					onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
						_color = '#'+hex;
						var popupobj=CrmPopup.getPopupObj("lastprev");
						var prev_divid=popupobj.divid;
						CrmPopup.findHtmlobj(prev_divid,css_type).val(_color);
						CrmPopup.findHtmlobj(prev_divid,'div_'+css_type).css('background',_color);
						crmPopupobj.CancelEvent();
					}
				});
			}
		}
	})
}

// 商城小程序 新建编辑
function  editMallBanner(record,type) {
	if(ld('#selfconfig_module_div tr[tag=module]').length >=5){
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['wxmall_banner_add']);
		return false;
	}
	var surl='index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_banner_setting_edit&record='+record+'&type='+type;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1)
		{
			currencies = data.result.currencies;
			crmPopupobj.setParams(data.result.title,saveMallBanner,"","LdPopWidth500px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);

		}
	})
}
// 保存
function saveMallBanner() {
	var popupobj=CrmPopup.getPopupObj("last");
	if(ld('#'+popupobj.divid +' [name=wxmall_banner_path]').val() == ''){
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['wxmall_banner_file_js']);
		return false;
	}
	if(ld('#'+popupobj.divid +' [name=wxmall_banner_url]').val()  == ''){
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['wxmall_banner_path_js']);
		return false;
	}
	var form = ld('#'+popupobj.divid+' [name=addMallBannerForm]')[0];
	var formdata = new FormData(form);
	ld.ajax({
		url: "index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_banner_save&type=save",
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: formdata,
		success: function(data){
			if(data.code ==1){
				mallBannerRefresh()
			}
		}
	});
	popupobj.CancelEvent();
}
//页面链接帮助页面
function getMallBannerUrl() {
	var surl='index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_banner_url';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1)
		{
			currencies = data.result.currencies;
			crmPopupobj.setParams(data.result.title,saveCurreny,"","LdPopWidth500px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);

		}
	})
}
//刷新
function mallBannerRefresh(){
	var surl = 'index.php?module=Settings&action=wechat_minimall_banner_setting&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
		DelProgressObjs();
	})
}

//向上向下移动
function mallBanner_moveupmodule(obj,type,id){

	var boforeval = ld(obj).parent().prev().prev().find('input').val();
	var mhtml = ld(obj).parent().parent().html();
	var trhtml = "<tr tag='module' class='lvtColData'>"+mhtml+"</tr>";
	if(type=='up'){
		ld(obj).parent().parent().prev().before(trhtml);
		//ld(obj).parent().parent().prev().prev().find('input').val(boforeval);
	}else{
		ld(obj).parent().parent().next().after(trhtml);
		//ld(obj).parent().parent().next().next().find('input').val(boforeval);
	}
	ld(obj).parent().parent().remove();

	var trLength = ld('.listEntries').find('tr[tag="module"]').length;
	ld('.listEntries').find('tr[tag="module"]').each(function (i) {
		if(i===0){
			ld(this).find('a[tag="move_up"] ').hide();
			ld(this).find('a[tag="move_down"]').show();
		}else if(i+1===trLength){
			ld(this).find('a[tag="move_up"]').show();
			ld(this).find('a[tag="move_down"]').hide();
		}else{
			ld(this).find('a[tag="move_up"]').show();
			ld(this).find('a[tag="move_down"]').show();
		}
		ld(this).find('td').eq(0).html(i+1);
	});
	// 更新图片排序
	updateMiniMallBannerSequence(id,type);
}
// 更新banner排序
function updateMiniMallBannerSequence(id,type) {
	var url='index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_banner_sequence';
	ld.ajax({
		url: url,
		type: 'POST',
		dataType: 'json',
		data: {id:id,type:type},
		success: function(res){
		}
	});
}
// 删除banner
function deleteMallBanner(id) {
	if(ld('#selfconfig_module_div tr[tag=module]').length <=1){
		RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['wxmall_banner_delete']);
		return false;
	}
	var url='index.php?module=Settings&action=SettingsAjax&file=wechat_minimall_banner_save';
	ld.ajax({
		url: url,
		type: 'POST',
		dataType: 'json',
		data: {id:id,type:'delete'},
		success: function(res){
			if(res.code==1){
				mallBannerRefresh()
			}
		}
	});
}
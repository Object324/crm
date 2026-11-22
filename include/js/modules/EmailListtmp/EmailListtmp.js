function EmailTemplate(){
   var that=this;
   this.ue = '';
}
EmailTemplate.refresh = function(){
	var urlstring = "module=EmailListtmp&action=EmailListtmpAjax&file=index&ajax=true";
	//alert(urlstring);
	RequestAjax(urlstring,function(rest){
		//ld('#pagecontent').html('<div class="wrapper-panel-inner">'+rest+'</div>');//原bug
		// 0041728: （https://61mis.com/kfbcrm [^]）邮件模板，新增/编辑邮件模板保存后，切换模块，界面没有切换，仍显示邮件模板列表
		listcontentobj.html(rest);
		// ld("#pagecontent .wrapper-panel-inner").html(rest);  //同上等效
		DelProgressObjs();
		//alert(rest);
	})
}
//邮件模版 - 新增
EmailTemplate.create = function(){
	var surl='index.php?module=EmailListtmp&action=EmailListtmpAjax&file=createemailtemplate';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","1000",'EmailListtmp',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,EmailTemplate.save,"","1000",'EmailListtmp',"",data.result.oktext,"",data.result.canceltext,"");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			var templatepopid = crmPopupobj.divid;
			// ld('#'+templatepopid+'_olayernodeid').css('z-index','700');
			// ld('#'+templatepopid).css('z-index','701');
			//crmPopupobj.show(data.result.content);
			EmailTemplate.ue = UE.getEditor('emailbody');
			EmailTemplate.ue.ready(function() {
				var id=ld('#emailbody').children("div:first-child").attr("id");
				ld('#'+id).css('z-index','99999');
				crmPopupobj.center();
			},400);
		}
	})
}
//邮件模版 - 编辑
EmailTemplate.edit= function(templateid){
	var surl='index.php?module=EmailListtmp&action=EmailListtmpAjax&file=editemailtemplate&templateid='+templateid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","1000",'EmailListtmp',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,EmailTemplate.save,"","1000",'EmailListtmp',"",data.result.oktext,"",data.result.canceltext,"");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			var templatepopid = crmPopupobj.divid;
			ld('#'+templatepopid+'_olayernodeid').css('z-index','1000');
			ld('#'+templatepopid).css('z-index','1001');
			EmailTemplate.ue = UE.getEditor('emailbody');
			setTimeout(function () {
				EmailTemplate.ue.ready(function() {
					crmPopupobj.center();
				},0);
			},500);
		}
	})
}
//邮件模版 - 保存
EmailTemplate.save = function(){
	//saveemailtemplate
	var popupobj=CrmPopup.getPopupObj("last");
	var templatename = ld("#"+popupobj.divid+" [name=templatename]").val();
	if(templatename == ''){
		var confirm_str = ld("#"+popupobj.divid+" [name=templatename]").attr('tag') + arrJsPopLabel['CANOTEMPTYGTH'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var data = new FormData(ld(".template_ajaxform")[0]);
	var popupobj=CrmPopup.getPopupObj("last");
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=EmailListtmp&action=EmailListtmpAjax&file=saveemailtemplate',
		success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
			EmailTemplate.refresh();
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })

}
//邮件模版 - 删除
EmailTemplate.del = function(templateid){
    var objdiv_content = arrJsPopLabel['SUREWANTDELETE'];//提示内容
	MessagePopup.TipTwo_warning(objdiv_content);
	var popupobj = CrmPopup.getPopupObj('last');
	ld('#'+popupobj.divid).find('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var urlstring = 'module=EmailListtmp&action=EmailListtmpAjax&file=deleteemailtemplate&parenttab=Marketing&templateid='+templateid;
		ldAjaxHtml('index.php?',urlstring,function (rest) {
			DelProgressObjs();
			EmailTemplate.refresh();
		})
	});
}

//邮件模版 - 查看
EmailTemplate.view = function(templateid){
	var surl='index.php?module=EmailListtmp&action=EmailListtmpAjax&file=detailviewemailtemplate&templateid='+templateid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'EmailListtmp',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,EmailTemplate.cancel,"","LdPopWidth800px",'EmailListtmp',"",data.result.oktext,"","","");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
		}
	})
}

EmailTemplate.cancel = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}
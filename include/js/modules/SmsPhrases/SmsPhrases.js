//index.php?module=SmsPhrases&action=DetailViewSMSTemplate&parenttab=Marketing&templateid=&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}
function ViewSMSTemplate(templateid){
	var surl='index.php?module=SmsPhrases&action=SmsPhrasesAjax&file=DetailViewSMSTemplate&parenttab=Marketing&templateid='+templateid;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'SmsPhrases',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,CancelSMSTemplate,"","LdPopWidth800px",'SmsPhrases',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
			updateSymbolAndCode();
		}
	})
}

function CancelSMSTemplate(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
}
// 同步短信模板
function SyncSMSTemplate(){
	// RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHECKINSETTING_REMIND1']);//BUG20241213-13 去掉第一层弹窗

	var urlstring = 'index.php?module=SmsPhrases&action=SmsPhrasesAjax&file=SaveSMSTemplate&ajax=true&operationtype=syncsms';
	ldAjax(urlstring,'',function(data){
		// var popupobj=CrmPopup.getPopupObj("last");
		// popupobj.CancelEvent();//关闭同步提示框

		if(data.code == 1){
			getListViewAjax();
			SmsContentSetting.getInstance().getSmsTemplateList();//BUG20241213-41 猜测可能是模板缓存，导致新同步过来的模板  群发没显示 ，同步模板后更新一下看看
			MessagePopup.TipOne_success(arrJsPopLabel['Synchronizedsuccess']);
		}else{
			MessagePopup.TipOne_warning(data.msg);
			return false;
		}
		DelProgressObjs();

	})
}
function EditSMSTemplate(templateid){
	ld('#rptContentLoading').show();
	var surl='module=SmsPhrases&action=SmsPhrasesAjax&file=EditSMSTemplate&parenttab=Marketing&templateid='+templateid;
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
        success: function(data)
        {
			
            if(data.code==1)
            {
                //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
                //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
				ld('#rptContentLoading').hide();
				currencies = data.result.currencies;
                crmPopupobj.setParams(data.result.title,SaveSMSTemplate,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);  
                crmPopupobj.show(data.result.content);
				// updateSymbolAndCode();
			}
		}
	})
}

function SaveSMSTemplate(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var templatename = CrmPopup.findHtmlobj(divid,'templatename').val();
	var templateid = CrmPopup.findHtmlobj(divid,'templateid').val();
	var template_type = ld("input[name='template_type']:checked").val();
	var templatebody = CrmPopup.findHtmlobj(divid,'body').val();
	if(templatename==''){
		var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if(templatebody==''){
		var confirm_str = arrJsPopLabel['CONTENTCANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var urlstring = "module=SmsPhrases&action=SaveSMSTemplate&ajax=true&templatename="+templatename+"&templateid="+templateid;
	urlstring += '&template_type='+template_type+'&body='+templatebody;

	RequestAjax(urlstring,function(rest){
		popupobj.CancelEvent();
		ld('#rptContentLoading').hide();
		DelProgressObjs();
        if(ld('#listsms_entries').length>0)
		      getListViewAjax();
        else
        {
            window.location.reload();
        }
	})
}

function getListViewAjax(){
	var urlstring = "module=SmsPhrases&action=SmsPhrasesAjax&file=index&ajax=true";
	//alert(urlstring);
	RequestAjax(urlstring,function(rest){
		ld('#listsms_entries').html(rest);
		DelProgressObjs();
		//alert(rest);
	})
}

function deleteListtmp(templateid,blockid,fieldid,module){
    var objdiv_content = arrJsPopLabel['SUREWANTDELETE'];//提示内容
	MessagePopup.TipTwo_warning(objdiv_content);
	var popupobj = CrmPopup.getPopupObj('last');
	ld('#'+popupobj.divid).find('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		if(module =='EmailListtmp')//邮件模板删除
			window.location.href='index.php?module='+module+'&action=deleteemailtemplate&parenttab=Marketing&templateid='+templateid+'&blockidsetting='+blockid+'&fieldidsetting='+fieldid;
		else {//短信模板删除
			var urlstring = 'module=' + module + '&action=' + module + 'Ajax&file=deletesmstemplate&parenttab=Marketing&templateid=' + templateid + '&blockidsetting=' + blockid + '&fieldidsetting=' + fieldid;
			ldAjaxHtml('index.php?', urlstring, function (rest) {
				DelProgressObjs();
				getListViewAjax();
			})
		}
	});
}
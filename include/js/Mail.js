/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//added by raju for emails

function eMail(module,oButton) {
	var select_options = document.getElementById('allselectedboxes').value;    
	var excludedRecords = document.getElementById("excludedRecords").value;
	var numOfRows = document.getElementById('numOfRows').value;
	var searchurl = document.getElementById('search_url').value;
	var viewid = getviewId();
	var url = "&viewname="+viewid+"&excludedRecords="+excludedRecords+"&searchurl="+searchurl;
	//Added to remove the semi colen ';' at the end of the string.done to avoid error.
	var idstring = "";

	if(select_options == 'all'){

        document.getElementById('idlist').value=idstring;
        allids = select_options;
		var count=numOfRows;

    } else {
		var x = select_options.split(";");
		var count=x.length;
		select_options=select_options.slice(0,(select_options.length-1));
   
		if (count > 1) {
			idstring=select_options.replace(/;/g,':')
			document.getElementById('idlist').value=idstring;
		}
		else {
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
		var allids = document.getElementById('idlist').value;
	}

	if(count > getMaxMassOperationLimit()) {
		var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
		if(confirm(confirm_str)) {
			var confirm_status = true;
		} else {
			return false;
		}
	} else {
		confirm_status = true;
	}

	if(confirm_status){
		fnvshobj(oButton,'sendmail_cont');
		sendmail(module,allids,url);
	}
}
//added by kevin for groupemail
function groupEmail(module,oButton){
    var select_options = document.getElementById('allselectedboxes').value;
    if(select_options == 'all'){
        document.getElementById('idlist').value=idstring;
        allids = select_options;
    } else {
		var x = select_options.split(";");
		var count=x.length;
		select_options=select_options.slice(0,(select_options.length-1));   
		if (count > 1) {
			idstring=select_options.replace(/;/g,',')
			document.getElementById('idlist').value=idstring;
		}
		else {
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
		var allids = document.getElementById('idlist').value;
	}
    if(allids.length>0)
    //location.href='index.php?module=Emails&action=GroupEmail&parenttab=Marketing&return_module='+module+'&select_options='+allids;
    url='index.php?module=Emails&action=GroupEmail&parenttab=Marketing&return_module='+module+'&select_options='+allids;
    openPopUp('xComposeEmail',this,url,'createemailWin',1024,768,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}

function massMail(module) {

	var select_options  =  document.getElementsByName('selected_id');
	x = select_options.length;
	var viewid =getviewId();		
	idstring = "";

	xx = 0;
	for(i = 0; i < x ; i++)
	{
		if(select_options[i].checked)
		{
			idstring = select_options[i].value +";"+idstring
				xx++
		}
	}
	if (xx != 0)
	{
		document.getElementById('idlist').value=idstring;
	}
	else
	{
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
		return false;
	}
	document.massdelete.action="index.php?module=CustomView&action=SendMailAction&return_module="+module+"&return_action=index&viewname="+viewid;
}

//added by rdhital for better emails
function set_return_emails(entity_id,email_id,parentname,emailadd,emailadd2,perm){

    
	if(perm == 0 || perm == 3) {
		if(emailadd2 == '')	{			
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",alert_arr.LBL_DONT_HAVE_EMAIL_PERMISSION);
			return false;
		}
		else
			emailadd = emailadd2;
	} else {
		if(emailadd == '')
			emailadd = emailadd2;
	}	

	if(emailadd != '') {
		var inputs = '';
		if(typeof(window.document.sendSMS) != 'undefined'){
			inputs = window.document.sendSMS;
			if(typeof(inputs.receivephone) != 'undefined'){
				inputs.receivephone.value = inputs.receivephone.value+emailadd+'<'+parentname+'>\r\n';
			}
			if(typeof(inputs.hidden_toid) != 'undefined'){
				inputs.hidden_toid.value = emailadd+','+inputs.hidden_toid.value;
			}
		}else if(typeof(window.document.EditView) != 'undefined'){
			inputs = window.document.EditView;
			if(typeof(inputs.parent_id) != 'undefined'){
				inputs.value = inputs.parent_id.value+entity_id+'@'+email_id+'|';
			}
			if(typeof(inputs.parent_name) != 'undefined'){
				inputs.parent_name.value = inputs.parent_name.value+parentname+'<'+emailadd+'>;';
			}
			if(typeof(inputs.hidden_toid) != 'undefined'){
				inputs.hidden_toid.value = emailadd+','+inputs.hidden_toid.value;
			}
		}
		var popupobj=CrmPopup.getPopupObj("last");
		popupobj.CancelEvent();
	} else {
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",parentname+arrJsPopLabel['DOESNOT_HAVE_AN_MAILID']);
		return false;
	}
}
//by ld kevin groupemail add tomail

//added by raju for emails

function validate_sendmail(idlist,module){
	var j=0;
    var popupobj=CrmPopup.getPopupObj('last');
    
	if(idlist == 'all'){
		var viewid = $('viewid').value;
		var excludedRecords = $("excludedRecords").value;
		var numOfRows = $('numOfRows').value;
		var searchurl = $('search_url').value;
		var url1 = "&sendmail=sendmail&viewname="+viewid+"&excludedRecords="+excludedRecords+"&searchurl="+searchurl;
	} else if(idlist == 'relatedListSelectAll'){
		var recordid = $('recordid').value;
		var excludedRecords = $('excludedRecords').value;
		url1 = "&recordid="+recordid+"&excludedRecords="+excludedRecords;
	} else {
		url1 = '';
	}
	var chk_emails = ld("#"+popupobj.divid+" input[type=checkbox]");

	email_type = new Array();
    var j=0;
	for(var i=0 ;i < chk_emails.length ;i++) {
	       
			if(ld(chk_emails[i]).get(0).checked != false){
				email_type [j++]= ld(chk_emails[i]).val();
			}
		
	}
	if(email_type != '') {
        
		var field_lists = email_type.join(':');
	//	var url= 'index.php?module=Emails&action=EditView&pmodule='+module+'&sendmail=true&idlist='+idlist+'&field_lists='+field_lists+url1;
        
        var page_addurl=encodeURIComponent('&pmodule='+module+'&sendmail=true&idlist='+idlist+'&field_lists='+field_lists+url1);
        
        var url= 'index.php?pageto_module=Emails&pageto_action=EditView&page_addurl='+page_addurl;
       
	   window.open(url,'xComposeEmail');
       
        	//openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
		//fninvshnew('roleLay');
		return true;
	} else {
		RemindsMsg("","LdPopWidth400px",'',"yes","yes",alert_arr.SELECT_MAILID);
	}
}
validate_sendmail.funname='validate_sendmail';
function sendmails(module,idstrings) {
    EmptyProgressObjs();
    
    ldAjax("index.php?module=Emails&return_module="+module+"&action=EmailsAjax&file=mailSelect&idlist="+idstrings,{},function(data){
            if(data.result.code==-1)
				{
            				  puyoungJS_DialogBox.unblock();
            				  var url= 'index.php?module=Emails&action=EditView&pmodule='+module+'&sendmail=true';
                        window.open(url,'xComposeEmail','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
            					// openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
            				  
				}
				else if (data.code==-2){
					MessagePopup.TipOne_warning(data.result.modulename+arrJsPopLabel['ModuleHasNoEmailField'])//BUG0073237 xxy 2023-9-25 市场活动-单据详情页-相关信息栏销售线索-选择了一条单据后，点击发送邮件，还会提示“请至少选择一条记录！”
				}
				else{		
				 
    				    
                        var popupobj=CrmPopup.load(data.result.title,validate_sendmail,"",500,"Emails",[idstrings,module],data.result.oktext,"",data.result.canceltext);
                        CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
                        
    
				}  
        
            DelProgressObjs();
    })
	/*new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: "module=Emails&return_module="+module+"&action=EmailsAjax&file=mailSelect&idlist="+idstrings,
			onComplete: function(response) {
			     
				if(response.responseText == "Mail Ids not permitted" || response.responseText == "No Mail Ids")
				{
        				  puyoungJS_DialogBox.unblock();
        				  var url= 'index.php?module=Emails&action=EditView&pmodule='+module+'&sendmail=true';
                    window.open(url,'xComposeEmail','menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        					// openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
        				  
                }
				else{		
				    
                    var popupobj=CrmPopup.load((headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText))
					//getObj('sendmail_cont').innerHTML = response.responseText;
//					fnvshobj('', 'sendmail_cont');
					// puyoungJS_DialogBox.block();
					// Drag.init(document.getElementById("roleLayHeading"), document.getElementById("sendmail_cont"));
					// set_cookie(relmod+"_all","");
				}           
			}
		}
	);*/
}

function rel_eMail(module,oButton,relmod){
	var allids='';
	if($(module+'_'+relmod+'_selectallActivate').value == 'true'){
		var recordid = document.getElementById('recordid').value;
		var excludedRec = $(module+'_'+relmod+'_excludedRecords').value;
		allids = 'relatedListSelectAll';
		var url = "&parent_module=Campaigns&excludedRecords="+excludedRec+"&recordid="+recordid;
	} else {
		var select_options = '';
		var cookie_val = get_cookie(relmod+"_all");
		if(cookie_val != null)
			select_options = cookie_val;
		//Added to remove the semi colen ';' at the end of the string.done to avoid error.
		var x = select_options.split(";");
		var viewid = '';
		var count = x.length
		var idstring = "";
		select_options = select_options.slice(0,(select_options.length-1));

		if (count > 1){
			idstring=select_options.replace(/;/g,':')
			allids=idstring;
		} else {
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
	}
	fnvshobj(oButton,'sendmail_cont');
	sendmail(relmod,allids,url);
	
}
function selectMailPopup(module,popup_url,selectmodule){
	if($("status") != undefined)
		$("status").style.display="inline";
	ld.ajax({
		url: 'index.php?'+popup_url+'&selectmodule='+selectmodule,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				if($("status") != undefined)
					$("status").style.display="none";
				var crmPopupobj=CrmPopup.load(data.result.title,"","","LdPopWidth950px",module,'','',"",'');  
				crmPopupobj.show(data.result.content);
				var bodyEditor = UE.getEditor('description1');
				window.setTimeout(function(){
					var id=ld('#description1').children("div:first-child").attr("id");
					ld('#'+id).css('z-index','99999');
					crmPopupobj.center();
				},200);
			}
		}
	})
}
//发送邮件  - 选择收件人
function selModulePopup(){
	var parent_type = document.EditView.parent_type.value;
	var surl = "module="+ parent_type +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_emails&select=enable&popup=yes&page_popup=yes";
	CrmPopupWindow('Emails',surl,parent_type);
}

//发送邮件 - 选择邮件模板
function openEmailTemplates(obj){
	 
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth950px",'Emails',"","","","");
	crmPopupobj.prevshow();
   
	ld.ajax({
		url: 'index.php?module=Users&action=UsersAjax&file=lookupemailtemplates',
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth950px",'Emails',"","","","");  
				crmPopupobj.quickcreatehtml=data.result.content;
				crmPopupobj.show(data.result.content);
			}
		}
	})
	return false;
}

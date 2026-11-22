/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 
function updateCampaignRelationStatus(relatedmodule, campaignid, crmid, campaignrelstatusid, campaignrelstatus)
{
	$("vtbusy_info").style.display="inline";
	document.getElementById('campaignstatus_popup_' + crmid).style.display = 'none';
	var data = "action=updateRelationsAjax&module=Campaigns&relatedmodule=" + relatedmodule + "&campaignid=" + campaignid + "&crmid=" + crmid + "&campaignrelstatusid=" + campaignrelstatusid;
	new Ajax.Request(
		'index.php',
			{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: data,
			onComplete: function(response) {
				if(response.responseText.indexOf(":#:FAILURE")>-1)
				{
					var confirm_str = alert_arr.ERROR_WHILE_EDITING;
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				}
				else if(response.responseText.indexOf(":#:SUCCESS")>-1)
				{
					document.getElementById('campaignstatus_' + crmid).innerHTML = campaignrelstatus;
					$("vtbusy_info").style.display="none";
				}
			}
		}
	);
}

function rel_toggleSelectAll_Records(module,relmodule,state,relCheckName) {

	 rel_toggleSelect(state,relCheckName,relmodule);
	 if(state == true) {
		$(module+'_'+relmodule+'_selectallActivate').value = 'true';
		$(module+'_'+relmodule+'_selectAllRec').style.display = 'none';
		$(module+'_'+relmodule+'_deSelectAllRec').style.display = 'inline';
	} else {
		$(module+'_'+relmodule+'_selectallActivate').value = 'false';
		$(module+'_'+relmodule+'_excludedRecords').value = '';
		$(module+'_'+relmodule+'_selectCurrentPageRec').checked = false;
		$(module+'_'+relmodule+'_selectAllRec').style.display = 'inline';
		$(module+'_'+relmodule+'_deSelectAllRec').style.display = 'none';
		$(module+'_'+relmodule+'_linkForSelectAll').hide();
	}
}


function set_return_specific_campaign(campaign_id, campaign_name) {
	var fldName = getOpenerObj("campaigns_name");
        var fldId = getOpenerObj("campaignid");
        fldName.value = campaign_name;
        fldId.value = campaign_id;
}

function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
}
}

function set_return_todo(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.task_parent_name.value = product_name;
        window.opener.document.QcEditView.task_parent_id.value = product_id;
	} else {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}
}

/**
 * 群发邮件
 * @author Tujt 2015-07-16
 */
function rel_eMail_click(module,oButton,relmod){
/*	var relName = 'Campaigns_Accounts_selected_id';
	if('Contacts' == relmod){
		relName = 'Campaigns_Contacts_selected_id';
	}*/
    //22474: 市场活动明细界面：相关信息-客户，勾选“标题行-□”，没有全选本页单据
    
    //bug:22742 市场活动明细界面：相关信息-联系人，勾选单据，点击【发送邮件】，不应该弹出提示“请至少选择一条记录！”
    //edit:cyb date:2016-06-01
    if(relmod == 'Accounts'){
         var relName='selected_id';
    }
	if(relmod == 'Leads'){//BUG0073237 xxy 2023-9-25 市场活动-单据详情页-相关信息栏销售线索-选择了一条单据后，点击发送邮件，还会提示“请至少选择一条记录！”
		var relName=module+'_'+relmod+'_selected_id';
   }
    if(relmod == 'Contacts'){
        var relName=module+'_'+relmod+'_selected_id';
    }
	var allids = '';
	if(ld('[name='+relName+']:checked').length > 0){
		ld('[name='+relName+']:checked').each(function(key,val){
		  //38448: （1.6）市场活动模块明细界面>相关客户：勾选单据点击群发邮件，报错
			allids += ld(val).val()+',';
		});
	}else{
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	// diony 20200707
	// 0041818: （https://61mis.com/kfbtest [^]）市场活动查看详情界面，相关信息客户界面，勾选单据点击【发送邮件】点不动
	// 注释下面这一行
	// fnvshobj('','sendmail_cont');
	getJsScript('include/js/Mail.js',function(){
		sendmail(relmod,allids,'');
	});
}
function changeRelAccountStatus(campaignid,accountid,relatedid)
{
    
    var popupobj=CrmPopup.getPopupObj("last");
    
  //  var campaignaccountrelstatus=document.getElementById('campaignaccountrelstatus').options[document.getElementById('campaignaccountrelstatus').selectedIndex].value;
  //alert(CrmPopup.findHtmlobj(popupobj.divid,'cmb_span_optiontext_campaignaccountrelstatus').text());
	var campaignaccountrelstatus=CrmPopup.findHtmlobj(popupobj.divid,'cmb_span_optiontext_campaignaccountrelstatus').val();

    var cur_page = 1;
     new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=Campaigns&action=CampaignsAjax&file=ChangeAccountStatus&mode=ajax&campaignid="+campaignid+"&accountid="+accountid+"&status="+encodeURIComponent(campaignaccountrelstatus),
			onComplete: function(response) {
				// document.getElementById("camaigns_account_status").innerHTML=response.responseText;

				//fnvshobj(obj, "camaigns_account_status");
				//document.getElementById("refresh-Accounts").click();
				popupobj.CancelEvent();
				var viewid = 0;
				ld('#rel-left-div-'+relatedid+' .DivC .Category ul li').each(function(){
					var _class = ld(this).attr('class');
					if(_class == 'currdataClass'){
						viewid = ld(this).attr('viewid');
						return false
					}
				});
				if(ld('#hidden_start') != undefined){
					cur_page = ld('#hidden_start').val();	
				}
				changeCampaignStatus(viewid,relatedid,cur_page)
			 }
       });
}
changeRelAccountStatus.funname='changeRelAccountStatus';

/**
修改市场活动关联的客户状态
**/
function PopchangeRelAccountStatus(obj,campaignid,accountid,relatedid)
{
    
    ld.ajax(
		
    		{
    			type: 'POST',
    			url: "index.php?"+"module=Campaigns&action=CampaignsAjax&file=PopAccountStatus&mode=ajax&campaignid="+campaignid+"&accountid="+accountid+'&relatedid='+relatedid,
                 dataType:'json',
    			success: function(data) {
        			 $("status").style.display="none";
                    
                     if(data.code==1)
    			     {
    			           var jspopup=[];
                         jspopup.push(campaignid);
                         jspopup.push(accountid);
                         jspopup.push(relatedid);
                         var crmpopupobj=CrmPopup.load(data.result.title,changeRelAccountStatus,"","LdPopWidth450px","Campaigns",jspopup,data.result.oktext,"",data.result.canceltext);
                         crmpopupobj.setOkfunParamObj(jspopup);
                         crmpopupobj.show(data.result.content);
                         var cls_picklistobj=new cls_picklist(data.result.fieldname,data.result.statuscombox);
                         crmpopupobj.picklistobjarray=[];
                         crmpopupobj.picklistobjarray[data.result.fieldname]=cls_picklistobj;
                         crmpopupobj.picklist_arrow_click=function(event,fieldname)
                           {
                           
                               cmb_fldname=fieldname;//用于picklist.js中document.onclick调用
                               cmb_parentdivid=this.divid;//用于picklist.js中document.onclick调用
                              crmpopupobj.picklistobjarray[fieldname].arrow_click(fieldname);
                              
                           }
                         
    			     }
                    
    			}
    		}
		);
        
    
       
}

function changeCampaignStatus(viewid,relatedid,cur_page){
	//if(document.DetailView){
//		var header = document.DetailView.module.value;
//		var record = document.DetailView.record.value;
//	}else if(document.EditView){
//		var header = document.EditView.module.value;
//		var record = document.EditView.record.value;
//	}else{
//		return;
//	}
   
    var detailViewPopupObj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    var header = detailViewPopupObj.module;
		var record = detailViewPopupObj.record;
	if(empty(cur_page))cur_page = 1;
//	var urldata = "&header="+header+"&record="+record+"&viewid="+viewid;
//	urldata += "&relatedid="+relatedid+"&start="+cur_page+"&related_left_type=1";
//	urldata += '&switchview='+viewid;
     var popupobj=CrmPopup.getPopupObj('last');
     
	if(ld('#select_campaignaccountrelstatus') != undefined){
	//	urldata += '&select_campaignaccountrelstatus='+ld('#select_campaignaccountrelstatus').val();
    //edit:can 2020-10026 43027: 市场活动->相关信息->客户，“状态”搜索默认为空，选择其他查询选项之后，无法选回“空”
        popupobj.otherurl='&select_campaignaccountrelstatus='+ld('#select_campaignaccountrelstatus').val();
	}
	//setRelListAjax(urldata,relatedid);
   
  
    DetailViewRelation.searchByPopupobj(popupobj);
}
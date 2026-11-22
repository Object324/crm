/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/		
		


document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");
function toggleDisplay(id){
		
if(this.document.getElementById( id).style.display=='none'){
	this.document.getElementById( id).style.display='inline'
	this.document.getElementById(id+"link").style.display='none';
					
}else{
	this.document.getElementById(  id).style.display='none'
	this.document.getElementById(id+"link").style.display='none';
	}
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

function add_data_to_relatedlist_incal(id,name)
{
	var idval = window.opener.document.EditView.contactidlist.value;
	var nameval = window.opener.document.EditView.contactlist.value;
	if(idval != '')
	{
		if(idval.indexOf(id) != -1)
                {
                        window.opener.document.EditView.contactidlist.value = idval;
                        window.opener.document.EditView.contactlist.value = nameval;
                }
                else
                {
                        window.opener.document.EditView.contactidlist.value = idval+';'+id;
			if(name != '')
                	{
				// this has been modified to provide delete option for Contacts in Calendar
				//this function is defined in script.js ------- Jeri
				window.opener.addOption(id,name);
                	}

                }
	}
	else
	{
		window.opener.document.EditView.contactidlist.value = id;
		if(name != '')
		{
			window.opener.addOption(id,name);
		}
		//end
	}
}
function set_return_specific(product_id, product_name) {
        //Used for DetailView, Removed 'EditView' formname hardcoding
        var fldName = getOpenerObj("contacts_name");
        var fldId = getOpenerObj("contact_id");
        fldName.value = product_name;
        fldId.value = product_id;
}
//only for Todo
function set_return_toDospecific(product_id, product_name) {
        var fldName = getOpenerObj("task_contact_name");
        var fldId = getOpenerObj("task_contact_id");
        fldName.value = product_name;
        fldId.value = product_id;
}

function submitform(id){
		document.massdelete.entityid.value=id;
		document.massdelete.submit();
}	

function searchMapLocation(addressType)
{
        var mapParameter = '';
        if (addressType == 'Main')
        {
		if(fieldname.indexOf('mailingstreet') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstreet')]))	
				mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstreet')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingcity') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcity')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcity')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingstate') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstate')]))
	                        mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingstate')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingcountry') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcountry')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingcountry')]).innerHTML+' ';
		}
		if(fieldname.indexOf('mailingzip') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingzip')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('mailingzip')]).innerHTML;
		}
        }
        else if (addressType == 'Other')
        {
		if(fieldname.indexOf('otherstreet') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstreet')]))
				mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstreet')]).innerHTML+' ';
		}
		if(fieldname.indexOf('othercity') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercity')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercity')]).innerHTML+' ';
		}
		if(fieldname.indexOf('otherstate') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstate')]))
	                        mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherstate')]).innerHTML+' ';
		}
                if(fieldname.indexOf('othercountry') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercountry')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('othercountry')]).innerHTML+' ';
		}
                if(fieldname.indexOf('otherzip') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherzip')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('otherzip')]).innerHTML;
		}
        }
	mapParameter = removeHTMLFormatting(mapParameter);
	window.open('http://maps.google.com/maps?q='+mapParameter,'goolemap','height=450,width=700,resizable=no,titlebar,location,top=200,left=250');
}
/**detailview_email_contact_show
更新操作
edit:cdw
date:20131120
reason:联系人详细界面群发邮件功能改进
**/
function detailview_email_contact_show()
{
  
     var allids=document.forms['DetailView'].record.value;
    $("status").style.display="inline";
          new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:"module=Contacts&action=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids,
        			onComplete: function(response) 
                    {
                    
                        $("status").style.display="none";
                        var results = response.responseText.split('&#&#&#');
                         $("Emailedit").innerHTML=results[1];
                         document.getElementById('Emailedit').style.display = 'block';
                        
                         
                    }
                }
          )
}
/**
更新操作
edit:cdw
date:20131120
reason:联系人详细界面群发短信功能改进
***/
function detailview_MassSMS_contact_show()
{
     var allids=document.forms['DetailView'].record.value;
    $("status").style.display="inline";
          new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:"module=Contacts&action=sendSMSField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids,
        			onComplete: function(response) 
                    {
                    
                        $("status").style.display="none";
                        var results = response.responseText.split('&#&#&#');
                         $("SMSedit").innerHTML=results[1];
                         document.getElementById('SMSedit').style.display = 'block';
                        
                         
                    }
                }
          )

}



//查看联系人上下级关系
var getContactHierarchy = function(contactid){
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_account_url = 'module=Users&action=UsersAjax&file=viewcontactinfo&popup_scopetype=private&popup_module=Contacts&contactid='+contactid+'&popup_selecttype=user';
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 104px;\'><div class=\'view-search\' ></div></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj('Contacts');
        scopepopupobj.popup_caption_value = arrJsPopLabel['Viewupperandlowerrelations'];//标题title
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		scopepopupobj.popup_header = '';
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = 'Contacts';//模块
		   cls_ScopePopup.prop.popup_url = popup_account_url;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		   ld('#'+cls_ScopePopup.popup_divid).attr('class','D_pop_box LdPopWidth500px ui-popup');
		   ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').hide();
		   ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_CLOSE']);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
					return false;
                });
            }
		});
	});
}

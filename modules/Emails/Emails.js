/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

var gFolderid = 2;
var gselectedrowid = 0;
function gotoWebmail()
{
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
                	method: 'post',
			postBody: "module=Webmails&action=WebmailsAjax&config_chk=true",
			onComplete: function(response) {
				if(response.responseText.indexOf('SUCCESS') > -1)
					window.location.href = "index.php?module=Webmails&action=index&parenttab=My Home Page";
				else
					$('mailconfchk').style.display = 'block';
					
			}
		}
	);

}
function set_return_groupemails(entity_id,email_id,parentname,emailadd,emailadd2,perm){
    if(perm == 0 || perm == 3) {
		if(emailadd2 == '')	{			
			RemindsMsg("","LdPopWidth400px",'',"yes","",alert_arr.LBL_DONT_HAVE_EMAIL_PERMISSION);
			return false;
		}
		else
			emailadd = emailadd2;
	} else {
		if(emailadd == '')
			emailadd = emailadd2;
	}	

	if(emailadd != '') {
	   if("parent_id" in document.EditView){
	       document.EditView.parent_id.value = document.EditView.parent_id.value+entity_id+'@'+email_id+'|';
	   }
		document.EditView.parent_name.value = document.EditView.parent_name.value+emailadd+'<'+parentname+'>\r\n';
		document.EditView.hidden_toid.value = emailadd+','+document.EditView.hidden_toid.value;
		cancelCrmPopup();
	} else {
		RemindsMsg("","LdPopWidth400px",'',"yes","",'"'+parentname+alert_arr.DOESNOT_HAVE_AN_MAILID);
		return false;
	}
}	
function getEmailContents(id,entitylistnum)
{
	$("status").style.display="inline";
	var rowid = 'row_'+id;
    onePageNum = $("onePageNum").value;//当前页邮件个数
    if(onePageNum < 11){
        $("rssScroll").className = 'emailListDiv0';
    }    
	gselectedrowid = id;
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Emails&action=EmailsAjax&file=DetailView&mode=ajax&record='+id,
			onComplete: function(response) {
						$("status").style.display="none";
						$("EmailDetails").innerHTML = response.responseText;
					}
			}
		);
}

function getListViewEntries_js(module,url)
{
	$("status").style.display="inline";
	if(document.getElementById('folderid') != undefined){
		url += '&folderid='+document.getElementById('folderid').value;
	}
	//alert(url);
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
                	method: 'post',
			postBody: "module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&"+url,
			onComplete: function(response) {
				$("status").style.display="none";
				$("email_con").innerHTML=response.responseText;
                gselectedrowid = 0;
				execJS(document.getElementById('email_con'));
			}
		}
	);

}

function massDelete()
{
	var delete_selected_row = false;
	//added to fix the issue 4295
	var select_options  =  document.getElementsByName('selected_id');
	var x = select_options.length;
	idstring = "";
	xx = 0;
	for(i = 0; i < x ; i++)
	{
		if(select_options[i].checked)
		{
			idstring = select_options[i].value +";"+idstring
			if(select_options[i].value == gselectedrowid)
			{
				gselectedrowid = 0;
				delete_selected_row = true;						
			}
			xx++
		}
	}
	var confirm_status = true;
	if (xx > 0)
	{
			document.massdelete.idlist.value=idstring;
			if(xx >= getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',xx,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
					idstring = '';
					for(i = 0; i < x ; i++){
						if(select_options[i].checked){
							if(i < getMaxMassOperationLimit()){
								idstring = select_options[i].value +";"+idstring
							}
						}
					}
				} else {
					confirm_status = false;
					return false;
				}
			}else{
				var confirm_str = arrJsPopLabel['SUREWANTDELETETHEDELECTED'] + xx + arrJsPopLabel['RECORDS'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					confrimMassDelete(delete_selected_row,gFolderid,idstring);
				});
				confirm_status = false;
			}
	}
	else
	{
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
	}
	if(confirm_status)
	{
		confrimMassDelete(delete_selected_row,gFolderid,idstring);
	}
	else
	{
		return false;
	}
}

function confrimMassDelete(delete_selected_row,gFolderid,idstring){		
	getObj('search_text').value = '';
	show("status");
	if(!delete_selected_row)
	{
		new Ajax.Request(
				'index.php',
				{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody: "module=Users&action=massdelete&folderid="+gFolderid+"&return_module=Emails&idlist="+idstring,
				onComplete: function(response) {
					$("status").style.display="none";
					if(empty(response.responseText)) return false;
					var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
					createElementDiv('mass_delete');//创建DIV
					ld('#mass_deletetitlename').html(restobj.title.value);
					sethtml(document.getElementById('mass_deletecontent'),restobj.log.value);
					ld('#mass_delete .D_pbtn .D_pbtncancel').css('display','none');
					ld('#mass_delete .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						fninvshnew('mass_delete');lingdangJS_DialogBox.unblock();
						execJS(document.getElementById('email_con'));
						getListViewEntries_js('Emails',restobj.start.value);//刷新页面
					});
					return false;
					$("status").style.display="none";
					//$("email_con").innerHTML=response.responseText;
					
				}
				}
				);
	}
	else	
	{
		new Ajax.Request(
				'index.php',
				{queue: {position: 'end', scope: 'command'},
						method: 'post',
						postBody: "module=Users&action=massdelete&folderid="+gFolderid+"&return_module=Emails&idlist="+idstring,
						onComplete: function(response) {
								$("status").style.display="none";
								if(empty(response.responseText)) return false;
								var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
								createElementDiv('mass_delete');//创建DIV
								ld('#mass_deletetitlename').html(restobj.title.value);
								sethtml(document.getElementById('mass_deletecontent'),restobj.log.value);
								ld('#mass_delete .D_pbtn .D_pbtncancel').css('display','none');
								ld('#mass_delete .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
									$('EmailDetails').innerHTML = '';
									//$("subjectsetter").innerHTML='';
									fninvshnew('mass_delete');lingdangJS_DialogBox.unblock();
									execJS(document.getElementById('email_con'));
									getListViewEntries_js('Emails',restobj.start.value);//刷新页面
								});
								return false;
								$("status").style.display="none";
									 /*   $("status").style.display="none";
										$("email_con").innerHTML=response.responseText;
										execJS($('email_con'));
										//$('EmailDetails').innerHTML = '<table valign="top" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td colspan="2">&nbsp;</td></tr></tbody></table></td></tr><tr><td style="padding-top: 10px;" height="284" valign="top"></td></tr></tbody></table>';
										$('EmailDetails').innerHTML = '';
										$("subjectsetter").innerHTML='';*/
						}
				}
		);
	}
}


function DeleteEmail(id)
{
	var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){

		getObj('search_text').value = '';
		gselectedrowid = 0;
		$("status").style.display="inline";
            new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: "module=Users&action=massdelete&return_module=Emails&folderid="+gFolderid+"&idlist="+id,
                onComplete: function(response) {
                    	var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
                    $("status").style.display="none";
                    /*
					$("email_con").innerHTML=restobj.log.value;
					execJS($('email_con'));
                    //$('EmailDetails').innerHTML = '<table valign="top" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td colspan="2">&nbsp;</td></tr></tbody></table></td></tr><tr><td style="padding-top: 10px;" height="284" valign="top"></td></tr></tbody></table>';
                    $('EmailDetails').innerHTML = '';
                    $("subjectsetter").innerHTML='';*/
                    document.location.reload();
                   
                    
                }
	     });
	})
        return false;
}
function Searchfn()
{
	gselectedrowid = 0;
	var osearch_field = document.getElementById('search_field');
	var search_field = osearch_field.options[osearch_field.options.selectedIndex].value;
	var search_text = document.getElementById('search_text').value;
	new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: "module=Emails&action=EmailsAjax&ajax=true&file=ListView&folderid="+gFolderid+"&search=true&search_field="+search_field+"&search_text="+search_text,
                onComplete: function(response) {
                	$("email_con").innerHTML=response.responseText;
	                $("status").style.display="none";
                    
                    //$('EmailDetails').innerHTML = '<table valign="top" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td colspan="2">&nbsp;</td></tr></tbody></table></td></tr><tr><td style="padding-top: 10px;" height="284" valign="top"></td></tr></tbody></table>';
                    $('EmailDetails').innerHTML = '';
                    $("subjectsetter").innerHTML='';
                    execJS($('email_con'));
                }
        }
   );
}

function getListViewCount(module,element,parentElement,url){
	if(module != 'Documents'){
		var elementList = document.getElementsByName(module+'_listViewCountRefreshIcon');
		for(var i=0;i<elementList.length;++i){
			elementList[i].style.display = 'none';
		}
	}else{
		element.style.display = 'none';
	}
	var elementList = document.getElementsByName(module+'_listViewCountContainerBusy');
	for(var i=0;i<elementList.length;++i){
		elementList[i].style.display = '';
	}
	var element = document.getElementsByName('search_url')[0];
	var searchURL = '';
	if(typeof element !='undefined'){
		searchURL = element.value;
	}else if(typeof document.getElementsByName('search_text')[0] != 'undefined'){
		element = document.getElementsByName('search_text')[0];
		var searchField = document.getElementsByName('search_field')[0];
		if(element.value.length > 0) {
			searchURL = '&query=true&searchtype=BasicSearch&search_field='+
				encodeURIComponent(searchField.value)+'&search_text='+encodeURIComponent(element.value);
		}
	}else if(document.getElementById('globalSearchText') != null &&
			typeof document.getElementById('globalSearchText') != 'undefined'){
            var searchText = document.getElementById('globalSearchText').value;
            searchURL = '&query=true&globalSearch=true&globalSearchText='+encodeURIComponent(searchText);
            if(document.getElementById('tagSearchText') != null && typeof document.getElementById('tagSearchText') != 'undefined'){
                var tagSearch = document.getElementById('tagSearchText').value;
                searchURL = '&query=true&globalSearch=true&globalSearchText='+encodeURIComponent(searchText)+'&tagSearchText='+encodeURIComponent(tagSearch);
            }
	}
	if(module != 'Documents'){
		searchURL += (url);
	}
	// Url parameters to carry forward the Alphabetical search in Popups,
	// which is stored in the global variable gPopupAlphaSearchUrl
	if(typeof gPopupAlphaSearchUrl != 'undefined' && gPopupAlphaSearchUrl != '')
		searchURL += gPopupAlphaSearchUrl;

	new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:"module="+module+"&action="+module+"Ajax&file=ListViewPagging&ajax=true"+searchURL,
				onComplete: function(response) {
					var elementList = document.getElementsByName(module+'_listViewCountContainerBusy');
					for(var i=0;i<elementList.length;++i){
						elementList[i].style.display = 'none';
					}
					elementList = document.getElementsByName(module+'_listViewCountRefreshIcon');
					if(module != 'Documents' && typeof parentElement != 'undefined' && elementList.length !=0){
						for(i=0;i<=elementList.length;){
							//No need to increment the count, as the element will be eliminated in the next step.
							elementList[i].parentNode.innerHTML = response.responseText;
						}
					}else{
						parentElement.innerHTML = response.responseText;
					}
				}
			}
	);
}

function goInWebMail(){
    var url='index.php?module=MailManager&action=index&parenttab=My Home Page&ahref=Settings';
    new Ajax.Request(
	        	'index.php',
	                {queue: {position: 'end', scope: 'command'},
	                	method: 'post',
	                        postBody:"module=Emails&action=EmailsAjax&file=Save&WebMail_check=true",
				onComplete: function(response) 
	            {
					 if(response.responseText.indexOf('SUCCESS') > -1)
					{
			  		 location.href=url;
					}else
					{
						//未检测到邮件账户，请先设置账户信息！
						var confirm_str = arrJsPopLabel['MAILACCOUNTNOTDETECTEDPLESEESET'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
							location.href="index.php?module=MailManager&action=index&parenttab=My Home Page#Settings";
						})
					}
	            }
             });
}
//列表选中变色
function listOnMouseOver(sel_id){
    var rows = "row_"+sel_id;
    if(document.getElementById(sel_id)!=undefined){
        if(document.getElementById(sel_id).checked){
            document.getElementById(rows).className = "lvtColDataSelected";
        }else{
            document.getElementById(rows).className = "lvtColDataHover";
        }
    }
    else{
        document.getElementById(rows).className = "lvtColDataHover";
    }
}
function listOnMouseOut(sel_id,type){
    var rows = "row_"+sel_id;
    if(document.getElementById(sel_id)!=undefined){
        if(document.getElementById(sel_id).checked){
            document.getElementById(rows).className = "lvtColDataSelected";
        }else{
            if(type == 'On'){
                document.getElementById(rows).className = "lvtColDataBj";
            }else{
                document.getElementById(rows).className = "lvtColData";
            }
        }
    }
    else{
        if(type == 'On'){
            document.getElementById(rows).className = "lvtColDataBj";
        }else{
            document.getElementById(rows).className = "lvtColData";
        }
    }
}
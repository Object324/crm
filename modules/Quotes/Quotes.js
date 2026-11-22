/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");


function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}

function set_return_specific(product_id, product_name) {
        
        var fldName = getOpenerObj("quotes_name");
        var fldId = getOpenerObj("quote_id");
        fldName.value = product_name;
        fldId.value = product_id;
        window.opener.document.EditView.action.value = 'EditView';
        window.opener.document.EditView.convertmode.value = 'update_quote_val';
	window.opener.document.EditView.submit();
	
}
function add_data_to_relatedlist(entity_id,recordid) {

        opener.document.location.href="index.php?module=Emails&action=updateRelations&destination_module=Accounts&entityid="+entity_id+"&parentid="+recordid;
}
function set_return_formname_specific(formname,product_id, product_name) {
        window.opener.document.EditView1.quotes_name.value = product_name;
        window.opener.document.EditView1.quote_id.value = product_id;
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


//报价单选择客户，如果客户有扣率则直接在产品明细中带出
function getAccountForDiscountRate(account_id,rowid){
    
	url = 'module=Accounts&action=AccountsAjax&file=getAccountForDiscountRate&accountid='+account_id;
	var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}
 

	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:url,
			onComplete: function(response) {		    
				var result=response.responseText;
              
				var rowcnt = parentwindow.document.getElementById('rowcnt').value;
				for(var i = 1; i<=rowcnt; i++){
					if(parentwindow.document.getElementById('discount_percent'+i) != undefined){
					  
					//	if(parentwindow.document.getElementById('discount_percent'+i).value <= 0 || parentwindow.document.getElementById('discount_percent'+i).value == ''){
						
                        	parentwindow.document.getElementById('discount_percent'+i).value =result;
					//	}
					}
				}
				//新增行时，不需要进行计划，只在切换客户时，进行赋值重新计算
				if(rowid <= 0){
				    
					parentwindow.fieldformulaobj.changediscountpercent();
				}
			}
		}
	);
}

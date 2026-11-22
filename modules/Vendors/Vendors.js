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
document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");
document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");

function check4null(form)
{
	var isError = false;
	var errorMessage = "";
	if (trim(form.productname.value) =='') 
	{
		isError = true;
		errorMessage += "\n Product Name";
		form.productname.focus();
	}
	if (isError == true) 
	{
		alert(alert_arr.MISSING_REQUIRED_FIELDS + errorMessage);
		return false;
	}
	return true;
}


function set_return_specific(vendor_id, vendor_name) 
{
        //getOpenerObj used for DetailView 
        var fldName = getOpenerObj("vendors_name");
        var fldId = getOpenerObj("vendor_id");
        fldName.value = vendor_name;
        fldId.value = vendor_id;
       
}
function set_SendCashBill_specific(vendor_id, vendor_name,mode)
{
     
    if(typeof(window.opener.document.EditView.vendors_name) != 'undefined')
        window.opener.document.EditView.vendors_name.value = vendor_name;
    if(typeof(window.opener.document.EditView.vendor_id) != 'undefined')
        window.opener.document.EditView.vendor_id.value = vendor_id;
   
	if(mode != 'DetailView'&& window.opener.document.EditView.purchaseorder_id.value<=0)
	{
	  
		//window.opener.document.EditView.action.value = 'EditView';
        window.opener.document.EditView.vendors_name.value = vendor_name;
        window.opener.document.EditView.vendor_id.value = vendor_id;
        
       	//window.opener.document.EditView.convertmode.value = 'update_so_val';
         
       	//window.opener.document.EditView.submit();
	}
    else 
    {
        window.opener.document.EditView.vendors_name.value = vendor_name;
        window.opener.document.EditView.vendor_id.value = vendor_id;
    }
    
}
function set_return_address(vendor_id, vendor_name,smownerid, street, city, state, code, country,pobox ) 
{
    
    if(document.getElementById('from_link').value != '') {
		window.opener.document.QcEditView.vendors_name.value = vendor_name;
        window.opener.document.QcEditView.vendor_id.value = vendor_id;
        
	   /**
        *@author:andy
        *@data:20141027
        *@reason:选择供应商带出联系人
        *@version:v5.8
        */
        if(window.opener.document.QcEditView.contacts_name != undefined && window.opener.document.QcEditView.contact_id != undefined)
        {
            //if(window.opener.document.QcEditView.contact_id.value == '' || window.opener.document.QcEditView.contact_id.value == 0)
            //{
                var form=window.opener.document.QcEditView;
                var frommodule = document.getElementById('frommodule').value;
                window.opener.customerintocontact(vendor_id,form,frommodule,'Vendors');//带入该客户的联系人
            //}
        }
    }
    else
    {
       alert('www');
    	if(typeof(document.EditView.vendors_name) != 'undefined')
            document.EditView.vendors_name.value = vendor_name;
        if(typeof(document.EditView.vendor_id) != 'undefined')
            document.EditView.vendor_id.value = vendor_id;
        //bug 0015334 zyh 20150605  供应商>明细>关联创建提醒：选择供应商后，不显示。
        if(typeof(window.opener.document.EditView.related_to_name) != 'undefined')
            window.opener.document.EditView.related_to_name.value = vendor_name;
        if(typeof(window.opener.document.EditView.related_to) != 'undefined')
            window.opener.document.EditView.related_to.value = vendor_id;
        if(typeof(window.opener.document.EditView.bill_street) != 'undefined')
                window.opener.document.EditView.bill_street.value = street;
        if(typeof(window.opener.document.EditView.ship_street) != 'undefined')
                window.opener.document.EditView.ship_street.value = street;
        if(typeof(window.opener.document.EditView.bill_city) != 'undefined')
                window.opener.document.EditView.bill_city.value = city;
        if(typeof(window.opener.document.EditView.ship_city) != 'undefined')
                window.opener.document.EditView.ship_city.value = city;
        if(typeof(window.opener.document.EditView.bill_state) != 'undefined')
                window.opener.document.EditView.bill_state.value = state;
        if(typeof(window.opener.document.EditView.ship_state) != 'undefined')
                window.opener.document.EditView.ship_state.value = state;
        if(typeof(window.opener.document.EditView.bill_code) != 'undefined')
                window.opener.document.EditView.bill_code.value = code;
        if(typeof(window.opener.document.EditView.ship_code) != 'undefined')
                window.opener.document.EditView.ship_code.value = code;
        if(typeof(window.opener.document.EditView.bill_country) != 'undefined')
                window.opener.document.EditView.bill_country.value = country;
        if(typeof(window.opener.document.EditView.ship_country) != 'undefined')
                window.opener.document.EditView.ship_country.value = country;
        if(typeof(window.opener.document.EditView.bill_pobox) != 'undefined')
                window.opener.document.EditView.bill_pobox.value = pobox;
        if(typeof(window.opener.document.EditView.ship_pobox) != 'undefined')
                window.opener.document.EditView.ship_pobox.value = pobox;
        /**
        *@author:andy
        *@data:20141027
        *@reason:选择供应商带出联系人
        *@version:v5.8
        */
     
        if(window.opener.document.EditView.contacts_name != undefined && window.opener.document.EditView.contact_id != undefined)
        {
            //if(window.opener.document.EditView.contact_id.value == '' || window.opener.document.EditView.contact_id.value == 0)
            //{
                var form=window.opener.document.EditView;
                var frommodule = document.getElementById('frommodule').value;
                window.opener.customerintocontact(vendor_id,form,frommodule,'Vendors');//带入该供应商的联系人
            //}
        }
        var parentwindow=window.opener;
     
             if(vendor_id > 0 && parentwindow.document.EditView.module != undefined){
    		 var EditViewModule = parentwindow.document.EditView.module.value;
            
    		 if(EditViewModule == 'SendCashBill' || EditViewModule == 'PurchaseOrder' ){
    			 var fldname = 'assigned_user_id';
              
    			 if(parentwindow.document.getElementById(fldname) != undefined){
    				var objoption=parentwindow.document.getElementById(fldname);
    				var optiontext='';
    				picklist=true;
    				if(objoption.length != undefined){
    					for(var i=0;i<objoption.length;i++)
    					{
    						if(objoption[i].value==smownerid)
    						{
    							objoption[i].selected=true;
    							optiontext=objoption[i].text;
    							parentwindow.document.getElementById(fldname).options[i].selected=true;
    						 
    							parentwindow.document.getElementById(fldname).selectedIndex=i;
    							parentwindow.document.getElementById(fldname).options[i].value=smownerid;
    							if(typeof parentwindow.document.getElementById(fldname).onchange=='function')
    								parentwindow.document.getElementById(fldname).onchange();
    							if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
    							{
    								var sourcename = objoption.name;
    								var sourcevalue = objoption.value;	
    								fielddepend.fieldValueChange(sourcename, sourcevalue);
    							}
    							break;
    						}
    					}
    					parentwindow.document.getElementById('cmb_span_optiontext_'+fldname).innerHTML=optiontext;
    				}
    			 }
    		 }
    	 }
    }  
}
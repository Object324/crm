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

prod_array = new Array();
function addtopricebook()
{
	if(document.addToPB.selected_id != undefined){
		var idstring='';
		var y=0;
		var x = document.addToPB.selected_id.length;
		//再次选择时
		if(x == undefined){
			cnt= 2;
			idstring = document.addToPB.selected_id.value;
			y = 1;
		}else{
			for(i = 0; i < x ; i++) {
				//获取选中的产品id
				if(document.addToPB.selected_id[i].checked) {
					idstring = document.addToPB.selected_id[i].value+";"+idstring;
					y = y + 1;
				}
			}
			cnt = 1;
		}
	}
	if (y != 0) {
		document.addToPB.idlist.value=idstring;
	}else{
		var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	document.addToPB.action="index.php?module=Products&action=addPbProductRelToDB&return_module=Products&return_action=AddProductsToPriceBook";
}

function updateListPrice(unitprice,fieldname,oSelect)
{
	if(oSelect.checked == true)
	{
		document.getElementById(fieldname).style.visibility = 'visible';
		document.getElementById(fieldname).value = unitprice;
	}else
	{
		document.getElementById(fieldname).style.visibility = 'hidden';
	}
}

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
		var confirm_str = arrJsPopLabel['CANOTEMPTY'] + errorMessage;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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

function deletePriceBookProductRel(id,pbid)
{
	var confirm_str = arrJsPopLabel['AREYOUSUREYOUWANTTOCANCELTHECONNECTION'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
	    $("status").style.display="inline";
	        new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody: 'module=Products&action=ProductsAjax&file=DeletePriceBookProductRel&ajax=true&return_action=CallRelatedList&return_module=PriceBooks&record='+id+'&pricebook_id='+pbid+'&return_id='+pbid,
				onComplete: function(response) {
						$("status").style.display="none";
						if($('RLContents')){
							$("RLContents").update(response.responseText);
						}
						if($('refresh-Products')){
							$('refresh-Products').click();
						}
				}
	        }
		);
    });
    return ;
}
function verify_data()
{
    var tmpobj=new Object();
    tmpobj.divid="editlistprice";
    CrmPopup.global_listPopupObj.push(tmpobj);
	var returnValue = true;
	var list_price = $('list_price');
        if(list_price.value != '' && list_price.value != 0)
        {
                 intval= intValidate('list_price','EditListPrice');

                if(!intval)
                {
                        returnValue =  false;
                }
               
        }
        else
        {
		if(list_price.value == '')
		{
			var confirm_str = arrJsPopLabel['WHOLESALEPRICECANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			returnValue = false;
		}
        }
	return returnValue;

}


function updateAllListPrice()
{
    var popupobj=CrmPopup.getPopupObj("last");
    
	var unitprice_array = popupobj.unit_price
	var fieldname_array = popupobj.field_name;

	var n=unitprice_array.length;	
	var unitprice,fieldname;
	var id;
	var fieldinfo;
	var checkid;

	for(j=0; j<unitprice_array.length; j++)
	{
		fieldinfo = fieldname_array[j].split("_");
		id = fieldinfo[0];
		checkid = "check_"+id;
      
		unitprice=unitprice_array[j];
		fieldname=fieldname_array[j];	
		updateListPrice(unitprice,fieldname,document.getElementById(checkid));
	}
}

function updateListPriceForField(fieldname,element)
{

     var popupobj=CrmPopup.getPopupObj("last");
    
	var unitprice_array = popupobj.unit_price
	var fieldname_array = popupobj.field_name;

	var index = fieldname_array.indexOf(fieldname);
    
	updateListPrice(unitprice_array[index],fieldname,element);
}


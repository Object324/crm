clearModuleProduct.other_clear=function()
{
//	document.forms['EditView'].salesorder_name.value='';
	//document.forms['EditView'].salesorder_id.value='';
    
    var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+' [name=salesorder_id]').val('');
    ld("#"+popupobj.divid+' [name=entitytypeid]').val('');
   
    ld("#"+popupobj.divid+" [name=salesorder_name]").val('');

}
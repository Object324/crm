clearModuleProduct.other_clear=function()
{
   
	var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+' [name=salesorder_id]').val('');
    ld("#"+popupobj.divid+' [name=entitytypeid]').val('');
   
    ld("#"+popupobj.divid+" [name=salesorder_name]").val('');

}
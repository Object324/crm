var popupobj=CrmPopup.getPopupObj("last");
popupobj.showafter=function()
{
	var  popupobj=CrmPopup.getPopupObj("last");
	if(ld("#"+popupobj.divid+" [name=productname]") != undefined){
		ld("#"+popupobj.divid+" [name=productname]").focus();
	}
}
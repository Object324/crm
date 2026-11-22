var popupobj=CrmPopup.getPopupObj("last");

popupobj.before_validate=function()
{
    //克莱门特：仅当关联的销售合同的合同性质是”维保合同“时才能保存。
	if( document.getElementById('version_account') != undefined && document.getElementById('version_account').value == 'climaveneta'){
		if( CrmPopup.findHtmlobj(divid,'ordertype').val() != undefined &&  CrmPopup.findHtmlobj(divid,'ordertype').val() != '' &&  CrmPopup.findHtmlobj(divid,'ordertype').val() != '维保合同'){
			var salesorder_no = CrmPopup.findHtmlobj(divid,'salesorder_name').val();
			RemindsMsg("","LdPopWidth400px","","","",'销售合同【'+salesorder_no+'】的合同性质不是“维保合同”，保存失败！');
			return false;
		}
	}
    
    return true;
}
var popupobj=CrmPopup.getPopupObj("last");

popupobj.before_validate=function()
{
    //克莱门特：仅当关联的销售合同的合同性质是”维保合同“时才能保存。
	if( document.getElementById('version_account') != undefined && document.getElementById('version_account').value == 'climaveneta'){
	   var popupobj=CrmPopup.getPopupObj('last');
       //edit:can 20210121 044397: 主页面左侧列表 销售管理 模块> 销售合同 > 关联创建服务合同 > 无法保存服务合同
    	if( CrmPopup.findHtmlobj(popupobj.divid,'ordertype').val() != undefined &&  CrmPopup.findHtmlobj(popupobj.divid,'ordertype').val() != '' &&  CrmPopup.findHtmlobj(divid,'ordertype').val() != '维保合同'){
			var salesorder_no = CrmPopup.findHtmlobj(popupobj.divid,'salesorder_name').val();
			RemindsMsg("","LdPopWidth400px","","","",'销售合同【'+salesorder_no+'】的合同性质不是“维保合同”，保存失败！');
			return false;
		}
	}
    
    return true;
}
//chj 界面显示后，加载腾讯地图
var popupobj=CrmPopup.getPopupObj("last");
 popupobj.showafter=function()
{
	getLocationAddress('locationaddress','edit');
}
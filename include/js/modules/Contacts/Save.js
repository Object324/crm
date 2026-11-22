var popupobj=CrmPopup.getPopupObj("last");
//chj 界面显示后，加载腾讯地图
 popupobj.showafter=function()
{
   
	getLocationAddress('locationaddress','edit');
}
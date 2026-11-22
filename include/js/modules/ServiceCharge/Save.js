//chj ������ʾ�󣬼�����Ѷ��ͼ
var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var bol = true;
    
	if(bol){
		 return true;
	}
}
 popupobj.showafter=function()
{
	getLocationAddress('locationaddress','edit');
}
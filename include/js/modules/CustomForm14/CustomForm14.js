//浩辰特殊开发  chj  20220530 合同生成 模块详情页面增加作废按钮
function Haochen_VoidOrder(obj,record){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid = popupobj.divid;
	var order_no = CrmPopup.findHtmlobj(divid,'dtlview_customform14_no').html();
	var msgConfirm = arrJsPopLabel['Confirmtovoidthecontract'];
	msgConfirm = msgConfirm.replace("{Var}",order_no);
	//alert(order_no);
	RemindsMsg("","LdPopWidth400px","","yes","yes",msgConfirm);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var surl = 'index.php?module=CustomForm14&action=CustomForm14Ajax&file=Haochen_VoidOrder&ajax=yes&record=' + record+'&frommodule='+popupobj.module;
		//alert(surl);
		ldAjax(surl, "", function (data) {
			if (data.code == 1) {
				DelProgressObjs();
				var tmparra=new Array();
				tmparra.push(record);
				var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
				var refreshdetailmodules = new Array(popupobj.module);
				tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
				tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
				tmpobj.update();//更新界面字段
				return false;
			}
		})
	});
}
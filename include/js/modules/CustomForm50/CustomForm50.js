function saveApproveLog(){
	var popupobj=CrmPopup.getPopupObj("last");
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	var approveid = ld("#"+popupobj.divid+" [name=approveid]").val();
	var stepid = ld("#"+popupobj.divid+" [name=stepid]").val();
	var obj = new SaveApproveOperation();
	ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
	return false;
}

//dongmao 微信公众号消息推送
SaveApproveOperation.prototype.saveApproveAfter = function(){
	if(version_account != undefined && version_account == 'dongmao'){
		var popupobj=CrmPopup.getPopupObj("last");
		var record = ld("#"+popupobj.divid+" [name=record]").val();
		var urlstring = 'index.php?module=CustomForm50&action=CustomForm50Ajax&file=WeChartMsg&getNum=yes&record='+record;
		ldAjax(urlstring,{},function(data){
			if(data.code == 1){
				if(data.result.num_rows > 0){
					ld('#rptContentLoading').show();
					startWeChart(record,0);
				}
			}
		})
	}
}

function startWeChart(record,startrow){
	var intervalrow=4;
	var urlstring = 'module=CustomForm50&action=CustomForm50Ajax&file=WeChartMsg&send=yes&record='+record;
	urlstring+="&startrow="+startrow+"&endrow="+(startrow+intervalrow);
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: urlstring,
			onComplete: function (response) {
				ld('#rptContentLoading').hide();
				var restobj = eval('(' + response.responseText + ')') ? eval('(' + response.responseText + ')') : JSON.parse(response.responseText);
				var tmppopupobjobj;

				if(startrow==0){
					 tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,'CustomForm50',"","","","");
					 tmppopupobjobj.show();
				}else{
					tmppopupobjobj=CrmPopup.getPopupObj('last');
				}

				var maxrows=parseInt(restobj.maxrows);
				var percent=parseInt(((startrow+intervalrow)/maxrows*100));
				tmppopupobjobj.setPercentWidth(percent);
				tmppopupobjobj.setTotalNum(restobj.selectrows);
				tmppopupobjobj.setCurNum(startrow);

				if(maxrows!=restobj.selectrows){
					tmppopupobjobj.setValidataNum(maxrows);
				}
				if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows)){
					startWeChart(record,startrow+4);
					return false;
				}else{
					tmppopupobjobj.CancelEvent();
				}
			}
		})
}
var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate=function()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;

	var publicaccount=CrmPopup.findHtmlobj(divid,"publicaccount").val();
	var record=CrmPopup.findHtmlobj(divid,"record").val();
	var cur_this=this;
	var bol=true;
	//朗捷：运输订单，当零担为 是 时，表体中的【毛重】字段值必须大于0
	if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
		if(CrmPopup.findHtmlobj(popupobj.divid,'cf_3052').val() != undefined){
			var lingdan = CrmPopup.findHtmlobj(popupobj.divid,'cf_3052').val();
			if(lingdan == '是'){
				var row_cnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();
				for(var i = 1; i<=row_cnt; i++){
					var hidden_rowid = ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val();
					if(hidden_rowid != 1){
						if(ld("#"+popupobj.divid+" [name=sf204"+i+"]").val() != undefined){
							var maozhong = ld("#"+popupobj.divid+" [name=sf204"+i+"]").val();
							if(maozhong <= 0.0){
								RemindsMsg("","LdPopWidth400px","","yes","yes","表体第"+i+"行的【毛重】必须大于0！");
								bol = false;
							}
						}
					}
				}
			}
		}
	}
	return bol;
}
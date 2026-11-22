/**
 * 浩辰特殊开发
 * @param	2022/6/15
 * @returns
 * @author chj 
 */
function haochen_listviewExport(obj,module){
	var popupobj = CrmPopup.getPopupObj('last');
	var viewname = ld("#" + popupobj.divid + " [name=viewname]").val();
	List_CheckBox_Ids.getIds(module);
	var select_options = List_CheckBox_Ids.ids;
	var selectidstring = select_options;
	obj.account = 'haochen';
	var surl='module='+module+'&action='+module+'Ajax&&file=Export' + module + 'ForHaochen&getprogress=yes&idstring=' + selectidstring + '&viewname=' + viewname;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	var _listviewExport = new listviewExport(obj,module);
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
			
            if(data.code==1)
            {
                crmPopupobj.setParams(data.result.title,_listviewExport.createExportProgress,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			}else{
				crmPopupobj.CancelEvent();//关闭弹出层
				var confirm_str = arrJsPopLabel['nodata'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}
	})
	return false;
}
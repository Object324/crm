var popupobj=CrmPopup.getPopupObj("last");
/* 郎捷：需求
edit:chj
date:2020-05-21
reason:单据头->合同编号：当“服务项目”选择“报关订单/运输订单/空运订单”时，控制“客户合同编号/供应商合同编号”字段不可编辑；当“服务项目”选择“仓储订单”时允许选择“客户合同编号/供应商合同编号
*/
function showReferenceModuleFieldBtn(){
	if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
		var service_type = '';	//服务项目
		if(CrmPopup.findHtmlobj(popupobj.divid,'service_type').val() != undefined){
			service_type = CrmPopup.findHtmlobj(popupobj.divid,'service_type').val();
		}
		if(service_type == '报关订单' || service_type == '运输订单' || service_type == '空运订单' || service_type == '简易报关草单' || service_type == '仓储订单'){
			if(CrmPopup.findHtmlobj(popupobj.divid,'potential_id_showmodule').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'potential_id_showmodule').hide();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_showmodule').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_showmodule').hide();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'potential_id_clear').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'potential_id_clear').hide();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_clear').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_clear').hide();
			}
		}else{
			if(CrmPopup.findHtmlobj(popupobj.divid,'potential_id_showmodule').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'potential_id_showmodule').show();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_showmodule').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_showmodule').show();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'potential_id_clear').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'potential_id_clear').show();
			}
			if(CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_clear').val() != undefined){
				CrmPopup.findHtmlobj(popupobj.divid,'customform04_id_clear').show();
			}
		}

		var surl = "index.php?module=CustomForm18&action=CustomForm18Ajax&file=getLangjieOrderDetailField&record="+popupobj.record;
		//alert(surl);
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				if(data.result.object_field_all != '' && data.result.object_field != ''){
					if(data.result.width != ''){
						CrmPopup.findHtmlobj(popupobj.divid,'proTab').css('width',data.result.width+'mm');
					}
					var rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
					
					for(var i=1;i<=rowcnt;i++){
						ld.each(data.result.object_field_all,function(key,columnname){
							if(ld.inArray(columnname,data.result.object_field) >= 0){
								//alert(columnname);
								if(CrmPopup.findHtmlobj(popupobj.divid,'productdetails_header_'+columnname).html() != undefined){
									CrmPopup.findHtmlobj(popupobj.divid,'productdetails_header_'+columnname).show();
								}
								if(CrmPopup.findHtmlobj(popupobj.divid,'productdetails_input_'+columnname+i).html() != undefined){
									CrmPopup.findHtmlobj(popupobj.divid,'productdetails_input_'+columnname+i).show();
								}
							}else{
								if(CrmPopup.findHtmlobj(popupobj.divid,'productdetails_header_'+columnname).html() != undefined){
									CrmPopup.findHtmlobj(popupobj.divid,'productdetails_header_'+columnname).hide();
								}
								if(CrmPopup.findHtmlobj(popupobj.divid,'productdetails_input_'+columnname+i).html() != undefined){
									CrmPopup.findHtmlobj(popupobj.divid,'productdetails_input_'+columnname+i).hide();
								}
							}
							
						})
					}
				}
			}
		})
	}
	
}

popupobj.showafter=function()
{	
	//郎捷：特殊需求控制
	//showReferenceModuleFieldBtn();
}
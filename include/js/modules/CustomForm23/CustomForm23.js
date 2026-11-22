/* 郎捷：需求
edit:chj
date:2020-06-05
reason:
1.客服下单->运输订单->选择车型之后表体根据“车型”自动带出“合同->运输”中单据分录是对应车型的“分录信息”
	1)合同->运输中的“启运地” 到 运输订单中的“装货地点”
	2)合同->运输中的“目的地” 到 运输订单中的“送货地点”

function getLangjieModuleRelatedInfo(selectmodule,selectedText){
	var popupobj=CrmPopup.getPopupObj('last');
	if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
		var potential_id = CrmPopup.findHtmlobj(popupobj.divid,'potential_id').val();	// 客户合同编号
		if(potential_id >= 1){
			var surl = "index.php?module=CustomForm23&action=CustomForm23Ajax&file=getLangjieModuleDetails&potential_id="+potential_id+"&selectedText="+selectedText;
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code==1){
					var popupobj=CrmPopup.getPopupObj("last");
					rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
					for(var i=1;i<=rowcnt;i++){
						if(CrmPopup.findHtmlobj(popupobj.divid,'sf158'+i).val() != undefined){
							CrmPopup.findHtmlobj(popupobj.divid,'sf158'+i).val('');
						}
						if(CrmPopup.findHtmlobj(popupobj.divid,'sf161'+i).val() != undefined){
							CrmPopup.findHtmlobj(popupobj.divid,'sf161'+i).val('');
						}
					}
					for(i_row in data.result){
						var object_data = data.result[i_row];
						if(i_row > rowcnt){
							fnAddTabDetailRow('CustomForm23');
						}
						for (var columnname in object_data) {
							var col_value = object_data[columnname];
							if(columnname == 'qiyundi'){
								columnname = 'sf158';	//装货地点
							}else if(columnname == 'mudidi'){
								columnname = 'sf161';	//送货地点
							}
							if(CrmPopup.findHtmlobj(popupobj.divid,columnname+i_row).val() != undefined){
								CrmPopup.findHtmlobj(popupobj.divid,columnname+i_row).val(col_value);
								//alert(object_data[columnname]+'-----'+columnname+i_row);
							}
						}
					}
					DelProgressObjs();
				}
			})
		}
	}
}*/

function getlangjieSalesOrderInfoByCarType()
{
    //*客服下单->运输订单->选择车型之后表体根据“车型”自动带出“报价单”中单据分录是对应车型的“分录信息”
    
    var popupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    
    var salesorderid=ld("#"+popupobj.divid+" [name=salesorder_id]").val();
    if(parseInt(salesorderid)<=0)
    {
        //没有选择保价单
        return false;
    }
    var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
  
    var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
   
    ld.each(ld(trobjs),function(){
        
        //清空行
        rowindex=ld(this).attr("rowindex");
        
        deleteRow(rowindex);
    })
    
    //有删除行，所有rowcount不一定等于lastrowindex;
    //获取
    var lastrowindex=ld(tableobj).find("tr[detaildeleted=no]").attr("rowindex");
    var rowindex=lastrowindex;
   var  rowcount=1;
    var cartype=ld("#"+popupobj.divid+" [name=carriage_type]").val();
    ldAjaxNoProgress("index.php?module=CustomForm23&action=CustomForm23Ajax&file=getLangJieSalesOrderByCarType"
        ,{"selectid":salesorderid,'cartype':cartype},function(ajaxdata){
            
            
            
             if(ajaxdata.result.addressinfo==undefined)
               {
                return ;
               }
              var addressinfo=ajaxdata.result.addressinfo;
            
              ld.each(addressinfo,function(tmpindex,address){
                     
                     if(rowindex>rowcount)
                    {
                        //没有空行则新增行
                       rowindex= fnAddTabDetailRow('CustomForm23');
                        
                    }
                    
                    var rowobj=ld(tableobj).find("tr[name=row"+rowindex+"]");
                    
                    ld(rowobj).find("[name=sf158"+rowindex+"]").val(address.start_address);
                   
                    ld(rowobj).find("[name=sf161"+rowindex+"]").val(address.end_address);
                    ld(rowobj).find("[name=cmb_span_optiontext_sf158"+rowindex+"]").val(address.start_address);
                    ld(rowobj).find("[name=cmb_span_optiontext_sf161"+rowindex+"]").val(address.end_address);
                    //ld(rowobj).find("[name=sf158"+rowindex+"]").val(address.start_address);
                   // ld(rowobj).find("[name=sf161"+rowindex+"]").val(address.end_address);
                    rowindex++;
              })
             popupobj.center();
          
    });
}
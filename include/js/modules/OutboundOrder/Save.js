
var popupobj=CrmPopup.getPopupObj("last");
popupobj.before_validate = function(){
	//chj 2020/12/24 43906: （https://61mis.com/kfbcrm/ [^]）>系统设置-库存参数-设置不允许负库存出库，新建出库单，以产品菠萝蜜111为例，它是负库存，仍然可以新建出库单
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var trobjs=popupobj.getTrObjsByDelType('no');
	var ids=[];
    var quantitys=[];
	var dataurl="module=OutboundOrder&action=OutboundOrderAjax&file=OutboundOrderForApprove&outbound_delivery=yes&record="+popupobj.record;
	ld.each(ld(trobjs),function(){
		var productid =ld(this).find("[detailcolumnname=hdnProductId]").val();
		var quantity = ld(this).find("[detailcolumnname=quantity]").val();
		if(productid > 0){
			ids.push(productid);
            quantitys.push(quantity);
		}
	});
	dataurl += "&productids="+ids.join(",")+"&quantitys="+quantitys.join(',');
	ldAjaxNoProgresssync('index.php',dataurl,function(ajaxdata){
		if (ajaxdata.code==1 ) {
			ret=true;
		} else {
			RemindsMsg("","width450",popupobj.module,"","",ajaxdata.msg);
			ret=false;
		}
	});
	return ret;
}
popupobj.after_validate=function()
{
    var ret=true;
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var version_trade =  '';  
	if(CrmPopup.getHtmlobjval(divid,'version_trade') != undefined){
		version_trade = ld("#"+divid+" [name=version_trade]").val();
	}
	//扫码行业：出库单严格参照源单优化
	if(version_trade == 'sweepbarcode'){
		var salesorder_id=ld("#"+popupobj.divid+" [name=salesorder_id]").val();
        var dataurl="module=OutboundOrder&action=OutboundOrderAjax&file=OutboundOrderSalesCheck&salesorder_id="+salesorder_id;
		dataurl+='&recordid='+popupobj.record;
        var rowcnt=ld("#"+popupobj.divid+" [name=rowcnt]").val();
        var ids=[];
        var quantitys=[];
        for(var i=1;i<=rowcnt;i++)
        {
            if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val()==0)
            {
              ids.push(ld("#"+popupobj.divid+" [name=hdnProductId"+i+"]").val());
              quantitys.push(ld("#"+popupobj.divid+" [name=quantity"+i+"]").val());
            }
        }
        dataurl+="&productids="+ids.join(",")+"&quantitys="+quantitys.join(',');
		//alert(dataurl);
		ld.ajax({
            type : "post",
            url : "index.php",
            data : dataurl,
            async:false,
            dataType:"json",
            timeout:10000,
            success : function(data) {
              
                if (data.code==1 ) {
                   ret=true;
                } else {
                    var error_msg = data.msg;
					RemindsMsg("","width450",popupobj.module,"","",error_msg);
					ret=false;
                }
            }
        });
	}	
	return ret;
}
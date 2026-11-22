/* 郎捷：需求
edit:chj
date:2020-05-21
reason:单据头->合同编号：当“服务项目”选择“报关订单/运输订单/空运订单”时，控制“客户合同编号/供应商合同编号”字段不可编辑；当“服务项目”选择“仓储订单”时允许选择“客户合同编号/供应商合同编号

function getLangjieModuleRelatedInfo(selectmodule,mid){
	var popupobj=CrmPopup.getPopupObj('last');
	if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
		var feiyong_type = CrmPopup.findHtmlobj(popupobj.divid,'feiyong_type').val();	// 费用类型
		var order_id = 0;
		var service_type = CrmPopup.findHtmlobj(popupobj.divid,'service_type').val();	//  服务项目
		if(feiyong_type == '应收'){
			order_id = CrmPopup.findHtmlobj(popupobj.divid,'potential_id').val();	//客户合同编号
		}else{
			order_id = CrmPopup.findHtmlobj(popupobj.divid,'customform04_id').val();	//供应商合同编号
		}
        order_id=mid;
		if(order_id >= 1){
			var surl = "index.php?module=CustomForm18&action=CustomForm18Ajax&file=getLangjieModuleDetails&order_id="+order_id+"&record="+mid+"&service_type="+encodeURIComponent(service_type)+"&selectmodule="+selectmodule;
			if((selectmodule == 'Potentials' || selectmodule == 'storage_port') && service_type == '仓储订单'){
				var storage_port = '';	// Port
				if(CrmPopup.findHtmlobj(popupobj.divid,'storage_port').val() != undefined){
					storage_port = CrmPopup.findHtmlobj(popupobj.divid,'storage_port').val();
				}
				surl += '&storage_port='+encodeURIComponent(storage_port);
			}
			surl += '&feiyong_type='+encodeURIComponent(feiyong_type);
			//alert(surl);
			ldAjax(surl,"",function(data){
				if(data.code==1){
					var popupobj=CrmPopup.getPopupObj("last");
					rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
					for(var i=1;i<=rowcnt;i++){
						fun_selectproduct.btn_clearProductInfo_Row(i);
					}
					if(data.result.width != ''){
						CrmPopup.findHtmlobj(popupobj.divid,'proTab').css('width',data.result.width+'mm');
					}
					if(data.result.object_field != '' && data.result.object_field_all != ''){
						setLangjieDetailFieldDisplay(data.result.object_field_all,data.result.object_field);
					}
					for(i_row in data.result.object_data){
						var object_data = data.result.object_data[i_row];
						if(i_row > rowcnt){
							fun_selectproduct.addproductrow();
							setLangjieDetailFieldDisplay(data.result.object_field_all,data.result.object_field);
						}
						for (var columnname in object_data) {
							var col_value = object_data[columnname];
							if(columnname == 'productid'){
								columnname = 'hdnProductId';
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

/*根据服务项目的不同，控制显示表体的列
function setLangjieDetailFieldDisplay(cur_modulefield,order_modulefield){
	var popupobj=CrmPopup.getPopupObj('last');
	if(order_modulefield != '' && cur_modulefield != ''){
		var rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
		for(var i=1;i<=rowcnt;i++){
			ld.each(cur_modulefield,function(key,columnname){
				if(ld.inArray(columnname,order_modulefield) >= 0){
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
}*/

function setTableTdLabellangjie(){
    //edit:can 20200803 设置郎捷单据分录数量的标签显示
    var  lastpopupobj=CrmPopup.getPopupObj("last");
    if(lastpopupobj.type==DetailViewPage.type)
    {
        var popupobj=lastpopupobj;
    }
    else
        var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    var service_typeobj=ld("#"+popupobj.divid+" [name=service_type]");
   
    if(ld(service_typeobj).length>0)
    {
        var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
        
        var value=ld(service_typeobj).val();
      
        if(value=='出入库'||value=='运输'||value=='local配送')
        {
            ld("#"+popupobj.divid+' [detailspancolumnname=quantity]').html("计费数值");
        }
        else if(value=='空运')
        {
            ld("#"+popupobj.divid+' [detailspancolumnname=quantity]').html("计费重量");
        }
        else if(value=='海运')
        {
            ld("#"+popupobj.divid+' [detailspancolumnname=quantity]').html("计费数值");
            
        }
        else if(value=='报关')
        {
            ld("#"+popupobj.divid+' [detailspancolumnname=quantity]').html("次数");
            
        }
        else
        {
            ld("#"+popupobj.divid+' [detailspancolumnname=quantity]').html("数量");
        }
        var tdobj=ld("#"+popupobj.divid+" [name=selectlistval]");
        while(ld(tdobj).length>0&&tdobj.prop("tagName").toLocaleLowerCase()!='td')
        {
            tdobj=ld(tdobj).parent();
        }
        ld(tdobj).find(" .icon-homeimg").css("display",'none');//客户报价单不可以修改
      // alert(ld("#"+popupobj.divid+" [name=selectsource]").length);
        ld("#"+popupobj.divid+" [name=selectsource]").val("SalesOrder");
        ld("#"+popupobj.divid+" [name=selectsource]").attr("disabled","disabled");
      //edit:can 2020-09-03 042540: （http://51mis.com/YS/liu237 [^]）费用项目菜单>应收费用单模块>序时簿界面：点击“单据编号”详情界面弹出层样式不统一，没有向右靠齐  
     if(lastpopupobj.type!=DetailViewPage.type)
        popupobj.center();
            
  
    }
    
}
/*
selectfieldname:选择的字段和选择的模块
*/
function setLangJieRelateFieldValue(selectfieldname,selectmodulename)
{
    //edit:can 20200803 选择单据后带出，客户报价单 
    //customform27_id
    var popupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    var customform27obj=ld("#"+popupobj.divid+" [name=customform27_id]");//配送单
    var customform23obj=ld("#"+popupobj.divid+" [name=customform23_id]");//运输单
    var customform21obj=ld("#"+popupobj.divid+" [name=customform21_id]");//海运
    var customform22obj=ld("#"+popupobj.divid+" [name=customform22_id]");//报关
    var customform24obj=ld("#"+popupobj.divid+" [name=customform24_id]");//空运
    var commissionobj=ld("#"+popupobj.divid+" [name=commission_id]");//出入库
    var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
   // var rowcount=ld(tableobj).find("tr[detaildeleted=yes]").length;
   var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
    var rowcount=ld(tableobj).find("tr[detaildeleted=no]").length;
  
    var rowindex=1;
    ld.each(ld(trobjs),function(){
        var tmprowindex=ld(this).attr("rowindex");
        if(parseInt(tmprowindex)>1)
        {
            deleteRow(tmprowindex);
        }
    })
   
   var url='';
   var port='';
    if(ld(customform27obj).length>0)
    {
        //Local配送订单
         var selectid=ld(customform27obj).val();
        
      url='&file=getLangJieSalesOrderSourceInfo&selectid='+selectid+"&selectmodule="+selectmodulename;
        
    }
    else if(ld(customform23obj).length>0)
    {
        //运输单
         var selectid=ld(customform23obj).val();
        url='&file=getLangJieSalesOrderSourceInfo&selectid='+selectid+"&selectmodule="+selectmodulename;
    }
    else if(ld(customform21obj).length>0)
    {
        //海运
        var selectid=ld(customform21obj).val();
        url='&file=getLangJieSalesOrderSourceInfo&selectid='+selectid+"&selectmodule="+selectmodulename;
    }
    else if(ld(customform22obj).length>0)
    {
        //报关
        var selectid=ld(customform22obj).val();
        url='&file=getLangJieSalesOrderSourceInfo&selectid='+selectid+"&selectmodule="+selectmodulename;
        
    }
    else if(ld(customform24obj).length>0)
    {
        //空运
        var selectid=ld(customform24obj).val();
        url='&file=getLangJieAirPortInfo&selectid='+selectid;
    }
    else if(ld(commissionobj).length>0)
    {
        //出入库
          var selectid=ld(commissionobj).val();
          var port=ld("#"+popupobj.divid+" [name=storage_port]").val();
          url='&file=getLangJieSalesOrderSourceInfo&selectid='+selectid+"&selectmodule="+selectmodulename;
       
    }
    
  ldAjaxNoProgress("index.php?module=CustomForm18&action=CustomForm18Ajax"+url,{'port':port},function(ajaxdata){
    
        ld("#"+popupobj.divid+" [name=selectlistval]").val(ajaxdata.result.salesorderid);
     
      ld("#"+popupobj.divid+" [name=selectlistval_label]").val(ajaxdata.result.salesorder_no);
      ld("#"+popupobj.divid+" [name=inventory_currency]").val(ajaxdata.result.currency_id);
       if(ajaxdata.result.detailfieldvalue==undefined)
       {
        return ;
       }
       popupobj.fieldformulaobj.ismasscount='yes';
       rowcount=1;
      rowindex=1;
     ld.each(ajaxdata.result.detailfieldvalue,function(productid,prod_array){//循环行
             if(rowindex>rowcount)
            {
                
                 rowindex=popupobj.selectproductobj.fnaddProductRow();
                 var tmprowobj=ld(tableobj).find("[name=row"+rowindex+"]");
                 ld(tmprowobj).children('td').eq(1).html(ld(tableobj).find("[detaildeleted=no]").length);
                
            }
           // console.log(rowindex);
           
            popupobj.selectproductobj.setValue(productid,prod_array,rowindex);
            
            autoTotalPrice(new Object(),rowindex);//特殊的字段公式

            
            rowindex++;
     })
      // @edit:dong @date:2020/09/18 @reason: tapd ID1001112 朗捷费用单个性化开发
      CustomForm18NotAllowEdit();
     popupobj.center();
//    
     popupobj.fieldformulaobj.ismasscount='no';
     popupobj.fieldformulaobj.CountsubTotal();//计算小计 合计
     
      
 })
}



//朗捷 应收费用单>出口空运特殊字段公式 计算运费
function autoTotalPrice(obj,id_rowIndex) {
     var popupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
     var service_type=ld("#"+popupobj.divid+" [name=service_type]").val();
     var tableobj=ld("#"+popupobj.divid+" [name="+popupobj.js_detailtablename+"]");
     var rowobj=ld(tableobj).find("[rowindex="+id_rowIndex+"]");
     var charging_type=ld(rowobj).find("[name=charging_type"+id_rowIndex+"]").val();//计费方式
     var price =ld(rowobj).find("[name=taxprice"+id_rowIndex+"]").val();//价格
     var tax_amountobj=ld(rowobj).find("[name=tax_amount"+id_rowIndex+"]");//费用金额
     var quantity=ld(rowobj).find("[name=quantity"+id_rowIndex+"]").val();
     if(service_type=='空运'&&charging_type=='特殊浮动计量')
     {
        var quantity=ld(rowobj).find("[name=quantity"+id_rowIndex+"]").val();
       //alert(quantity);
        if(eval(quantity)<45)
        {
             price=ld(rowobj).find("[name=sf10131"+id_rowIndex+"]").val();
            //tax_amountobj.val(eval(quantity*45));
        }
        else if(eval(quantity)<100)
        {
            price=ld(rowobj).find("[name=sf10267"+id_rowIndex+"]").val();
            
        }
        else if(eval(quantity)<300)
        {
            price=ld(rowobj).find("[name=sf10403"+id_rowIndex+"]").val();
        }
        else if(eval(quantity)<500)
        {
            price=ld(rowobj).find("[name=sf10539"+id_rowIndex+"]").val();
        }
        else if(eval(quantity)<1000)
        {
            price=ld(rowobj).find("[name=sf10675"+id_rowIndex+"]").val();
        }
        else
        {
            price=ld(rowobj).find("[name=sf10811"+id_rowIndex+"]").val();
        }
        var pricemin=ld(rowobj).find("[name=list_amount"+id_rowIndex+"]").val();//价格-MIN	
       
        tax_amountobj.val(Math.max(eval(quantity*price),eval(pricemin)));
     }
     else
     {
        if(charging_type=='按次'||charging_type=='按次/票')
         {
            //费用金额=价格
              if(service_type=='海运')
                tax_amountobj.val(eval(price*quantity));
            else
                tax_amountobj.val(eval(price));
         }
         else if (charging_type=='按天'){
            //计费方式=按天：费用金额=价格*（天数-免仓期）*毛重 字段
            var sf30667=ld(rowobj).find("[name=sf30667"+id_rowIndex+"]").val();//免仓期
            var commissionobj=ld("#"+popupobj.divid+" [name=commission_id]");
            if(ld(commissionobj).length<=0)
            {
                return ;
            }
            var   pricemin=ld(rowobj).find("[name=span_list_amount"+id_rowIndex+"]").html();
            commissionid=ld(commissionobj).val();
            if(popupobj.customform18days==undefined)
            {
                popupobj.customform18days=[];
                popupobj.customfrom18commissionid=[];
                //popupobj.customform18type=[];
            }
            var quantity=ld(rowobj).find("[name=quantity"+id_rowIndex+"]").val();
            if(ld.inArray(commissionid,popupobj.customfrom18commissionid)>=0)
            {
                var days=parseInt(popupobj.customform18days[ld.inArray(commissionid,popupobj.customfrom18commissionid)].days);
                var commissiontype=popupobj.customform18days[ld.inArray(commissionid,popupobj.customfrom18commissionid)].commissiontype;
                var tmpquantity=eval(price*(days-sf30667)*quantity);
                if(commissiontype=='入库')
                {
                    tax_amountobj.val(0);
                }
                else
                    tax_amountobj.val(Math.max(pricemin,tmpquantity));
            }
            else
            ldAjaxNoProgress("index.php?module=CustomForm18&action=CustomForm18Ajax&file=getLangJieInOutDays",{'commissionid':commissionid},function(ajaxdata){
                var days=parseInt(ajaxdata.result.days);
               var commissiontype=ajaxdata.result.commissiontype;
               if(commissiontype=='入库')
               {
                tax_amountobj.val(0);
               }
               else
                {
                    var tmpquantity=eval(price*(days-sf30667)*quantity);
                    tax_amountobj.val(Math.max(pricemin,tmpquantity));
                   
                }
                 popupobj.customfrom18commissionid.push(commissionid);
                 
                 popupobj.customform18days.push({'commission_id':commissionid,'days':days,'commissiontype':commissiontype});
            })
         }
         else if(charging_type=='计量且有MIN')
         {
            //d.计费方式=计量且有MIN：费用金额=MAX（价格*数量字段，价格-MIN）
            //价格-MIN
            var pricemin=ld(rowobj).find("[name=span_list_amount"+id_rowIndex+"]").html();
            var quantity=ld(rowobj).find("[name=quantity"+id_rowIndex+"]").val();
           
            tax_amountobj.val(Math.max(eval(price*quantity),pricemin));
         }
         else if(charging_type=='计量')
         {
            //c.计费方式=计量：费用金额=价格*数量字段
            tax_amountobj.val(eval(price*quantity));
            
         }
     
     }
     popupobj.fieldformulaobj.CountsubTotal();
     
    
}

//分录中只读 设置但当前行某些字段不允许编辑
function CustomForm18NotAllowEdit(){
    var popupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
    var trobjs=popupobj.getTrObjsByDelType('no');
    
    var rowcnt = ld("#"+popupobj.divid + " [name=rowcnt]").val();
    ld.each(trobjs,function(){
        readOnlyValue = ld(rowobj).find(" [name=sf32264]").val();
        if(readOnlyValue =='Y'){
            ld(rowobj).find(" [name=productname]").siblings('a').hide(); //费用项目后面的两个按钮
            ld(rowobj).find(" [name=taxprice]").css('cursor','not-allowed').attr('readonly','true');//价格
            ld(rowobj).find(" [name=tax2]").css('cursor','not-allowed').attr('readonly','true');//税率
            ld(rowobj).find(" [name=quantity]").css('cursor','not-allowed').attr('readonly','true');//次数
            ld(rowobj).find(" [name=tax_amount]").css('cursor','not-allowed').attr('readonly','true');//费用金额
        }else{
            ld(rowobj).find(" [name=productname]").siblings('a').show(); //费用项目后面的两个按钮
            ld(rowobj).find(" [name=taxprice]").css('cursor','auto').removeAttr('readonly');//价格
            ld(rowobj).find(" [name=tax2]").css('cursor','auto').removeAttr('readonly');//税率
            ld(rowobj).find(" [name=quantity]").css('cursor','auto').removeAttr('readonly');//次数
            ld(rowobj).find(" [name=tax_amount]").css('cursor','auto').removeAttr('readonly');//费用金额
        }
    })
    /*var readOnlyValue;
    for (var i=1 ;i<=rowcnt;i++){
        readOnlyValue = ld('#'+popupobj.divid +" [name=sf32264"+i+"]").val();
        if(readOnlyValue =='Y'){
            ld('#'+popupobj.divid+" [name=productname"+i+"]").siblings('a').hide(); //费用项目后面的两个按钮
            ld('#'+popupobj.divid+" [name=taxprice"+i+"]").css('cursor','not-allowed').attr('readonly','true');//价格
            ld('#'+popupobj.divid+" [name=tax2"+i+"]").css('cursor','not-allowed').attr('readonly','true');//税率
            ld('#'+popupobj.divid+" [name=quantity"+i+"]").css('cursor','not-allowed').attr('readonly','true');//次数
            ld('#'+popupobj.divid+" [name=tax_amount"+i+"]").css('cursor','not-allowed').attr('readonly','true');//费用金额
        }else{
            ld('#'+popupobj.divid+" [name=productname"+i+"]").siblings('a').show(); //费用项目后面的两个按钮
            ld('#'+popupobj.divid+" [name=taxprice"+i+"]").css('cursor','auto').removeAttr('readonly');//价格
            ld('#'+popupobj.divid+" [name=tax2"+i+"]").css('cursor','auto').removeAttr('readonly');//税率
            ld('#'+popupobj.divid+" [name=quantity"+i+"]").css('cursor','auto').removeAttr('readonly');//次数
            ld('#'+popupobj.divid+" [name=tax_amount"+i+"]").css('cursor','auto').removeAttr('readonly');//费用金额
        }
    }*/

}
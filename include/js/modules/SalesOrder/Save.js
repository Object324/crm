var popupobj=CrmPopup.getPopupObj('last');
popupobj.before_validate = function(){
	var ret=true;
	//chj 2022/9/20 中德信用额度控制下单(2)_1663310360000_576
	if(account_version=='zhongde')
    {
		var popupobj=CrmPopup.getPopupObj("last");
		var total = ld("#"+popupobj.divid+" [name=total]").val();
		var cf_5153 = ld("#"+popupobj.divid+" [name=cf_5153]").val();	// 是否可查信用
		var cf_5150 = ld("#"+popupobj.divid+" [name=cf_5150]").val();	// 客户信用额度可用余额
		var cf_5154 = ld("#"+popupobj.divid+" [name=cf_5154]").val();	// 销售员信用额度可用余额
		var temp_amount = 0;
		if(cf_5153 == '是'){
			if(!empty(cf_5150) && !empty(cf_5154)){
				if(cf_5150 < cf_5154){
					temp_amount = cf_5150;
				}else{
					temp_amount = cf_5154;
				}
			}else{
				if(!empty(cf_5150)){
					temp_amount = cf_5150;
				}else if(!empty(cf_5154)){
					temp_amount = cf_5154;
				}
			}
			
		}else{
			 if(!empty(cf_5154)){
				temp_amount = cf_5154;
			}
		}
		if(!empty(temp_amount) && temp_amount < total){
			RemindsMsg("","width450",popupobj.module,"","","信用额度小于合计金额，保存失败！");
			ret=false;
		}
	}
	return ret;
}
popupobj.after_validate=function()
{

    //var jsQualifyDateobj=new jsQualifyDate();
    //jsQualifyDateobj.saveSalesOrderDetail();
    
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

   // var record =CrmPopup.getHtmlobjval(divid,'record');
    //zxm 20231208 首页简报穿透之后查看详情点编辑 保存报错该js类不存在
    AjaxJSPage('SalesOrder_js','include/js/modules/SalesOrder/SalesOrder.js');
    var cls_SalesOrderobj=new cls_SalesOrder();
    cls_SalesOrderobj.FindProdcutForQtyinstock();//设置合同订单分录明细中数量超过安全库存数量时是否需要提示
    
    if(account_version=='yiwen')
    {
        var cf_3166obj=ld("#"+popupobj.divid+" [name=cf_3166]");//客户订单号
        if(ld(cf_3166obj).length>0&&ld.trim(ld(cf_3166obj).val())!="")
        {
            ldAjaxNoProgresssync("index.php?module=SalesOrder&action=SalesOrderAjax&file=YiWenDuplicateCheck&id="+popupobj.record+"&cf_3166="+encodeURIComponent(ld(cf_3166obj).val()),{},function(ajaxdata){
                if(ajaxdata.code=='-1')
                {
                    alert(ajaxdata.msg);
                }
            })
        }
        var rowobjs=popupobj.getTrObjsByDelType("no");
        var msgerror='';
        
        ld.each(rowobjs,function(){
            var cf_4943obj=ld(this).find("[name=span_cf_4943]");
            var rowindex=ld(this).attr("rowindex");
            
            if(ld(cf_4943obj).length>0)
            {
                //采购计量单位
                var value=ld(cf_4943obj).html();
				var sf19022obj=ld(this).find(" [name=sf19022]");//报价计量单位
				if(ld.trim(ld(sf19022obj).val())==value)
				{
				return true;
				}
                var num=value.replace(/[^0-9]/ig,"");
			
                if(num=="undefined"||num==undefined||num==''||num==0)
                {
                    
                }
                else
                {
                   
                    var quantity=ld(this).find("[detailcolumnname=quantity]").val();
                    if(quantity%num!=0)
                    {
                        msgerror+="第"+rowindex+"行数量不是'"+num+"'的整数倍\n";
                        
                    }
                }
            }
        })
        if(msgerror!="")
        {
            alert(msgerror);
            
        }
		
    }
    if(!cls_SalesOrderobj.AlertProductQtyinstock_bol)
    {
        
    }
    else{
        
        return CheckSalesOrderData();
    }
    
}
function  CheckSalesOrderData()
{
     var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var version_account =  '';
   
	if(CrmPopup.getHtmlobjval(divid,'version_account') != undefined){
		version_account = ld("#"+divid+" [name=version_account]").val();
	}
  
    var ret=true;
    var trobjs=popupobj.getTrObjsByDelType('no');
    if(version_account=='haige')
    {
         var quote_id=ld("#"+popupobj.divid+" [name=quote_id]").val();
        var dataurl="module=SalesOrder&action=SalesOrderAjax&file=SalesOrderQuoteCheck&quoteid="+quote_id;

            dataurl+='&salesorderrecord='+popupobj.record;

		var dataurl_export = "module=SalesOrder&action=SalesOrderAjax&file=SalesOrderQuoteCheckExport&quoteid="+quote_id;
        
        var rowcnt=ld("#"+popupobj.divid+" [name=rowcnt]").val();
      
        var ids=[];
        var quantitys=[];
        
        
        //for(var i=1;i<=rowcnt;i++)
        ld.each(trobjs,function(){
            //if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val()==0)
            //{
              ids.push(ld(this).find(" [detailcolumnname=hdnProductId]").val());
              quantitys.push(ld(this).find(" [name=quantity]").val());
            //}
        });
        dataurl+="&productids="+ids.join(",")+"&quantitys="+quantitys.join(',');
		dataurl_export+="&productids="+ids.join(",")+"&quantitys="+quantitys.join(',');
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
					if(error_msg != ''){
						error_msg += '<a href="index.php?'+dataurl_export+'" id="link_down" >下载错误日志</a>';
						
					}
                     RemindsMsg("","width450",popupobj.module,"","",error_msg);
                   ret=false;
                }
            }
        });
    }else if(version_account=='yiwen'){
        //@edit:liushuai,2020-07-20,reason:义文机电，销售订单：“是否出口”，“是否供方直发”，“首样报告”做功能控制,外币订单时，是否出口和是否供方直发必须有一个选是，才能保存，人民币时，都不能选是。
        //@edit:liushuai,2020-09-14,reason:【ID1001100】需求变更，是否出口和是否供方直发已经去掉了，改成发货方了
        var rowcnt=ld("#"+popupobj.divid+" [name=rowcnt]").val();
        var productId,quantity,moq,mpq,productCategory;
        //for(var i=1;i<=rowcnt;i++)
        ld.each(trobjs,function(){
            productId = ld(this).find(" [detailcolumnname=hdnProductId]").val();
            if(productId != undefined && productId > 0) { //表示有选择产品时才做判断
                // MOQ、MPQ 特殊判断
                quantity =ld(this).find(" [detailcolumnname=quantity]").val();// CrmPopup.getHtmlobjval(divid,'quantity'+i);//订单数量
                quantity = parseInt(quantity)?parseInt(quantity):0;
                moq =ld(this).find(" [detailcolumnname=cf_4221]").val(); //CrmPopup.getHtmlobjval(divid,'cf_4221'+i);//MOQ:最小订单数量
                moq = parseInt(moq)?parseInt(moq):0;
                mpq =ld(this).find(" [detailcolumnname=cf_4222]").val();// CrmPopup.getHtmlobjval(divid,'cf_4222'+i);//MPQ:最小打包数量
                mpq = parseInt(mpq)?parseInt(mpq):0;
                productCategory =ld(this).find(" [detailcolumnname=cf_2907]").val();// CrmPopup.getHtmlobjval(divid,'cf_2907'+i);// cf_29071:产品总类
                // console.log('quantity:'+quantity);console.log('moq:'+moq);console.log('mpq:'+mpq);
                if (productCategory == '代理品牌' || productCategory == '非代理品牌') {
                    if(quantity != moq || quantity != mpq || moq != mpq){
                        var confirm_str = arrJsPopLabel['NOTMEETMOQORMPQ'];
                        alert(confirm_str.replace(/{N}/, i));  // alert("第"+i+"行不符合MOQ或MPQ设定值");
                        // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str.replace(/{N}/, i));//新建弹出层会影响后面逻辑判断，除非紧跟return false
                        // return false;
                    }
                }

            }
        });
        
    }else if(version_account=='amks'){
        //@edit:liushuai,2020-08-31,reason:ID1001039/艾迈柯思“赠品提醒”个性化开发
        var rowcnt=ld("#"+popupobj.divid+" [name=rowcnt]").val();
        var productId,productname,quantity,taxprice,is_free,row;
        var product_jsonarr = [];//如果定义成 {}  就等于是 JSON.parse 之后的数据。
        var tmp_productId_arr = [];
        var product_arr = [];

         ld.each(trobjs,function(){
            productId = ld(this).find(" [detailcolumnname=hdnProductId]").val();
            if( productId != undefined && productId > 0) {
                productname =ld(this).find(" [detailcolumnname=productname]").val();// ld("#"+popupobj.divid+" [name=productname"+i+"]").val();
                // is_free = trim(ld("#"+popupobj.divid+" [name=sf5710"+i+"]").val()); //是否赠品 sf6963
                is_free = ld(this).find(" [name=cmb_span_optiontext_sf6963]").val();//trim(ld("#"+popupobj.divid+" [name=cmb_span_optiontext_sf6963"+i+"]").val())//是否赠品 sf6963
                quantity =ld(this).find(" [name=quantity]").val();// CrmPopup.getHtmlobjval(divid,'quantity'+i);//订单数量
                quantity = parseInt(quantity)?parseInt(quantity):0;
                // product_arr[i] =
                product_jsonarr[i] = {'tmp_productId':productId,'tmp_quantity':quantity,'tmp_is_free':is_free};
            }
        })

        // console.log(product_jsonarr);

        ld.each(trobjs,function(){
            productId = ld(this).find(" [detailcolumnname=hdnProductId]").val();
            if ( productId != undefined && productId > 0) { //表示有选择产品,没删除时才做判断
                // 判断是否是赠品
                productname =ld(this).find(" [detailcolumnname=productname]").val();// ld("#" + popupobj.divid + " [name=productname" + i + "]").val();//产品名称
                // is_free = trim(ld("#"+popupobj.divid+" [name=sf5710"+i+"]").val()); //是否赠品 sf6963
                is_free =ld(this).find(" [name=cmb_span_optiontext_sf6963]").val();;// trim(ld("#" + popupobj.divid + " [name=cmb_span_optiontext_sf6963" + i + "]").val())//是否赠品 sf6963

                quantity =ld(this).find(" [detailcolumnname=quantity]").val();// CrmPopup.getHtmlobjval(divid, 'quantity' + i);//订单数量
                quantity = parseInt(quantity) ? parseInt(quantity) : 0;
                taxprice = ld(this).find(" [detailcolumnname=taxprice]").val();;//CrmPopup.getHtmlobjval(divid, 'taxprice' + i);//单价（含税单价）
                taxprice = parseInt(taxprice) ? parseInt(taxprice) : 0;

                row = ld(this).attr("rowindex");//ld("#"+popupobj.divid+" [name=row"+i+"]").find('td').eq(1).text(); //行号

                if (taxprice == 0 && is_free != '是') { //情况三：单价为0，需要选择是赠品
                    var confirm_str = '第' + row + '行产品' + productname + '当前单价为0，是否赠品未选是，请修改后保存';
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return false;
                }
                if (taxprice != 0 && is_free == '是') { //情况三：选择是赠品,单价需要为0
                    var confirm_str = '第' + row + '行产品' + productname + '是赠品但当前单价不为0，请修改后保存';
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return false;
                }

                if (is_free == '是' && product_jsonarr.length - 1 < 2) {  //情况一：产品AAA选择了是赠品，但无正常销售的其他行(只有一行产品)
                    var confirm_str = '第' + row + '行产品' + productname + '选择了是赠品，但无正常销售数据，请修改后保存';
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return false;
                }
                if (is_free == '是') {  //情况一：产品AAA选择了是赠品，但无正常销售的其他行（多行产品但没有选择赠品的同类产品）
                    tmp_productId_arr = []; //多行产品需要 置空
                    for (var j = 1; j <= product_jsonarr.length - 1; j++) {  //rowcnt 添空行也算进去了，所以应该循环有选择产品的行，length - 1是因为数组索引默认为0，而我们是以当前行 为索引
                        if (j != i && product_jsonarr.hasOwnProperty(j) && product_jsonarr[j].hasOwnProperty('tmp_productId')) {  //去掉当前产品行 的判断  如果点击了中间产品删除按钮会导致product_jsonarr[j].tmp_productId未定义，需要排除
                            // console.log('j:'+j+"  i:"+i);
                            tmp_productId_arr[j] = product_jsonarr[j].tmp_productId;
                        }
                    }

                    

                    if (tmp_productId_arr.indexOf(productId) == -1) {
                        var confirm_str = '第' + row + '行产品' + productname + '选择了是赠品，但无正常销售数据，请修改后保存';
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                        return false;
                    } else {  //情况二：是赠品 也选择了 单价为0  ，还需要判断 赠品数量 是否小于  正常销售数量
                        if (product_jsonarr[tmp_productId_arr.indexOf(productId)].tmp_is_free == '是') {  //同一产品选择了两个是赠品
                            var confirm_str = '第' + row + '行产品' + productname + '选择了是赠品，但无正常销售数据，请修改后保存';
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                            return false;
                        }
                        if (product_jsonarr[tmp_productId_arr.indexOf(productId)].tmp_quantity < quantity) {
                            var confirm_str = '第' + row + '行产品' + productname + '选择了是赠品，但正常销售数量小于赠品数量，请修改后保存';
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                            return false;
                        }
                    }

                }
            }
        })
    }
    
   return ret;
}


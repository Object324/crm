//批量审批
function masscheckSendCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){ 
	//var url = 'module=SendCashBill&type=check&action=SendCashBillAjax&file=BankConfirm&idlist='+idlist;
	//RequestAjax(url,function(rest){
		//if(rest.indexOf('#####:success') > -1){
		  
          if(confirm_status){
            confirm_masscheckSendCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status);
          }else{//确定要进行审核吗？
            RemindsMsg("","LdPopWidth400px",module,"yes","yes",alert_str);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                confirm_masscheckSendCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status); 
            });                   
          }

		//}else{//您选择的记录有已审核的单据，不能进行批量审核！
			//alert(arrJsPopLabel['yhbsrcdnbb']);
		//}
	//});
	return false;
}
//审核付款单
function confirm_masscheckSendCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){
    url = 'module=SendCashBill&action=SendCashBillAjax&file=BankConfirm&type=checklist&return_module='+module;
	url += '&'+gstart+'&viewname='+viewid+'&idlist='+idlist+'&SearchScope='+searchscope;
	RequestAjax(url,function(rest){
		if(empty(rest)) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var divobj = createElementDivs('massApproveCashBill');
		ld(divobj).css('max-height','350px');
		ld('#massApproveCashBillcontent').css('max-height','250px');
		ld('#massApproveCashBillcontent').css('overflow-y','auto');
		var submitlog = '<div style="width:97%;margin-top:10px;margin-bottom:10px;line-height:22px;padding-left:10px;">';
		submitlog += restobj.log.value;//批量提交失败日志
		submitlog += '</div>';
		ld(divobj).find('div.D_pop_tit .D_ptita').html(restobj.title.value);
		ld('#massApproveCashBillcontent').html(submitlog);
		fnvshobj('', 'massApproveCashBill');
		ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
			fninvshnew('massApproveCashBill');lingdangJS_DialogBox.unblock();
			getId('allselectedboxes').value = '';
			getListViewEntries_js(module,'start='+restobj.start.value);//刷新页面
		});
	});
}
/*
edit:Can
date:20130606
reason:无付款计划金额
*/
function NoSendPayment(obj)
{
    var ret=true;
    if(obj == 'select')
        obj = document.getElementById('nosendpayment');
    var otherselect = document.getElementById('otherselect').value;    //调整 增加 减少
     if(isNaN(obj.value)&& trim(obj.value)!="")
    {
        //其它款项金额非法！
        var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        obj.focus();
        
        if(!document.all)
        {
             obj.select();
             window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
        }
        
        ret=false;
    }
    obj.value=trim(obj.value);
    if(obj.value=="")
    {
        obj.value=0;
    }
    var curvalue=0;
     var paymenttab=document.getElementById("proTab");
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
     {
       /*if(document.getElementById("chkPayment"+i).checked)
       {*/
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(document.getElementById("curSendCashBill"+i).value);
        }
          
       //}
     }
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(otherselect == 1)
        var total=curvalue+parseFloat(obj.value);
    else
        var total=curvalue-parseFloat(obj.value);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    document.getElementById("totalplayment").value =parseFloat(total).toFixed(2);
    return ret;
}
function setSendCashBillTotal(){
	
}
/*
edit:chj
date:2014-4-22
reason:调整回款计划总金额(v5.3)
*/
function selSendPayment(obj)
{
    var ret=true;
    var curvalue=0;
    var nopaymentplan = document.getElementById('nosendpayment').value;
    var paymenttab=document.getElementById("proTab");
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
    {
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(document.getElementById("curSendCashBill"+i).value);
        }
    }
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(obj == 1)
        var total=curvalue+parseFloat(nopaymentplan);
    else
        var total=curvalue-parseFloat(nopaymentplan);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    document.getElementById("totalplayment").value=parseFloat(total).toFixed(2)
    return ret;
}
function calSendTotal()
{
    var ret=true;
    var curvalue=0;

	var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}
    var nopaymentplan = parentwindow.document.getElementById('nosendpayment').value;
    var paymenttab=parentwindow.document.getElementById("proTab");
    var otherselect=parentwindow.document.getElementById("otherselect").value;
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
    {
        if(parentwindow.document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(parentwindow.document.getElementById("curSendCashBill"+i).value);   
        }
    }
    //求回款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=curvalue.toFixed(2);
    
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(otherselect == 1)
        var total=curvalue+parseFloat(nopaymentplan);
    else
        var total=curvalue-parseFloat(nopaymentplan);
    if(parentwindow.document.getElementById('span_sendcashbill_total') != undefined){
		parentwindow.document.getElementById('span_sendcashbill_total').innerHTML = parseFloat(total).toFixed(2);
	}
	if(parentwindow.document.getElementById('sendcashbill_total') != undefined){
		parentwindow.document.getElementById('sendcashbill_total').value = parseFloat(total).toFixed(2);
	}
	if(curvalue > 0){
		parentwindow.document.getElementById('span_sendcashbill_total').style.display = '';
		parentwindow.document.getElementById('sendcashbill_total').style.display = 'none';
	}else{
		parentwindow.document.getElementById('span_sendcashbill_total').style.display = 'none';
		parentwindow.document.getElementById('sendcashbill_total').style.display = '';
	}
	//totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
function deleteRowSendPayment(i)
{
	rowCnt--;
	var paymenttab = document.getElementById('proTab');
	var rowcount = paymenttab.rows.length;
	var dis_row = 0;

//	document.getElementById('proTab').deleteRow(i);
	document.getElementById("row"+i).style.display = 'none';
    document.getElementById('deleterow'+i).value = 1;
	for(var k=1;k<rowcount-3;k++)
    {
		if(document.getElementById('deleterow'+k).value == 0){
			dis_row++;
		}
	}
	//没有明细行
	if(dis_row == 0){
		if(document.getElementById('span_sendcashbill_total') != undefined){
			document.getElementById('span_sendcashbill_total').style.display = 'none';
		}
		if(document.getElementById('sendcashbill_total') != undefined){
			document.getElementById('sendcashbill_total').style.display = '';
		}
	}else{
		if(document.getElementById('span_sendcashbill_total') != undefined){
			document.getElementById('span_sendcashbill_total').style.display = '';
		}
		if(document.getElementById('sendcashbill_total') != undefined){
			document.getElementById('sendcashbill_total').style.display = 'none';
		}
	}
	updateCashbillSourceNo();
    ShowSequence();
}
/*
edit:Can
date:20130606
reason:本次付款金额改变
*/
function curSendCashBill(obj)
{
    var ret=true;
    if(obj!=undefined)
    {
         obj.value=trim(obj.value);
     
        if(isNaN(obj.value)&& obj.value!="")
        {
            //金额非法！
            //alert(arrJsPopLabel['AMOUNTILLEGAL']);
            //obj.focus();
             if(!document.all)
            {
                 obj.select();
                 window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
            }
    
            ret= false;
        }
        if(obj.value=="")
        {
            obj.value=0;
        }
    }
    else
    {
        obj=document.getElementById("curSendCashBill1");
    }
    if(obj==undefined)//有可能没有付款单
    {
        return ;
    }
     var chkName="curSendCashBill";//
     var rowindex=obj.name.substring(chkName.length);
     var paymenttab=document.getElementById("proTab");
     var tabtr=paymenttab.rows[rowindex];
    

     var curvalue=0;    
  
     var rowcount=paymenttab.rows.length;//总行数
     var nowtr;
     var nowtd;
     for(var i=1;i<rowcount-3;i++)
     {
       
        
       /*if(document.getElementById("chkPayment"+i).checked)
       {*/
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(document.getElementById("curSendCashBill"+i).value);
        }
          
      // }
        
     }
   
      //求付款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=curvalue.toFixed(2);
    document.getElementById("totalhaveplaymentamount").value = curvalue.toFixed(2);
    //求无付款计划和有付款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];//小计行
    var totalpaymenttd=totalpaymenttr.cells[1];
   var total=parseFloat(parseFloat(curvalue).toFixed(2))+parseFloat(document.getElementById("nosendpayment").value);
    document.getElementById("totalplayment").value = parseFloat(total).toFixed(2);
    if(document.getElementById('span_sendcashbill_total') != undefined){
		document.getElementById('span_sendcashbill_total').innerHTML = parseFloat(total).toFixed(2);
	}
	if(document.getElementById('sendcashbill_total') != undefined){
		document.getElementById('sendcashbill_total').value = parseFloat(total).toFixed(2);
	}
	//totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
/*
edit:can
date:20130710
reason:付款单上采购订单清除后清除相应的付款计划列表

*/
function ClearSendPaymentList(module)
{
   
    var tabpay=document.getElementById("proTab");
    if(tabpay!=undefined)
    {
        for(var i=1;i<tabpay.rows.length-3;i++)
        {
            tabpay.deleteRow(i);
        }
         tabpay.rows[tabpay.rows.length-3].cells[1].innerHTML=0.00;
        tabpay.rows[tabpay.rows.length-1].cells[1].innerHTML=document.getElementById("nosendpayment").value;
    }
    return false;
}
/*
edit:Can
date:20130606
reason:选择行（checkbox)
*/

function checkedamount_click(obj)
{
     var chkName="chkPayment";//
     var rowindex=obj.name.substring(chkName.length);
     var paymenttab=document.getElementById("proTab");
     var tabtr=paymenttab.rows[rowindex];
     
     var tabtdamount=tabtr.cells[5];//金额
     var tabtdactualamount=tabtr.cells[6];//实付金额
     var tabtdCashBill=tabtr.cells[7];//本次付款
     var curvalue=0;
    
    if(obj.checked)
    {
        obj.value="0";
        
         curvalue=parseFloat(tabtdamount.innerHTML)-parseFloat(tabtdactualamount.innerHTML);
        tabtdCashBill.innerHTML='<input type="text" value="'+parseFloat(curvalue).toFixed(2)+'" onchange="return curSendCashBill(this)"  name="curSendCashBill'+rowindex+'" id="curSendCashBill'+rowindex+'"/>'
    }
    else 
    {
        obj.value="1";
        curvalue=parseFloat(document.getElementById("curSendCashBill"+rowindex).value);
        curvalue=0-curvalue;
        tabtdCashBill.innerHTML='<input type="text"  readonly="true"  name="curSendCashBill'+rowindex+'" id="curSendCashBill'+rowindex+'"/>';
        
    }
    var rowcount=paymenttab.rows.length;//总行数
    
    //求付款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    if(trim(paymenttd.innerHTML)=="")
    {
        paymenttd.innerHTML=0.00;
    }
  
    paymenttd.innerHTML=(parseFloat(curvalue)+parseFloat(paymenttd.innerHTML)).toFixed(2);
    
    //求无付款计划和有付款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    
    if(trim(totalpaymenttd.innerHTML)=='')
        totalpaymenttd.innerHTML=0;
    var total=curvalue+parseFloat(totalpaymenttd.innerHTML);
    if(document.getElementById('span_sendcashbill_total') != undefined){
		document.getElementById('span_sendcashbill_total').innerHTML = parseFloat(total).toFixed(2);
	}
	if(document.getElementById('sendcashbill_total') != undefined){
		document.getElementById('sendcashbill_total').value = parseFloat(total).toFixed(2);
	}
   // totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
}
/*
edit:can
date;20130606
reason:付款单保存判断付款计划信息
*/
function verifySendPayment()
{
    
     var paymenttab=document.getElementById("proTab");
      var rowcount=paymenttab.rows.length;//总行数
     var nowtr;
     var acutalamount=0;//已付（实付)金额
     var amount=0;//计划金额
     var ret=true;
     for(var i=1;i<rowcount-3;i++)
     {
        /*if(document.getElementById("chkPayment"+i).checked)
        {*/
             if(trim(document.getElementById("curSendCashBill"+i).value)=="")
             {
                document.getElementById("curSendCashBill"+i).value=0;
             }
              
             if(isNaN(document.getElementById("curSendCashBill"+i).value))
             {
                //无效的本次付款！
                var confirm_str = arrJsPopLabel['INVALIDPAYMENT'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("curSendCashBill"+i).focus();
                
                ret=false;
             }
             
            //nowtr=paymenttab.rows[i];
            //acutalamount=parseFloat(nowtr.cells[7].innerHTML);//已付金额
            //amount=parseFloat(nowtr.cells[6].innerHTML);//计划金额
            /*if(parseFloat(document.getElementById("curSendCashBill"+i).value)>(amount-acutalamount))
            {
                //本次付款不能超过“金额-已付金额”，请重新录入！
                alert(arrJsPopLabel['PAYMENTSCANOTEXCEEDPAID']);
                document.getElementById("curSendCashBill"+i).focus();
                ret=false;
            }*/
         /*}*/
     }
     /*if(trim(document.getElementById("nosendpayment").value)!="" && isNaN(document.getElementById("nosendpayment").value))
     {
        //无效无付款计划金额！
        alert(arrJsPopLabel['INVALIDPLANAMOUNT']);
        document.getElementById("nosendpayment").focus();
        ret=false;
     }*/
     if(trim(document.getElementById("nosendpayment").value)=="")
     {
        document.getElementById("nosendpayment").value=0;
     }
    
    if(!formValidate())
    {
        return false;
    }
     return ret;
}

/*
Edit:Can
date:20130614
reason:全选
*/
function chkAll(obj)
{
     var paymenttab=document.getElementById("proTab");
     var rowcount=paymenttab.rows.length;
     var tabtr;
     var tabtdamount;
     var tabtdactualamount;
     var tabtdCashBill;
     
     var curvalue=0;
     var totalvalue=0;
     if(obj.checked)
     {
        for(var i=1;i<rowcount-3;i++)
         {
            tabtr=paymenttab.rows[i];
            tabtdamount=tabtr.cells[5];//金额
            tabtdactualamount=tabtr.cells[6];//实付金额
            tabtdCashBill=tabtr.cells[7];//本次付款
          
            document.getElementById("chkPayment"+i).checked=true;
            document.getElementById("chkPayment"+i).value="0";
            curvalue=parseFloat(tabtdamount.innerHTML)-parseFloat(tabtdactualamount.innerHTML);
            totalvalue=parseFloat(totalvalue)+curvalue;
            tabtdCashBill.innerHTML='<input type="text" value="'+parseFloat(curvalue).toFixed(2)+'" onchange="return curSendCashBill(this)"  name="curSendCashBill'+i+'" id="curSendCashBill'+i+'"/>'
         }
     }
     else 
     {
         for(var i=1;i<rowcount-3;i++)
         {
            tabtr=paymenttab.rows[i];
            tabtdCashBill=tabtr.cells[7];//本次付款
            document.getElementById("chkPayment"+i).checked=false;
            document.getElementById("chkPayment"+i).value="1";
            tabtdCashBill.innerHTML='<input type="text"  readonly="true"  name="curSendCashBill'+i+'" id="curSendCashBill'+i+'"/>'
         }
     }
     var rowcount=paymenttab.rows.length;//总行数
    
    //求付款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=parseFloat(totalvalue).toFixed(2);
   
    //求无付款计划和有付款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
     var nopaymentamount=document.getElementById("nosendpayment").value;
    var totalamount=parseFloat(parseFloat(totalvalue).toFixed(2))+parseFloat(nopaymentamount);
    totalpaymenttd.innerHTML=parseFloat(totalamount).toFixed(2);
}

function checkcashbill(id,type,ctype)
{
    if(type==1){
        var confirm_str = arrJsPopLabel['stcoy'];
    }else if(type==2){
        var confirm_str = arrJsPopLabel['stacoy'];
    }
    
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){   
        new Ajax.Request("index.php",
            {
                queue:{
                    position:"end",
                    scope:"command"
                },
                method:"post",
                postBody:"action=BankConfirm&module=SendCashBill&type="+type+"&record="+id,
                onComplete:function (response) {
                  if(ctype == 1)
                  {
                    window.location.href="index.php?module=SendCashBill&action=DetailView&record="+id; 
                  }
                  else if(ctype == 2)
                  {
                    window.location.href="index.php?module=SendCashBill&action=DetailView&record="; 
                  }
                }
            }
        ); 
    });   
}


/**
 * 给原单项添加对应编号
 * @param
 * @returns
 * @author Chj 
 */
function getSendPaymentList_PurchaseOrderNo(){
	var tableName = document.getElementById('proTab');
	var prev = tableName.rows.length;
	var rowcount = eval(prev)-3;//3:代表 模块明细的描述 减去：小计、调整、合计
	var purOrder_array = new Array();
	for(var i=1; i<=rowcount-1; i++){//减去1  代表减去列头
		if(document.getElementById('deleterow'+i).value == 0){
			var purchaseorder_no = document.getElementById('hidden_purchaseorder'+i).value;
			purOrder_array[i-1] = purchaseorder_no;
		}
	}
	if(purOrder_array.length > 0){
		if(document.getElementById('purchaseorder_id') != undefined){
			document.getElementById('purchaseorder_id').value = purOrder_array.join(',');
		}
	}
}

//V6.5:财务和库存单据选择源单  使用橡皮擦，清除供应商或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearVendors.other_clear=function()
{
    clearModuleProduct(this,'SendCashBill',''); 
}
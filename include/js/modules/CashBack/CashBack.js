/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

/*
edit:Can
date:20130606
reason:无付款计划金额
*/
function NoSendPayment(obj)
{
    var ret=true;
     if(isNaN(obj.value)&& trim(obj.value)!="")
    {
        //其它款项金额非法！
        alert(arrJsPopLabel['INVALIDADJUSTMENTAMOUNT']);
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
     var paymenttab=document.getElementById("SendPaymentList");
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
     {
       if(document.getElementById("chkPayment"+i).checked)
       {
          curvalue=curvalue+parseFloat(document.getElementById("curSendCashBill"+i).value);
          
       }
     }
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
  
    var total=curvalue+parseFloat(obj.value);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}

/*
edit:Can
date:20130606
reason:本次付款金额改变
*/
function curSendCashBill(obj)
{
     obj.value=trim(obj.value);
     var ret=true;
    if(isNaN(obj.value)&& obj.value!="")
    {
        //金额非法！
        alert(arrJsPopLabel['AMOUNTILLEGAL']);
        obj.focus();
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
     var chkName="curSendCashBill";//
     var rowindex=obj.name.substring(chkName.length);
     var paymenttab=document.getElementById("SendPaymentList");
     var tabtr=paymenttab.rows[rowindex];
     var tabtdamount=tabtr.cells[5];//金额
     var tabtdactualamount=tabtr.cells[6];//实付金额
     var tabtdCashBill=tabtr.cells[7];//本次付款
     var curvalue=0;
     if(obj.value>(parseFloat(tabtdamount.innerHTML)-parseFloat(tabtdactualamount.innerHTML)))
     {
        //本次付款不能超过“金额-已付金额”，请重新录入！
        alert(arrJsPopLabel['PAYMENTSCANOTEXCEEDPAID']);
        obj.focus();
         if(!document.all)
        {
             obj.select();
             window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
        }
        ret= false;
     }
     var rowcount=paymenttab.rows.length;//总行数
     var nowtr;
     var nowtd;
     for(var i=1;i<rowcount-3;i++)
     {
       if(document.getElementById("chkPayment"+i).checked)
       {
          curvalue=curvalue+parseFloat(document.getElementById("curSendCashBill"+i).value);          
       }
        
     }
     
     
      //求付款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=curvalue.toFixed(2);
    
    //求无付款计划和有付款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
   var total=parseFloat(parseFloat(curvalue).toFixed(2))+parseFloat(document.getElementById("nosendpayment").value);

    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
/*
edit:can
date:20130710
reason:付款单上采购订单清除后清除相应的付款计划列表

*/
function ClearSendPaymentList(module)
{
   
    var tabpay=document.getElementById("SendPaymentList");
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
     var paymenttab=document.getElementById("SendPaymentList");
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
    
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
}
/*
edit:can
date;20130606
reason:付款单保存判断付款计划信息
*/
function verifySendPayment()
{

     var paymenttab=document.getElementById("SendPaymentList");
     var rowcount=paymenttab.rows.length;//总行数
     var nowtr;
     var acutalamount=0;//已付（实付)金额
     var amount=0;//计划金额
     var ret=true;
     
     for(var i=1;i<rowcount-3;i++)
     {
        if(document.getElementById("chkPayment"+i).checked)
        {
             if(trim(document.getElementById("curSendCashBill"+i).value)=="")
             {
                document.getElementById("curSendCashBill"+i).value=0;
             }
              
             if(isNaN(document.getElementById("curSendCashBill"+i).value))
             {
                //无效的本次付款！
                alert(arrJsPopLabel['INVALIDPAYMENT']);
                document.getElementById("curSendCashBill"+i).focus();
                
                ret=false;
             }
             
            nowtr=paymenttab.rows[i];
            acutalamount=parseFloat(nowtr.cells[6].innerHTML);//已付金额
            amount=parseFloat(nowtr.cells[5].innerHTML);//计划金额
            if(parseFloat(document.getElementById("curSendCashBill"+i).value)>(amount-acutalamount))
            {
                //本次付款不能超过“金额-已付金额”，请重新录入！
                alert(arrJsPopLabel['PAYMENTSCANOTEXCEEDPAID']);
                document.getElementById("curSendCashBill"+i).focus();
                ret=false;
            }
            
         }
     }
     if(trim(document.getElementById("nosendpayment").value)!="" && isNaN(document.getElementById("nosendpayment").value))
     {
        //无效无付款计划金额！
        alert(arrJsPopLabel['INVALIDPLANAMOUNT']);
        document.getElementById("nosendpayment").focus();
        ret=false;
     }
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
     var paymenttab=document.getElementById("SendPaymentList");
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



/*
edit:diony
date:20140717
reason:采购退货单、采购退款单判断金额是否超过 
*/
function validatePurchaseTotal(module)
{
    var vstring = new Array();
    var max_row_count = document.getElementById('rowcnt').value;
	var currency_id = 0;
    for(var i = 1; i<=max_row_count; i++)
    {
        if(document.getElementById('hidden_rowid_'+i).value == 0){
            vstring[i-1] = document.getElementById('hdnProductId'+i).value +'-'+ document.getElementById('quantity'+i).value +'-'+ document.getElementById('total').value+'-'+document.getElementById('lineitem_id'+i).value;
        }
    }
 
        var record = document.EditView.salesbackid.value;
        var cashbackid = document.EditView.record.value;
        if(cashbackid.length==0)
        { 
            cashbackid = 0;
        }
        url = "index.php?module=SalesBack&action=SalesBackAjax&file=SalesBackOperation&parenttab=Sales&record="+record+"&cashbackid="+cashbackid+"&idstring="+vstring+"&type=savecashcheck";
		//alert(url);return false;
    http_reqfield=createfieldXMLHTTP();
    http_reqfield.open("POST",url,false);
    isDuplicate=false;
    http_reqfield.onreadystatechange=RequestPurchaseBack;
    http_reqfield.setRequestHeader("If-Modified-Since","0");
    http_reqfield.send();
    if(isDuplicate == false)
    {
        return true;
    }
    return false;
}


function RequestPurchaseBack()
{
    if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
    {
        var str=http_reqfield.responseText;
    	if(str.indexOf('###SUCCESS###') >= 0)
        {
           isDuplicate=false;
        }
        else
        {
            var results=str.split('###ERROR###');
            puyoungJS_DialogBox.unblock();
            if(results[1] == 2)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS1']);
            }
            else if(results[1] == 3)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS2']);
            }
            else if(results[1]==50)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS50']);
                
            }
            else if(results[1] == 4)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS3']);
            }
            else if(results[1] == 5)
            {
                alert(arrJsPopLabel['THENUMBEROFRETURNS4']);
            }	
            isDuplicate=true;
        }
    }
}
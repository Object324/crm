
/*
function trim(str){   
  
    str = str.replace(/^(\s|\u00A0)+/,'');   
    for(var i=str.length-1; i>=0; i--){   
        if(/\S/.test(str.charAt(i))){   
            str = str.substring(0, i+1);   
            break;   
        }   
    }   
    return str;   
}  */
//批量审核
function masscheckCashBill(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){
	//var url = 'module=CashBill&type=check&action=CashBillAjax&file=BankConfirm&idlist='+idlist;
	//RequestAjax(url,function(rest){
		//if(rest.indexOf('#####:success') > -1){
            if(confirm_status){
                confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status);
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                //点击确认
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status);
                }); 
            }
}

function confirm_massCheck(alert_str,module,gstart,viewid,idlist,searchscope,confirm_status){
    var url = 'module=CashBill&action=CashBillAjax&file=BankConfirm&type=checklist&return_module='+module;
    url += '&'+gstart+'&viewname='+viewid+'&idlist='+idlist+'&SearchScope='+searchscope;
    RequestAjax(url,function(rest){
        if(empty(rest)) return false;
        var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
        var divobj = createElementDivs('massApproveCashBill');
        ld(divobj).css('max-height','350px');
        ld('#massApproveCashBillcontent').css('max-height','250px');
        ld('#massApproveCashBillcontent').css('overflow-y','auto');
        var submitlog = '<div style="width:97%;line-height:22px;padding-left:10px;">';
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
reason:无回款计划金额
*/
function nopayment(obj)
{
    var ret=true;
    if(obj == 'select')
        obj = document.getElementById('nopaymentplan');
    var otherselect = document.getElementById('otherselect').value;    //调整 增加 减少
     if(isNaN(obj.value)&& trim(obj.value)!="")
    {
        //无回款计划金额非法！
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
        var curCashBill = document.getElementById("curCashBill"+i);
        if(isNaN(curCashBill.value) || curCashBill.value=='')
            curCashBill.value = 0;
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(curCashBill.value);
        }   
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
function deleteRowPayment(i)
{
	//rowCnt--;
	var paymenttab = document.getElementById('proTab');
	var rowcount = paymenttab.rows.length;
	var dis_row = 0;
//	document.getElementById('proTab').deleteRow(i);
    if(document.getElementById("row"+i) != undefined){
        document.getElementById("row"+i).style.display = 'none';   
    }
    if(document.getElementById('deleterow'+i) != undefined){
        document.getElementById('deleterow'+i).value = 1;   
    }
	for(var k=1;k<rowcount-3;k++)
    {
		if(document.getElementById('deleterow'+k).value == 0){
			dis_row++;
		}
	}
	//没有明细行
	if(dis_row == 0){
		if(document.getElementById('span_cashbill_total') != undefined){
			document.getElementById('span_cashbill_total').style.display = 'none';
		}
		if(document.getElementById('cashbill_total') != undefined){
			document.getElementById('cashbill_total').style.display = '';
		}
	}else{
		if(document.getElementById('span_cashbill_total') != undefined){
			document.getElementById('span_cashbill_total').style.display = '';
		}
		if(document.getElementById('cashbill_total') != undefined){
			document.getElementById('cashbill_total').style.display = 'none';
		}
	}
	updateCashbillSourceNo();
    ShowSequence();
}
function setCashBillTotal(obj){
	if(document.getElementById('span_cashbill_total') != undefined){
		document.getElementById('span_cashbill_total').innerHTML = obj.value;
	}
}
function caltotal()
{
    var ret=true;
    var curvalue=0;
	var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}
    var nopaymentplan = parentwindow.document.getElementById('nopaymentplan').value;
    var paymenttab=parentwindow.document.getElementById("proTab");
    var otherselect=parentwindow.document.getElementById("otherselect").value;
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
    {
        if(parentwindow.document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(parentwindow.document.getElementById("curCashBill"+i).value);   
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
	if(parentwindow.document.getElementById('span_cashbill_total') != undefined){
		parentwindow.document.getElementById('span_cashbill_total').innerHTML = parseFloat(total).toFixed(2);
	}
	if(parentwindow.document.getElementById('cashbill_total') != undefined){
		parentwindow.document.getElementById('cashbill_total').value = parseFloat(total).toFixed(2);
	}
	if(curvalue > 0){
		parentwindow.document.getElementById('span_cashbill_total').style.display = '';
		parentwindow.document.getElementById('cashbill_total').style.display = 'none';
	}else{
		parentwindow.document.getElementById('span_cashbill_total').style.display = 'none';
		parentwindow.document.getElementById('cashbill_total').style.display = '';
	}
    //totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
/*
edit:chj
date:2014-4-22
reason:调整回款计划总金额(v5.3)
*/
function selpayment(obj)
{
    var ret=true;
    var curvalue=0;
    var paymenttab=document.getElementById("proTab");
    var rowcount=paymenttab.rows.length;//总行数
    var nopaymentplan = document.getElementById('nopaymentplan');
    if(isNaN(nopaymentplan.value) || nopaymentplan.value=='')
        nopaymentplan.value = 0;
    for(var i=1;i<rowcount-3;i++)
    {
        var curCashBill = document.getElementById("curCashBill"+i);
        if(isNaN(curCashBill.value) || curCashBill.value=='')
            curCashBill.value = 0;
        curvalue=curvalue+parseFloat(curCashBill.value);
    }
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    if(obj == 1)
        var total=curvalue+parseFloat(nopaymentplan.value);
    else
        var total=curvalue-parseFloat(nopaymentplan.value);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    document.getElementById("totalplayment").value=parseFloat(total).toFixed(2)
    return ret;
}
/*
edit:Can
date:20130606
reason:本次收款金额改变
*/
function curCashBill(obj)
{
    obj.value=trim(obj.value);
    var ret=true;
    if(isNaN(obj.value)&& obj.value!="")
    {
        //金额非法！
        var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
    var chkName="curCashBill";//
    var rowindex=obj.name.substring(chkName.length);
    var paymenttab=document.getElementById("proTab");
    var tabtr=paymenttab.rows[rowindex];
    var tabtdamount=tabtr.cells[6];//金额
    var tabtdactualamount=tabtr.cells[7];//实收金额
    var tabtdCashBill=tabtr.cells[10];//本次收款
    var curvalue=0;
    var rowcount=paymenttab.rows.length;//总行数
    var nowtr;
    var nowtd;
    for(var i=1;i<rowcount-3;i++)
    {
        var curCashBill = document.getElementById("curCashBill"+i);
        if(isNaN(curCashBill.value) || curCashBill.value=='')
            curCashBill.value = 0;
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(curCashBill.value);
        }   
    }  
    var nopaymentplan = document.getElementById("nopaymentplan");
    if(isNaN(nopaymentplan.value) || nopaymentplan.value=='')
        nopaymentplan.value = 0;
    //求回款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=curvalue.toFixed(2);
    document.getElementById("totalhaveplaymentamount").value = curvalue.toFixed(2);
    //求无回款计划和有回款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    var otherselect = document.getElementById('otherselect').value;    //调整 增加 减少
    if(otherselect == 1)  
        var total=parseFloat(parseFloat(curvalue).toFixed(2))+parseFloat(nopaymentplan.value);
    else
        var total=parseFloat(parseFloat(curvalue).toFixed(2))-parseFloat(nopaymentplan.value);
    document.getElementById("totalplayment").value = parseFloat(total).toFixed(2);
	if(document.getElementById('span_cashbill_total') != undefined){
		document.getElementById('span_cashbill_total').innerHTML = parseFloat(total).toFixed(2);
	}
	if(document.getElementById('cashbill_total') != undefined){
		document.getElementById('cashbill_total').value = parseFloat(total).toFixed(2);
	}
    //totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
/*
edit:can
date:20130710
reason:收款单上合同订单清除后清除相应的回款计划列表
*/
function ClearPaymentList(module)
{
   
    var tabpay=document.getElementById("proTab");
    if(tabpay!=undefined)
    {
        for(var i=1;i<tabpay.rows.length-3;i++)
        {
            tabpay.deleteRow(i);
        }
         tabpay.rows[tabpay.rows.length-3].cells[1].innerHTML=0.00;
        tabpay.rows[tabpay.rows.length-1].cells[1].innerHTML=document.getElementById("nopaymentplan").value;
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
     var tabtdactualamount=tabtr.cells[6];//实收金额
     var tabtdCashBill=tabtr.cells[7];//本次收款
     var curvalue=0;
    
    if(obj.checked)
    {
         obj.value="0";
         curvalue=parseFloat(tabtdamount.innerHTML)-parseFloat(tabtdactualamount.innerHTML);         
         tabtdCashBill.innerHTML='<input type="text" value="'+parseFloat(curvalue).toFixed(2)+'" onchange="return curCashBill(this)"  name="curCashBill'+rowindex+'" id="curCashBill'+rowindex+'"/>'
    }
    else 
    {
        obj.value="1";
        curvalue=parseFloat(document.getElementById("curCashBill"+rowindex).value);
        curvalue=0-curvalue;
        tabtdCashBill.innerHTML='<input type="text"  readonly="true"  name="curCashBill'+rowindex+'" id="curCashBill'+rowindex+'"/>';
        
    }
    var rowcount=paymenttab.rows.length;//总行数
    
    //求回款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
if(trim(paymenttd.innerHTML)=="")
{
    paymenttd.innerHTML=0.00;
}
  
    paymenttd.innerHTML=(parseFloat(curvalue)+parseFloat(paymenttd.innerHTML)).toFixed(2);
    
    //求无回款计划和有回款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    var total=curvalue+parseFloat(totalpaymenttd.innerHTML);
    
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
}
/*
edit:can
date;20130606
reason:收款单保存判断回款计划信息
*/
function verifyPaymentPlan()
{

     var paymenttab=document.getElementById("proTab");
     var rowcount=paymenttab.rows.length;//总行数
     var nowtr;
     var acutalamount=0;//已收（实收)金额
     var amount=0;//计划金额
     var ret=true;
     
     for(var i=1;i<rowcount-3;i++)
     {        
        /*if(document.getElementById("chkPayment"+i).checked)
        {*/
             if(trim(document.getElementById("curCashBill"+i).value)=="")
             {
                document.getElementById("curCashBill"+i).value=0;
             }
              
             if(isNaN(document.getElementById("curCashBill"+i).value))
             {
                //无效的本次收款！
                var confirm_str = arrJsPopLabel['INVALIDCOLLECTION'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("curCashBill"+i).focus();
                
                ret=false;
             }
             
             
           /* nowtr=paymenttab.rows[i];
           acutalamount=parseFloat(nowtr.cells[7].innerHTML);//已收金额
           amount=parseFloat(nowtr.cells[6].innerHTML);//计划金额
           经过讨论暂时注释
            
            if(parseFloat(document.getElementById("curCashBill"+i).value)>(amount-acutalamount))
            {
                //本次收款不能超过“金额-已收金额”，请重新录入！
                alert(arrJsPopLabel['COLLECTIONCANOTEXCEEDRECEIVED']);
                document.getElementById("curCashBill"+i).focus();
                ret=false;
            }*/
            
         //}
     }
    /* if(trim(document.getElementById("nopaymentplan").value)!="" && isNaN(document.getElementById("nopaymentplan").value))
     {
        //无效无回款计划金额！
        alert(arrJsPopLabel['INVALIDPAYMENTPLAN']);
        document.getElementById("nopaymentplan").focus();
        ret=false;
     }
     if(trim(document.getElementById("nopaymentplan").value)=="")
     {
        document.getElementById("nopaymentplan").value=0;
     }*/
    
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
            tabtdactualamount=tabtr.cells[6];//实收金额
            tabtdCashBill=tabtr.cells[7];//本次收款
          
            //document.getElementById("chkPayment"+i).checked=true;
            //document.getElementById("chkPayment"+i).value="0";
            curvalue=parseFloat(tabtdamount.innerHTML)-parseFloat(tabtdactualamount.innerHTML);
            totalvalue=parseFloat(totalvalue)+curvalue;
            tabtdCashBill.innerHTML='<input type="text" value="'+parseFloat(curvalue).toFixed(2)+'" onchange="return curCashBill(this)"  name="curCashBill'+i+'" id="curCashBill'+i+'"/>'
         }
         //alert(totalvalue);
         
     }
     else 
     {
         for(var i=1;i<rowcount-3;i++)
         {
            tabtr=paymenttab.rows[i];
         
            tabtdCashBill=tabtr.cells[7];//本次收款
            //document.getElementById("chkPayment"+i).checked=false;
            //document.getElementById("chkPayment"+i).value="1";
            tabtdCashBill.innerHTML='<input type="text"  readonly="true"  name="curCashBill'+i+'" id="curCashBill'+i+'"/>'
         }
     }
        
     
     var rowcount=paymenttab.rows.length;//总行数
    
    //求回款计划的总金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=parseFloat(totalvalue).toFixed(2);
    
    //求无回款计划和有回款计划的总金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
     var nopaymentamount=document.getElementById("nopaymentplan").value;
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

    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        new Ajax.Request("index.php",
            {
                queue:{
                    position:"end",
                    scope:"command"
                },
                method:"post",
                postBody:"action=BankConfirm&module=CashBill&type="+type+"&record="+id,
                onComplete:function (response) {
                  if(ctype == 1)
                  {
                    window.location.href="index.php?module=CashBill&action=DetailView&record="+id; 
                  }
                  else if(ctype == 2)
                  {
                    window.location.href="index.php?module=BankAccountSet&action=DetailView&record="; 
                  }
                }
            }
        );  
    });
}
clearAccountsContactsInfo.other_clear=function()
{
  clearModuleProduct("",'CashBill','');
}
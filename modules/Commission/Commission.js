/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/**
type:表示佣金还是佣金比例.1:佣金比例,2:佣金
**/
function curCommission(obj,type,row)
{
    obj.value=trim(obj.value);
    var ret=true;
    if(!isNaN(obj.value)&& obj.value=="")
    {
        //金额非法！
        var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        obj.focus();
    }
    if(obj.value=="")
        obj.value=0;
    if(type == 1)
        var chkName="rate";//
    else
        var chkName="noamount";//
    var rowindex=obj.name.substring(chkName.length);
    var paymenttab=document.getElementById("proTab");
    var tabtr=paymenttab.rows[rowindex];
    //var salesorderamount=tabtr.cells[2].innerHTML;
    var salesorderamount = document.getElementById('salesordertotal'+row).value;
    var curvalue=0;
    var rowcount=paymenttab.rows.length;//总行数
    if(document.getElementById("rate"+rowindex)!=undefined && document.getElementById("rate"+rowindex).value == "")
        document.getElementById("rate"+rowindex).value = 0;
    if(document.getElementById("noamount"+rowindex).value == "")
        document.getElementById("noamount"+rowindex).value = 0;
    
    if(type == 2)
    {
		//佣金单，更改币种，金额比列不正确
		if(document.EditView.hidden_currency_id != undefined)
		{
			var hidden_currency_id = document.EditView.hidden_currency_id.value;//选中后的币种类型
			var hidden_currency_rate= parseFloat(document.EditView.hidden_currency_rate.value);//选中后的币种汇率
			var entity_currency_id = document.getElementById('currency_id'+row).value;//原单的币种类型
			var entity_cnversion_rate = parseFloat(document.getElementById('cnversion_rate'+row).value);//原单的币种汇率
			
            //如果选择的币种类型不等于原单的币种
			if(hidden_currency_id != entity_currency_id)
			{
				//选中的币种为人民币
				if(hidden_currency_id == 1)
				{
					//汇率 = 佣金金额*选中币种汇率/原单金额
					var rate = parseFloat(document.getElementById("noamount"+rowindex).value)*entity_cnversion_rate/(parseFloat(salesorderamount)*0.01);
				}
				else{
					//汇率 = 佣金金额*选中币种汇率/原单币种汇率/原单金额
					var rate = parseFloat(document.getElementById("noamount"+rowindex).value)/hidden_currency_rate*entity_cnversion_rate/(parseFloat(salesorderamount)*0.01);
				}
			}
			else{
				var rate = parseFloat(document.getElementById("noamount"+rowindex).value)/(parseFloat(salesorderamount)*0.01);
			}
		}
		else{
			var rate = parseFloat(document.getElementById("noamount"+rowindex).value)/(parseFloat(salesorderamount)*0.01);
		}

        if(document.getElementById("rate"+rowindex) != undefined)
            document.getElementById("rate"+rowindex).value = parseFloat(rate).toFixed(2); 
    }
    else
    {
        
       	    if(document.EditView.hidden_currency_id != undefined)
		   {
    			var hidden_currency_id = document.EditView.hidden_currency_id.value;//选中后的币种类型
    			var hidden_currency_rate= parseFloat(document.EditView.hidden_currency_rate.value);//选中后的币种汇率
    			var entity_currency_id = document.getElementById('currency_id'+row).value;//原单的币种类型
    			var entity_cnversion_rate = parseFloat(document.getElementById('cnversion_rate'+row).value);//原单的币种汇率
                if(hidden_currency_id!=entity_currency_id)
                {
                    var noamount = parseFloat(salesorderamount) * parseFloat(document.getElementById("rate"+rowindex).value)/100;
                    if(hidden_currency_id==1)
                    {
                        noamount=noamount/entity_cnversion_rate;
                    }
                    else
                    {
                        noamount=noamount/hidden_currency_rate*entity_cnversion_rate;
                    }
                    document.getElementById("noamount"+rowindex).value = parseFloat(noamount).toFixed(2);  
                }
                else
                {
                    var noamount = parseFloat(salesorderamount) * parseFloat(document.getElementById("rate"+rowindex).value)/100;
                    document.getElementById("noamount"+rowindex).value = parseFloat(noamount).toFixed(2);  
                }
                
           } 
    }
    for(var i=1;i<rowcount-3;i++)
    {
        var noamount = document.getElementById("noamount"+i);
        if(isNaN(noamount.value) || noamount.value=='')
            noamount.value = 0;
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue = curvalue + parseFloat(noamount.value);
        }
    }
    var setnoamount = document.getElementById("setnoamount").value;
    if(setnoamount == "")
        setnoamount = 0;
    //佣金金额
    var paymenttr=paymenttab.rows[rowcount-3];
    var paymenttd=paymenttr.cells[1];
    paymenttd.innerHTML=curvalue.toFixed(2);
    document.getElementById("totalhaveplaymentamount").value=curvalue.toFixed(2);

    //佣金中金额
    var totalpaymenttr=paymenttab.rows[rowcount-1];
    var totalpaymenttd=totalpaymenttr.cells[1];
    var otherselect = document.getElementById('otherselect').value;    //调整 增加 减少
    if(otherselect == 1)
        var total=parseFloat(parseFloat(curvalue).toFixed(2))+parseFloat(setnoamount);
    else
        var total=parseFloat(parseFloat(curvalue).toFixed(2))-parseFloat(setnoamount);
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    document.getElementById("totalplayment").value=parseFloat(total).toFixed(2);
    return ret;
}



function deleteRowPayment(i)
{
    if(document.getElementById("row"+i) != undefined){
        document.getElementById("row"+i).style.display = 'none';   
    }
    if(document.getElementById('deleterow'+i) != undefined){
        document.getElementById('deleterow'+i).value = 1;   
    }
}
function caltotal()
{
    var ret=true;
    var curvalue=0;
    var nopaymentplan = document.getElementById('setnoamount').value;
    var paymenttab=document.getElementById("proTab");
    var otherselect=document.getElementById("otherselect").value;
    var rowcount=paymenttab.rows.length;//总行数
    for(var i=1;i<rowcount-3;i++)
    {
        var noamount = document.getElementById("noamount"+i);
        if(isNaN(noamount.value) || noamount.value=='')
            noamount.value = 0;
        if(document.getElementById("deleterow"+i).value == 0)
        {
            curvalue=curvalue+parseFloat(noamount.value);   
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
    totalpaymenttd.innerHTML=parseFloat(total).toFixed(2);
    return ret;
}
function caltotal_Detail()
{
	if(document.getElementById('subtotal_amount') != undefined){
		var curvalue=document.getElementById('subtotal_amount').innerHTML;
		var adjustmentType = '+';
		var nomount_value=0;
		if(document.getElementById('adjustmentType') != undefined){
			adjustmentType = document.getElementById('adjustmentType').value; //调整 增加 减少
		}
		var nomount_obj = document.getElementById('noamount');
		if(nomount_obj != undefined && isNaN(nomount_obj.value)&& trim(nomount_obj.value)!=""){
			//无回款计划金额非法！
            var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTAMOUNT'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			nomount_obj.focus();
			return false;
		}
		if(nomount_obj != undefined){
			nomount_value =trim(nomount_obj.value);
			if(nomount_value==""){
				nomount_value=0;
			}
		}
		if(adjustmentType == '+')
			var total=parseFloat(curvalue)+parseFloat(nomount_value);
		else
			var total=parseFloat(curvalue)-parseFloat(nomount_value);
		document.getElementById("total").value =parseFloat(total).toFixed(2);
		document.getElementById("sum_rmb_total").innerHTML =parseFloat(total).toFixed(2);
	}
}
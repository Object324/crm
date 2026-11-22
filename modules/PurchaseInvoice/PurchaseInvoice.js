/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");

//V6.5:财务和库存单据选择源单  使用橡皮擦，清除供应商或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearVendors.other_clear=function()
{
    clearModuleProduct(this,'PurchaseInvoice',''); 
}

function  NewSendPayment(obj,divid,purchaseinvoiceid,deployid,isImmediatelycreate)
{
    var prompt;
    $("status").style.display="inline";
    calendarParentid="CreateSendPaymentp";//该变量在jscalendar/dynamiccalendar.js/
    if(deployid > 0)
    {
        if(deployid == 1)
        {
            //prompt = "付款计划总额已经等于未计划金额，是否继续？";
            prompt = arrJsPopLabel['PAYMENTPLANEQUALUNPLANNED'];
        }
        else if(deployid == 2)
        {
            //prompt = "付款计划总额已经大于未计划金额，是否继续？";
            prompt = arrJsPopLabel['PAYMENTPLANGREATERUNPLANNED'];
        }
        var payment= window.confirm(prompt);
        if(payment){
        }
        else
        {  
            $("status").style.display="none";
            return false;
        }
    }
     //弹出框的设计
    var results;
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=SendPayment&action=PurchaseInvoiceSendPayment&purchaseinvoiceid=" +purchaseinvoiceid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate,
		onComplete:function (response) {
			if(response.responseText.indexOf(("error::"))!=-1){
				var errorre=response.responseText.split("error::")[1];
				alert(errorre);
				$("status").style.display="none";
				return false;
			}
        results=response.responseText.split("####:###");
         if(results[1].indexOf(("error####::"))!=-1)
         {
            var errorre=results[1].split("error####::")[1];
            alert(errorre);
            $("status").style.display="none";
            return false;
         }  
        $("SendPayment_form_div").innerHTML=results[1];
        fnvshobj(obj,divid);
        $("status").style.display="none";
		}
	});
   
}
function blocksetsendcashbillpop(idname,vid){

    lingdangJS_DialogBox.unblock();
    var newbox=document.getElementById(idname);
    newbox.style.display="none";
    location.href="index.php?module=PurchaseInvoice&action=DetailView&Create=true&&purchasetype=yes&record="+vid;
}
function LoadPeriodTime(obj)
{
    var period=document.getElementById("OkPeriodTime");
    var loadcount=period.value;
    var r = /^\+?[1-9][0-9]*$/;　　//正整数 
    var nopaymentamount=document.forms['frmsendpayment'].nopaymentamount.value;
    if( isNaN(loadcount))
    {
    //期数应该输入正整数！
        var confirm_str = arrJsPopLabel['PERIODSSHOULDPOSITIVEINTEGER'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        document.getElementById("OkPeriodTime").focus();
            return false;
    }
    if(!r.test(loadcount))
    {
            //期数应该输入正整数！
            var confirm_str = arrJsPopLabel['PERIODSSHOULDPOSITIVEINTEGER'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            document.getElementById("OkPeriodTime").focus();
            return false;
    }
        var percentamount=nopaymentamount/loadcount;
      
        percentamount=parseFloat(percentamount).toFixed(2);
        //alert(document.getElementById("tabsendpayment").rows.length);
       while(document.getElementById("tabsendpayment").rows.length>1)
       {
         document.getElementById("tabsendpayment").deleteRow(1);
       }
           
           
        
        var startperiodtime=document.forms['frmsendpayment'].startPeriodTime.value;
        var startplandate=document.forms['frmsendpayment'].startplandate.value;
        var newRow;
        var newCell;
        var tddelete;
        var tdperiodtime;
        var tdamount;
        var tdplandate;
        var dates
        var mnth="";
        var count = 100/loadcount;
        var month_days=0;////月份的天数
		var date30 = new Array('4','6','9','11');
        for(var i=1;i<=loadcount;i++)
        {
            newRow=document.getElementById("tabsendpayment").insertRow(i);
            newRow.id="row"+i;
            tddelete=newRow.insertCell(0);
            tddelete.align='center';
            tddelete.innerHTML="<a class='icon-homeimg icon-sdel' href='javascript:;' onclick='deletetr(this)'></a>";

            tdperiodtime=newRow.insertCell(1);
            var objperiodtime=document.createElement('input');
            objperiodtime.type='text';
            objperiodtime.size=10;
            objperiodtime.id="periodtime"+i;
            objperiodtime.name="periodtime"+i;
            objperiodtime.value=startperiodtime;
            tdperiodtime.appendChild(objperiodtime);
            
            //objratio.onblur=percentamount(objratio,'amount'+i,nopaymentamount);
            /*20101010
            andrew
            改进功能  合同关联创建回款计划
            在添加function 时出现问题，王灿说还是用html直接赋值
            */
           tdratio=newRow.insertCell(2);
           tdratio.innerHTML="<input type='text' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
            /**
            *更新操作
            *edit:can
            *date:20131230
            *reason:06560: 合同订单->点击“创建回款计划”按钮，然后加载100期回款计划，再连续删除5~10期，程序就会弹出错误，如
            **/
            //tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+i+"' id='periodtime"+i+"' value='"+(startperiodtime)+"'/>";
            tdamount=newRow.insertCell(3);
           
            tdamount.innerHTML="<input type='text' size='10' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
            tdplandate=newRow.insertCell(4);
          //  
            var objplandate=document.createElement('input');
            objplandate.type='text';
            objplandate.size=10;
            objplandate.readOnly=true;
            objplandate.id='plandate'+i;
            objplandate.name='plandate'+i;
            var dates=startplandate.split("-");
            if((dates[0]%4==0 && dates[0]%100!=0)||(dates[0]%400==0)){
                    month_days=29;
                if(dates[1]==2&&dates[2]>29){
                   dates[2]=29; 
                }
            }
            else
            {
                 month_days=28;
                if(dates[1]==2&&dates[2]>28){
                dates[2]=28; 
                }
            }
			if(ld.inArray(dates[1],date30) > 0 && dates[2] >= 30){
				dates[2]=30;
			}
        var tempdate=startplandate;
        switch(parseInt(dates[1]))
        {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
                month_days=31;
                break;
            case 4:
            case 6:
            case 9:
            case 11:
             month_days=30;   
             break;
                    
        }
      
        if(dates[2]>month_days)
        {
            dates[2]=month_days;
        }
        startplandate=dates[0]+"-"+dates[1]+"-"+dates[2];
        objplandate.value=dates[0]+"-"+dates[1]+"-"+dates[2];
        tdplandate.innerHTML="<input type='text' size='15' readonly='true' name='plandate"+i+"' value='"+startplandate+"' id='plandate"+i+"\' onClick='WdatePicker()' class='Wdate'/>";
        //tdplandate.innerHTML+= "&nbsp;<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img"+i+"' onclick='showCalendar(\"plandate"+i+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
        
        tddescription=newRow.insertCell(5);
        tddescription.innerHTML="<textarea  name='description"+i+"' id='description"+i+"' value='' cols='100%' style='height: 22px;'></textarea>";

        
        startplandate=tempdate;
        dates=startplandate.split("-");
        dates[1]=parseInt(dates[1],10)+1;
            if(dates[1]<10)
            {
                dates[1]="0"+dates[1];
            }
            if(dates[1]>=13)
            {
                dates[1]="01";
                dates[0]=parseInt(dates[0],10)+1;
               
            }
            startplandate=dates[0]+"-"+dates[1]+"-"+dates[2];
            startperiodtime++;
             
        }
    }
/*
添加行
*/
function Addtr()
{
    var deploy = document.getElementById("DeployValue").value;
    var tabplan=document.getElementById("tabsendpayment");
    var rowcount=tabplan.rows.length;
    var planamount=0.0;//计划总金额
    var planratio=0;//计划比例
    var curperiod=1;
    var curamount=0;
    var balanceratio=100;
    var prompt;
    var nopaymentamount=parseFloat(document.forms['frmsendpayment'].nopaymentamount.value);//未计划金额
    var plandate=document.forms['frmsendpayment'].NowDate.value;
    var balanceamount=parseFloat(document.forms['frmsendpayment'].nopaymentamount.value);
    if(rowcount > 0)
    {
        for( var i=1;i<rowcount;i++)
        {
            
            if(trim(document.getElementById("amount"+i).value)=="")
            {
            }
            else if(isNaN(document.getElementById("amount"+i).value))
            {
                //金额非法！
                var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("amount"+i).focus();
                return  false;
            }
            else 
            {
                curamount=parseFloat(document.getElementById("amount"+i).value);
                planamount=parseFloat(planamount)+curamount;
                curratio=parseFloat(document.getElementById("ratio"+i).value);
                planratio=parseFloat(planratio)+curratio;
            
            }
           if(!isNaN(document.getElementById("periodtime"+i).value))
           curperiod=parseFloat(document.getElementById("periodtime"+i).value)+1;
        }
    }
    var currow=rowcount-1;
    if(rowcount>1)
    {
        
        plandate=document.getElementById("plandate"+currow).value;
        var dates=plandate.split("-");
     
        dates[1]=parseInt(dates[1],10)+1;
        if(dates[1]<10)
        {
            dates[1]="0"+dates[1];
        }
        if(dates[1]>=13)
        {
            dates[1]="01";
            dates[0]=parseInt(dates[0],10)+1;
        }
        var nowmaxdaysInmonth=getDaysInMonth(dates[0],dates[1]);
        
        var prevmonth=parseInt(dates[1],10)-1;
        if(prevmonth<=0)
        {
            prevmonth=12;
        }
        /*
        edit:can
        reason:7361: 采购订单->创建付款计划：计划付款日期时间2月份显示了30、31号
        */
        var premaxdaysInmonth=getDaysInMonth(dates[0],prevmonth);
        if(dates[2]==premaxdaysInmonth)
        {
            dates[2]=nowmaxdaysInmonth;
        }
        else if(nowmaxdaysInmonth<parseInt(dates[2],10))
        {
            dates[2]=nowmaxdaysInmonth;
        }
         plandate=dates[0]+"-"+dates[1]+"-"+dates[2];
         balanceamount=parseFloat(nopaymentamount)-parseFloat(planamount);
         balanceratio=100-parseFloat(planratio);
        if(deploy == 0)
        {
            if(balanceamount < 0)
            {
                balanceamount = 0;
            }  
        }
        if(deploy == 1)
        {
            if(planamount>=nopaymentamount)
            {
                //付款计划总额已经等于未计划金额！
                var confirm_str = arrJsPopLabel['PAYMENTPLANEQUALAMOUNTNOTPLAN'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        else
        {
            if(planamount >= nopaymentamount)
            {
                if(planamount == nopaymentamount)
                {
                    //prompt = "付款计划总额已经等于未计划金额，是否继续？";
                    prompt = arrJsPopLabel['PAYMENTPLANEQUALUNPLANNED'];
                }
                else
                {
                    //prompt = "付款计划总额已经大于未计划金额，是否继续？";
                    prompt = arrJsPopLabel['PAYMENTPLANGREATERUNPLANNED'];
                }
                RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                  addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate);
                });
                return ;
            }   
        }
    }
    addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate);   
}

//添加行
function addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate){
    var tabtr=tabplan.insertRow(rowcount);
    tabtr.id="row"+rowcount;
    var tddelete=tabtr.insertCell(0);
    tddelete.align="center";
    tddelete.innerHTML="<a class='icon-homeimg icon-sdel' href='javascript:;' onclick='deletetr(this)'></a>";

    var tdperiodtime=tabtr.insertCell(1);
    tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/>";
    var tdratio=tabtr.insertCell(2);
    tdratio.innerHTML="<input type='text' size='10' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(3);
    tdamount.innerHTML="<input type='text' size='10' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
    var tdplandate=tabtr.insertCell(4);
   
    tdplandate.innerHTML="<input type='text' size='15' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\' onClick='WdatePicker()' class='Wdate' />";
    //tdplandate.innerHTML+= "&nbsp;<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img"+rowcount+"' onclick='showCalendar(\"plandate"+rowcount+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
    var tddescription=tabtr.insertCell(5);
    tddescription.innerHTML="<textarea  name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' style='height: 22px;'></textarea>";
}

/*
删除行
*/
function deletetr(obj)
{
    var rowindex=0;
    var paymentamount=document.getElementById("paymentamount").value;
     var tabplan=document.getElementById("tabsendpayment");
     while(obj.tagName!="TR")
     {
         obj=obj.parentNode;
     }
     rowindex=obj.id.substring(3);
    tabplan.deleteRow(rowindex);
     var rowcount=tabplan.rows.length;
     if(rowindex>rowcount)
     {
        return ;
     }
     var j=parseInt(rowindex);
     var i=parseInt(rowindex)+1;
     var tdimage;
     var tdhtml;
     var obbj;
     /*
     更新操作
     edit:can
     date:20131031
     reason:5420: 采购订单明细界面：创建付款计划窗口点击添加按钮时网页左下角报错
     */
    for(j;j<rowcount;j++)
    {
       document.getElementById("row"+i).id="row"+j;
        obbj=document.getElementById("periodtime"+i);
       obbj.name="periodtime"+j;
        obbj.id="periodtime"+j;
       document.getElementById("amount"+i).name="amount"+j;
       document.getElementById("amount"+i).id="amount"+j;
       document.getElementById("ratio"+i).name="ratio"+j;
       document.getElementById("ratio"+i).id="ratio"+j;
       document.getElementById("ratio"+j).onchange = function(){
            var idstr = this.id;
            var jj = idstr.substring(5,idstr.length);
            changeamountn(this,'amount'+jj,'ratio'+jj,paymentamount);
       }
       document.getElementById("amount"+j).onchange = function(){
            var idstr = this.id;
            var jj = idstr.substring(5,idstr.length);
            changeamountn(this,'ratio'+jj,'amount'+jj,paymentamount);
       }
       document.getElementById("plandate"+i).name="plandate"+j;
       document.getElementById("plandate"+i).id="plandate"+j;
        /*tdimage=tabplan.rows[j].cells[3];
        
        tdimage.innerHTML="<input type='text' size='10' value='"+ document.getElementById("plandate"+i).value+"' id='plandate"+j+"' name='plandate"+j+"'/>"+"<img class='popimg'  src='themes/softed/images/btnL3Calendar.gif' id='img"+j+"' onclick='showCalendar(\"plandate"+j+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
        */
        i++;
    }
     
}
/*
edit:Can
date:20130603
reason:采购订单创建批量付款计划

*/
function SaveSendPayment(obj,oformname)
{
    var prompt;
    document.getElementById('save_payment_check').disabled=true;
    var oform=document.forms[oformname];
    var deploy = document.getElementById("DeployValue").value;
   	lingdangJS_DialogBox.block();
    if(oform.autocreate!=undefined)
    {
        oform.submit();
        return;
    }
     var tabplan=document.getElementById("tabsendpayment");
     
    var rowcount=tabplan.rows.length;
    var planamount=0.0;
    if(rowcount<=1)
    {
         lingdangJS_DialogBox.unblock();	
         //付款计划金额和未计划金额不一致！
         var confirm_str = arrJsPopLabel['PAYMENTSPLANINCONSISTENCY'];
         RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

         document.getElementById('save_payment_check').disabled=false;
         return false;
    }
    for( var i=1;i<rowcount;i++)
    {
        if(document.getElementById("periodtime"+i).value=="")
        {
            //期次不能为空！
            var confirm_str = arrJsPopLabel['OFTIMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            document.getElementById("periodtime"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
         return  false;
        }
        if(document.getElementById("amount"+i).value==0 ||trim(document.getElementById("amount"+i).value)=="")
        {
            //金额不能为空或等于零！
            var confirm_str = arrJsPopLabel['AMOUNTCANOTZERO'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            document.getElementById("amount"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
            return false;
        }
       if(isNaN(document.getElementById("amount"+i).value))
       {	
         //金额非法！
         var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
         RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

         document.getElementById("amount"+i).focus();
         document.getElementById('save_payment_check').disabled=false;
         return  false;
       }
       if(document.getElementById("plandate"+i).value=="")
       {	
         //计划日期不能为空！
         var confirm_str = arrJsPopLabel['PLANNEDATECANOTEMPTY'];
         RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

         document.getElementById("plandate"+i).focus();
         document.getElementById('save_payment_check').disabled=false;
         return false;
       }
        planamount=parseFloat(parseFloat(planamount)+parseFloat(document.getElementById("amount"+i).value)).toFixed(2);
        //planamount=parseFloat(parseFloat(planamount)+parseFloat(document.getElementById("amount"+i).value)).toFixed(2);
    }
    var nopaymentamount=parseFloat(document.forms['frmsendpayment'].nopaymentamount.value).toFixed(2);
   
    if(deploy == 1)
    {
        if(planamount!=nopaymentamount)
        {
            lingdangJS_DialogBox.unblock();	
            //付款计划金额和未计划金额不一致！
            var confirm_str = arrJsPopLabel['PAYMENTSPLANINCONSISTENCY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

            document.getElementById('save_payment_check').disabled=false;
            return false;
        }  
    }
    else if(deploy == 0)
    {
        if(planamount == nopaymentamount)
        {
            oform.submit();
            return ;
        }
        else
        {
            if(planamount < nopaymentamount)
            {
                //prompt = "付款计划总额小于未计划金额，是否继续？";
                prompt = arrJsPopLabel['PAYMENTPLANLESSUNPLANNED'];
            }
            else
            {
                //alert(planamount+'-'+nopaymentamount);
                //prompt = "付款计划总额已经大于未计划金额，是否继续？";
                prompt = arrJsPopLabel['PAYMENTPLANGREATERUNPLANNED'];
            }
                var objdiv_title =  arrJsPopLabel['WARMPROMPT'];//标题
                var objdiv_content = prompt;//提示内容
                //创建提示弹出层
                create_divobj('save_payment_reminder',objdiv_title,objdiv_content,'yes','','no');
                ld('#layer').addClass("indextop_8");//遮罩层
                ld('#save_payment_reminder').addClass("indextop_9");//提示弹出层
                ld("#save_payment_reminder .D_pop_tit .D_ptitc").attr('onclick','').unbind('click');
                ld("#save_payment_reminder .D_pbtn .D_pbtncancel").attr('onclick','').unbind('click');
                //确定事件
                ld('#save_payment_reminder .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    ld('#layer').removeClass("indextop_8");//遮罩层
                    ld('#save_payment_reminder').removeClass("indextop_9");//提示弹出层
                    ld('#save_payment_reminder').hide();
                    oform.submit();
                });
                //点击关闭按钮
                ld("#save_payment_reminder .D_pop_tit .D_ptitc").unbind('click').on('click',function(){
                    ld('#layer').removeClass("indextop_8");//遮罩层
                    ld('#save_payment_reminder').removeClass("indextop_9");//提示弹出层
                    ld('#save_payment_reminder').hide();
                });
                //点击取消按钮
                ld("#save_payment_reminder .D_pbtn .D_pbtncancel").unbind('click').on('click',function(){
                    ld('#layer').removeClass("indextop_8");//遮罩层
                    ld('#save_payment_reminder').removeClass("indextop_9");//提示弹出层
                    ld('#save_payment_reminder').hide();
                    document.getElementById('save_payment_check').disabled=false;
                });
                ld('#save_payment_check').attr("disabled",false); 
                return false  
        }
    }
    oform.submit(); 
}

function CashSet(obj,divid,purchaseorderid)
    {
        fninvsh('CreateSendPayment');
        $("status").style.display="inline";
  
     //弹出框的设计
     	new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"module=SendPayment&action=CashSet&purchaseorderid=" +purchaseorderid,
			onComplete:function (response) {
    			 var results=response.responseText.split("####:###");
                 if(results[1].indexOf(("error####::"))!=-1)
                 {
                    var errorre=results[1].split("error####::")[1];
                    alert(errorre);
                    $("status").style.display="none";
                    return false;
                 }
    			 $("SetSendPayment_form_div").innerHTML=results[1];
                
    			 fnvshobj(obj,divid);
                 $("status").style.display="none";
			}
		}); 
    }

	/*
    reason:付款计划设置添加行
     edit:can
    date:20130619
    */
    function addSetTr(obj)
    {
        var tableset=document.getElementById("tableSet");
        var rowcount=tableset.rows.length;
       var total=0;
       for(var i=1;i<rowcount;i++)
       {
        
            if(isNaN(document.getElementById("percent"+i).value))
             {
                //付款比例非法！
                var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

                document.getElementById("percent"+i).focus();
                return false;
             }
             if(document.getElementById("percent"+i).value<=0)
             {
                //付款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PAYMENTPERCENTAGEPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             total=total+parseFloat(document.getElementById("percent"+i).value);
       }
      
       if(parseFloat(total)>=100)
       {
            //付款比例合计必须等于100！
            var confirm_str = arrJsPopLabel['PAYMENTEQUALPROPORTION100'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
       }
       var addrow=tableset.insertRow(rowcount);
       var other=100-parseFloat(total);
       
       addrow.id="row"+rowcount;
       var addcell=addrow.insertCell(0);
       addcell.align='center';
       addcell.innerHTML='<a class="icon-homeimg icon-sdel" href="javascript:;" onclick="deletesettr(this)"></a>';
       addcell=addrow.insertCell(1);
       addcell.innerHTML='<input style="width:70px;" name="periodtime'+rowcount+'" id="periodtime'+rowcount+'" type="text" value="'+rowcount+'" />';
       addcell=addrow.insertCell(2);
       addcell.innerHTML='<input style="width:70px;" onchange="return percentChange(this)" name="percent'+rowcount+'" id="percent'+rowcount+'" type="text" value="'+parseFloat(other).toFixed(2)+'"  />';
    }
    
    function percentChange(obj)
    {
        if(isNaN(obj.value))
        {
             //付款比例非法！
             var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
             RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
             obj.focus();
        
            if(!document.all)
            {
                 obj.select();
                 window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
            }
            return false;
        }
        if(obj.value<=0)
        {
             //付款比例必须是正整数！
             var confirm_str = arrJsPopLabel['PAYMENTPERCENTAGEPOSITIVEINT'];
             RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
             obj.focus();
        
            if(!document.all)
            {
                 obj.select();
                 window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
            }
            return false;
        }
        document.getElementById(obj.id).value=parseFloat(obj.value).toFixed(2);
        return true;
    }
    
    /*
    reason:付款计划设置删除
    edit:can
    date:20130619
    
    */
    function deletesettr(obj)
    {
        while(obj.tagName!="TR")
        {
            obj=obj.parentNode;
        }
        var trid=obj.id;
        
        var rowindex=obj.rowIndex;
        var tableset=document.getElementById("tableSet");
        tableset.deleteRow(rowindex);
        var trow;
        var j=0;
        var rowcount=tableset.rows.length;
        for(var i=rowindex;i<rowcount;i++)
        {
            trow=tableset.rows[i];
            trow.id="row"+i;
            j=i+1;
           // alert(j);
            document.getElementById("periodtime"+j).name="periodtime"+i;
            document.getElementById("periodtime"+j).id="periodtime"+i;
            document.getElementById("percent"+j).name="percent"+i;
            document.getElementById("percent"+j).id="percent"+i;
        }
    }
    
     function SaveSendPaymentSet(obj)
    {
         var tableset=document.getElementById("tableSet");
         var total=0;
         for(var i=1;i<tableset.rows.length;i++)
         {
            
             if(isNaN(document.getElementById("percent"+i).value))
             {
                //付款比例非法！
                var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             if(document.getElementById("percent"+i).value<=0)
             {
                //付款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PAYMENTPERCENTAGEPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             total=total+parseFloat(document.getElementById("percent"+i).value);
             
         }
         if(parseFloat(total)!=100.00)
         {
            //付款比例合计必须等于100！
            var confirm_str = arrJsPopLabel['PAYMENTEQUALPROPORTION100'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
         }
         document.forms["frmSendPaymentSet"].submit();
    }
     function positiveInteger(num)
    {
            if (num=="")
            {
                return false;
            }
            
            if (!(/(^[1-9]\d*$)/.test(num)))
            {
                return false;
            }
           
            return true;
    }
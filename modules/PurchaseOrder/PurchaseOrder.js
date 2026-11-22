/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");

function set_return(product_id, product_name) {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
}
/*
edit:chj
date:2013-11-05
reson:入库 采购订单选择后，自动导入采购订单所关联的所有产品
*/
function set_product_specific(product_id, product_name, product_all)
{
    var product_info = product_all.split("#");
    var fldName = getOpenerObj("purchaseorder_name");
    var fldId = getOpenerObj("purchaseorder_id");
    var product_array = new Array();
    fldName.value = product_name;
    fldId.value = product_id;
    window.opener.document.EditView.action.value = 'EditView';
   	window.opener.document.EditView.convertmode.value = 'update_purchase_val';
   	window.opener.document.EditView.submit();
}
function set_return_specific(product_id, product_name) {
        
        var fldName = getOpenerObj("purchaseorder_name");
        var fldId = getOpenerObj("purchaseorder_id");
        fldName.value = product_name;
        fldId.value = product_id;
}
function set_return_formname_specific(formname, product_id, product_name) {
        window.opener.document.EditView1.purchaseorder_name.value = product_name;
        window.opener.document.EditView1.purchaseorder_id.value = product_id;
}
function set_return_todo(product_id, product_name) {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}
/**
edit:can
reason:isImmediatelycreate:上海
**/
function  NewSendPayment(obj,divid,purchaseorderid,deployid,isImmediatelycreate)
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
		postBody:"module=SendPayment&action=PopSendPayment&purchaseorderid=" +purchaseorderid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate,
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
    location.href="index.php?module=PurchaseOrder&action=DetailView&parenttab=Purchase&Create=true&&purchasetype=yes&record="+vid;
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
                alert(arrJsPopLabel['AMOUNTILLEGAL']);
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
                alert(arrJsPopLabel['PAYMENTPLANEQUALAMOUNTNOTPLAN']);
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
    obj.parentNode.removeChild(obj);
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


/********************************************************************************/
//付款计划设置函数
/********************************************************************************/

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
    
/*
    
function CreateSendPayment(obj,divid,purchaseorderid)
{
    
    
    $("status").style.display="inline";
     calendarParentid="CreateSendPayment";//该变量在jscalendar/dynamiccalendar.js/

     //弹出框的设计
     	new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"module=SendPayment&action=PopCreateSendPayment&purchaseorderid=" +purchaseorderid+'&ReportHeader=DHeader',
			onComplete:function (response) {
			 var results=response.responseText.split("####:###");
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
*/

function set_return_inventory(product_id,product_name,unitprice,qtyinstock,curr_row) {
        window.opener.document.EditView.elements["txtProduct"+curr_row].value = product_name;
        window.opener.document.EditView.elements["hdnProductId"+curr_row].value = product_id;
	window.opener.document.EditView.elements["txtListPrice"+curr_row].value = unitprice;
	getOpenerObj("unitPrice"+curr_row).innerHTML = unitprice;
	getOpenerObj("qtyInStock"+curr_row).innerHTML = qtyinstock;
	window.opener.document.EditView.elements["txtQty"+curr_row].focus()
}
/**
 * @edit:chj
 * @date:2014-9-12
 * @reason:采购订单相关信息 创建付款计划判断 采购订单金额是否大于付款计划的总额
 * @description:
 */
function isCreateSendPayment($module,$record,obj)
{
    //alert("index.php?module="+$module+"&action=EditView&return_module="+$module+"&return_action=DetailView&Create=yes&iscreatesendpayment=true&purchaseorder_id="+$record+"");
     $("status").style.display="inline";
     new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+$module+"&action=EditView&return_module="+$module+"&return_action=DetailView&Create=yes&iscreatesendpayment=true&purchaseorder_id="+$record+"",
			onComplete: function(response) {
                $("status").style.display="none";
	 		    var results=response.responseText.split("###SUCCESS###");
                if(results[1] == 1)
                {
                      var obj = document.getElementById("tagOpenWin");  
                      obj.href = "index.php?module="+$module+"&action=EditView&return_module="+$module+"&return_action=DetailView&relatedcreate=yes&fromid="+$record+"&frommodule=PurchaseOrder&purchaseorder_id="+$record;
                      obj.click(); 
                }
                else{
                    var confirm_str = arrJsPopLabel['THETOTALAMOUNTOFTHEPURCHASEORDERAMOUNT'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    return false;                                        
                }                         
			}
		}
    );
}
/**
 * @edit:chj
 * @date:2014-11-27
 * @reason:采购订单 - 付款计划
 * @description:
 */
function ChangeCurrency(obj)
{
    var currency_id = obj.value;    //选择后的币种ID
    var before_currency_id = document.getElementById('before_currency_id').value;   //选择前的币种ID
    if(window.confirm(arrJsPopLabel['ALLCURRENCYOFAMOUNTWILLBEFIXED']))
    {
        //alert('module=Settings&action=SettingsAjax&file=ChangeRateAmount&ajax=true&currency_id='+currency_id+'&before_currency_id='+before_currency_id+'&getCurrencyCate=true');
        new Ajax.Request(
    		'index.php',
    		{queue: {position: 'end', scope: 'command'},
    			method: 'post',
    			postBody: 'module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&currency_id='+currency_id+'&before_currency_id='+before_currency_id+'&getCurrencyCate=true',
    			onComplete: function(response) { 
                    if(response.responseText.indexOf('###SUCCESS###') > -1)
                    {
                        var results=response.responseText.split('###SUCCESS###');
                        //获取结果集 0：选择前币种汇率 1：选择后的币种汇率
                        var result=results[1].split('|');
                        //人民币 - 非人民币 / 公式：金额*非人民币汇率
                        //非人民币 - 非人民币 or  非人民币  - 人民币 / 公式:(金额/选择前汇率)*选择后汇率
                        if(ld('#purchaseorderamount1') != undefined)    //合同订单金额
                        {
                            var purchaseorderamount = ld('#purchaseorderamount1').html();
							purchaseorderamount = purchaseorderamount.replace(/,/gi,'');
                            if(before_currency_id == 1)
                                purchaseorderamount = purchaseorderamount*result[1];
                            else
                                purchaseorderamount = (purchaseorderamount/result[0])*result[1];
							if(isNaN(purchaseorderamount))purchaseorderamount = 0;
                            purchaseorderamount = purchaseorderamount.toFixed(2);
                            document.frmsendpayment.salesorderamount.value = purchaseorderamount;
							ld('#purchaseorderamount1').html(purchaseorderamount);
                                
                        }
                        if(ld('#nopaymentamount1') != undefined)    //未计划金额
                        {
                            var nopaymentamount = ld('#nopaymentamount1').html();
                            if(before_currency_id == 1)
                                nopaymentamount = nopaymentamount*result[1];
                            else{
                                nopaymentamount = (nopaymentamount/result[0])*result[1];
							}
							if(isNaN(nopaymentamount))nopaymentamount = 0;
                            nopaymentamount = nopaymentamount.toFixed(2);
                            document.frmsendpayment.nopaymentamount.value = nopaymentamount;
							ld('#nopaymentamount1').html(nopaymentamount);
                        }
                        //期次
                        var tableName = document.getElementById('tabsendpayment');
                        var prev = tableName.rows.length;
                        prev = prev - 1;//减去列头行
                        for(var i = 1; i<=prev; i++)
                        {
                            if(document.getElementById('amount'+i) != undefined)
                            {
                                var amount = document.getElementById('amount'+i).value;
                                if(before_currency_id == 1)
                                    amount = amount*result[1];
                                else
                                    amount = (amount/result[0])*result[1];
								if(isNaN(amount))amount = 0;
                                amount = amount.toFixed(2);
                                document.getElementById('amount'+i).value = amount;
                            }
                        }
                        document.getElementById('before_currency_id').value = obj.value;
                    }
                    return false;
    			}
    		}
    		
    	);   
    }
    else
    {
        //取消，币种默认值还原
        document.frmsendpayment.currency_id.value = document.getElementById('before_currency_id').value;
        return false;
    }
} 

function jsQualifyDate(){
    this.form= document.forms['EditView']; 
    this.form.action.value='Save';
    var topBtn = ld('input[name="button"][class="save"]')[0];
    var cur_this=this;
    topBtn.onclick =function(){
         cur_this.savePurchaseOrderDetail();
    }
    var botBtn = ld('input[name="button"][class="save"]')[1];
    botBtn.onclick =function(){
        cur_this.savePurchaseOrderDetail();
    }
}

jsQualifyDate.prototype.savePurchaseOrderDetail = function(){
    var cur_this=this;
    if(validateInventory('PurchaseOrder')){
        var vendorid = ld('form input[name="vendor_id"]').val();
        
        var productid = getProtabInfo('hdnProductId','no');
        
        url = 'module=PurchaseOrder&action=PurchaseOrderAjax&file=CheckMaturitydate&vendorid='+vendorid+'&productid='+productid;	
    	new Ajax.Request(
    		'index.php',
    		{
    		    queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
				    
				    var result=response.responseText;
				    if(result.indexOf('#&#Success#&#')>=0){
				        FieldDuplicateValidate('PurchaseOrder',cur_this.form);
				        return true;
				    }else{
                        RemindsMsg("","LdPopWidth400px","","yes","",result);
                        return false;
				    }
				}
    		}
    	); 

    }else{
        return false;
    }
}

//源美特殊控制，判断明细表体字段“暂定价价格”、“点价价格”、“点价期限/时间”
function setProductToolFieldDisplay(mode){
	var ordertype;
	if(mode == 'detail'){
		if(ld('#dtlview_ordertype > font') != undefined){
			ordertype = trim(ld('#dtlview_ordertype > font').html());
		}
	}else{
		if(document.getElementById('ordertype') != undefined){
			ordertype = document.getElementById('ordertype').value;
		}
	}
	var rowcnt = ld('#rowcnt').val();
	if(ordertype == '点价合同'){
		//不显示暂定价价格
		/*if(ld('#productdetails_header_tempprice') != undefined){
			ld('#productdetails_header_tempprice').hide();
		}
		if(ld('#subtotal_tempprice') != undefined){
			ld('#subtotal_tempprice').hide();
		}*/
		for(var i = 1; i<=rowcnt; i++){
			if(i == 1){
				if(ld('#tempprice'+i) != undefined){
					ld('#tempprice'+i).attr("readonly",false);
					ld('#tempprice'+i).css('background-color','#ffffff');
				}
				if(ld('#clickprice'+i) != undefined){
					ld('#clickprice'+i).attr("readonly",true);
					ld('#clickprice'+i).css('background-color','#efefef');
				}
				if(ld('#clicktime'+i) != undefined){
					ld('#clicktime'+i).attr("readonly",true);
					ld('#clicktime'+i).css('background-color','#efefef');
				}
			}else{
				if(ld('#tempprice'+i) != undefined){
					ld('#tempprice'+i).attr("readonly",true);
					ld('#tempprice'+i).css('background-color','#efefef');
				}
				if(ld('#clickprice'+i) != undefined){
					ld('#clickprice'+i).attr("readonly",false);
					ld('#clickprice'+i).css('background-color','#ffffff');
				}
				if(ld('#fee_process'+i) != undefined){
					ld('#fee_process'+i).attr("readonly",true);
					ld('#fee_process'+i).css('background-color','#efefef');
				}
				if(ld('#fee_transport'+i) != undefined){
					ld('#fee_transport'+i).attr("readonly",true);
					ld('#fee_transport'+i).css('background-color','#efefef');
				}
				if(ld('#adjprice'+i) != undefined){
					ld('#adjprice'+i).attr("readonly",true);
					ld('#adjprice'+i).css('background-color','#efefef');
				}
				if(ld('#clicktime'+i) != undefined){
					ld('#clicktime'+i).attr("readonly",true);
					ld('#clicktime'+i).css('background-color','#efefef');
				}
			}
			
		}
		/*for(var i = 1; i<=rowcnt; i++){
			if(ld('#clicktime'+i) != undefined){
				ld('#clicktime'+i).attr("readonly",false);
				ld('#clicktime'+i).css('background-color','#ffffff');
				ld('#clicktime'+i).addClass('Wdate');
				ld('#clicktime'+i).attr('onclick','WdatePicker()');
			}
		}*/
	}else{
		//显示暂定价价格
		/*if(ld('#productdetails_header_tempprice') != undefined){
			ld('#productdetails_header_tempprice').show();
		}
		if(ld('#subtotal_tempprice') != undefined){
			ld('#subtotal_tempprice').show();
		}*/
		for(var i = 1; i<=rowcnt; i++){
			if(ld('#tempprice'+i) != undefined){
				ld('#tempprice'+i).attr("readonly",false);
				ld('#tempprice'+i).css('background-color','#ffffff');
			}
			if(ld('#fee_process'+i) != undefined){
				ld('#fee_process'+i).attr("readonly",false);
				ld('#fee_process'+i).css('background-color','#ffffff');
			}
			if(ld('#fee_transport'+i) != undefined){
				ld('#fee_transport'+i).attr("readonly",false);
				ld('#fee_transport'+i).css('background-color','#ffffff');
			}
			if(ld('#adjprice'+i) != undefined){
				ld('#adjprice'+i).attr("readonly",false);
				ld('#adjprice'+i).css('background-color','#ffffff');
			}
			if(ld('#clicktime'+i) != undefined){
				ld('#clicktime'+i).attr("readonly",true);
				ld('#clicktime'+i).css('background-color','#efefef');
			}
		}
		//不显示点价价格、点价期限/时间
		/*if(ld('#productdetails_header_clickprice') != undefined){
			ld('#productdetails_header_clickprice').hide();
		}
		if(ld('#subtotal_clickprice') != undefined){
			ld('#subtotal_clickprice').attr("disabled",true);
		}*/
		for(var i = 1; i<=rowcnt; i++){
			if(ld('#clickprice'+i) != undefined){
				ld('#clickprice'+i).attr("readonly",true);
				ld('#clickprice'+i).css('background-color','#efefef');
				
			}
		}
		/*if(ld('#productdetails_header_clicktime') != undefined){
			ld('#productdetails_header_clicktime').hide();
		}
		if(ld('#subtotal_clicktime') != undefined){
			ld('#subtotal_clicktime').hide();
		}*/
		/*for(var i = 1; i<=rowcnt; i++){
			if(ld('#clicktime'+i) != undefined){
				ld('#clicktime'+i).attr("readonly",true);
				ld('#clicktime'+i).css('background-color','#efefef');
				ld('#clicktime'+i).removeClass('Wdate');
				ld('#clicktime'+i).attr('onclick','');
			}
		}*/
	}
}
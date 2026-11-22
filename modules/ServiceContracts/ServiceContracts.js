/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

/*
*新增操作 by andy
*服务单新增服务合同字段，弹出窗带入数值
*date:20140227
*/
function set_return_specific(help_id, help_name) {
        
	//getOpenerObj used for DetailView 
    if(document.basicSearch.frommodule != undefined && document.basicSearch.frommodule.value == 'Expense')
    {
        var fldName = getOpenerObj("salesorder_name");
        var fldId = getOpenerObj("salesorder_id");   
    }
    else
    {
        var fldName = getOpenerObj("servicecontracts_name");
        var fldId = getOpenerObj("servicecontractsid");
    }
    fldName.value = help_name;
    fldId.value = help_id;
}

/*
*andrew
*创建回款计划弹出框
*date:20141124
param:isImmediatelycreate:是否为立即创建 ,yes:立即创建
*/
function NewPaymentPlan(obj,divid,servicecontractsid,deployid,isImmediatelycreate)
{
   
    var prompt;
    $("status").style.display="inline";
    calendarParentid="CreatePaymentplan";//该变量在jscalendar/dynamiccalendar.js/
    if(deployid > 0)
    {
        if(deployid == 1)
        {
            //回款计划总额已经等于未计划金额，是否继续？
            prompt = arrJsPopLabel['REIMBURSEMENTEQUALUNPLANNED'];
        }
        else if(deployid == 2)
        {
            //回款计划总额已经大于未计划金额，是否继续？
            prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
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
		postBody:"module=PaymentPlan&action=ServiceContractsPaymentPlan&servicecontractsid=" +servicecontractsid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate+'&frommodule=ServiceContracts',
		onComplete:function (response) {
		if(response.responseText.indexOf(("error::"))!=-1){
			var errorre=response.responseText.split("error::")[1];
			RemindsMsg("","LdPopWidth400px","","yes","",errorre);
			$("status").style.display="none";
			return false;
		}
        results=response.responseText.split("####:###");
         if(results[1].indexOf(("error####::"))!=-1)
         {
            var errorre=results[1].split("error####::")[1];
            RemindsMsg("","LdPopWidth400px","","yes","",errorre);
            $("status").style.display="none";
            return false;
         }  
         $("status").style.display="none";         
        $("Paymentplan_form_div").innerHTML=results[1];
        fnvshobj(obj,divid);
		}
	});
   
}


/*
删除行
*/
function deletetr(obj)
{
    var rowindex=0;
     var tabplan=document.getElementById("tabpaymentplan");
     var paymentamount=document.getElementById("paymentamount").value;
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
            var jj = idstr.substring(6,idstr.length);
            changeamountn(this,'ratio'+jj,'amount'+jj,paymentamount);
       }
            document.getElementById("plandate"+i).name="plandate"+j;
            document.getElementById("plandate"+i).id="plandate"+j;

       /*
        tdimage=tabplan.rows[j].cells[3];
        
        tdimage.innerHTML="<input type='text' size='10' value='"+ document.getElementById("plandate"+i).value+"' id='plandate"+j+"' name='plandate"+j+"'/>"+"<img class='popimg'  src='themes/softed/images/btnL3Calendar.gif' id='img"+j+"' onclick='showCalendar(\"plandate"+j+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
        */
        i++;
    }
     
}

/*
添加行
*/
function Addtr()
{
    var deploy = document.getElementById("DeployValue").value;
    var tabplan=document.getElementById("tabpaymentplan");
    var rowcount=tabplan.rows.length;
    var planamount=0.0;//计划总金额
    var planratio=0;//计划比例
    var curperiod=1;
    var curamount=0;
    var balanceratio=100;
    var prompt;
    var nopaymentamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value);//未计划金额
    var plandate=document.forms['frmpaymentplan'].NowDate.value;
    var balanceamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value);

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
	//项目状态
	var pliststr=document.getElementById("pliststr").value;
	var dates=pliststr.split(",");
	var is=0;
	var selectHTML='';
	while(dates.length-1>is){
		selectHTML += "<option value='"+dates[is]+"'>"+dates[is]+"</option>"
		is++;
	}
	selectHTML = selectHTML+"</select>";
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
        if((dates[0]%4==0 && dates[0]%100!=0)||(dates[0]%400==0)){
            if(dates[1]==2&&dates[2]>29){
               dates[2]=29; 
            }
        }
        if(dates[1]==2&&dates[2]>28){
            dates[2]=28; 
        }
         plandate=dates[0]+"-"+dates[1]+"-"+dates[2];

         balanceamount=parseFloat(nopaymentamount)-parseFloat(planamount);
         balanceratio=100-parseFloat(planratio);
        /*
        Edit:chj
        date:20130814
        reason:控制汇款计划金额;追加还款期限  1 是可以追加  0 不可以追加
        */
        if(deploy == 0)
        {
            if(balanceamount < 0)
            {
                balanceamount = 0;
            }  
            if(balanceratio < 0)
            {
                balanceratio = 0;
            }  
        }
        if(deploy == 0)
        {
            if(planamount>=nopaymentamount)
            {
                //回款计划总额已经等于未计划金额！
                var confirm_str = arrJsPopLabel['PLANAMOUNTEQUALUNPLANAMOUNT'];
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
                    //回款计划总额已经等于未计划金额，是否继续？
                    prompt = arrJsPopLabel['REIMBURSEMENTEQUALUNPLANNED'];
                }
                else
                {
                    //回款计划总额已经大于未计划金额，是否继续？
                    prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
                    
                }

                RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                  addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate,selectHTML);
                });
                return ;
            }   
        }
    }
    addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate,selectHTML);
}

//添加行
function addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,plandate,selectHTML){
	var paymenttype = ld('#paymenttype').val();
    var tabtr=tabplan.insertRow(rowcount);
    tabtr.id="row"+rowcount;
    var tddelete=tabtr.insertCell(0);
    tddelete.align='center';
    tddelete.innerHTML="<a class='icon-homeimg icon-sdel' href='javascript:;' onclick='deletetr(this)'></a>";

    var tdperiodtime=tabtr.insertCell(1);
    tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/>";
    var tdratio=tabtr.insertCell(2);
    tdratio.innerHTML="<input type='text' size='10' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(3);
    tdamount.innerHTML="<input type='text' size='10' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
	var tdplandate=tabtr.insertCell(4);
    tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\'/>";
	tdplandate.id='paymentpan_date_td_'+rowcount;
	if(paymenttype == '项目状态'){
		tdplandate.style.display='none';
	}
    var tdprjectstatus = tabtr.insertCell(5);
    tdprjectstatus.innerHTML="<select class='commonSelectPop' name='projectstatus"+rowcount+"'>"+selectHTML;
	tdprjectstatus.id='projectstatus_td_'+rowcount;
	if(paymenttype == '计划回款日期'){
		tdprjectstatus.style.display='none';
	}
	var tddescription=tabtr.insertCell(6);
    tddescription.innerHTML="<textarea  name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' style='height: 22px;'></textarea>";
}

/*
edit:andrew
date:20141125
reason:服务合同创建回款计划允许用户自定义设置回款计划期数。
*/    
function LoadPeriodTime(obj)
    {
         var period=document.getElementById("OkPeriodTime");
         var loadcount=period.value;
         var r = /^\+?[1-9][0-9]*$/;　　//正整数 
         var nopaymentamount=document.forms['frmpaymentplan'].nopaymentamount.value;
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
        //alert(document.getElementById("tabpaymentplan").rows.length);
       while(document.getElementById("tabpaymentplan").rows.length>1)
       {
         document.getElementById("tabpaymentplan").deleteRow(1);
       }
           
           
        
        var startperiodtime=document.forms['frmpaymentplan'].startPeriodTime.value;
        var startplandate=document.forms['frmpaymentplan'].startplandate.value;
        var newRow;
        var newCell;
        var tddelete;
        var tdperiodtime;
        var tdamount;
        var tdplandate;
        var dates
        var mnth="";
        var count = 100/loadcount;
		var date30 = new Array('4','6','9','11');
        for(var i=1;i<=loadcount;i++)
        {
            newRow=document.getElementById("tabpaymentplan").insertRow(i);
            newRow.id="row"+i;
            tddelete=newRow.insertCell(0);
            tddelete.align="center";
            tddelete.innerHTML="<a class='icon-homeimg icon-sdel' href='javascript:;' onclick='deletetr(this)'></a>";

            tdperiodtime=newRow.insertCell(1);
            var objperiodtime=document.createElement('input');
            objperiodtime.type='text';
            objperiodtime.size=10;
            objperiodtime.id="periodtime"+i;
            objperiodtime.name="periodtime"+i;
            objperiodtime.value=startperiodtime;
            tdperiodtime.appendChild(objperiodtime);
   
            tdratio=newRow.insertCell(2);
            tdratio.innerHTML="<input type='text' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
            tdamount=newRow.insertCell(3);
            tdamount.innerHTML="<input type='text' size='10' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
            tdplandate=newRow.insertCell(4);
            
            tddescription=newRow.insertCell(5);
            tddescription.innerHTML="<textarea  name='description"+i+"' id='description"+i+"' value='' cols='100%' style='height: 22px;'></textarea>";

           
            var objplandate=document.createElement('input');
            objplandate.type='text';
            objplandate.size=10;
            objplandate.readOnly=true;
            objplandate.id='plandate'+i;
            objplandate.name='plandate'+i;
            var dates=startplandate.split("-");
        if((dates[0]%4==0 && dates[0]%100!=0)||(dates[0]%400==0)){
            if(dates[1]==2&&dates[2]>29){
               dates[2]=29; 
            }
        }
        if(dates[1]==2&&dates[2]>28){
            dates[2]=28; 
        }
		
		if(ld.inArray(dates[1],date30) > 0 && dates[2] >= 30){
			dates[2]=30;
		}
        var tempdate=startplandate;
        startplandate=dates[0]+"-"+dates[1]+"-"+dates[2];
        objplandate.value=dates[0]+"-"+dates[1]+"-"+dates[2];
        tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate' readonly='true' name='plandate"+i+"' value='"+startplandate+"' id='plandate"+i+"\'/>";
        //tdplandate.innerHTML+= "<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img"+i+"' onclick='showCalendar(\"plandate"+i+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
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
edit:andrew
date:20141125
reason:服务合同创建批量回款计划

*/
function SavePaymentPlan(obj,oformname)
{
    var prompt;
  document.getElementById('save_payment_check').disabled=true;
    oform=document.forms[oformname];
    var deploy = document.getElementById("DeployValue").value;
   
   	lingdangJS_DialogBox.block();
    if(oform.autocreate!=undefined)
    {
        oform.submit();
        return;
    }
     var tabplan=document.getElementById("tabpaymentplan");
     
    var rowcount=tabplan.rows.length;
    var planamount=0.0;
    if(rowcount<=1)
    {
         lingdangJS_DialogBox.unblock();	
         //回款计划金额和未计划金额不一致！
         var confirm_str = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
         RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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
            var confirm_str = arrJsPopLabel['AMOUNTCANOTNULL'];
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
    }
    var nopaymentamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value).toFixed(2);

    if(deploy == 0)
    {
        if(planamount!=nopaymentamount)
        {
            //回款计划金额和未计划金额不一致！
            var confirm_str = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);

            document.getElementById('save_payment_check').disabled=false;
            return false;
        }  
    }
    else if(deploy == 1)
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
                //prompt = "回款计划总额小于未计划金额，是否继续？";
                //回款计划总额小于未计划金额，是否继续？
                prompt = arrJsPopLabel['REIMBURSEMENTLESSUNPLANNED'];
            }
            else
            {
               // alert(planamount+'-'+nopaymentamount);
                //prompt = "回款计划总额已经大于未计划金额，是否继续？";
                //回款计划总额已经大于未计划金额，是否继续？
                prompt = arrJsPopLabel['REIMBURSEMENTGREATERUNPLANNED'];
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
/**
 * @edit:chj
 * @date:2014-11-27
 * @reason:服务合同 - 回款计划
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
                        if(ld('#salesorderamount1') != undefined)    //合同订单金额
                        {
                            var salesorderamount = ld('#salesorderamount1').html();
                            salesorderamount = salesorderamount.replace(/,/gi,'');
                            if(before_currency_id == 1)
                                salesorderamount = salesorderamount*result[1];
                            else
                                salesorderamount = (salesorderamount/result[0])*result[1];
                            salesorderamount = salesorderamount.toFixed(2);
                            document.frmpaymentplan.salesorderamount.value = salesorderamount;
							ld('#salesorderamount1').html(salesorderamount);
                                
                        }
                        if(ld('#nopaymentamount1') != undefined)    //未计划金额
                        {
                            var nopaymentamount = ld('#nopaymentamount1').html();
                            nopaymentamount = nopaymentamount.replace(/,/gi,'');
                            if(before_currency_id == 1)
                                nopaymentamount = nopaymentamount*result[1];
                            else
                                nopaymentamount = (nopaymentamount/result[0])*result[1];
                            nopaymentamount = nopaymentamount.toFixed(2);
                            document.frmpaymentplan.nopaymentamount.value = nopaymentamount;    
							ld('#nopaymentamount1').html(nopaymentamount);
                        }
                        //期次
                        var tableName = document.getElementById('tabpaymentplan');
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
        document.frmpaymentplan.currency_id.value = document.getElementById('before_currency_id').value;
        return false;
    }
}

//回款计划类型，点击事件，更改显示列
function changeListHeader(obj){
	var paymenttype = obj.value;	//回款计划类型
	var tabplan=document.getElementById("tabpaymentplan");

	var rowcount=tabplan.rows.length;
	if(paymenttype == '项目状态'){
		ld('#paymentpan_date_tr').hide();
		ld('#projectstatus_tr').show();
	}else{
		ld('#paymentpan_date_tr').show();
		ld('#projectstatus_tr').hide();
	}
	if(rowcount >= 1){
		for(var i = 1; i<=rowcount; i++){
			if(paymenttype == '项目状态'){
				ld('#paymentpan_date_td_'+i).hide();
				ld('#projectstatus_td_'+i).show();
				ld('#paymentplan_times').hide();
			}else{
				ld('#paymentpan_date_td_'+i).show();
				ld('#projectstatus_td_'+i).hide();
				ld('#paymentplan_times').show();
			}
		}
	}
}
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

//document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");

//V6.5:财务和库存单据选择源单  使用橡皮擦，清除供应商或者清除源单之后，分录中的产品信息应该清空，源单信息区块内容也应该清空。
clearVendors.other_clear=function()
{
    clearModuleProduct(this,'PurchaseInvoice',''); 
}

function  NewSendPayment(obj,divid,purchaseinvoiceid,deployid,isImmediatelycreate)
{
    var prompt;
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
	var surl = "index.php?module=SendPayment&action=PurchaseInvoiceSendPayment&purchaseinvoiceid=" +purchaseinvoiceid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
    crmPopupobj.type='CreateSendPaymentplan';
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,SaveSendPayment,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml('SmOwnerSearchScope');
            cls_resetComboxHtmlobj.searchhtmltype='div';
            cls_resetComboxHtmlobj.picklistcontent=data.result.user_arr;
           cls_resetComboxHtmlobj.setComboxObjHtml();
           ld("#"+crmPopupobj.divid+" [name=cmb_span_optiontext_SmOwnerSearchScope]").html(data.result.selectedlastname);
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
            {
                    cls_wxOpenDataobj.bindAllOpenDataByPopupObj(crmPopupobj);
            }
		}else{
			crmPopupobj.CancelEvent();
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg); 
		}
	})
 	/*new Ajax.Request("index.php",
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
	});*/
   
}
function blocksetsendcashbillpop(idname,vid){

    puyoungJS_DialogBox.unblock();
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
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        document.getElementById("OkPeriodTime").focus();
            return false;
    }
    if(!r.test(loadcount))
    {
            //期数应该输入正整数！
            var confirm_str = arrJsPopLabel['PERIODSSHOULDPOSITIVEINTEGER'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
            tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";
			
			tdperiodtime=newRow.insertCell(1);
            var objperiodtime=document.createElement('input');
			tdperiodtime.innerHTML="<input type='text' name='periodtime"+i+"' value='"+startperiodtime+"' id='periodtime"+i+"' class='ld-input-inner' size='10'>";
           /*tdperiodtime=newRow.insertCell(1);
            var objperiodtime=document.createElement('input');
            objperiodtime.type='text';
            objperiodtime.size=10;
            objperiodtime.id="periodtime"+i;
            objperiodtime.name="periodtime"+i;
            objperiodtime.value=startperiodtime;
            tdperiodtime.appendChild(objperiodtime);*/
            
            //objratio.onblur=percentamount(objratio,'amount'+i,nopaymentamount);
            /*20101010
            andrew
            改进功能  合同关联创建回款计划
            在添加function 时出现问题，王灿说还是用html直接赋值
            */
           tdratio=newRow.insertCell(2);
           tdratio.innerHTML="<input type='text' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' class='ld-input-inner' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
            /**
            *更新操作
            *edit:can
            *date:20131230
            *reason:06560: 合同订单->点击“创建回款计划”按钮，然后加载100期回款计划，再连续删除5~10期，程序就会弹出错误，如
            **/
            //tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+i+"' id='periodtime"+i+"' value='"+(startperiodtime)+"'/>";
            tdamount=newRow.insertCell(3);
           
            tdamount.innerHTML="<input type='text' class='ld-input-inner' size='20' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
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
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
    tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";

    var tdperiodtime=tabtr.insertCell(1);
    tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/>";
    var tdratio=tabtr.insertCell(2);
    tdratio.innerHTML="<input class='ld-input-inner' type='text' size='10' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(3);
    tdamount.innerHTML="<input class='ld-input-inner' type='text' size='10' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
    var tdplandate=tabtr.insertCell(4);
   
    tdplandate.innerHTML="<input type='text' size='15' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\' onClick='WdatePicker()' class='Wdate ld-input-inner' />";
    tdplandate.setAttribute('class', 'ld-form-item-content');
    var tddescription=tabtr.insertCell(5);
    tddescription.innerHTML="<textarea name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>";
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
function SaveSendPayment()
{
	var prompt;
	var deploy = document.getElementById("DeployValue").value;
	var tabplan=document.getElementById("tabsendpayment");

    var rowcount=tabplan.rows.length;
    var planamount=0.0;
    if(rowcount<=1)
    {
        // puyoungJS_DialogBox.unblock();
         //付款计划金额和未计划金额不一致！
         var confirm_str = arrJsPopLabel['PAYMENTSPLANINCONSISTENCY'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

         document.getElementById('save_payment_check').disabled=false;
         return false;
    }
  
    for( var i=1;i<rowcount;i++)
    {
        if(document.getElementById("periodtime"+i).value=="")
        {
            //期次不能为空！
            var confirm_str = arrJsPopLabel['OFTIMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById("periodtime"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
         return  false;
        }
        if(document.getElementById("amount"+i).value==0 ||trim(document.getElementById("amount"+i).value)=="")
        {
            //金额不能为空或等于零！
            var confirm_str = arrJsPopLabel['AMOUNTCANOTZERO'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById("amount"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
            return false;
        }
       if(isNaN(document.getElementById("amount"+i).value))
       {	
         //金额非法！
         var confirm_str = arrJsPopLabel['AMOUNTILLEGAL'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

         document.getElementById("amount"+i).focus();
         document.getElementById('save_payment_check').disabled=false;
         return  false;
       }
       if(document.getElementById("plandate"+i).value=="")
       {	
         //计划日期不能为空！
         var confirm_str = arrJsPopLabel['PLANNEDATECANOTEMPTY'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

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
           // puyoungJS_DialogBox.unblock();
            //付款计划金额和未计划金额不一致！
            var confirm_str = arrJsPopLabel['PAYMENTSPLANINCONSISTENCY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

            document.getElementById('save_payment_check').disabled=false;
            return false;
        }else{
			submitNewSendPaymentPlan();
		}
    }
    else if(deploy == 0)
    {
        if(planamount == nopaymentamount)
        {
            submitNewSendPaymentPlan();
        }
        else
        {
            if(parseFloat(planamount) < parseFloat(nopaymentamount))  //直接比较其实相当于在字符串比较 导致弹出层信息错误一直走else
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
            //edit:can 20210201 043960: （61mis.com/kfbcrm）财务管理-采购发票-相关信息-收款计划-新建（需要补丁）；新建收款计划时，若收款金额少于未计划金额，弹出层信息有误，且确认保存或取消后界面变灰色；
            RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
            // @edit:liushuai,2021-02-20,reason:0044572: （61mis.com/kfbcrm）财务管理-采购发票-相关信息创建-付款计划；付款计划少于未计划金额时，点击无法保存；（系统参数设置为否，1是，0否）
            //确定事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                submitNewSendPaymentPlan();
            });
            return false;
        }
    }
}

//付款计划 - 保存
function submitNewSendPaymentPlan(){
	var popupobj=CrmPopup.getPopupObj("last");
	var data = new FormData(ld(".noMargin")[0]);
	var surl = "";
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=SendPayment&action=SendPaymentAjax&file=MassAdd',
		success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
			//chj 2020/12/1 43439: （本地php72，8.3.2版本）财务管理-采购发票-相关信息；采购发票相关创建付款计划，保存后付款单据没有立即刷新显示出来
           var tmparra=new Array();
             var tmpobj= new AfterUpdatePrevPopupObjContent("SendPayment",getEmptyValueInfo(),tmparra);
            var refreshlistmodules=[];
            refreshlistmodules.push("SendPayment");
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
}
 function CashSet(obj,divid,purchaseorderid)
    {
		//关闭回款计划弹出层
        var popupobj=CrmPopup.getPopupObj("last");
		popupobj.CancelEvent();

		var surl = "index.php?module=SendPayment&action=SendPaymentAjax&file=CashSet&purchaseorderid=" +purchaseorderid
		var popupobj=CrmPopup.getPopupObj("last");
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,SaveSendPaymentSet,'',"LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.show(data.result.content);
                // 需要去掉的给高度
                crmPopupobj.reduceBodyHeight = 37;
                // 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                //BUG20240625-64 ls 销售订单相关信息关联创建收款计划界面，点击新增期次->确定->设置默认收款比例->取消所有弹窗后，点击新建，界面一直显示加载中(弹窗没有被正常关闭)
                ld('#'+crmPopupobj.divid+' .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
                    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                    var record = popupobj.record;
                    NewSendPayment('','CreateSendPayment',record,0,'no','no');
                });
			}else{
				crmPopupobj.CancelEvent();
				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg); 
			}
		})
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
        for(var i=1;i<rowcount;i++){
            if(isNaN(document.getElementById("percent"+i).value))
            {
                //付款比例非法！
                var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

                document.getElementById("percent"+i).focus();
                return false;
            }
            if(document.getElementById("percent"+i).value<=0)
            {
                //付款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PAYMENTPERCENTAGEPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
            }
            total=total+parseFloat(document.getElementById("percent"+i).value);
        }
        if(parseFloat(total)>=100){
            //付款比例合计必须等于100！
            var confirm_str = arrJsPopLabel['PAYMENTEQUALPROPORTION100'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
        var addrow=tableset.insertRow(rowcount);
        var other=100-parseFloat(total);
        addrow.id="row"+rowcount;
        var addcell=addrow.insertCell(0);
        addcell.innerHTML='<input class="ld-input-inner" name="periodtime'+rowcount+'" id="periodtime'+rowcount+'" type="text" value="'+rowcount+'" />';
        addcell=addrow.insertCell(1);
        addcell.innerHTML='<input class="ld-input-inner" onchange="return percentChange(this)" name="percent'+rowcount+'" id="percent'+rowcount+'" type="text" value="'+parseFloat(other).toFixed(2)+'"  />';
        addcell=addrow.insertCell(2);
        addcell.innerHTML='<i class="ld-fonticon ld-fonticon-del" onclick="deletesettr(this)"></i>';
    }
    
    function percentChange(obj)
    {
        if(isNaN(obj.value))
        {
             //付款比例非法！
             var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
    
     function SaveSendPaymentSet()
    {
         var tableset=document.getElementById("tableSet");
         var total=0;
         for(var i=1;i<tableset.rows.length;i++)
         {
            
             if(isNaN(document.getElementById("percent"+i).value))
             {
                //付款比例非法！
                var confirm_str = arrJsPopLabel['PAYMENTRATIOILLEGAL'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             if(document.getElementById("percent"+i).value<=0)
             {
                //付款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PAYMENTPERCENTAGEPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             total=total+parseFloat(document.getElementById("percent"+i).value);
             
         }
         if(parseFloat(total)!=100.00)
         {
            //付款比例合计必须等于100！
            var confirm_str = arrJsPopLabel['PAYMENTEQUALPROPORTION100'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
         }
         var popupobj=CrmPopup.getPopupObj("last");
		var record = ld("#"+popupobj.divid+" [name=record]").val();
		var data = new FormData(ld(".setSendCashBillForm")[0]);
		var surl = "";
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: data,
			url: 'index.php?module=PaymentPlan&action=PaymentPlanAjax&file=SaveCashBillSet',
			success: function(json, textStatus, xhr) {
				ld('#rptContentLoading').hide();
				popupobj.CancelEvent();
				NewSendPayment('','CreateSendPayment',record,0,'no','no');
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		  })
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
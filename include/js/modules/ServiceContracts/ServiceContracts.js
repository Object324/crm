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
            return false;
        }
    }
	var surl = "index.php?module=PaymentPlan&action=PaymentPlanAjax&file=ServiceContractsPaymentPlan&servicecontractsid=" +servicecontractsid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate+'&frommodule=ServiceContracts';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'PaymentPlan',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code == 1){
			crmPopupobj.setParams(data.result.title,saveNewPaymentPlan,"","LdPopWidth800px",'PaymentPlan',"",data.result.oktext,"",data.result.canceltext,"");  
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
    return false;
   
}
function saveNewPaymentPlan(){
	var tabplan=document.getElementById("tabpaymentplan");

	var rowcount=tabplan.rows.length;
	var planamount=0.0;
	if(rowcount<=1)
	{
		// puyoungJS_DialogBox.unblock();	
		//回款计划金额和未计划金额不一致！
		var confirm = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
		return false;
	}
	for( var i=1;i<rowcount;i++)
    {
        if(document.getElementById("periodtime"+i).value=="")
        {
            //puyoungJS_DialogBox.unblock();	
            //期次不能为空！
            var confirm = arrJsPopLabel['OFTIMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            document.getElementById("periodtime"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
            return  false;
        }
        if(document.getElementById("amount"+i).value==0 ||trim(document.getElementById("amount"+i).value)=="")
        {
            //puyoungJS_DialogBox.unblock();	
            //金额不能为空或等于零！
            var confirm = arrJsPopLabel['AMOUNTCANOTNULL'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            document.getElementById("amount"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
            return false;
        }
       if(isNaN(document.getElementById("amount"+i).value))
       {
            //  puyoungJS_DialogBox.unblock();	
            //金额非法！
            var confirm = arrJsPopLabel['AMOUNTILLEGAL'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            document.getElementById("amount"+i).focus();
            document.getElementById('save_payment_check').disabled=false;
            return  false;
       }
       var paymenttype = ld('#paymenttype').val();
       if(paymenttype=='计划回款日期'){
		   if(document.getElementById("plandate"+i).value=="")
		   {
			// puyoungJS_DialogBox.unblock();	
			 //计划日期不能为空！
			 var confirm = arrJsPopLabel['PLANNEDATECANOTEMPTY'];
			 RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
			 document.getElementById("plandate"+i).focus();
			 document.getElementById('save_payment_check').disabled=false;
			 return false;
		   }
          
       }
       //37119: 如果在回款计划的页面设置中， 增加了“备注”栏目的属性为：必录项， 则在合同保存时弹出的回款计划页面，也应是必录项
        var planremarklabel=ld("#planremarklabel").val();
           if(document.getElementById('planremarktypeofdata').value=='m'&&ld.trim(ld("#description"+i).val())=='')
           {
            var confirm=arrJsPopLabel['LINE']+i+arrJsPopLabel['row']+planremarklabel+arrJsPopLabel['CANOTEMPTY'];
            
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
                 document.getElementById('save_payment_check').disabled=false;
                return false;
           }
        planamount=parseFloat(parseFloat(planamount)+parseFloat(document.getElementById("amount"+i).value)).toFixed(2);
    }
	var deploy = document.getElementById("DeployValue").value;
	var nopaymentamount=parseFloat(document.forms['frmpaymentplan'].nopaymentamount.value).toFixed(2);
	if(deploy == 1)
    {
        if(planamount!=nopaymentamount)
        {
            //puyoungJS_DialogBox.unblock();	
            //回款计划金额和未计划金额不一致！
            var confirm = arrJsPopLabel['PLANNEDINCONSISTENTUNPLANNED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm);
            document.getElementById('save_payment_check').disabled=false;
            return false;
        }else{
			submitNewPaymentPlan();
		}
    }
    else if(deploy == 0)
    {
        if(planamount == nopaymentamount)
        {
            submitNewPaymentPlan();
        }
        else
        {
            if(parseFloat(planamount) < parseFloat(nopaymentamount))
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

            RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
            //确定事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                submitNewPaymentPlan();
            });
        }
    }
	
}
saveNewPaymentPlan.funname='saveNewPaymentPlan';


//回款计划 - 保存
function submitNewPaymentPlan(){
	var popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj = CrmPopup.getPopupObj("lastprev");
	var data = new FormData(ld(".noMargin")[0]);
	var surl = "";
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=PaymentPlan&action=PaymentPlanAjax&file=MassAdd',
		success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
            //duan 详情页创建相关信息后刷新进度追踪图
            if(prevpopupobj.pagetype =='detailview_modulepage'){
                DetailViewRelation.showpage_moduledetail(prevpopupobj);
            }
            var tmparra=new Array();
            var tmpobj= new AfterUpdatePrevPopupObjContent("PaymentPlan",getEmptyValueInfo(),tmparra);
            tmparra.push("PaymentPlan");
            tmpobj.eachrefreshlistbyModules(tmparra);
            
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
}
//SavePaymentPlan

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
    var popupobj=CrmPopup.getPopupObj('last');
    
	var paymenttype =ld("#"+popupobj.divid+' [name=paymenttype]').val();// ld('#paymenttype').val();
    
    var tabtr=tabplan.insertRow(rowcount);
    tabtr.id="row"+rowcount;
    var tddelete=tabtr.insertCell(0);
    tddelete.align='center';
    tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";

    var tdperiodtime=tabtr.insertCell(1);
    tdperiodtime.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/>";
    var tdratio=tabtr.insertCell(2);
    tdratio.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(3);
    tdamount.innerHTML="<input type='text' size='10' class='ld-input-inner gwidth100' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
	var tdplandate=tabtr.insertCell(4);
    tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate ld-input-inner' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\'/>";
	tdplandate.id='paymentpan_date_td_'+rowcount;
    tdplandate.setAttribute('class', 'ld-form-item-content');

    if (ld('input[name=paymenttypevalue]').val() == 'noproject') {//ls 2021-11-04 项目立项模块关闭时，新增期次不应该有项目状态
        var tddescription=tabtr.insertCell(5);
    }else{
        if(paymenttype == '项目状态'){
            tdplandate.style.display='none';
        }
        var tdprjectstatus = tabtr.insertCell(5);
        tdprjectstatus.innerHTML="<select class='ld-select-inner' name='projectstatus"+rowcount+"'>"+selectHTML;
        tdprjectstatus.id='projectstatus_td_'+rowcount;
        //edit:can 2020-11-03 43095: （8.2.9安装包）服务管理-服务合同；点击服务合同编号，新建收款计划，新增批次，备注下方的文本框显示出现问题
        if(paymenttype == '计划收款日期'||paymenttype=='计划回款日期'){
            tdprjectstatus.style.display='none';
        }
        var tddescription=tabtr.insertCell(6);
    }

    tddescription.innerHTML="<textarea  name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>";
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
        var tdprojectstatus;
        var tdplandate;
        var dates
        var mnth="";
        var count = 100/loadcount;
        //edit:duan 生成收款计划时，选择日期为31会出现日期读取失败的情况
		var date30 = new Array('4','6','9','11','04','06','09');
        for(var i=1;i<=loadcount;i++)
        {
            newRow=document.getElementById("tabpaymentplan").insertRow(i);
            newRow.id="row"+i;
            tddelete=newRow.insertCell(0);
            tddelete.align="center";
            tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";

            tdperiodtime=newRow.insertCell(1);
            var objperiodtime=document.createElement('input');
            objperiodtime.type='text';
            objperiodtime.size=10;
            objperiodtime.id="periodtime"+i;
            objperiodtime.name="periodtime"+i;
            objperiodtime.value=startperiodtime;
            objperiodtime.className='commonTextBoxPop gwidth100';
            tdperiodtime.appendChild(objperiodtime);
			 if(i == loadcount){
				percentamount = nopaymentamount - percentamount*(loadcount - 1);
				percentamount = parseFloat(percentamount).toFixed(2);
				count = 100 - count.toFixed(2)*(loadcount - 1);
			}
            tdratio=newRow.insertCell(2);
            tdratio.innerHTML="<input type='text' class='commonTextBoxPop gwidth100' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
            tdamount=newRow.insertCell(3);
            tdamount.innerHTML="<input type='text' class='commonTextBoxPop gwidth100' size='10' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
            tdplandate=newRow.insertCell(4);

            //ls 2021-11-03 收款计划新建，新建收款计划时，重算收款期次，然后切换收款计划类型会失败；会出现项目状态和收款日期一起出现问题
            tdplandate.id='paymentpan_date_td_'+i;

            if (ld('input[name=paymenttypevalue]').val() == 'noproject'){ //当Projects模块未启用时收款计划类型只有计划回款日期
                tddescription=newRow.insertCell(5);
            }else{
                var paymenttype = ld('#paymenttype').val();
                if(paymenttype == '项目状态'){
                    tdplandate.style.display='none';
                }
                tdprojectstatus=newRow.insertCell(5);

                //项目状态
                var pliststr=document.getElementById("pliststr").value;
                var tmp_plist=pliststr.split(",");
                var is=0;
                var selectHTML='';
                while(tmp_plist.length-1>is){
                    selectHTML += "<option value='"+tmp_plist[is]+"'>"+tmp_plist[is]+"</option>"
                    is++;
                }

                tdprojectstatus.innerHTML="<select class='commonSelectPop' name='projectstatus"+i+"' id='projectstatus"+i+"'/>" +selectHTML
                "</select>";

                tdprojectstatus.id='projectstatus_td_'+i;
                if(paymenttype == '计划收款日期'){
                    tdprojectstatus.style.display='none';
                }

                tddescription=newRow.insertCell(6);
            }

            // tddescription=newRow.insertCell(5);
            tddescription.innerHTML="<textarea name='description"+i+"' id='description"+i+"' value='' cols='100%' style='height: 30px;'></textarea>";

           
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
        tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate ld-input-inner' readonly='true' name='plandate"+i+"' value='"+startplandate+"' id='plandate"+i+"\'/>";
        tdplandate.setAttribute('class', 'ld-form-item-content');
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
 /*
    更新操作
    edit:can
    date:20131030
    reason:合同订单调整回款计划(v3.1)
    */
    function ChangePaymentPlan(obj,id)
    {
        $("status").style.display="inline";
        var salesorderid=id;
     //弹出框的设计
     	new Ajax.Request("index.php",
    		{
    			queue:{
    				position:"end",
    				scope:"command"
    			},
    			method:"post",
    			postBody:"module=PaymentPlan&action=ChangePaymentPlan&salesid=" +salesorderid,
    			onComplete:function (response) {
    			 /*
                 reason:6002: 建议：当合同订单没有回款计划时，合同订单查看界面点击调整回款计划按钮后希望可以给出提示信息
                 edit:can
                 date:20131209
                 */
    			 if(response.responseText.indexOf('###ERROR####')!=-1)
                 {
                    //该合同订单无回款计划！
                    var confirm_str = arrJsPopLabel['SALESORDERWITHOUTPAYMENTPLAN'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    $("status").style.display="none";
                    return false;
                 }
				  if(response.responseText.indexOf('###ERROR2####')!=-1)
                 {
                    //该合同订单无回款计划！
                    var confirm_str = arrJsPopLabel['YOUDONOTHAVETHECONTRACTPORDER'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    $("status").style.display="none";
                    return false;
                 }
    			 var results=response.responseText.split("####:###");
              
    			 $("dvChangePaymentPlan").innerHTML=results[1];
                  
                 $("status").style.display="none";
                 fnvshobj(obj,"dvChangePaymentPlan");
    			}
    		}
        ); 
    }
    
    /*
更新操作
edit:can
reason:服务合同调整回款计划(V3.1)
*/
function paymentplanChk(obj,rowindex)
{
    
    var nowamount=0;
    var oldamount=document.getElementById("oldamount"+rowindex).value;
    var tab=document.getElementById("ChangePaymentList");
    var tabcel=tab.rows[rowindex+1].cells[8];//调整后金额
    
    if(obj.checked)
    {
        obj.value=1;
        document.getElementById("amountpercent"+rowindex).readOnly=false;
        document.getElementById("amountpercent"+rowindex).value=100;
        nowamount=document.getElementById("amountpercent"+rowindex).value*oldamount/100;
    }
    else
    {
        obj.value=2;
        document.getElementById("amountpercent"+rowindex).value="0";
        nowamount=document.getElementById("amountpercent"+rowindex).value*oldamount/100;
        document.getElementById("amountpercent"+rowindex).value="";
        document.getElementById("amountpercent"+rowindex).readOnly=true;
    }
  
    nowamount=parseFloat(nowamount).toFixed(2);
    tabcel.innerHTML="<input type='hidden' value='"+nowamount+"' name='nowamount"+rowindex+"' id='nowamount"+rowindex+"'/>"+nowamount;
}
/*
更新操作
edit:can
reason:服务合同调整回款计划
other:保存
*/
function SaveChangtePaymentPlan(obj,frmname)
{
    var tab=document.getElementById("ChangePaymentList");
    var tabcel;
    var oldamount=0;
    var nowamount=0;
    var choiceCount=0;
    for(var i=0;i<tab.rows.length-1;i++)
    {
        if(document.getElementById("chk"+i).checked!=true)
        {
            continue;
        }
        choiceCount++;
        if(trim( document.getElementById("amountpercent"+i).value)=="")
        {
            //调整系数不能为空！
            var confirm_str = arrJsPopLabel['ADJUSTMENTFACTORCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById("amountpercent"+i).focus();
            return false;
        }
        if(isNaN(document.getElementById("amountpercent"+i).value))
        {
            //无效的调整系数(%)！
            var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTFACTOR'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.getElementById("amountpercent"+i).focus();
            return false;
        }
        oldamount=document.getElementById("oldamount"+i).value;
       
    }
    if(choiceCount<=0)
    {
        //请至少选择一条记录！
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    document.forms[frmname].submit();
}

function amountPercentChange(obj,rowindex)
{
     var avalue=0;
    if(trim(obj.value)=="")
    {
        //obj.value=0;
         tabcel.innerHTML="";
        return ;
    }
    else
    {
        avalue=document.getElementById("amountpercent"+rowindex).value;
    }
    if(isNaN(obj.value))
    {
         //无效的调整系数(%)！
         var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTFACTOR'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
         obj.focus();
         return false;
    }
    var oldamount=document.getElementById("oldamount"+rowindex).value;
    var tab=document.getElementById("ChangePaymentList");
    var tabcel=tab.rows[rowindex+1].cells[8];//调整后金额
    var nowamount=parseFloat(avalue)*oldamount/100;
    nowamount=parseFloat(nowamount).toFixed(2);
    tabcel.innerHTML="<input type='hidden' value='"+nowamount+"' name='nowamount"+rowindex+"' id='nowamount"+rowindex+"'/>"+nowamount;
}
/*
更新操作
edit:can
date:20131118
reason:5650: 皓星还有两个问题要解决：1.明细表可租面积统计方法2.合同订单调整回款计划
*/
function AllChangePercent(obj)
{
    var svalue=document.getElementById("txtChangePercent").value;
    if(trim(svalue)=="")
    {
        document.getElementById("txtChangePercent").value=0;
    }
    if(isNaN(svalue))
    {
         //无效的统一调整系数(%)！、无效的调整系数(%)！：这两个我用了同一个弹出提醒
         var confirm_str = arrJsPopLabel['INVALIDADJUSTMENTFACTOR'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
         document.getElementById("txtChangePercent").focus();
         return false;
    }
    var tab=document.getElementById("ChangePaymentList");
    var tabcel;
    var oldamount=0;
    var nowamount=0;
     /*
        edit:can
        date:20131202
        reason:5955: 合同订单调整回款计划功能改进：增加是否要递进式调整复选框（皓星）
        */
    if(document.getElementById('chkIncreatement').checked==true)
    {
        for(var i=0;i<tab.rows.length-1;i++)
        {
            tabcel=tab.rows[i+1].cells[8];//调整后金额
            document.getElementById("chk"+i).checked=obj.checked;
           document.getElementById("chk"+i).checked=true;
           document.getElementById("chk"+i).value=1;
           document.getElementById("amountpercent"+i).readOnly=false;
           document.getElementById("amountpercent"+i).value=svalue;
           oldamount=document.getElementById("oldamount0").value;
           if(i>0)
           {
             oldamount=document.getElementById("nowamount"+(i-1)).value
           }
           nowamount=document.getElementById("amountpercent"+i).value*oldamount/100;
           nowamount=parseFloat(nowamount).toFixed(2);
           tabcel.innerHTML="<input type='hidden' value='"+nowamount+"' name='nowamount"+i+"' id='nowamount"+i+"'/>"+nowamount;
        }
    }
    else
    {
        for(var i=0;i<tab.rows.length-1;i++)
        {
            document.getElementById("chk"+i).checked=obj.checked;
            tabcel=tab.rows[i+1].cells[8];//调整后金额
            oldamount=document.getElementById("oldamount"+i).value;
           document.getElementById("chk"+i).checked=true;
           document.getElementById("chk"+i).value=1;
           document.getElementById("amountpercent"+i).readOnly=false;
           document.getElementById("amountpercent"+i).value=svalue;
           nowamount=document.getElementById("amountpercent"+i).value*oldamount/100;
            nowamount=parseFloat(nowamount).toFixed(2);
            tabcel.innerHTML="<input type='hidden' value='"+nowamount+"' name='nowamount"+i+"' id='nowamount"+i+"'/>"+nowamount;
            
        }
    }
}


// ljj 20240524 XUQIU1002227 服务合同增加续签按钮，可自动生成单据，续签一年
function renewContracts(module,record,iscontinue) {
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=renewContracts&record='+record;
    url += '&sourcefrom=PC';
    if (iscontinue == 'yes'){
        url += '&iscontinue=yes';
    }
    ldAjax(url,'',function (data) {
        if (data.code == 1){//成功续签
            MessagePopup.TipOne_success(data.msg);
            var messagepopupobj = CrmPopup.getPopupObj('last');
            var confirm_button = ld('#'+messagepopupobj.divid).find('a[name=hyperlink]');
            var tmparra=new Array();
            tmparra.push(record);
            var tmpobj= new AfterUpdatePrevPopupObjContent(module,'',tmparra);
            tmparra=[module];
            tmpobj.eachrefreshlistbyModules(tmparra);

        }else if (data.code == 'confirm_renew'){//已续签，是否继续
            MessagePopup.TipTwo_warning(data.msg);
            var messagepopupobj = CrmPopup.getPopupObj('last');
            var confirm_button = ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]');
            confirm_button.bind('click',function () {
                renewContracts(module,record,'yes');
            });
        }else{//无字段,无法继续等提示
            MessagePopup.TipOne_warning(data.msg);
        }
    });

}
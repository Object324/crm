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

//document.write("<script type='text/javascript' src='modules/MailManager/Mask.js'></"+"script>");
function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}

function set_return_specific(product_id, product_name, mode, product_all) {
    /*
    edit:can
    date;20131231
    reason:出库单选择合同订单，然后再刷新页面后不能显示产品明细
    */
    //getOpenerObj used for DetailView 
    //var fldName = getOpenerObj("salesorder_name");
    //var fldId = getOpenerObj("salesorder_id");
    //fldName.value = product_name;    
    //fldId.value = product_id;
 
    /**
    *edit:cyb
    *date:2016-06-08
    *reason:服务合同选择合同订单带出产品明细
    **/
    if(window.opener.document.EditView.salesorder_name != undefined){
	     window.opener.document.EditView.salesorder_name.value = product_name; 
	}
    if(window.opener.document.EditView.salesorder_id != undefined){
	     window.opener.document.EditView.salesorder_id.value = product_id; 
	}
	if(mode != 'DetailView')
	{
		if(window.opener.document.EditView.module != undefined && window.opener.document.EditView.module.value !='SalesOrder'){
            window.opener.document.EditView.action.value = 'EditView';
			window.opener.document.EditView.convertmode.value = 'update_so_val';
			window.opener.document.EditView.submit();
		}
           
	}
}
function set_return_formname_specific(formname, product_id, product_name) {
        window.opener.document.EditView1.purchaseorder_name.value = product_name;
        window.opener.document.EditView1.purchaseorder_id.value = product_id;
}
function set_return_todo(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.task_parent_name.value = product_name;
        window.opener.document.QcEditView.task_parent_id.value = product_id;
	} else {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
	}
}
/*
Edit:can
date:20130524
reason:创建回款计划弹出框
*/
function setPaymentCoOrdinate(obj,divid){
	oBtnObj = obj;
	var tagName = document.getElementById(divid);
	leftpos  = 0;
	toppos = 0;
	aTag = oBtnObj;
	do{
	  leftpos  += aTag.offsetLeft;
	  toppos += aTag.offsetTop;
	} while(aTag = aTag.offsetParent);

	tagName.style.top= toppos + 20 + 'px';
	tagName.style.left= leftpos - 276 + 'px';
    tagName.style.zIndex=1001;
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
}
/**
edit:can
param:isImmediatelycreate:是否为立即创建 ,yes:立即创建
param:isshowPrintDiv:是否显示打印弹出层，yes:显示，no:不显示；
**/
function NewPaymentPlan(obj,divid,salesorderid,deployid,isImmediatelycreate,isshowPrintDiv)
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
	var surl = "index.php?module=PaymentPlan&action=PaymentPlanAjax&file=PopPaymentPlan&salesorderid=" +salesorderid+'&ReportHeader=DHeader&Immediatelycreate='+isImmediatelycreate+'&frommodule=SalesOrder&isshowPrintDiv='+isshowPrintDiv;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'PaymentPlan',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code == 1){
			crmPopupobj.setParams(data.result.title,saveNewPaymentPlan,"","LdPopWidth800px",'PaymentPlan',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
            
            //edit: xll 2023/05/16 BUG0060876 新建订单弹出“收款计划”后，点击“设置默认收款比例”设置窗口消失 
            var popupobj = CrmPopup.getPopupObj('last');
            popupobj.record = salesorderid;
            
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
       if(paymenttype=='计划收款日期'){
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
		success: function(data) {
		  
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
            //duan 详情页创建相关信息后刷新进度追踪图
            if(prevpopupobj.pagetype =='detailview_modulepage'){
                DetailViewRelation.showpage_moduledetail(prevpopupobj);
            }
            //41431: (61mis.com/kfbtest）合同订单模块>单据详情界面：工具栏点击“复制”按钮，然后保存单据，界面卡死，一直显示“加载中”
		   var tmparra=new Array();
            var tmpobj= new AfterUpdatePrevPopupObjContent("PaymentPlan",getEmptyValueInfo(),tmparra);
            var refreshlistmodules=[];
            refreshlistmodules.push("PaymentPlan");
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            if(data.result.sysdeploy != undefined &&data.result.sysdeploy['SalesOrder']['deploytype']==57&&data.result.sysdeploy['SalesOrder']['deployvalue']=='0'){
                var param = {'module':'SalesOrder','recordid':data.result.sysdeploy['SalesOrder']['record']};
                
                getJsScript('include/js/SystemPopup/PrintPopup.js',function(){
                    PrintPopup.showpopuphaveparam(param);
                });
            }
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
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
	var paymenttype = ld('#paymenttype').val();
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
           /*
           edit:can
           date:201300801
           reason:4585: 建议：合同订单保存后创建回款计划界面，修改最后一期金额，然后单击添加时“期次”应该也有默认值
           */

                if(!isNaN(document.getElementById("periodtime"+i).value))
                curperiod=parseFloat(document.getElementById("periodtime"+i).value)+1;
        }
    }
    var currow=rowcount-1;
    if(rowcount>1)
    {
        //计划回款日期
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
		balanceamount=parseFloat(nopaymentamount)-parseFloat(planamount);
		balanceratio=100-parseFloat(planratio);
        /*
        Edit:chj
        date:20130814
        reason:控制汇款计划金额;追加还款期限  1 是  0 否
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
        if(deploy == 1)
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
                  addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML);
                });
                return ;
            }   
        }
    }else{
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
    }
    addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML);
}

//添加行
function addrowstr(tabplan,rowcount,curperiod,balanceratio,balanceamount,nopaymentamount,paymenttype,plandate,selectHTML){

    var tabtr=tabplan.insertRow(rowcount);
    tabtr.id="row"+rowcount;
    var tddelete=tabtr.insertCell(0);
    tddelete.align='center';
    tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";
    /*
       edit:can
       date:201300801
       reason:4585: 建议：合同订单保存后创建回款计划界面，修改最后一期金额，然后单击添加时“期次”应该也有默认值
       */
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
        if(paymenttype == '计划收款日期'){
            tdprjectstatus.style.display='none';
        }
        var tddescription=tabtr.insertCell(6);
    }

    tddescription.innerHTML="<textarea name='description"+rowcount+"' id='description"+rowcount+"' value='' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>";
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
     reason:5420: 合同订单明细界面：创建回款计划窗口点击添加按钮时网页左下角报错
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

       //alert(document.getElementById("ratio"+j).onchange);
       //document.getElementById("ratio"+j).onchange=changeamountn(document.getElementById("ratio"+j),'amount'+j,'ratio'+j,paymentamount);
       document.getElementById("ratio"+j).onchange = function(){
            var idstr = this.id;
            var jj = idstr.substring(5,idstr.length);
            changeamountn(this,'amount'+jj,'ratio'+jj,paymentamount);
       }
       document.getElementById("amount"+j).onchange = function(){
            var idstr = this.id;
            var jj = idstr.substring(6,idstr.length);
            changeratio(this,'ratio'+jj,'amount'+jj,paymentamount);
       }
		document.getElementById("plandate"+i).name="plandate"+j;
		document.getElementById("plandate"+i).id="plandate"+j;
		document.getElementById("projectstatus"+i).name="projectstatus"+j;
		document.getElementById("projectstatus"+i).id="projectstatus"+j;
       /*
        tdimage=tabplan.rows[j].cells[3];
        
        tdimage.innerHTML="<input type='text' size='10' value='"+ document.getElementById("plandate"+i).value+"' id='plandate"+j+"' name='plandate"+j+"'/>"+"<img class='popimg'  src='themes/softed/images/btnL3Calendar.gif' id='img"+j+"' onclick='showCalendar(\"plandate"+j+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
        */
        i++;
    }
     
}
//0018073: 合同订单>新建：新建保存后，弹出创建回款计划弹出层。点击“取消”按钮。不应该刷新合同订单明细界面。
function isSalesOrderPrint(obj,isprint,div){
	//关闭创建汇款计划弹出层
	fninvshnew(div);
	if(isprint == 'yes'){
		NewPrintSalesOrder(obj,'printSalesOrderDiv');
	}
}
/*
edit:can
date:20130604
reason:新增合同订单后立即创建回款计划


function CreatePayment(obj,divid,salesorderid)
{
    $("status").style.display="inline";
     calendarParentid="CreatePaymentplan";//该变量在jscalendar/dynamiccalendar.js/

     //弹出框的设计
     	new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"module=PaymentPlan&action=PopCreatePayment&salesorderid=" +salesorderid+'&ReportHeader=DHeader',
			onComplete:function (response) {
			 var results=response.responseText.split("####:###");
             if(results[1].indexOf(("error####::"))!=-1)
             {
                 var errorre=results[1].split("error####::")[1];
                 
                alert(errorre);
                $("status").style.display="none";
                return false;
             }
             

			 $("Paymentplan_form_div").innerHTML=results[1];
             
				//setPaymentCoOrdinate(obj,divid);
                fnvshobj(obj,divid);
                $("status").style.display="none";
			}
		}); 
}*/
    
    /*
    edit:can
    date:20130618
    reason:手动创建回款计划界面
    */
    function Manual_CreatePaymentPlan()
    {
        fninvsh('CreatePaymentplan');
        document.getElementById("createPaymentid").click();
        //CreatePayment(document.getElementById("createPaymentid"),'CreatePaymentplan',DetailView.record.value);
    }
    


/********************************************************************************/
//回款计划设置函数
/********************************************************************************/
// wym 移动到RelateCreatePaymentPlan.js里了
    function CashSet(obj,divid,salesorderid)
    {
		//关闭回款计划弹出层
        var popupobj=CrmPopup.getPopupObj("last");
		popupobj.CancelEvent();

        var DetailPopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
        //edit: xll 2023/05/16 BUG0060876 新建订单弹出“收款计划”后，点击“设置默认收款比例”设置窗口消失 
        if(salesorderid == 0 && DetailPopupobj != undefined && DetailPopupobj.record != undefined)
        {
             salesorderid = DetailPopupobj.record;
        }
        else if(salesorderid == 0 && popupobj.record != undefined){
             salesorderid = popupobj.record;
        }
        
		var surl = "index.php?module=PaymentPlan&action=PaymentPlanAjax&file=CashSet&salesorderid=" +salesorderid;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'PaymentPlan',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code == 1){
				crmPopupobj.setParams(data.result.title,SaveCashBillSet,CancelCashBillSet,"LdPopWidth600px",'PaymentPlan',"",data.result.oktext,"",data.result.canceltext,"");
			
				crmPopupobj.show(data.result.content);
			}
		})
    }
    function blocksetcashbillpop(idname,vid){
   	    puyoungJS_DialogBox.unblock();
        var newbox=document.getElementById(idname);
        newbox.style.display="none";
        location.href="index.php?module=SalesOrder&action=DetailView&parenttab=Sales&salestype=yes&record="+vid;
    }
    /*
    reason:回款计划设置添加行
    edit:can
    date:20130619
    */
    function addSetTr(obj) {
        var tableset=document.getElementById("tableSet");
        var rowcount=tableset.rows.length;
        var total=0;
        for(var i=1;i<rowcount;i++) {
            if(isNaN(document.getElementById("percent"+i).value)){
                //回款比例非法！
                var confirm_str = arrJsPopLabel['PROPORTIONILLEGALMONEYBACK'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
            }
            if(document.getElementById("percent"+i).value<=0){
                //回款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PROPORTIONBACKMUSTPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
            }
            total=total+parseFloat(document.getElementById("percent"+i).value);
        }
	    if(total >=100){
            //回款比例合计已经超过100！
            var confirm_str = arrJsPopLabel['Totalproportionhasbeenmorethan100'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
	    }
        var rowindex=rowcount;
        var addrow=tableset.insertRow(rowindex);
        var other=100-parseFloat(total);
       
        addrow.id="row"+rowindex;
        var addcell=addrow.insertCell(0);
        addcell.innerHTML='<input name="periodtime'+rowindex+'" id="periodtime'+rowindex+'" type="text" class="ld-input-inner" value="'+rowindex+'" />';
        addcell=addrow.insertCell(1);
        addcell.innerHTML='<input onchange="return percentChange(this)" class="ld-input-inner" name="percent'+rowindex+'" id="percent'+rowindex+'" type="text" value="'+parseFloat(other).toFixed(2)+'"  />';
        addcell=addrow.insertCell(2);
        addcell.innerHTML='<i class="ld-fonticon ld-fonticon-del" href="javascript:;" onclick="deletesettr(this)"></i>';
    }
    
	function CancelCashBillSet(){
	   //edit:can 2020-12-03 43553: （本地php54，8.3.1.1版本）采购管理-采购订单-相关信息-付款计划（需要补丁）；在采购订单相关信息创建付款计划，付款计划新增界面点击左下角设置付款比例，付款比例弹出层中点取消，页面会一直转圈缓冲
       //  var popupobj=CrmPopup.getPopupObj('last');
        //edit:can 20210925 48033: （https://81mis.com/kfbcrm/ [^]）合同订单查看详情界面，相关信息中【新建】收款计划，点击【设置默认收款比例】-【取消】，再点击【设置默认比例】时点不动
        // popupobj.CancelEvent();
     	 var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
		var record = popupobj.record;
        //@edit:liushuai,2021-04-06,reason:0045262: （61mis.com/kfbcrm）销售管理-合同订单-详情；相关创建收款计划，设置默认收款比例时，点击取消；单据详情会被关掉
		// popupobj.CancelEvent();
		NewPaymentPlan('','CreatePaymentplan',record,0,'no','no');
	}

    function percentChange(obj)
    {
        if(isNaN(obj.value))
        {
             //回款比例非法！
             var confirm_str = arrJsPopLabel['PROPORTIONILLEGALMONEYBACK'];
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
             obj.focus();
        
            if(!document.all)
            {
                 obj.select();
                 window.setTimeout( function(){ obj.focus();obj.select(); }, 0);  
            }
            return false;
        }
                
        //if(!positiveInteger(obj.value))
        if(obj.value<=0)
        {
             //回款比例必须是正整数！
             var confirm_str = arrJsPopLabel['PROPORTIONBACKMUSTPOSITIVEINT'];
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
    reason:回款计划设置删除
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
            document.getElementById("periodtime"+j).name="periodtime"+i;
            document.getElementById("periodtime"+j).id="periodtime"+i;
            document.getElementById("percent"+j).name="percent"+i;
            document.getElementById("percent"+j).id="percent"+i;
        }
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
    //设置回款比例 - 保存
    function SaveCashBillSet()
    {
         var tableset=document.getElementById("tableSet");
         var total=0;
         for(var i=1;i<tableset.rows.length;i++)
         {
             if(isNaN(document.getElementById("percent"+i).value))
             {
                //回款比例非法！
                var confirm_str = arrJsPopLabel['PROPORTIONILLEGALMONEYBACK'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             //if(!positiveInteger(document.getElementById("percent"+i).value))
             if(document.getElementById("percent"+i).value<=0)             
             {
                //回款比例必须是正整数！
                var confirm_str = arrJsPopLabel['PROPORTIONBACKMUSTPOSITIVEINT'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                document.getElementById("percent"+i).focus();
                return false;
             }
             total=total+parseFloat(document.getElementById("percent"+i).value);
             
         }
         if(parseFloat(total) < 100)
         {
            //回款比例合计必须等于100！
            var confirm_str = arrJsPopLabel['PROPORTIONPAYMENTMUSTEQUAL'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
         }
		

	    if(parseFloat(total) > 100){
		    //回款比例合计已经超过100！
            var confirm_str = arrJsPopLabel['Totalproportionhasbeenmorethan100'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
	    }
		var popupobj=CrmPopup.getPopupObj("last");
		var record = ld("#"+popupobj.divid+" [name=record]").val();
		var data = new FormData(ld(".setCashBillForm")[0]);
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
				NewPaymentPlan('','CreatePaymentplan',record,0,'no','no');
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		  })
    }
    
/*
edit:can
date:20131022
reason:合同订单创建回款计划允许用户自定义设置回款计划期数。
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
        var month_days="0";//月份的天数
		var date30 = new Array('4','6','9','11');
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
			//0040881: （51mis.com/kfbtest）回款计划新增界面，回款计划金额按比例除不尽时，比例金额合计不等于总金额
            if(i == loadcount){
				percentamount = nopaymentamount - percentamount*(loadcount - 1);
				percentamount = parseFloat(percentamount).toFixed(2);
				count = 100 - count.toFixed(2)*(loadcount - 1);
			}
           
            //objratio.onblur=percentamount(objratio,'amount'+i,nopaymentamount);
            /*20101010
            andrew
            改进功能  合同关联创建回款计划
            在添加function 时出现问题，王灿说还是用html直接赋值
            */
           tdratio=newRow.insertCell(2);
           tdratio.innerHTML="<input type='text' class='commonTextBoxPop gwidth100' name='ratio"+i+"' value='"+count.toFixed(2)+"' id='ratio"+i+"' onchange=changeamountn(this,'amount"+i+"','ratio"+i+"','"+nopaymentamount+"'); size='10'>";
            /**
            *更新操作
            *edit:can
            *date:20131230
            *reason:06560: 合同订单->点击“创建回款计划”按钮，然后加载100期回款计划，再连续删除5~10期，程序就会弹出错误，如
            **/
            //tdperiodtime.innerHTML="<input type='text' size='10'  name='periodtime"+i+"' id='periodtime"+i+"' value='"+(startperiodtime)+"'/>";
            tdamount=newRow.insertCell(3);
           
            tdamount.innerHTML="<input type='text' size='10' class='commonTextBoxPop gwidth100' name='amount"+i+"' id='amount"+i+"' onchange=changeratio(this,'ratio"+i+"','amount"+i+"','"+nopaymentamount+"'); value='"+percentamount+"'/>";
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
        //20768: 合同订单>明细：关联创建回款计划，当回款计划日期为31号时，4、6、9、11月份日期显示错误。
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
        tdplandate.innerHTML="<input type='text' onClick='WdatePicker()' class='Wdate ld-input-inner' size='15' readonly='true' name='plandate"+i+"' value='"+startplandate+"' id='plandate"+i+"\'/>";
        //ls 2021-11-03 48559: (81mis.com/kfbcrm/index.php)合同订单》收款计划新建，新建收款计划时，重算收款期次，然后切换收款计划类型会失败；会出现项目状态和收款日期一起出现问题
        tdplandate.id='paymentpan_date_td_'+i;
        tdplandate.setAttribute('class', 'ld-form-item-content');

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
  date:20131030
  reason:合同订单调整回款计划
  other:dvChangePaymentPlan:回款计划弹出框id(V3.1)
  */   
function fnvChangePaymentPlan(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	tagName.style.display = 'block';
	//tagName.style.visibility = "visible";
       
   var pagewidth=Math.min( document.body.scrollWidth,document.body.clientWidth  );
   var widthM=tagName.offsetWidth;

   leftSide=(pagewidth-widthM)/2;
    
	var IE = document.all?true:false;
	if(IE)
	{
		if($("repposition1"))
		{
			if(topSide > 1200)
			{
				topSide = topSide-250;
			}
		}
	}

	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
	tagName.style.top= topSide + 'px';
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
}
/*
更新操作
edit:can
date:20131030
reason:合同订单调整回款计划(V3.1)(全选)
*/
function ChangePaymentPlanchkAll(obj)
{
    var tab=document.getElementById("ChangePaymentList");
    var tabcel;
    var oldamount=0;
    var nowamount=0;
    for(var i=0;i<tab.rows.length-1;i++)
    {
        document.getElementById("chk"+i).checked=obj.checked;
        tabcel=tab.rows[i+1].cells[8];//调整后金额
        oldamount=document.getElementById("oldamount"+i).value;
        if(obj.checked)
        {
            document.getElementById("chk"+i).value=1;
            document.getElementById("amountpercent"+i).readOnly=false;
            document.getElementById("amountpercent"+i).value=100;
            nowamount=document.getElementById("amountpercent"+i).value*oldamount/100;
        }
        else
        {
            document.getElementById("chk"+i).value=2;
            document.getElementById("amountpercent"+i).value="0";
            nowamount=document.getElementById("amountpercent"+i).value*oldamount/100;
            document.getElementById("amountpercent"+i).value="";
            document.getElementById("amountpercent"+i).readOnly=true;
        }
       
        nowamount=parseFloat(nowamount).toFixed(2);
        tabcel.innerHTML="<input type='hidden' value='"+nowamount+"' name='nowamount"+i+"' id='nowamount"+i+"'/>"+nowamount;
        
    }
}
/*
更新操作
edit:can
date:20131030
reason:合同订单调整回款计划(V3.1)(百分比改变)
*/
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
/*
更新操作
edit:can
date:20131030
reason:合同订单调整回款计划(V3.1)
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
date:20131030
reason:合同订单调整回款计划
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
        /*
        edit:can
        date:20131202
        reason:5955: 合同订单调整回款计划功能改进：增加是否要递进式调整复选框（皓星）
        */
       // nowamount=oldamount*document.getElementById("amountpercent"+i).value/100;
        //document.getElementById("nowamount"+i).value=parseFloat(nowamount).toFixed(2);
        
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
/**
 * @edit:chj
 * @date:2014-11-27
 * @reason:合同订单 - 回款计划
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

/*
更新操作
edit:diony
date:20141126
reason:合同订单自动创建出库单
*/
function saveOutboundorder(type)
{
    if(type == 1)
    {
        document.getElementById("autowarehouseid").value=document.getElementById("AfterCreateSalesOrder_CreateOutboundOrder").value;
    }
    else
    {
        document.getElementById("autowarehouseid").value=0;
    }
    document.EditView.submit();
}

function NewPrintSalesOrder(obj,divid)
{
     fnvshobj(obj,divid);
}
/**
edit:can
reason:创建淘宝订单
param:type:1(导入),2(检查遗漏)
**/

function CreateTaoOrder(type)
{
    puyoungJS_DialogBox.block();
    openNewDiv('newDiv');
    if(type==1)
    {
        window.location.href="index.php?module=SalesOrder&action=KDeeOrder";
    }
    else if(type==2)
     window.location.href="index.php?module=SalesOrder&action=KDeeOrder&checkSalesOrder=yes";
}
 /**
 edit:can
 reason:发货
 **/
 function ChangeTaoOrderStatus(obj)
 {
 
     var select_options = document.getElementById('allselectedboxes').value;
	var numOfRows = document.getElementById('numOfRows').value;
	var excludedRecords = $('excludedRecords').value;
    var excludedRecords=document.getElementById("excludedRecords").value;
	var viewid =getviewId();
     var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var url="index.php?module=SalesOrder&action=TaoBaoOrderStatus"+"&viewname="+viewid+"&excludedRecords="+excludedRecords+"&SearchScope="+searchScope;

	if(select_options=='all') 
    {
        var idstring = select_options;
        if(count > getMaxMassOperationLimit()) 
        {
			var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
			if(confirm(confirm_str)) 
            {
				var confirm_status = true;
			} 
            else 
            {
				return false;
			}
        }
        puyoungJS_DialogBox.block();
        openNewDiv('newDiv');
        window.location=url+"&idstring="+idstring;
    }
    else
    {
   	    var x = select_options.split(';');
		var count = x.length;
		if(count > 1) 
        {
			idstring = select_options;
        }
        else 
        {
      var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
      RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
        puyoungJS_DialogBox.block();
        openNewDiv('newDiv');
         window.location=url+"&idstring="+idstring;
    }
 }

/*
edit:can
date:20130814
reason:新增和编辑模板中选择模块事件
*/
function moduleSel(obj)
{
    new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody: 'module=SalesOrder&action=SMSContent&printtabid='+obj.value,
		onComplete: function(response) {
			if(response.responseText.indexOf("SUCCESS")>-1)
            {
                var results=response.responseText.split("##SUCCESS##");
                document.getElementById("tabField").innerHTML=results[1];
            }
		}
	}
	);

}
/*
edit:can
date:20130815
reason:打印模板新增和编辑界面字段选择
*/
function fieldSel(obj)
{
    if(document.getElementById("moduleSelID") != undefined && document.getElementById("moduleSelID").value=='14')
    {
        document.getElementById("selField").value="[Pvar."+obj.value+"]";
    }
    else
    {
        document.getElementById("selField").value="[var."+obj.value+"]";    
    }
}
/*
edit:can
date:20130815
reason:打印模板中插入模板
*/

function InsertTemplate(obj)
{
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        alert(arrJsPopLabel['PLEASESELECTFIELD']);
        return false;
    }
   // var CKcontent=document.getElementById('CKcontent');
    //var txtvalue=document.forms['sendInfoSMSContentForm'].SelectField.options[document.forms['sendInfoSMSContentForm'].SelectField.selectedIndex].text;
    //document.getElementById('CKcontent').value += document.getElementById("selField").value;
   // insertText(CKcontent,document.getElementById("selField").value);
   var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;
    //document.getElementById('CKcontent').value += document.getElementById("selField").value;
    //insertText(CKcontent,document.getElementById("selField").value);
	/**
	 * 用jquery重写该事件，实现在textarea光标处插入代码
	 * @reason 0014906: 出库单> 明细,关于发送短信中的"插入到内容模板"按钮点不动问题
	 * @author Tujt 2015-05-13
	 */
	(function($){
	 $.fn.extend({
	  insertAtCaret: function(myValue){
	   var $t=$(this)[0];
	   if (document.selection) {
		this.focus();
		sel = document.selection.createRange();
		sel.text = myValue;
		this.focus();
	   }
	   else 
		if ($t.selectionStart || $t.selectionStart == '0') {
		 var startPos = $t.selectionStart;
		 var endPos = $t.selectionEnd;
		 var scrollTop = $t.scrollTop;
		 $t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
		 this.focus();
		 $t.selectionStart = startPos + myValue.length;
		 $t.selectionEnd = startPos + myValue.length;
		 $t.scrollTop = scrollTop;
		}
		else {
		 this.value += myValue;
		 this.focus();
		}
	  }
	 }) 
	})(ld);
	ld('#CKcontent').insertAtCaret(ld('#selField').val());
}


function insertText(obj,str) {
    //edit:can reason:14247: 合同订单-明细：发送短信-设置短信内容弹出层：【插入到内容模板】按钮点击没有反应
   if (typeof obj.selectionStart === 'number' && typeof obj.selectionEnd === 'number') {
        var startPos = obj.selectionStart,
            endPos = obj.selectionEnd,
            cursorPos = startPos,
            tmpStr = obj.value;
        obj.value = tmpStr.substring(0, startPos) + str + tmpStr.substring(endPos, tmpStr.length);
        cursorPos += str.length;
        obj.selectionStart = obj.selectionEnd = cursorPos;
    } else {
        obj.value += str;
    }
}


/*
edit:diony
date:20150116
reason:合同订单群发短信
*/
function SMSSendSalesOrderGroup(obj,type)
{
    var select_options = document.getElementById('allselectedboxes').value;
    var numOfRows = document.getElementById('numOfRows').value;
    var excludedRecords = $('excludedRecords').value;
    var excludedRecords=document.getElementById("excludedRecords").value;
    var viewid =getviewId();
    var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    
    
    //弹出框的设计
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=SalesOrder&action=SMSSendSalesOrderCheck&smstype="+type,
		onComplete:function (response) {
		     if(response.responseText.indexOf("####:###")>-1)
             {
                var results=response.responseText.split("####:###");
                alert(results[1]);
                return false;
             }
             else
             {
                var url="index.php?module=SalesOrder&action=SMSSendSalesOrderGroup&smstype="+type+"&viewname="+viewid+"&excludedRecords="+excludedRecords+"&SearchScope="+searchScope;
                if(select_options=='all') 
                {
                    var idstring = select_options;
                    if(count > getMaxMassOperationLimit()) 
                    {
                        var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
                        if(confirm(confirm_str)) 
                        {
                            var confirm_status = true;
                        } 
                        else 
                        {
                            return false;
                        }
                    }
                    puyoungJS_DialogBox.block();
                    window.location=url+"&idstring="+idstring;
                }
                else
                {
                    var x = select_options.split(';');
                    var count = x.length;
                    if(count > 1) 
                    {
                        idstring = select_options;
                    }
                    else 
                    {
                        alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
                        return false;
                    }
                    puyoungJS_DialogBox.block();
                    window.location=url+"&idstring="+idstring;
                }
             }
		}
	}); 
}

function fun_Dividend()
{
    fun_Dividend.cur_obj=null;
    fun_Dividend.rate_class_name_prefix="rate_hidden_money_";//利息ID名称的前缀
    fun_Dividend.dividend_money_class_name_prefix="span_dividend_money_";//派息金额ID名称前缀
    
}

fun_Dividend.getInstance=function()
{
    if(fun_Dividend.cur_obj==null)
    {
        
        fun_Dividend.cur_obj=new fun_Dividend();
        
        fun_Dividend.cur_obj.init();
    }
    
    return fun_Dividend.cur_obj;
}
/**
字符串千分位
**/
fun_Dividend.toThousands=function(num) {
    var result = '', counter = 0;
    num = (num || 0).toString();
    var decimal_digit="";//小数点的值
    if(num.indexOf(".")>=0)
    {
        decimal_digit=num.substr(num.indexOf("."));
        num=num.substr(0,num.indexOf("."));
    }
    
    for (var i = num.length - 1; i >= 0; i--) {
        counter++;
        result = num.charAt(i) + result;
        if (!(counter % 3) && i != 0) { result = ',' + result; }
    }
    return result+decimal_digit;
}
fun_Dividend.prototype.init=function()
{
    this.table_obj=document.getElementById("tb_create_dividend_detail");
    this.invenst_amount=ld("#hidden_dividend_Princial").val();//投资金额
    if(this.table_obj!=undefined)
        this.rowcount=this.table_obj.rows.length;//表格行数
    this.recalculate='no';
   /*this.float_income_type=document.getElementById("float_income").options[document.getElementById("float_income").selectedIndex].value;*/
  
}
/**
浮动收益类型改变
修改最后一行派息金额
**/
fun_Dividend.prototype.float_income=function()
{
     var rowIndex=this.rowcount;
     var rate_id_name=fun_Dividend.rate_class_name_prefix+rowIndex;
     var dividend_money_id_name=fun_Dividend.dividend_money_class_name_prefix+rowIndex;
     var dividend_money=0;//派息金额
     var adjustment_money=0;//调整金额
     var rate_money=document.getElementById(rate_id_name).value;//利息
    
     if(!isNaN(document.getElementById("txt_row_"+rowIndex).value)&&document.getElementById("txt_row_"+rowIndex).value!="")
     {
        document.getElementById("txt_row_"+rowIndex).value=parseFloat(document.getElementById("txt_row_"+rowIndex).value).toFixed(2);
        adjustment_money=document.getElementById("txt_row_"+rowIndex).value;//
     }
  
    ld("#"+dividend_money_id_name).html(fun_Dividend.toThousands(parseFloat(dividend_money).toFixed(2)));
    ld("#dividend_money_"+rowIndex).val(parseFloat(dividend_money).toFixed(2));
      
}
/**
调整金额
***/
fun_Dividend.prototype.adjustment=function(obj)
{
   var row_index=obj.getAttribute("txt_row");
   if(!isNaN(obj.value))
   {
    if(obj.value=='')
    {
         obj.value=0.00;
    }
      var rate_class_name=fun_Dividend.rate_class_name_prefix+row_index;
      var rate_money=parseFloat(ld("#"+rate_class_name).val()).toFixed(2);
       obj.value=parseFloat(obj.value).toFixed(2);//调整
      var dividend_money=parseFloat(rate_money)+parseFloat(obj.value);//派息金额
      var dividend_money_id_name=fun_Dividend.dividend_money_class_name_prefix+row_index;
      if((this.rowcount)==row_index)//最后一行
      {
         //派息金额=本金+利息+调整+浮动收益
         dividend_money=parseFloat(dividend_money)+parseFloat(this.invenst_amount);
       
         ld("#"+dividend_money_id_name).html(fun_Dividend.toThousands(parseFloat(dividend_money).toFixed(2)));
         ld("#dividend_money_"+row_index).val(parseFloat(dividend_money).toFixed(2));
      }
      else
      {
        ld("#"+dividend_money_id_name).html(fun_Dividend.toThousands(parseFloat(dividend_money).toFixed(2)));
        ld("#dividend_money_"+row_index).val(parseFloat(dividend_money).toFixed(2));
      }
      var parenttd=ld("#"+dividend_money_id_name).parent();
      var parenttr=parenttd.parent();
      if(parenttd.attr("tag")=='yes_dividend')
      {
          var tds=parenttr.children();
         
           var parent_sibling=parenttd.next();//获取派息金额列；
            var parent_old_value=parent_sibling.html();
            if(parseFloat(dividend_money).toFixed(2)!=parseFloat(parent_old_value).toFixed(2))
            {
                   tds.css("color",'red');
                   obj.style.color="red";
                  tds.attr("title",dividend_money_change_tip);
            }
            else
            {
                tds.css("color","#666");
                tds.attr("title","");
                bj.style.color="#666";
            }
            
        
      }
   }
   else
   {
     obj.value="0.00";
   }
}
fun_Dividend.prototype.rate_sendday_type=function(obj)
{
    var day=this.option_day[obj.options[obj.selectedIndex].value];
    if(parseInt(day)<10)
    {
        day="0"+day;
    }
    var rate_sendobj=null;
    var rate_senddate="";
    var datearray=null;
    var spanobj=null;
    for(var i=1;i<=this.rowcount;i++)
    {
        rate_sendobj=ld("#rate_sendday_"+i);
        rate_senddate=rate_sendobj.val();
        datearray= rate_senddate.split("-");
        rate_sendobj.val(datearray[0]+"-"+datearray[1]+"-"+day);
        spanobj=rate_sendobj.next();
        spanobj.html(rate_sendobj.val());
    }
}
fun_Dividend.prototype.save_dividendorder_detail=function(obj)
{
	//chj 2021/3/12 44955: （http://51mis.com/ys/1018 [^]）客户问题（徐燕男），合同订单单据查看详情界面，更多->创建派息单->保存，返回到首页界面了
	var form_data = new FormData(ld("#DividendOrder_form_div [name=frmdividenorderdetail]")[0]);
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: form_data,
		url: 'index.php?module=DividendOrder&action=DividendOrderAjax&file=saveDetail',
		success: function(data) {
			ld('#rptContentLoading').hide();
			
				 fninvshnew('CreateDividendOrder');
			 fninvshnew('Remind_dividendRules');
			
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
    //document.forms['frmdividenorderdetail'].submit();
}


/* editor:gyq_09 reason:派息规则按钮事件 异步加载产品目录下派息规则JS date:*/
fun_Dividend.prototype.Buttons_dividendRules = function(obj,module,record){

    /* 隐藏派息单 */
   // ld('#CreateDividendOrder').hide();
   fun_Dividend.getInstance().cancel();
    getJsScript('include/js/modules/Products/ProductsDividendRules.js',function(){
        Products_dividendRules.getInstance().Rules_In_CreateDividendOrder(obj,module,record);
    });
}




fun_Dividend.prototype.showDividendOrderDetail=function(rate_senddate,startdate,enddate)
{
     
    var detailhtmltable='<table width="100%" cellspacing="1" cellpadding="0" border="0" class="listEntries D_pop_bod" style="width:100%;"><tr>';
    detailhtmltable+="<th>"+this.detail_table_header.startdate+"</th>";
    detailhtmltable+="<th>"+this.detail_table_header.enddate+"</th>";
    detailhtmltable+="<th>"+this.detail_table_header.days+"</th>";
    detailhtmltable+="<th>"+this.detail_table_header.rate_senddate+"</th>";
    detailhtmltable+="<th>"+this.detail_table_header.capital+"</th>";
    detailhtmltable+="<th>"+this.detail_table_header.rate+"</th>";
    if(this.detail_table_header.have_float=='yes')
    {
        detailhtmltable+="<th>"+this.detail_table_header.float_income+"</th>";
    }
    detailhtmltable+="<th>"+this.detail_table_header.dividendmoney+"</th>";
    detailhtmltable+="</tr>";
    var array_index=0;
    var detail_array=Array();
    for(var i=0;i<this.hide_dividendorder_obj.length;i++)
    {
        var hide_start_date=this.hide_dividendorder_obj[i].startdate;
        var hide_end_date=this.hide_dividendorder_obj[i].enddate;
        if(this.hide_dividendorder_obj[i].rate_senddate==rate_senddate&&startdate<=hide_start_date&&enddate>=hide_end_date)
        {
            detail_array[array_index]=this.hide_dividendorder_obj[i];
            
            array_index++;
        }
    }
   
        
        for( var j=0;j<detail_array.length;j++ )
        {  
            detailhtmltable+="<tr>";
            detailhtmltable+="<td>"+detail_array[j].startdate+"</td>";
            detailhtmltable+="<td>"+detail_array[j].enddate+"</td>";
            detailhtmltable+="<td>"+detail_array[j].days+"</td>";
            detailhtmltable+="<td>"+detail_array[j].rate_senddate+"</td>";
            detailhtmltable+="<td>"+detail_array[j].principal+"</td>";
            detailhtmltable+="<td>"+detail_array[j].rate_money+"</td>";
            if(this.detail_table_header.have_float=='yes')
            {
                if(detail_array[j].float_income==null)
                    detail_array[j].float_income="";
                 detailhtmltable+="<td>"+detail_array[j].float_income+"</td>";
            }
            detailhtmltable+="<td>"+detail_array[j].dividend_money+"</td>";
             detailhtmltable+="</tr>";
            
        }
       
    detailhtmltable+="</table>";
    
    ld("#DividendOrder_detail_div").html(detailhtmltable);
    fnvshobj(null,'show_dividendorder_detail');
}

/**
重算
type:list,detail
**/
fun_Dividend.prototype.Recalculate=function(type,salesorderid)
{
   
     if(type=='detail')
     {
        this.recalculate='yes';
        
        ld.ajax( {
            
            url:"index.php?module=DividendOrder&action=DividendOrderAjax&type=detail",
            type:'POST',  
            data:{  
                    "salesorderid":salesorderid,
                    'file':'PopDividendOrder'
                }, 
              
              dataType:'json',  
              success:function(rest)
              {
                fun_Dividend.prototype.hide_dividendorder_obj=rest.hide_objs;
                fun_Dividend.prototype.detail_table_header=rest.header;
                document.getElementById("dividendOrder_show_Table").innerHTML=rest.showtable;
               document.getElementById("dividendOrder_hide_Table").innerHTML=rest.hidetable;
              },
              error:function()
              {
                
              }
        });
     }
     else
     {
       
        List_CheckBox_Ids.getIds('SalesOrder');//
        if(List_CheckBox_Ids.num_rows<=0)
        {
             document.getElementById("dividendorder_rate_radio_select_record").checked=false;
            document.getElementById("dividendorder_rate_radio_select_record").disabled=true;
            document.getElementById("dividendorder_rate_radio_search_result").checked=true;
        }
        else 
        {
             //document.getElementById("dividendorder_rate_radio_select_record").disabled=true;
              document.getElementById("dividendorder_rate_radio_select_record").checked=true;
        }
        document.getElementById("list_dividend_rate_recalculate").style.display="block";
         fnvshobj(null,'list_dividend_rate_recalculate');
        
     }
}
fun_Dividend.prototype.List_Recalculate=function()
{
     if(confirm(arrJsPopLabel['INTERESTRECALWILLCHANGE'])==false)
     {
        return false;
     }
     var data_scope=0;
     var recalculate_method=0;
     if(document.getElementById("dividendorder_rate_radio_search_result").checked)
     {
        data_scope=1;//重算搜索结果
     }
     else
     {
        data_scope=2;//重算选定的记录
     }
     
     if(document.getElementById("dividendorder_rate_radio_del_no").checked)
     {
        recalculate_method=1;//删除未派记录并重算
     }
     else
     {
        recalculate_method=2;//删除全部记录并重算
     }
      List_CheckBox_Ids.getIds('SalesOrder');//
     if(data_scope==2)
     {
       
        if(List_CheckBox_Ids.num_rows<=0)
        {
            alert(arrJspopLabel['SELECTRECALRECORD']);
            return false;
        }
     }
   
    window.location.href="index.php?module=DividendOrder&action=saveDetail&dividendorderids="+List_CheckBox_Ids.ids+"&data_scope="+data_scope+"&recalculate_method="+recalculate_method+"&type=list";
    
}

fun_Dividend.prototype.cancel=function()
{
    
    if(this.recalculate=='yes')
    {
       
        if(confirm(dividend_recalculate_save_tip))
        {
            fun_Dividend.getInstance().save_dividendorder_detail(this);
        }
    }
        
    else
    {
        
        fninvshnew('CreateDividendOrder');
    }
        
}
/**
 *edit:cyb
 *date:2016-06-15
 *reason:合同订单相关信息赎回选项列表新建显示弹出层；
**/
function showRedemptionPop(obj,recordid,relationId,redemptionid){
    var surl = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=showRedemptionPop&recordid='+recordid+'&relationId='+relationId+'&redemptionid='+redemptionid;	
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Redemption',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,saveRedemption,"","LdPopWidth800px",'Redemption',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
		}
	})
    
}
/**
 *edit:cyb
 *date:2016-06-15
 *reason:保存赎回记录
**/
function saveRedemption(){
    var popupobj=CrmPopup.getPopupObj("last");
	var recordid = ld("#"+popupobj.divid+" [name=salesorderid]").val();
	var relationId = ld("#"+popupobj.divid+" [name=relationid]").val();
	var redemptionid = ld("#"+popupobj.divid+" [name=redemotionid]").val();
    //赎回日期不能为空
    if(document.getElementById('redemptiontime').value==''){
        alert(document.getElementById('rdpt_label').innerHTML+arrJsPopLabel['CANOTEMPTY']);
        //document.getElementById('redemptiontime').focus();    	 
        return false;
    }else{
       var redemptiontime=document.getElementById('redemptiontime').value; 
    }
    //赎回份额不能为空
    if(document.getElementById('redemptionquantity').value==''){
       alert(document.getElementById('rdpq_label').innerHTML+arrJsPopLabel['CANOTEMPTY']);
       return false;
    }
    //赎回份额不能小于0
    if(document.getElementById('redemptionquantity').value<=0){
       alert(document.getElementById('rdpq_label').innerHTML+arrJsPopLabel['CANNOTLESSZERO']);
       return false; 
    }else{
        var redemptionquantity=document.getElementById('redemptionquantity').value;
    }
    if(document.getElementById('redemptionisfree').checked){
        var redemptionisfree=1;
    }else{
        var redemptionisfree=0;
    }
    var redemptioncost=document.getElementById('redemptioncost').value;
    url = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=saveRedemption&recordid='+recordid+'&redemptionid='+redemptionid;	
    url+='&redemptiontime='+redemptiontime+'&redemptionquantity='+redemptionquantity+'&redemptionisfree='+redemptionisfree+'&redemptioncost='+redemptioncost;
	ldAjax(url,"",function(data){
		if(data.code == 1){
			popupobj.CancelEvent();
             var tmparra=new Array();
             var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                        //新增刷新列表
              tmparra.push(popupobj.module);
                       
              tmpobj.eachrefreshlistbyModules(tmparra);
                      
			//DetailViewRelation.refresh_relatedlist('SalesOrder');
		}
        DelProgressObjs();
	})
	
}
saveRedemption.funname='saveRedemption';
/*
var findproduct_finished=false;
var http_reqfield;
function jsQualifyDate(){
    this.form= document.forms['EditView']; 
    this.form.action.value='Save';
    var topBtn = ld('input[name="button"][class="save"]')[0];
    var cur_this=this;
    topBtn.onclick =function(){
         cur_this.saveSalesOrderDetail();
    }
    var botBtn = ld('input[name="button"][class="save"]')[1];
    botBtn.onclick =function(){
        cur_this.saveSalesOrderDetail();
    }
}

jsQualifyDate.prototype.saveSalesOrderDetail = function(){
	var cur_this = this;
	var mode = document.EditView.mode.value;
   // if(validateInventory('SalesOrder')){
        var accountid = ld('form input[name="account_id"]').val();
        var productid = getProtabInfo('hdnProductId','no');
      //  var max_row_count = document.getElementById('rowcnt').value;
        var popupobj=CrmPopup.getPopupObj('last');
        
        var tableobj=popupobj.getDetailTableObj();
        var trobjs=popupobj.getTrObjsByDelType('no');
        for (var i=1;i<=max_row_count;i++) 
        ld.each(trobjs,function()
        {
            //如果启用了expiry_date，并且expiry_date不为空，且expiry_date小于服务器当前日期，则不允许保存。
            //if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('expiry_date'+i) != undefined && document.getElementById('expiry_date'+i).value != ''){
                var exper_date =ld(this).find("[detailcolumnname=expiry_date]");// document.getElementById('expiry_date'+i).value;
                if(new Date(current_date)>new Date(exper_date)){
                    var passexpirydate = arrJsPopLabel['PASSEXPIRYDATE'];
                    alert(passexpirydate.replace("%s",ld(this).find("[detailcolumnname=productname]").val()));
                    return false;
                }
            //}
        })
        url = 'module=SalesOrder&action=SalesOrderAjax&file=CheckMaturitydate&accountid='+accountid+'&productid='+productid;	
    	new Ajax.Request(
    		'index.php',
    		{
    		    queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {		    
				    var result=response.responseText;
                    
				    if(result.indexOf('#&#Success#&#')>=0){
						if(mode != 'edit'){
							//判断产品负库存
							cur_this.FindProdcutForQtyinstock();
						}else{
						//	FieldDuplicateValidate('SalesOrder',cur_this.form);
							return true;
						}
				    }else{
                        RemindsMsg("","LdPopWidth400px","","yes","yes",result);
                        return false;
				    }
				}
    		}
    	);
   // }else{
      //  return false;
   // }
}

//判断产品数量负库存
jsQualifyDate.prototype.FindProdcutForQtyinstock = function(obj){
	var max_row_count = document.getElementById('rowcnt').value;
   
   var popupobj=CrmPopup.getPopupObj('last');
   
	var productinfo = [];
	var k = 0;
    var trobjs=popupobj.getTrObjsByDelType('no');
	//for (var i=1;i<=max_row_count;i++) 
    ld.each(ld(trobjs),function(){
	//	if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('quantity'+i) != undefined && document.getElementById('quantity'+i).value != ''){
			var productid =ld(this).find("[detailcolumnname=hdnProductId]").val();// document.getElementById('hdnProductId'+i).value;
			var quantity = ld(this).find("[detailcolumnname=quantity]").val();//document.getElementById('quantity'+i).value;
			if(productid > 0){
				productinfo[k] = productid +'|'+quantity;
				k++;
			}
		//}
	});
   
	if(productinfo.length >= 1){
	   //安全库存
		var url = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=CheckProductQtyinstock&frommodule=SalesOrder&productinfo='+productinfo.join(',');	
		http_reqfield=createfieldXMLHTTP();
		http_reqfield.open("POST",url,false);
		findproduct_finished=false;
		http_reqfield.onreadystatechange=AlertProductQtyinstock;
		http_reqfield.setRequestHeader("If-Modified-Since","0");
		http_reqfield.send(null);
	}
    else
    {
        //37916: （1.6）合同订单【新建】界面，不选择产品名称保存时，【保存】按钮点不动
       // FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
	   return true;
    }
}

var AlertProductQtyinstock = function(){
	if(http_reqfield.readyState ==4){
		if(http_reqfield.status==0||http_reqfield.status==200){
			var isinit = 0;
			var results=trim(http_reqfield.responseText);
            if(results==''|| results==undefined ||results=='undefined'|| results==null)
            {
              //  FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
			//	return true;
            }
			var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
			if(restobj.code == -1){
				var info = '<b>'+restobj.err_subject+'</b><br />';
				info += restobj.err_info;
				if(ld('#findproductqtyinstock_div').length == 1){
					if(0 == isinit) isinit = 1;
				}
				var divobj = createElementDivs('findproductqtyinstock_div');
				ld(divobj).find('.E_pop_tit .E_ptita').html(arrJsPopLabel['SAVE']);
				ld(divobj).css('max-height','500px');
				ld('#findproductqtyinstock_divcontent').html(info);
				ld('#findproductqtyinstock_divcontent').css('max-height','300px');
				ld('#findproductqtyinstock_divcontent').css('border','none');
				if(0 == isinit){//初次加载的时候才显示
					ld('#fieldmap_div').css('top','28%');
				}
				//确认事件
				ld('#findproductqtyinstock_div .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
				//	fninvshnew('findproductqtyinstock_div');
					//FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
					return true;
				});
				//取消事件
				ld('#findproductqtyinstock_div .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
					fninvshnew('findproductqtyinstock_div');
					return false;
				});
			}else{
				FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
				return true;
			}
		}
	}
}
*/

//合同订单选择客户，如果客户有扣率则直接在产品明细中带出
function getAccountForDiscountRate(account_id,rowid){
	url = 'module=Accounts&action=AccountsAjax&file=getAccountForDiscountRate&accountid='+account_id;
	/*var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
		parentwindow=window.opener;
	}*/
 
 var popupobj=CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:url,
			onComplete: function(response) {		    
				var result=response.responseText;
               var trobjs=popupobj.getTrObjsByDelType('no');
               ld.each(trobjs,function(){
                 if(ld(this).find(" [name=discount_percent]").length>0){
					  
				
						ld(this).find(" [name=discount_percent]").val(result);
                        
					}
               })
			/*	var rowcnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();// parentwindow.document.getElementById('rowcnt').value;
				for(var i = 1; i<=rowcnt; i++){
					if(ld("#"+popupobj.divid+" [name=discount_percent"+i+"]").length>0){
					  
					//	if(parentwindow.document.getElementById('discount_percent'+i).value <= 0 || parentwindow.document.getElementById('discount_percent'+i).value == ''){
						ld("#"+popupobj.divid+" [name=discount_percent"+i+"]").val(result);
                        	//parentwindow.document.getElementById('discount_percent'+i).value =result;
					//	}
					}
				}*/
				//新增行时，不需要进行计划，只在切换客户时，进行赋值重新计算
				if(rowid <= 0){
				    
					popupobj.fieldformulaobj.changediscountpercent();
				}
			}
		}
	);
}

//源美特殊控制，判断明细表体字段“暂定价价格”、“点价价格”、“点价期限/时间”
function setProductToolFieldDisplay(mode,popupobj){
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
	var rowcnt =ld("#"+popupobj.divid+" [name=rowcnt]").val();// ld('#rowcnt').val();
    
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
	
	}
}




function SyDataInterFace(record,stype){
	var url = 'module=SalesOrder&action=SalesOrderAjax&file=CheckSyDataInterFace&frommodule=SalesOrder&type='+stype+'&record='+record;
	new Ajax.Request(
		'index.php',
		{
			queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:url,
			onComplete: function(response) {
				var results=trim(response.responseText);
				if(results == 'error'){
					alert('当前订单已经同步，再次同步会删除原先同步的订单明细数据，是否继续？');
					return false;
				}else{
					if(stype = 'approve'){
						var obj = new SaveApproveOperation();
						ld_defer.then(obj.saveApproveBefore()).then(obj.saveApprove()).then(obj.saveApproveAfter());
						return true;
					}else{
						return true;
					}
				}
			}
		}
	); 
}
function cls_SalesOrder()
{
    var that=this;
    this.AlertProductQtyinstock_bol=true;
    this.FindProdcutForQtyinstock=function()
    {
        
           var popupobj=CrmPopup.getPopupObj('last');
          
        	var productinfo = [];
        	var k = 0;
            var trobjs=popupobj.getTrObjsByDelType('no');
        	//for (var i=1;i<=max_row_count;i++) 
            ld.each(popupobj.detaildatavalue_arr,function(tmpindex,tmpvalueinfo){
        	//	if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('quantity'+i) != undefined && document.getElementById('quantity'+i).value != ''){
        			var productid =tmpvalueinfo.productid;//ld(this).find("[detailcolumnname=hdnProductId]").val();// document.getElementById('hdnProductId'+i).value;
        			var quantity =tmpvalueinfo.quantity;// ld(this).find("[detailcolumnname=quantity]").val();//document.getElementById('quantity'+i).value;
        			if(productid > 0){
        				productinfo[k] = productid +'|'+quantity;
        				k++;
        			}
        		//}
        	});
           
        	if(productinfo.length >= 1){
        	   //安全库存
        		var url = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=CheckProductQtyinstock&frommodule=SalesOrder&productinfo='+productinfo.join(',');	
        		http_reqfield=createfieldXMLHTTP();
        		http_reqfield.open("POST",url,false);
        	//	findproduct_finished=false;
        		http_reqfield.onreadystatechange=that.AlertProductQtyinstock;
        		http_reqfield.setRequestHeader("If-Modified-Since","0");
        		http_reqfield.send();
        	}
            else
            {
                //37916: （1.6）合同订单【新建】界面，不选择产品名称保存时，【保存】按钮点不动
               // FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
        	   return true;
            }
    }
    
    this.AlertProductQtyinstock= function(){
    	if(http_reqfield.readyState ==4){
    		if(http_reqfield.status==0||http_reqfield.status==200){
    			var isinit = 0;
    			var results=trim(http_reqfield.responseText);
                if(results==''|| results==undefined ||results=='undefined'|| results==null)
                {
                  //  FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
    			//	return true;
                    return true;
                }
    			var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
    			if(restobj.code == -1){
    			//	var info = '<b>'+restobj.err_subject+'</b><br />';
                    var info = restobj.err_subject+':\n';
    				info += restobj.err_info;
    				if(ld('#findproductqtyinstock_div').length == 1){
    					if(0 == isinit) isinit = 1;
    				}
    				/*var divobj = createElementDivs('findproductqtyinstock_div');
    				ld(divobj).find('.E_pop_tit .E_ptita').html(arrJsPopLabel['SAVE']);
    				ld(divobj).css('max-height','500px');
    				ld('#findproductqtyinstock_divcontent').html(info);
    				ld('#findproductqtyinstock_divcontent').css('max-height','300px');
    				ld('#findproductqtyinstock_divcontent').css('border','none');
    				if(0 == isinit){//初次加载的时候才显示
    					ld('#fieldmap_div').css('top','28%');
    				}*/
                    if(confirm(info.replace("<br />","\n")))
                    {
                        that.AlertProductQtyinstock_bol= true;
                    }
                    else{
                        that.AlertProductQtyinstock_bol= false;
                    }
                    
    			
    			}else{
    			//	FieldDuplicateValidate('SalesOrder',document.forms['EditView']);
    				that.AlertProductQtyinstock_bol= true;
    			}
    		}
    	}
    }
}

//chj 2022/9/20 中德信用额度控制下单(2)_1663310360000_576
/*
* orgvlue  授信组织
* account_id 客户id
* cf_5153  是否可查信用
* assigned_user_id 负责人
*/
function getZhongDe_AccountOrgForKis(orgvlue,account_id,cf_5153,assigned_user_id){
	var url = 'index.php?module=SalesOrder&action=SalesOrderAjax&file=getZhongDeOrg&orgvlue='+encodeURIComponent(orgvlue)+'&account_id='+account_id+'&cf_5153='+encodeURIComponent(cf_5153)+'&assigned_user_id='+assigned_user_id;
    ldAjax(url,"",function(data){
        if(data.code == 1){
             var popupobj = CrmPopup.getPopupObj("last");
			 ld("#"+popupobj.divid+" [name=cf_5150]").val(data.result.acc_org_value);
			ld("#"+popupobj.divid+" [name=span_cf_5150]").html(data.result.html_acc_org_value);
			ld("#"+popupobj.divid+" [name=cf_5154]").val(data.result.user_org_value);
			ld("#"+popupobj.divid+" [name=span_cf_5154]").html(data.result.html_user_org_value);
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",'error');
            return false;
        }
        DelProgressObjs();
    })
}


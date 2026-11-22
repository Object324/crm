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



function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}
function set_return_specific(product_id, product_name) {
        
        var fldName = getOpenerObj("potentials_name");
        var fldId = getOpenerObj("potential_id");
        fldName.value = product_name;
        fldId.value = product_id;
}
function add_data_to_relatedlist(entity_id,recordid,destination_module) 
{
    ldAjaxHtmlNoProgress('index.php',"module=Potentials&action=updateRelations&destination_module="+destination_module+"&entityid="+entity_id+"&parentid="+recordid,function(ajaxhtml) {
        var popupobj=CrmPopup.getPopupObj('lastprev');
        var divid = popupobj.divid;
        var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+destination_module).val();
        var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+destination_module).val();
        cancelCrmPopup();
        showRelatedCustomView(related_id,viewid);
        popupobj.relatelistsizeobj.setRelatedResizeTable_Init(destination_module);
        set_rel_count();
    });
}
function set_return_address(potential_id, potential_name, account_id, account_name, bill_street, ship_street, bill_city, ship_city, bill_state, ship_state, bill_code, ship_code, bill_country, ship_country,bill_pobox,ship_pobox) {

	if(typeof(window.opener.document.EditView.potentials_name) != 'undefined')
                window.opener.document.EditView.potentials_name.value = potential_name;
        if(typeof(window.opener.document.EditView.potential_id) != 'undefined')
                window.opener.document.EditView.potential_id.value = potential_id;
	if(typeof(window.opener.document.EditView.accounts_name) != 'undefined')
                window.opener.document.EditView.accounts_name.value = account_name;
        if(typeof(window.opener.document.EditView.account_id) != 'undefined')
                window.opener.document.EditView.account_id.value = account_id;
        if(typeof(window.opener.document.EditView.bill_street) != 'undefined')
                window.opener.document.EditView.bill_street.value = bill_street;
        if(typeof(window.opener.document.EditView.ship_street) != 'undefined')
                window.opener.document.EditView.ship_street.value = ship_street;
        if(typeof(window.opener.document.EditView.bill_city) != 'undefined')
                window.opener.document.EditView.bill_city.value = bill_city;
        if(typeof(window.opener.document.EditView.ship_city) != 'undefined')
                window.opener.document.EditView.ship_city.value = ship_city;
        if(typeof(window.opener.document.EditView.bill_state) != 'undefined')
                window.opener.document.EditView.bill_state.value = bill_state;
        if(typeof(window.opener.document.EditView.ship_state) != 'undefined')
                window.opener.document.EditView.ship_state.value = ship_state;
        if(typeof(window.opener.document.EditView.bill_code) != 'undefined')
                window.opener.document.EditView.bill_code.value = bill_code;
        if(typeof(window.opener.document.EditView.ship_code) != 'undefined')
                window.opener.document.EditView.ship_code.value = ship_code;
        if(typeof(window.opener.document.EditView.bill_country) != 'undefined')
                window.opener.document.EditView.bill_country.value = bill_country;
        if(typeof(window.opener.document.EditView.ship_country) != 'undefined')
                window.opener.document.EditView.ship_country.value = ship_country;
        if(typeof(window.opener.document.EditView.bill_pobox) != 'undefined')
                window.opener.document.EditView.bill_pobox.value = bill_pobox;
        if(typeof(window.opener.document.EditView.ship_pobox) != 'undefined')
                window.opener.document.EditView.ship_pobox.value = ship_pobox;
}
function set_return_contact(potential_id, potential_name, contact_id, contact_name) {

	if(typeof(window.opener.document.EditView.potentials_name) != 'undefined')
                window.opener.document.EditView.potentials_name.value = potential_name;
        if(typeof(window.opener.document.EditView.potential_id) != 'undefined')
                window.opener.document.EditView.potential_id.value = potential_id;
	if(typeof(window.opener.document.EditView.contacts_name) != 'undefined')
                window.opener.document.EditView.contacts_name.value = contact_name;
        if(typeof(window.opener.document.EditView.contact_id) != 'undefined')
                window.opener.document.EditView.contact_id.value = contact_id;
}
function set_return_potential(potential_id,potential_name)
{
	/**
	 * 快速创建，form的name值是QcEditView，而不是EditView
	 * @reason 0012667: 快速创建>>联系记录，点击“销售机会”字段的选择按钮，结果报.js错误
	 * @author Tujt 2014-11-21
	 */
	var editform;
	if(typeof(window.opener.document.EditView) != 'undefined')
		editform = window.opener.document.EditView;
	else if(typeof(window.opener.document.QcEditView) != 'undefined')
		editform = window.opener.document.QcEditView;
    if(typeof(editform.potentials_name) != 'undefined')
		editform.potentials_name.value = potential_name;
    if(typeof(editform.potential_id) != 'undefined')
		editform.potential_id.value = potential_id;
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
function  NewReceivablesforecast(obj,divid,potentialsid,deployid,type)
{
    var prompt;
    calendarParentid="Createreceivablesforecast";//该变量在jscalendar/dynamiccalendar.js/
    if(deployid <= 0||(deployid==2&&type==1))
    {
        if(deployid == 0||deployid == 2)
        {
            //该销售机会已创建回款预测
            prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast'];
           
            RemindsMsg("","LdPopWidth400px","","yes","",prompt);

            return false;
        }
    }else if(deployid==2&&type==2){
        return false;
    }
     //弹出框的设计
    var results;
	var surl = "index.php?module=Potentials&action=popreceivablesforecast&potentialsid=" +potentialsid+'&ReportHeader=DHeader';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'RECEIVABLESFORECAST',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code == 1){
			crmPopupobj.setParams(data.result.title,savereceivablesforecast,"","LdPopWidth800px",'RECEIVABLESFORECAST',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
		}else{
			crmPopupobj.CancelEvent();
			var errorre=arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast'];
			RemindsMsg("","LdPopWidth400px","","yes","",errorre);
			ld('#rptContentLoading').hide();
		}
	})
   
}
/*
添加行
*/
function Addtr()
{

    var deploy = document.getElementById("DeployValue").value;
    var tabplan=document.getElementById("tabreceivablesforecast");
    var rowcount=tabplan.rows.length;
    var planamount=0.0;//计划总金额
    var planratio=0;//计划比例
    var curperiod=1;
    var curamount=0;
    var balanceratio=100;
    var prompt;
    var nopaymentamount=parseFloat(document.forms['frmsendpayment'].nopaymentamount.value);//未计划金额
   
    if(nopaymentamount==''||isNaN(nopaymentamount))
    {
        nopaymentamount=0;
    }
    
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
                alert(arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast2']);
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
                    prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast3'];
                }
                else
                {
                    //prompt = "付款计划总额已经大于未计划金额，是否继续？";
                    prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast4'];
                }
                var payment= window.confirm(prompt);
                if(payment){
                }
                else
                {
                    return false;
                }
            }   
        }
    }
  
    var tabtr=tabplan.insertRow(rowcount);
    tabtr.id="row"+rowcount;
    var tddelete=tabtr.insertCell(0);
    tddelete.align="center";
    tddelete.innerHTML="<i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i>";
    var tdratio=tabtr.insertCell(1);
    tdratio.innerHTML="<input type='hidden' class='ld-input-inner' size='10'  name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/><input type='text' size='10' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(2);
    tdamount.innerHTML="<input type='text' class='ld-input-inner' size='10' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
    var tdplandate=tabtr.insertCell(3);
    tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate ld-input-inner' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\'/>";
    tdplandate.setAttribute('class', 'ld-form-item-content');
}
function deletere(id,reid){
		if(confirm(arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'])){
		  EmptyProgressObjs();
          ldAjax("index.php?module=Potentials&action=PotentialsAjax&file=Deletereceivablesforecast&id="+id+"&record="+reid,{},function(){
            
                        var tmparra=new Array();
                     
                      var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                        //新增刷新列表
                      tmparra=[popupobj.module];
                      tmpobj.eachrefreshlistbyModules(tmparra);
                      delete tmpobj;
                     DelProgressObjs();
          });
		  //location.href="index.php?module=Potentials&action=Deletereceivablesforecast&id="+id+"&record="+reid;
		}
}
function editre(obj,reid){
    var results;
	//弹出框的设计
    var results;
    EmptyProgressObjs();
	var surl = "index.php?module=Potentials&action=PotentialsAjax&file=popeditreceivablesforecast&receivablesforecastid=" +reid+'&ReportHeader=DHeader';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'RECEIVABLESFORECAST',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code == 1){
			crmPopupobj.setParams(data.result.title,savereceivablesforecast,"","LdPopWidth800px",'RECEIVABLESFORECAST',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
		}else{
			crmPopupobj.CancelEvent();
			var errorre=arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast'];
			RemindsMsg("","LdPopWidth400px","","yes","",errorre);
			ld('#rptContentLoading').hide();
		}
	})
}
/*
删除行
*/
function deletetr(obj)
{
    var rowindex=0;
     var tabplan=document.getElementById("tabreceivablesforecast");
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
            var jj = idstr.substring(5,idstr.length);
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
reason:保存回款预期

*/
function savereceivablesforecast()
{
	var prompt;
	var deploy = document.getElementById("DeployValue").value;
	var tabplan=document.getElementById("tabreceivablesforecast");
	
	var rowcount=tabplan.rows.length;
	var planamount=0.0;
    if(rowcount<=1)
    {
         puyoungJS_DialogBox.unblock();
         //付款计划金额和未计划金额不一致！
         prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast5'];
         RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);

        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            oform.submit();
        });

        document.getElementById('save_payment_check').disabled=false;
        return false;
    }

    for( var i=1;i<rowcount;i++)
    {
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
   
        if(planamount!=nopaymentamount)
        {
            puyoungJS_DialogBox.unblock();
            //付款计划金额和未计划金额不一致！
                     //付款计划金额和未计划金额不一致！
            prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast5'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                submitNoPaymentPlan();
            });
           /// document.getElementById('save_payment_check').disabled=false;
            return false;
        }else{
            submitNoPaymentPlan();
        }  
}
savereceivablesforecast.funname='savereceivablesforecast';


//回款计划 - 保存
function submitNoPaymentPlan(){
	var popupobj=CrmPopup.getPopupObj("last");
	var edittype = ld("#"+popupobj.divid+" [name=edittype]").val();
	if(edittype == 1){
		var surl = "index.php?module=Potentials&action=PotentialsAjax&file=MassEditRE";
	}else{
		var surl = "index.php?module=Potentials&action=PotentialsAjax&file=MassAdd";
	}
	var data = new FormData(ld(".noMargin")[0]);
    surl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(surl,data);
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: surl,
		success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
            var lastpopupobj=CrmPopup.getPopupObj('last');
         
            if(lastpopupobj.type==DetailViewPage.type)
            {
                                return false;
            }
		//	if(edittype == 1){
			//	DetailViewRelation.refresh_relatedlist('RECEIVABLESFORECAST');
                      var tmparra=new Array();
                                        var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
                        //新增刷新列表
                      tmparra=[popupobj.module];
                      tmpobj.eachrefreshlistbyModules(tmparra);
                      delete tmpobj;
                      			//}
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
}
/*
更新操作
edit:lmx
date:20140220
reason:销售机会共享(V5.3)
*/
function PotentialsShare(obj,id)
{
   ldAjaxHtml('index.php?',"module=Potentials&action=PotentialsAllView&id="+id,function (ajaxhtml) {
       var results=ajaxhtml.split('##SUCCESS##');

       $('divPotentialsShare').innerHTML=results[1];
       /**
        *@edit:andy
        *@date:
        *@reason:待使用统一遮罩层
        *@version:
        */
       fnvshobj(obj,'divPotentialsShare');
       DelProgressObjs();
   });
}
/*
更新操作
edit:lmx
date:20140220
reason:销售机会共享(V5.3)
*/
function select_all(checkel,groupname){
    var checkel=$(checkel);
    var thechecked=checkel.checked;
    var allcheckvals=$$('.StepUserClass');
    for(var i=0;i<allcheckvals.length;i++){
    var el=allcheckvals[i];
    var groupnameattr=el.getAttribute("groupname");
    if(groupnameattr==groupname)
    {
       el.checked=thechecked; 
      
    }
   
     
    }
} 

function SavePotentialstShare(obj)
{
    var form=document.forms['frmPotentialstShare'];
    form.submit();
    return false;
}
/**
 * @edit:chj
 * @date:2014-11-26
 * @reason:销售机会 - 回款预测更换币种
 * @description:
 */
function ChangeCurrency(obj)
{
    var currency_id = obj.value;    //选择后的币种ID
    var before_currency_id = document.getElementById('before_currency_id').value;   //选择前的币种ID
    if(window.confirm(arrJsPopLabel['ALLCURRENCYOFAMOUNTWILLBEFIXED']))
    {
        //alert('module=Settings&action=SettingsAjax&file=ChangeRateAmount&ajax=true&currency_id='+currency_id+'&before_currency_id='+before_currency_id+'&getCurrencyCate=true');
        ldAjaxHtmlNoProgress('index.php?','module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&currency_id='+currency_id+'&before_currency_id='+before_currency_id+'&getCurrencyCate=true',function(ajaxhtml) {
            if(ajaxhtml.indexOf('###SUCCESS###') > -1)
            {
                var results=ajaxhtml.split('###SUCCESS###');
                //获取结果集 0：选择前币种汇率 1：选择后的币种汇率
                var result=results[1].split('|');
                //人民币 - 非人民币 / 公式：金额*非人民币汇率
                //非人民币 - 非人民币 or  非人民币  - 人民币 / 公式:(金额/选择前汇率)*选择后汇率
                if(document.frmsendpayment.potentialamount1 != undefined)    //总金额
                {
                    var potentialamount = document.frmsendpayment.potentialamount1.value;
                    potentialamount = potentialamount.replace(/,/gi,'');
                    if(before_currency_id == 1)
                        potentialamount = potentialamount*result[1];
                    else
                        potentialamount = (potentialamount/result[0])*result[1];
                    potentialamount = potentialamount.toFixed(2);
                    document.frmsendpayment.potentialamount.value = document.frmsendpayment.potentialamount1.value = potentialamount;
                }
                if(ld('#nopaymentamount1').html() != undefined)    //预测金额
                {
                    var nopaymentamount = ld('#nopaymentamount1').html();
                    if(before_currency_id == 1)
                        nopaymentamount = nopaymentamount*result[1];
                    else
                        nopaymentamount = (nopaymentamount/result[0])*result[1];
                    nopaymentamount = nopaymentamount.toFixed(2);
                    ld('#nopaymentamount').val(nopaymentamount);
                    ld('#nopaymentamount1').html(nopaymentamount);
                }
                //期次
                var tableName = document.getElementById('tabreceivablesforecast');
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
        });
    }
    else
    {
        //取消，币种默认值还原
        document.frmsendpayment.currency_id.value = document.getElementById('before_currency_id').value;
        return false;
    }
} 

/**
 *@author:andy
 *@data:20141029
 *@reason:销售机会序时簿‘跟进操作’新建联系记录
 *@version:|
 */
 function CreateContactRecordsByPotentials(obj,return_id,record,return_module,return_action) {
    //首页销售漏斗跟进。先关闭弹层
    if(document.getElementById('showPotentials')!=null){
        fninvshnew('showPotentials');
    }
    
   ld('#rptContentLoading').show();
  var tmpurlsting = 'module=ContactRecords&action=ContactRecordsAjax&file=QuickCreate&type=gengjin&ajax=true&qcreatetype=menu&return_module='+return_module+'&return_id='+return_id+"&return_action="+return_action+'&records='+record+"&Create=true";
    ldAjaxHtmlNoProgress('index.php?',tmpurlsting,function(ajaxhtml) {
        document.getElementById("status").style.display="none";
        document.getElementById("qcform").style.display="inline";
        document.getElementById("qcform").innerHTML = ajaxhtml;
        // Evaluate all the script tags in the response text.
        var scriptTags = document.getElementById("qcform").getElementsByTagName("script");
        for(var i = 0; i< scriptTags.length; i++){
            var scriptTag = scriptTags[i];
            eval(scriptTag.innerHTML);
        }
        fnvshobj(this, 'qcformDiv');
        eval(document.getElementById("qcform"));


    });
}

// @edit:dong @date:2020/08/04 @reason: 移动到listview.js
/*var location_lat = 0;
var location_lng = 0;
function getLocationAddress(fldname,mode){
	
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//默认省份
	var bill_state = '';
	var bill_city = '';
	if(mode == 'edit'){
		bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
		bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
	}else if(mode == 'detail'){
		bill_state =trim(ld('#dtlview_bill_state font').html());
		bill_city = trim(ld('#dtlview_bill_city font').html());
	}
	//定位地址
	var address  = '';
	if(!empty(fldname) && CrmPopup.findHtmlobj(divid,fldname).val() != undefined){
		address = CrmPopup.findHtmlobj(divid,fldname).val();
	}
	if(empty(address) && (!empty(bill_state) || !empty(bill_city))){
		address = bill_state + bill_city;
	}
	//详情页
	if(mode == 'detail' && document.getElementById('dtlview_locationaddress') != undefined && document.getElementById('dtlview_locationaddress').innerHTML != ''){
		address = document.getElementById('dtlview_locationaddress').innerHTML;
	}
	if(empty(address))return '';
	var module_mod = '';
	if(mode == 'detail' || mode == 'edit'){
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	}else{
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint_list=yes";	//多、列表
		module_mod = 'select';
	}
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);    
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						 ld('#'+divid + ' .f-item').css('display', 'block');
						if(empty(module_mod)){
							location_lat = restobj['entries']['lat'];
							location_lng = restobj['entries']['lng'];
							//创建script标签
							var script = document.createElement("script");
							//设置标签的type属性
							script.type = "text/javascript";
							//设置标签的链接地址
							script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
							//添加标签到dom
							document.body.appendChild(script);
						}else{
							var info = '';
							for(var i in restobj['entries']){
								if(restobj['entries'][i]['address'] != undefined){
									info += '<li state="'+restobj['entries'][i]['state']+'" city="'+restobj['entries'][i]['city']+'" district="'+restobj['entries'][i]['district']+'" address="'+restobj['entries'][i]['address']+'" point="'+restobj['entries'][i]['point']+'" country="'+restobj['entries'][i]['country']+'">';
									info += '<span>'+restobj['entries'][i]['address']+'</span>';
									info += '</li>';

								}
							}

							CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
							CrmPopup.findHtmlobj(divid,'search_location_address').show();

			              ld('#'+divid).unbind('click').on('click',function(){
			                CrmPopup.findHtmlobj(divid,'search_location_address').hide();
			              })
							
							ld('#search_location_address').find('li').each(function() {
								ld(this).click(function() {
									var district = ld(this).attr('district');
									var state = ld(this).attr('state');
									var city = ld(this).attr('city');
									var address = ld(this).attr('address');
									var point = ld(this).attr('point');
									var country = ld(this).attr('country'); 
									var point_arr = point.split(',');
									location_lat = point_arr[0];
									location_lng = point_arr[1];
									//city = trim(city.replace('市',''));
									if(CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != ''){
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
											CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
											scriptMap(address,district,city,state,country)
										});
										ld('input[class="D_pbtncancel"]').unbind('click').on('click',function(){
					                      CrmPopup.findHtmlobj(divid,'search_location_address').hide();
					                    });
									}else{
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										scriptMap(address,district,city,state,country)
									}
								})
							})

						}
					}else{
						//var info = '<li><span>'+arrJsPopLabel['thelocationaddress']+'</span></li>';
						//CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
						//CrmPopup.findHtmlobj(divid,'search_location_address').show();
						ld('#'+divid + ' .f-item').css('display', 'none');
					}
					
				}
			}
	  )
}
//加载地图
function scriptMap(address,district,city,state,country){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	CrmPopup.findHtmlobj(divid,'bill_street').val(address);
	if(CrmPopup.findHtmlobj(divid,'bill_city').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_city').val(city);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_city').html(city);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_state').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_state').val(state);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_state').html(state);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_area').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_area').val(district);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_area').html(district);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_country').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_country').val(country);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_country').html(country);
	}
	CrmPopup.findHtmlobj(divid,'search_location_address').hide();
	//创建script标签
	var script = document.createElement("script");
	//设置标签的type属性
	script.type = "text/javascript";
	//设置标签的链接地址
	script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
	//添加标签到dom
	document.body.appendChild(script);
}
//加载地图api后的回调函数
function initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	ld("#"+divid+" [name=location_map_td]").show();
	 var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                                 // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}

function enlarge_map(address){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	if(empty(address)){
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes&record="+popupobj.record+"&frommodule="+popupobj.module;	//单
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						location_lat = restobj['entries']['lat'];
						location_lng = restobj['entries']['lng'];
						var table_html = '<div name="big_container" id="big_container" style="height:500px;"></div>';
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth800px","","yes","",table_html);
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&callback=Big_initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
						//添加标签到dom
						document.body.appendChild(script);
					}
				}
			}
	  )
}
//
function Big_initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var map = new qq.maps.Map(ld("#"+divid+" [name=big_container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}*/

//@edit:liushuai,2020-07-20,reason:义文机电，线索/项目管理模块，分录增加“跟踪”按钮，点击按钮跳出新建“线索物料跟踪”
//rowid:行号
function goToCustomForm09Create(rowid, module) {
    // alert(module);//Potentials
    // listviewbutton_click(this,'CustomForm09','Create',event);return false;

    var popupobj=CrmPopup.getPopupObj('last');
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
    

    // popupobj.record   //线索编号
    // var span_cf_2894 = ld(rowobj).find(" [detailcolumnname=span_cf_2894]").text();// 物料编码 span标签 //默认不用编辑，就不用做判断
    var span_cf_3606 = ld(rowobj).find(" [detailcolumnname=span_cf_3606]").text();// 物料编码 span标签 //默认不用编辑，就不用做判断

    var productid= ld(rowobj).find(" [detailcolumnname=hdnProductId]").val();
    if(productid!=""&&parseInt(productid)>0){
        var productname =ld(rowobj).find(" [name=productname]").val();// 客户物料号
    }else{
        var confirm_str = arrJsPopLabel['PLEASESELECTPRODUCT'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return;
    }

     var assigned_user_id=ld("#"+popupobj.divid+"  [name=assigned_user_id]").val();//负责人
 //   var cf_3606 = ld(rowobj).find(" [detailcolumnname=cf_3606]").text();   //物料名称
    if(popupobj.pagetype==DetailViewPage.pagetype)
        var cf_4747=ld(rowobj).find(" [detailfieldname=cf_4747]").html();//物料名称
    else
        var cf_4747=ld(rowobj).find(" [detailcolumnname=cf_4747]").val();//物料名称
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_2896=ld(rowobj).find(" [detailfieldname=cf_2896]").html();//EV代码
    else
        var cf_2896=ld(rowobj).find(" [detailcolumnname=cf_2896]").val();//EV代码
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_2742=ld(rowobj).find(" [detailfieldname=cf_2742]").html();//义文零件号
    else
         var cf_2742=ld(rowobj).find(" [detailcolumnname=cf_2742]").val();//义文零件号
         
    var productname =ld(rowobj).find(" [detailfieldname=productname]").find("a").text();// 客户物料号   //物料编码
    var product_id = ld(rowobj).find(" [detailfieldname=productname]").find("a").attr('referencerecord');
    if(popupobj.pagetype==DetailViewPage.pagetype)  
        var cf_4733=ld(rowobj).find(" [detailfieldname=cf_4733]").html();//成交概率
    else
        var cf_4733=ld(rowobj).find(" [detailcolumnname=cf_4733]").val();//成交概率
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_4853=ld(rowobj).find(" [detailfieldname=cf_4853]").html();//是否成交
    else
    {
         var cf_4853=ld(rowobj).find(" [detailcolumnname=cf_4853]").val();//是否成交
         if(cf_4853==0)
         {
            cf_4853='否';
         }
         else
         {
            cf_4853='是';
         }
    }
   
   
  

    var  objparams = new CreatePagePopup.params();
    // ls 2021-09-24 【ID1002058】义文，个性化开发需求（谢彦涛）
    objparams.params['refreshpage']='no';
    objparams.params['createdtype']='quickcreate';
    // objparams.params['isduplicate'] = 'no';
    //线索 新建不用带入线索编号，此时还没保存    CustomForm09:义文机电的物料跟踪表
    if(popupobj.record > 0)
        CreatePagePopup.showpage('CustomForm09', "&cur_account=yiwen&assigned_user_id="+assigned_user_id+"&cf_2974="+cf_4747+"&cf_4524="+cf_2896+"&cf_4525="+cf_2742+"&cf_2973="+productname+"&cf_2975="+cf_4733+"&cf_4522="+cf_4853+"&product_id="+product_id+"&product_id_name="+productname+"&potential_id="+popupobj.record, objparams);
    else
        CreatePagePopup.showpage('CustomForm09', "&cur_account=yiwen&assigned_user_id="+assigned_user_id+"&cf_2974="+cf_4747+"&cf_4524="+cf_2896+"&cf_4525="+cf_2742+"&cf_2973="+productname+"&cf_2975="+cf_4733+"&cf_4522="+cf_4853+"&product_id="+product_id+"&product_id_name="+productname, objparams);
}

//@edit:liushuai,2020-10-30,reason:义文机电，线索/项目管理模块，分录增加“跟踪”按钮，点击按钮跳出新建“物料跟踪表”(详情页)
//rowid:行号
function goToCustomForm09Detail(rowid, module) {console.log(rowid+","+module);
    // alert(module);//Potentials
    // listviewbutton_click(this,'CustomForm09','Create',event);return false;

    var popupobj=CrmPopup.getPopupObj('last');
    // var tableobj=popupobj.getDetailTableObj();
    var tableobj=ld("#"+popupobj.divid+" [name=proTab]");
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");

    // popupobj.record   //线索编号
    // var span_cf_2894 = ld(rowobj).find(" [detailcolumnname=span_cf_2894]").text();// 物料编码 span标签
     var assigned_user_id=ld("#"+popupobj.divid+"  [name=assigned_user_id]").val();//负责人
 //   var cf_3606 = ld(rowobj).find(" [detailcolumnname=cf_3606]").text();   //物料名称
 //edit:can 2020-11-30 43512: （http://51mis.com/demo/yiwenjidian [^]）客户问题（谢彦涛），线索模块分录点击跟踪按钮，跳出的线索物料跟踪表，应把下面表格字段的值带到物料跟踪表上
    if(popupobj.pagetype==DetailViewPage.pagetype)
        var cf_4747=ld(rowobj).find(" [detailfieldname=cf_4747]").html();//物料名称
    else
        var cf_4747=ld(rowobj).find(" [detailcolumnname=cf_4747]").val();//物料名称
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_2896=ld(rowobj).find(" [detailfieldname=cf_2896]").html();//EV代码
    else
        var cf_2896=ld(rowobj).find(" [detailcolumnname=cf_2896]").val();//EV代码
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_2742=ld(rowobj).find(" [detailfieldname=cf_2742]").html();//义文零件号
    else
         var cf_2742=ld(rowobj).find(" [detailcolumnname=cf_2742]").val();//义文零件号
         
    var productname =ld(rowobj).find(" [detailfieldname=productname]").find("a").text();// 客户物料号   //物料编码
    var product_id = ld(rowobj).find(" [detailfieldname=productname]").find("a").attr('referencerecord');
    if(popupobj.pagetype==DetailViewPage.pagetype)  
        var cf_4733=ld(rowobj).find(" [detailfieldname=cf_4733]").html();//成交概率
    else
        var cf_4733=ld(rowobj).find(" [detailcolumnname=cf_4733]").val();//成交概率
    if(popupobj.pagetype==DetailViewPage.pagetype)    
        var cf_4853=ld(rowobj).find(" [detailfieldname=cf_4853]").html();//是否成交
    else
    {
         var cf_4853=ld(rowobj).find(" [detailcolumnname=cf_4853]").val();//是否成交
         if(cf_4853==0)
         {
            cf_4853='否';
         }
         else
         {
            cf_4853='是';
         }
    }
   
   
  

    var  objparams = new CreatePagePopup.params();
    // ls 2021-09-24 【ID1002058】义文，个性化开发需求（谢彦涛）
    objparams.params['refreshpage']='no';
    objparams.params['createdtype']='quickcreate';//当前模块创建其它模块单据时，不刷新页面
    // objparams.params['isduplicate'] = 'no';
    //线索 新建不用带入线索编号，此时还没保存    CustomForm09:义文机电的物料跟踪表
    if(popupobj.record > 0)
        CreatePagePopup.showpage('CustomForm09', "&cur_account=yiwen&assigned_user_id="+assigned_user_id+"&cf_2974="+cf_4747+"&cf_4524="+cf_2896+"&cf_4525="+cf_2742+"&cf_2973="+productname+"&cf_2975="+cf_4733+"&cf_4522="+cf_4853+"&product_id="+product_id+"&product_id_name="+productname+"&potential_id="+popupobj.record, objparams);
    else
        CreatePagePopup.showpage('CustomForm09', "&cur_account=yiwen&assigned_user_id="+assigned_user_id+"&cf_2974="+cf_4747+"&cf_4524="+cf_2896+"&cf_4525="+cf_2742+"&cf_2973="+productname+"&cf_2975="+cf_4733+"&cf_4522="+cf_4853+"&product_id="+product_id+"&product_id_name="+productname, objparams);
}

/*
*edit: chj
*date: 2020/11/19
*reason: 销售机会序时簿 - 客户漏斗
*/
function getCustomerFunnel(module){
    ////zxm 2021-0309 highcharts改成echarts
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=getCustomerFunnel';
    var paramsstr = '';//参数  这个参数要传到点击事件中  穿透的时候直接用这个参数
    //基本、高级查询条件
    if(!empty(searchtype_btn)){
        surl += '&'+getUrlString(searchtype_btn);
        surl += "&query=true&ajax=true&search=true";
        paramsstr += '&'+getUrlString(searchtype_btn);
        paramsstr += "&query=true&ajax=true&search=true";
    }

    //alert(surl);return false;
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
    crmPopupobj.prevshow();
    //wyt_220706_XUQIU1000477_销售机会漏斗表 旁边显示各阶段的百分占比
    ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				var sales_stage = data.result.sales_stage;
				var sales_stage_count = data.result.sales_stage_count;
                var topdata = [];
                var bottomdata = [];
                var legenddata = [];
                var oldcustomer_marketing = data.result.oldcustomer_marketing;
                var oldcustomer_marketing_count = data.result.oldcustomer_marketing_count;

                ld.each(sales_stage,function(index,item){
                    item = item + ' : '+ (sales_stage_count[index]);
                    // var value = (1 - 0.1 * index) * 100;
                    var value = 100-100/sales_stage.length*index;
                    topdata[index] = {name:item,value:value};
                    legenddata.push(item);
                })
                ld.each(oldcustomer_marketing,function(index,item){

                    item = item + ' : '+ oldcustomer_marketing_count[index];
                    var value = (0.1 * (index+1)) * 100;
                    bottomdata[index] = {name:item,value:value};
                    legenddata.push(item);
                });

				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth1100px",module,"",'',"",'',"");
				var _content = '<div id="advance_stage_charts_div" style="overflow: hidden; width: 100%; height: 520px; margin: 20px auto;" data-highcharts-chart="0">';
				_content += '</div>';
				crmPopupobj.show(_content);
				crmPopupobj.setScrollDivMaxHeight();
				//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
                let noAlertOfSalestage = '<input id="noAlertOfSalestage" value="yes" type="hidden">';
                ld("#" + crmPopupobj.divid + "_head").children(":first").after(noAlertOfSalestage);
				var myChart = echarts.init(document.getElementById('advance_stage_charts_div'),echartTheme);
                var grid = {
                    left: '3%',
                    right: '4%',
                    containLabel: true
                };
				var option = {
                    title: {
                        text: '',
                    },
                    grid:grid,
                    series: [
                        {
                            type: 'funnel',
                            width: '80%',
                            height: '48%',
                            left: '10%',
                            top: '20',
                            label: {
                                show: true,
                                position: 'inside'
                            },
                            data: topdata
                        },
                        {
                            type: 'funnel',
                            width: '80%',
                            height: '32%',
                            left: '10%',
                            top: '52%',
                            sort: 'ascending',
                            label: {
                                show: true,
                                position: 'inside'
                            },
                            data: bottomdata
                        }
                    ]
                };
                myChart.setOption(option);
                myChart.on('click', function (params) {
                    //zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
                    let componentIndex = params.componentIndex;
                    let stagename = '';
                    let oldcustomer_name = '';
                    if(componentIndex==0){
                        stagename = sales_stage[params.dataIndex];
                    }
                    if(componentIndex==1){
                        oldcustomer_name = oldcustomer_marketing[params.dataIndex];
                    }
                    showPotentialsStageListData(stagename,1,oldcustomer_name,'Potentials',stagename,data.result.title,paramsstr);
                });
                return false;
			}
	});
}

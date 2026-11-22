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
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module=Potentials&action=updateRelations&destination_module="+destination_module+"&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
			var divid = popupobj.divid;
			var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+destination_module).val();
			var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+destination_module).val();
			cancelCrmPopup();
			showRelatedCustomView(related_id,viewid);
			setRelatedResizeTable_Init(destination_module);
			set_rel_count();
		}
	}
	);
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
    $("status").style.display="inline";
    calendarParentid="Createreceivablesforecast";//该变量在jscalendar/dynamiccalendar.js/
    if(deployid <= 0||(deployid==2&&type==1))
    {
        if(deployid == 0||deployid == 2)
        {
            //该销售机会已创建回款预测
            prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast'];
            $("status").style.display="none";
           
            RemindsMsg("","LdPopWidth400px","","yes","",prompt);

            return false;
        }
    }else if(deployid==2&&type==2){
        $("status").style.display="none";
        return false;
    }
     //弹出框的设计
    var results;
    //alert("module=Potentials&action=popreceivablesforecast&potentialsid=" +potentialsid+'&ReportHeader=DHeader');
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=Potentials&action=popreceivablesforecast&potentialsid=" +potentialsid+'&ReportHeader=DHeader',
		onComplete:function (response) {
        results=response.responseText.split("####:###");
         if(results[1].indexOf(("error####::"))!=-1)
         {
            var errorre=arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast'];
            alert(errorre);
            $("status").style.display="none";
            return false;
         }  
         $("status").style.display="none";         
        $("potentialsid_form_div").innerHTML=results[1];
        fnvshobj(obj,divid);
        //setPaymentCoOrdinate(obj,divid);
		}
	});
   
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
    tddelete.innerHTML="<a class='icon-homeimg icon-sdel' href='javascript:;' onclick='deletetr(this)'></a>";
    var tdratio=tabtr.insertCell(1);
    tdratio.innerHTML="<input type='hidden' size='10'  name='periodtime"+rowcount+"' id='periodtime"+rowcount+"' value='"+curperiod+"'/><input type='text' size='10' name='ratio"+rowcount+"' id='ratio"+rowcount+"' value='"+parseFloat(balanceratio).toFixed(2)+"' onchange=changeamountn(this,'amount"+rowcount+"','ratio"+rowcount+"','"+nopaymentamount+"');>";
    var tdamount=tabtr.insertCell(2);
    tdamount.innerHTML="<input type='text' size='10' name='amount"+rowcount+"' id='amount"+rowcount+"' value='"+parseFloat(balanceamount).toFixed(2)+"' onchange=changeratio(this,'ratio"+rowcount+"','amount"+rowcount+"','"+nopaymentamount+"');>";
    var tdplandate=tabtr.insertCell(3);
   
    tdplandate.innerHTML="<input type='text' size='15' onClick='WdatePicker()' class='Wdate' readonly='true' name='plandate"+rowcount+"' value='"+plandate+"' id='plandate"+rowcount+"\'/>";
    //tdplandate.innerHTML+= "&nbsp;<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img"+rowcount+"' onclick='showCalendar(\"plandate"+rowcount+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
 
    
}
function deletere(id,reid){
		if(confirm(arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'])){
		  location.href="index.php?module=Potentials&action=Deletereceivablesforecast&id="+id+"&record="+reid;
		}
}
function editre(obj,reid){
    var results;
 	new Ajax.Request("index.php",
	{
		queue:{
			position:"end",
			scope:"command"
		},
		method:"post",
		postBody:"module=Potentials&action=popeditreceivablesforecast&receivablesforecastid=" +reid+'&ReportHeader=DHeader',
		onComplete:function (response) {
        results=response.responseText.split("####:###");
         if(results[1].indexOf(("error####::"))!=-1)
         {
            var errorre=results[1].split("error####::")[1];
            alert(errorre);
            $("status").style.display="none";
            return false;
         }  
         $("status").style.display="none";         
        $("potentialsid_form_div").innerHTML=results[1];
        fnvshobj(obj,'Createreceivablesforecast');
        //setPaymentCoOrdinate(obj,divid);
		}
	});
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
function savereceivablesforecast(obj,oformname)
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
     var tabplan=document.getElementById("tabreceivablesforecast");
     
    var rowcount=tabplan.rows.length;
    var planamount=0.0;
    if(rowcount<=1)
    {
         lingdangJS_DialogBox.unblock();	
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
            lingdangJS_DialogBox.unblock();	
            //付款计划金额和未计划金额不一致！
                     //付款计划金额和未计划金额不一致！
            prompt = arrJsPopLabel['Thepotentialhasbeencreatedreceivablesforecast5'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",prompt);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                oform.submit();
            });
            document.getElementById('save_payment_check').disabled=false;
            return false;
        }else{
            oform.submit();
        }  
}
/*
更新操作
edit:lmx
date:20140220
reason:销售机会共享(V5.3)
*/
function PotentialsShare(obj,id)
{
    $("status").style.display="inline";
      new Ajax.Request("index.php",
    	{
    		queue:
            {
    			position:"end",
    			scope:"command"
    		},
    		method:"post",
    		postBody:"module=Potentials&action=PotentialsAllView&id="+id,
    		onComplete:function (response) {
    		    var results=response.responseText.split('##SUCCESS##');
                
                $('divPotentialsShare').innerHTML=results[1];
                /**
                 *@edit:andy 
                 *@date:
                 *@reason:待使用统一遮罩层
                 *@version:
                 */
               fnvshobj(obj,'divPotentialsShare');
               /*                              
                Lay = 'divPotentialsShare';
				var tagName = document.getElementById(Lay);
				var leftSide = findPosX(obj);
				var topSide = findPosY(obj);
				var maxW = tagName.style.width;
                var H = screen.height;  //获取当前分辨率高度
                var W = screen.width;   //获取当前分辨率宽度
              
				var widthM = maxW.substring(0,maxW.length-2);
				var getVal = parseInt(leftSide) + parseInt(widthM);
                //if(getVal  > document.body.clientWidth ){                
				if(topSide < H){
					/*leftSide = parseInt(leftSide) - parseInt(widthM);
					tagName.style.left = leftSide + 50 + 'px';
					tagName.style.top = topSide + 20 + 'px';
                    tagName.style.left = (W-parseInt(widthM))/2 + 'px';
					tagName.style.top = topSide - 30 + 'px';                    
				}else{
				    //tagName.style.left = leftSide + 50 + 'px';
                    tagName.style.top = (topSide - H/2) + 60 + 'px';
					tagName.style.left = (W-parseInt(widthM))/2 + 'px';                    
				}
		
                lingdangJS_DialogBox.block();
				tagName.style.display = 'block';
				tagName.style.visibility = "visible";*/
                $("status").style.display="none";
              }                
    		
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
    
    $("status").style.display="inline";
  
    new Ajax.Request(
        'index.php',
        {
            queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=ContactRecords&action=ContactRecordsAjax&file=QuickCreate&type=gengjin&ajax=true&qcreatetype=menu&return_module='+return_module+'&return_id='+return_id+"&return_action="+return_action+'&records='+record+"&Create=true",
            onComplete: function(response) {
                document.getElementById("status").style.display="none";
                document.getElementById("qcform").style.display="inline";
				document.getElementById("qcform").innerHTML = response.responseText;
				// Evaluate all the script tags in the response text.
				var scriptTags = document.getElementById("qcform").getElementsByTagName("script");
				for(var i = 0; i< scriptTags.length; i++){
					var scriptTag = scriptTags[i];
					eval(scriptTag.innerHTML);
				}
                fnvshobj(this, 'qcformDiv');   
                eval(document.getElementById("qcform"));
                    
                
            }
        }
    );
}


// @edit:dong @date:2020/08/04 @reason: 移动到listview.js
/*
var location_lat = 0;
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
									city = trim(city.replace('市',''));
									if(CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != ''){
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
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
						var info = '<li><span>'+arrJsPopLabel['thelocationaddress']+'</span></li>';
						CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
						CrmPopup.findHtmlobj(divid,'search_location_address').show();
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
	if(empty(address)){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
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
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth850px","","yes","",table_html);
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

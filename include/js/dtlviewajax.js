/*********************************************************************************
*{*修改编码格式:统一编码：UTF-8*}*
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
 
var globaldtlviewspanid = "";
var globaleditareaspanid = ""; 
var globaltxtboxid = "";
var itsonview=false;
// to retain the old value if we cancel the ajax edit
var globaltempvalue = '';
var globaluitype = '';
var globalmouseover_num = 0;
function showHide(showId, hideId)
{
	New_show(showId);
  
	fnhide(hideId);

    //edit: xll 2023/07/31 BUG0064157 kfbcrm 客户---查看详情--小编辑“公司email”--输入值点取消---再点编辑，内容没有清空
    var popupobj=CrmPopup.getPopupObj('last');
    var input_id = 'txtbox_' + showId.split('_')[1];
    var inputobj = ld("#"+popupobj.divid+" #"+input_id);
    if(inputobj.length > 0 && inputobj.get(0).type == 'text'){
        var tmp_value = ld("#"+popupobj.divid+" [name="+showId+"]").text();
        inputobj.val(tmp_value);
    }

}

function hndCancel(valuespanid,textareapanid,fieldlabel)
{
   var popupobj=CrmPopup.getPopupObj('last');
	showHide(valuespanid,textareapanid);
	if(popupobj.globaluitype == '56'||popupobj.globaluitype == '156')
	{
        //zkt 20240112 BUG0077978 成员管理-编辑是否管理员字段，改成不勾选，点击取消，再次编辑这个字段，仍是是不勾选的状态。
        var input_id = 'txtbox_' + popupobj.globaltxtboxid;
        var inputobj = ld("#"+popupobj.divid+" #"+input_id);
        if(inputobj.length > 0 ){
            if(globaltempvalue == 1){
                inputobj.get(0).checked = true;
            }else{
                inputobj.get(0).checked = false;
            }
        }
	}
	else if(popupobj.globaluitype != '53' && popupobj.globaluitype != '33'){
		if(getObj(popupobj.globaltxtboxid) && getObj(popupobj.globaltxtboxid) != ''){
			getObj(popupobj.globaltxtboxid).value = globaltempvalue;
		}
	}
	if(popupobj.globaluitype == 2 && (popupobj.globalfieldlabel == 'accountname' || popupobj.globalfieldlabel == 'vendorname')){
		if(ld('#business_'+popupobj.globalfieldlabel) != undefined){
			ld('#business_'+popupobj.globalfieldlabel).show();
		}
	}
  if(popupobj.globaluitype == 1 && popupobj.globalfieldlabel == 'express_no' && document.getElementById("txtbox_express_no").value !=''){
    if(ld('#logistics_query') != undefined){
      ld('#logistics_query').show();
    }
  }
  globaltempvalue = '';
  itsonview=false;
  return false;
}
function hndMouseOver(uitype,fieldLabel)
{
  
      var mouseArea="";
      mouseArea="mouseArea_"+ fieldLabel;
      if(itsonview)
      {
            return;
      }
      var popupobj=CrmPopup.getPopupObj('last');

      if (popupobj){
          popupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
      }

      //New_show("crmspanid");
	  popupobj.globaluitype = uitype;
      popupobj.globaldtlviewspanid= "dtlview_"+ fieldLabel;//valuespanid;
      popupobj.globaleditareaspanid="editarea_"+ fieldLabel;//textareapanid;
	  popupobj.globalfieldlabel = fieldLabel;
      //globaluitype=uitype;
	  if(popupobj.globaluitype == 53)
	  {
		  if(typeof(document.DetailView.assigntype[0]) != 'undefined')
		  {
			  var assign_type_U = document.DetailView.assigntype[0].checked;
			  var assign_type_G = document.DetailView.assigntype[1].checked;
			  if(assign_type_U == true)
				  popupobj.globaltxtboxid= 'txtbox_U'+fieldLabel;
			  else if(assign_type_G == true)
				  popupobj.globaltxtboxid= 'txtbox_G'+fieldLabel;
		  }else
		  {
			  popupobj.globaltxtboxid= 'txtbox_U'+fieldLabel;
		  }
	  }
      //zkt 20230316 BUG0062800 “销售线索”，查看界面，当手机号码本来为空时，点击编辑，输入错误的手机号，点击保存，没有提示信息 
      else if(popupobj.globaluitype == 1101){
	       popupobj.globaltxtboxid= popupobj.module+'_txtbox_'+fieldLabel;
	  }
      else
	  {
      	  popupobj.globaltxtboxid= fieldLabel;//textboxpanid;
	  }
      divObj = ld("#"+popupobj.popupdivid+ " [name=crmspanid]");
      divObj.css('display','inline');
      divObj.unbind('mouseover').bind('mouseover',function(){
          ld(this).css('display','inline');
      });
     // alert(divObj.length);
      //crmy = findPosY(getObj(mouseArea));
     // crmx = findPosX(getObj(mouseArea));
    
     if(ld("#"+popupobj.divid+ " [name="+mouseArea+"]").length<1)
     {
        
        return ;
     }
    var fieldobj = ld("#"+popupobj.divid+ " [name="+mouseArea+"]");
    //edit:duan 2022-1-11 判断元素是否存在鼠标移出事件，如果不存在，则添加
    var objevent = ld._data(fieldobj.get(0),"events");
    if(objevent!=undefined && objevent['mouseout']!=undefined){
    }else{
        fieldobj.unbind('mouseout').bind('mouseout',function(){
            divObj.css('display','none');
        })
    }
    
     crmy=fieldobj.offset().top;
     crmx=fieldobj.offset().left;
    var popupobjleft=0;
    var popupobjtop=0;
    if(ld("#"+popupobj.popupdivid).length>0){
        popupobjleft=ld("#"+popupobj.popupdivid).offset().left-22;
        popupobjtop=ld("#"+popupobj.popupdivid).offset().top;
    }
      if(document.all)
      {
          divObj.get(0).onclick=handleEdit;
      }
      else
      {
          divObj.get(0).setAttribute('onclick','handleEdit();');
      }
    
      /**
        *更新操作
        *edit:kevin
        *date:2013-10-28
        *reason:0005453: 打开客户单据查看界面时，IE浏览器页面左下角有时会报错，但是还没有查清原因，无法按规律重现，错误如图所示。
        */
      //divObj.style.left=(crmx+getObj(mouseArea).offsetWidth -divObj.offsetWidth)+"px";
	  //0030276: PC端>财务>采购发票明细界面：编辑按钮在边框线的中间。（火狐问题）
      
	  if(popupobj.globalmouseover_num == 0){
		popupobj.globalmouseover_num++;
       
	//	divObj.style.left=(crmx+$(mouseArea).offsetWidth -divObj.offsetWidth*2)+"px";
	  }else{
		//divObj.style.left=(crmx+$(mouseArea).offsetWidth -divObj.offsetWidth)+"px";
       
	  }
      var left=(crmx-popupobjleft+ld("#"+popupobj.popupdivid+ " [name="+mouseArea+"]").width()-divObj.width());
      var top=(crmy-popupobjtop)+10;
       divObj.css("left",left+"px");
      divObj.css("top",top+"px");
   //   divObj.style.top=crmy+"px";
}

function handleEdit()
{
    var popupobj=CrmPopup.getPopupObj('last');
	 if(popupobj.globaluitype == 2 && (popupobj.globalfieldlabel == 'accountname' || popupobj.globalfieldlabel == 'vendorname')){
		if(ld('#business_'+popupobj.globalfieldlabel) != undefined){
			ld('#business_'+popupobj.globalfieldlabel).hide();
		}
	 }
   if(popupobj.globaluitype == 1 && popupobj.globalfieldlabel == 'express_no'){
    if(ld('#logistics_query') != undefined){
      ld('#logistics_query').hide();
    }
   }
     New_show(popupobj.globaleditareaspanid) ;
     
     fnhide(popupobj.globaldtlviewspanid);
	 if(popupobj.globaluitype == 56||popupobj.globaluitype == 156) {
         var input_id = 'txtbox_' + popupobj.globaltxtboxid;
         var inputobj = ld("#"+popupobj.divid+" #"+input_id);
         if(inputobj.length > 0 ){
             globaltempvalue = ld(inputobj).val();
         }
     }
     else if(popupobj.globaluitype != 53){
		 if(getObj(popupobj.globaltxtboxid) && getObj(popupobj.globaltxtboxid) != ''){
			globaltempvalue = getObj(popupobj.globaltxtboxid).value;
			if(getObj(popupobj.globaltxtboxid).type != 'hidden')
				getObj(popupobj.globaltxtboxid).focus();
		 }
	 }
     fnhide('crmspanid');
     itsonview=true;
     return false;
}

//Asha: Function changed to trim both leading and trailing spaces.
function trim(str) {
    //alert(str);
    if(str!=undefined)
    {
        var s = str.replace(/\s+$/,'');
     	s = s.replace(/^\s+/,'');
     	return s;
    }
	return "";
}

var genUiType = "";
var genFldValue = "";
var httpreq=null;
var isDuplicate=true;
var diveditArea="";
/*
edit:can
date:20130805
reason:自定义设置增加是否允许重复设置


function dtlViewDuplicate(fieldLabel,module,uitype,tableName,fieldName,crmId)
{
  
 
   var popupobj=CrmPopup.getPopupObj("last");
   
    $("status").style.display="inline";
      var txtbox='txtbox_';
      diveditArea="editarea_"+fieldLabel;
    if(uitype==53)//负责人
    {
        txtbox=txtbox+'U'+fieldLabel;
    }
    else
    {
        txtbox=fieldLabel;
    }
	
    //var fieldvalue=trim(document.getElementById(txtbox).value);
    var fieldvalue=ld("#"+popupobj.divid+" [name="+txtbox+"]").val();
    if(uitype==15 || uitype==33)//下拉框
    {
        
        fieldvalue=trim(ld("#"+popupobj.divid+" [name="+txtbox+"]").text());
    }
    if(fieldvalue=="")
    {
        return true;
    }
    fieldvalue=encodeURIComponent(fieldvalue);
    
    url="index.php?module="+module+"&action=FieldDuplicate&fieldname="+fieldName+"&fieldvalue="+fieldvalue+"&fieldid="+crmId;
  
    httpreq=createXMLHTTP();
    httpreq.open("POST",url,false);
    isDuplicate=false;
  
    httpreq.onreadystatechange=FieldDuplicateRequest;
    httpreq.setRequestHeader("If-Modified-Since","0");
    httpreq.send(null);
    $("status").style.display="none";
    return !isDuplicate;
}
function FieldDuplicateRequest()
{
    if(httpreq.readyState==4)
    {
        if(httpreq.status==0||httpreq.status==200)
        {
                var str=httpreq.responseText;
            	if(str.indexOf('##success##') <= -1)
                {
					if(str.indexOf('##error##') > -1)
					{
						var results=str.split('##error##');
						puyoungJS_DialogBox.unblock();
                        RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
						isDuplicate=true;
					}else if(str.indexOf('divNoRecord') > -1){
						//您没有权限执行这个操作（可能是查重）
						var confirm_str = arrJsPopLabel['NOPERMITTEDEXECUTE'];
                         RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
						puyoungJS_DialogBox.unblock();
						isDuplicate=true;
					}
                }
        }
    }
}*/
function dtlViewAjaxSave(fieldLabel,module,uitype,tableName,fieldName,crmId)
{   
    
    var popupobj=CrmPopup.getPopupObj('last');
    //edit:duan 避免自动化任务弹出层对象divid错误
    AdvanceStage.reset_pupupobj_divid(popupobj);
    var dtlView = "dtlview_"+ fieldLabel;
	var editArea = "editarea_"+ fieldLabel;
	var keywordsArea = "ldkeywords_field_"+ fieldLabel;
	var groupurl = "";
    
    //
    itsonview=false;
  /*  dtlViewAjaxSave.uitype=uitype;
    dtlViewAjaxSave.module=module;
    dtlViewAjaxSave.crmid=crmId;
    dtlViewAjaxSave.tablename=tableName;
    dtlViewAjaxSave.fieldlabel=fieldLabel;
    */
    if(popupobj.dtlViewAjaxSave==undefined)
    {
        popupobj.dtlViewAjaxSave=new Object();
    }
    popupobj.dtlViewAjaxSave.uitype=uitype;
    popupobj.dtlViewAjaxSave.module=module;
    popupobj.dtlViewAjaxSave.crmid=crmId;
    popupobj.dtlViewAjaxSave.tablename=tableName;
    popupobj.dtlViewAjaxSave.fieldlabel=fieldLabel;
	if(popupobj.globaluitype == 53)
	{
		if(typeof(document.DetailView.assigntype[0]) != 'undefined')
		{
			var assign_type_U = document.DetailView.assigntype[0].checked;
			var assign_type_G = document.DetailView.assigntype[1].checked;
		}else
		{
			var assign_type_U = document.DetailView.assigntype.checked;
		}
		if(assign_type_U == true)
		{
			var txtBox= 'txtbox_U'+fieldLabel;
		}
		else if(assign_type_G == true)
		{
			var txtBox= 'txtbox_G'+fieldLabel;
			var group_id = encodeURIComponent($(txtBox).options[$(txtBox).selectedIndex].text); 
			var groupurl = "&assigned_group_id="+group_id+"&assigntype=T"
		}
	}
	else if(uitype == 15 || uitype == 16 || uitype == 153)
	{	
		//var txtBox= "txtbox_"+ fieldLabel;
		var txtBox = fieldName;

	}
	else if(popupobj.globaluitype == 33)
	{
	  //var txtBox= "txtbox_"+ fieldLabel;
      var txtBox=  fieldLabel;
	  var oMulSelect =ld("#"+popupobj.divid+" [name="+txtBox+"]").get(0);
	  var r = new Array();
	  var notaccess_label = new Array();
	  for (iter=0;iter < oMulSelect.options.length ; iter++)
	  {
      	      if (oMulSelect.options[iter].selected)
        		{
        			r[r.length] = oMulSelect.options[iter].value;
        			notaccess_label[notaccess_label.length] = oMulSelect.options[iter].text;
        		}
	  }
	}else
	{
		//var txtBox= "txtbox_"+ fieldLabel;
        var txtBox=  fieldLabel;
	}
	if(popupobj.globaluitype == 2 && ((popupobj.globalfieldlabel == 'accountname' && (module == 'Accounts' || module == 'ServiceCharge')) || (popupobj.globalfieldlabel == 'vendorname' && module == 'Vendors'))){
		if(ld('#business_'+popupobj.globalfieldlabel) != undefined){
			ld('#business_'+popupobj.globalfieldlabel).show();
		}
	}
  if(popupobj.globaluitype == 1 && popupobj.globalfieldlabel == 'express_no' && (module == 'SalesOrder' || module == 'OutboundOrder' || module == 'Invoice')){
    if(ld('#logistics_query') != undefined && document.getElementById("txtbox_express_no").value !=''){
      ld('#logistics_query').show();
    }
  }
	/*
    *Liver2016/04/11 bug0021270:日程管理>相关信息：【结束时间】小编辑后日期可以小于【开始时间】
    */
    if(module=='Calendar'){
         var calendarStart_time =ld("#"+popupobj.divid+" [name=date_start]").val();// document.getElementById("txtbox_date_start").value; //日程管理开始时间
         var calendarEnd_time =ld("#"+popupobj.divid+" [name=due_start]").val(); document.getElementById("txtbox_due_date").value; //日程管理结束时间
            if(calendarEnd_time < calendarStart_time)
             {
               var confirm_str = arrJsPopLabel['STARTDATECANNOTBEGREATERTHANENDDATE'];
               RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
               return false;
             }
            
    }
    
    //0023517: 费率设定 明细界面：小编辑 字段“起始日期”大于“截止日期”，没有弹出提示“起始日期不能大于截止日期”
    if(module=='Rate'){
        var calendarStart_time =ld("#"+popupobj.divid+" [name=startdate]").val();// document.getElementById("txtbox_startdate").value; //开始日期
        var calendarEnd_time =ld("#"+popupobj.divid+" [name=enddate]").val();// document.getElementById("txtbox_enddate").value; //结束日期
        if(calendarEnd_time < calendarStart_time)
        {
           var confirm_str = arrJsPopLabel['THISDATENOEDNDATE'];
           RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
           return false; 
        }
    }
    
    
	var popupTxt= "popuptxt_"+ fieldLabel;      
	var hdTxt = "hdtxt_"+ fieldLabel;
	//小编辑 提现单 存现单  转入转出账号
	if(module=='CashDeposit'||module=='PutCash'){
		var inputs;
	//	if(document.DetailView != undefined){
		  var outaccountobj=ld("#"+popupobj.divid+" [name=outaccount]");
          var inaccountobj=ld("#"+popupobj.divid+" [name=inaccount]");
          
			//if(document.DetailView.outaccount != undefined && document.DetailView.inaccount != undefined){
			 if(outaccountobj.length>0&&inaccountobj.length>0){
				if(outaccountobj.val() == inaccountobj.val()){
					var hdTxt_Value =ld("#"+popupobj.divid+" [name="+hdTxt+"]");// ld("#"+hdTxt).val();
                    var tmpobj=ld("#"+popupobj.divid+" [name="+fieldName+"]");
					tmpobj.val(tmpobj.find("option[text='"+hdTxt_Value+"']").attr("value"));
					var confirm_str = arrJsPopLabel['taaacnbtttsa'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}else{
				    var tmpobj=ld("#"+popupobj.divid+" [name="+fieldName+"]");
					var hdTxt_Value =tmpobj.val();// ld("#"+fieldName).val();
					ld("#"+popupobj.divid+" [name="+hdTxt+"]").val(tmpobj.find("option[value='"+hdTxt_Value+"']").attr("text"));
				}
			}	
		//}
        
	}
     
       //重新加载布局规则(下拉框不需要条用)
    //if(popupobj.fieldruleobj!=null&&popupobj.fieldruleobj!=undefined&&(uitype==1||uitype==19||uitype==21||uitype==56))
      //   popupobj.fieldruleobj.CheckReLoadPopup();//重新加载布局规则
         
	if(formValidate() == false)
	{
		return false;
	}
    for (var i = 0; i < popupobj.fields.length; i++)
    {
        var tmpuitype=popupobj.fields[i].uitype ;
        var type = popupobj.fields[i].typeofdata.split("~"); 
        if(type[1]=='M'&&SaveDataRecord.isfileattachUitype(tmpuitype))
        {
            ////edit:can 20230908 72372 项目信息（客户模块）设置了布局规则，“项目阶段”字段变更为中标项目时，附件字段“附件(中标通知或其他附件等)”变为必填，大编辑状态下没问题，
             if(popupobj.filejsondata[popupobj.fields[i].columnname]==undefined||popupobj.filejsondata[popupobj.fields[i].columnname].length<=0)
             {
                var confirm_str = popupobj.fields[i].fieldlabel+arrJsPopLabel['CANOTEMPTY'];
       
                 audioRemindsMsg("","","","","",confirm_str);
                return false;
             }
        }
    }


	//ld("#status").get(0).style.display="inline";
	var isAdmin =ld("#"+popupobj.divid+" [name=hdtxt_IsAdmin]").val();// document.getElementById("hdtxt_IsAdmin").value; 
  
 
    
	//overriden the tagValue based on UI Type for checkbox 
	if(uitype == '56'||uitype=='156')
	{
		//if(document.getElementById(txtBox).checked == true)
       if(ld("#"+popupobj.divid+" [name="+txtBox+"]").prop("checked"))
		{
			if(module == "Contacts")
			{
				var obj = getObj("email");
				if((fieldName == "portal") && (obj == null || obj.value == ''))
				{
					tagValue = "0";
                      var confirm_str = alert_arr.PORTAL_PROVIDE_EMAILID;
                      RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
				else
					tagValue = "1";

			}
			else
				tagValue = "1";
		}else
		{
			tagValue = "0";
		}
	}else if(uitype == '33')
	{
		tagValue = r.join(" |##| ");
  	}else if(uitype == '24' || uitype == '21')
        {
                tagValue =ld("#"+popupobj.divid+" [name="+txtBox+"]").val().replace(/<br\s*\/>/g, " ");//// document.getElementById(txtBox).value.replace(/<br\s*\/>/g, " ");

        }
        else if(uitype=="251" ||uitype=="252")
        {
            	tagValue = trim(ld("#"+popupobj.divid+" [name="+fieldName+"]").val());//trim(document.getElementById(fieldName).value);
              
        }
     
        else
	   {
	    /*if(uitype==1101)
        {
            txtBox=module+"_"+txtBox;
        }*/
		
     
		
        if(uitype==15)
        {
            //派息单状态字段fieldname为"status"和进度条"status"的iD相同
            tagValue=ld("#"+popupobj.divid+" [name="+txtBox+"]").val();
           
        }
        else
        {
            tagValue = trim(ld("#"+popupobj.divid+" [name="+txtBox+"]").val());//trim(document.getElementById(txtBox).value);
        }
		if(module == "Contacts")
                {
			if(getObj('portal'))
                        {
                                var port_obj = getObj('portal').checked;
                                if(fieldName == "email" && tagValue == '' && port_obj == true)
                                {
                                    var confirm_str = alert_arr.PORTAL_PROVIDE_EMAILID;
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }
                        }
                }
	}    
    
	var data = "file=DetailViewAjax&module=" + module + "&action=" + module + "Ajax&record=" + crmId+"&recordid=" + crmId ;
    var fieldvalue_url = "&fldName=" + fieldName + "&fieldValue=" + escapeAll(tagValue) + "&ajxaction=DETAILVIEW"+groupurl;
	data = data + fieldvalue_url;
    //edit:can 20200812 42377: （http://39.108.96.128/crm/ [^]）徐燕男客户问题（速优），合同订单模块>单据详情界面：“阿里运营”区块，“买家保障是否开通”字段点击“小编辑”按钮，然后点击保存，会自动生成一条新的“服务合同”
    data+='&mode=edit';

    /*if(module == 'Users') {
        data += "&form_token=" + (document.getElementsByName('form_token')[0].value);
    }
    */
    
    var paymentstatus =CrmPopup.getHtmlobjval(popupobj.divid,fieldName);

    
    if(module == 'PaymentPlans'){
        if(paymentstatus !='未收'&&fieldName=='paymentstatus'){
            if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])){
                data += "&PaymentPlan_Save=yes";
            }else{
                //先用小编辑按钮编辑“状态”字段然后关闭弹出框，再用小编辑按钮编辑其他的字段时仍会弹出该提示信息 
                 //ld("#status").css("display","none");
                var objoption=CrmPopup.findHtmlobj(popupobj.divid,fieldname);
                
                objoption.val(popupobj.picklistobjarray[fieldname].beforevalue);//保存 用到的隐藏域
                return false;
            }
        }
    }
    if(module == 'SendPayments'){
        if(paymentstatus !='未付'&&fieldName=='cpstatus'){
            if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])){
                data += "&PaymentPlan_Save=yes";
            }else{
                //先用小编辑按钮编辑“状态”字段然后关闭弹出框，再用小编辑按钮编辑其他的字段时仍会弹出该提示信息 
                 //ld("#status").css("display","none");
                var objoption=CrmPopup.findHtmlobj(popupobj.divid,fieldname);
                
                objoption.val(popupobj.picklistobjarray[fieldname].beforevalue);//保存 用到的隐藏域
                return false;
            }
        }
    }
    //edit:duan date:2024/10/29 reason:用户界面小编辑职位级别时，额外获取json信息
    if(module == 'Users' && fieldName == 'userlevel'){
        var jsonvalue=ld("#"+popupobj.divid+" [name=jsonvalue_"+fieldName+"]").val();
        data+='&jsonvalue_'+fieldName+'='+jsonvalue;
    }

   if(fieldName=='cashmoney'){
   var reg = new RegExp("[\\d,.]+");
    if(!reg.test(escapeAll(tagValue))){
        var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    var numbervalue = escapeAll(tagValue);
    parseInt(numbervalue);
    if(numbervalue>1000000000000){
        var confirm_str = arrJsPopLabel['TAETML'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
   } 
    var isEdit='no';
    var con = true;
    var lastpopupobj = popupobj;

    //duan 20240611 修改后需要判断是否重置审批状态,调整提示框
    con = validatasave.checkResetApprove(popupobj,crmId,module,function () {
        dtlViewAjaxSave(fieldLabel,module,uitype,tableName,fieldName,crmId);
    });
    if (!con) {
        return '';
    }

    //duan 20231009 小编辑增加验证规则提示
    validatasave.CheckAllowSavePhpRule(module,crmId,fieldvalue_url).then(result => {
        con = result;
        if(!con){
            return '';
        }
        var popupobj = lastpopupobj;
        popupobj.dtlViewAjaxSave.retValue = '';
        ldAjaxNoProgresssync("index.php?" + data,'',function (data) {
            //$("status").style.display = "none";
            /*andrew
            *0009838: “提现单”、“存现单”：当金额大于转出账户的余额，保存时，建议给出提示“金额大于转出账户余额，是否保存”，确定后可以保存。
           */

            if (data.code == -1) {
                if ((module == 'PutCash' || module == 'CashDeposit') && uitype == 72 && fieldName == 'cashmoney') {
                    if (window.confirm(arrJsPopLabel['TATIGTTABWTS'])) {
                        ldAjaxHtmlNoProgress('index.php?',data + '&checkOK=OK',function (response) {

                            if (response.indexOf(":#:FAILURE") > -1) {
                                var confirm_str = alert_arr.ERROR_WHILE_EDITING;
                                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                            } else if (response.indexOf(":#:ERR") > -1) {
                                alert_str = response.replace(":#:ERR", "");
                                alert_str = alert_str.replace(/[ ]/g, "");
                                alert_str = alert_str.replace(/[\r\n]/g, "");
                                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", alert_str);
                            } else if (response.indexOf(":#:SUCCESS") > -1) {

                                popupobj.dtlViewAjaxSave.afterOperation(fieldName);

                            } else if (module.toLocaleLowerCase() == "paymentplan" || module.toLocaleLowerCase() == "sendpayment") {
                                if (response.indexOf("####::##success") != -1) {
                                    popupobj.dtlViewAjaxSave.afterOperation(fieldName);
                                } else {
                                    var results = response.split("####::##error");
                                    document.getElementById("crmspanid").style.display = "none";
                                    $("MainDetailFeilds").innerHTML = results[1];
                                }
                            }
                        });
                    } else {
                        handleEdit();
                    }
                } else {
                    var confirm_str = data.msg;

                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                }

                return false;

            } else {

                showHide(dtlView, editArea);  //show,hide

                popupobj.dtlViewAjaxSave.retValue = data.result.datainfo[fieldName]['value'];
                //zxm BUG20240603-10 bug详情界面--优先级--编辑，改变优先级点保存后，表头部分的优先级没有及时更新显示
                ld('#'+keywordsArea).text(popupobj.dtlViewAjaxSave.retValue);
                dtlViewAjaxSave.afterOperation(fieldName);

                //更新界面的值
                var tmparra = new Array();
                tmparra.push(popupobj.record);
                var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
                //var tmparra=new Array();
                //tmparra=[popupobj.module];
                // tmpobj.eachrefreshDetailViewByModules(tmparra);
                tmpobj.update();

                workflowCallApiPop(data.result);//工作流API弹窗


                if (data.msg.indexOf(":#:SUCCESS##POPCREATEDIVIDENDORDER") > -1) {
                    //合同订单（金融行业创建派息单)
                    detailbutton_click(null, 'SalesOrder', 'dividendcreate', crmId);
                }
                if (data.msg.indexOf(":#:AUTOEXECCREATECALENDARTEMPLATE") > -1) {
                    createTemplateCalendars("index.php?module=Calendar&action=EditView&autoexec=yes&product_id=" + crmId + "&parent_id=" + crmId + "&frommodule=" + module + "&fldName=" + fieldName);
                }

                if (module.toLocaleLowerCase() == "paymentplan" || module.toLocaleLowerCase() == "sendpayment") {

                    //修改状态，则界面无法编辑（待处理
                    var results = data.msg.split("####::##error");

                    // document.getElementById("crmspanid").style.display="none";
                    if ($("MainDetailFeilds") != undefined && $("MainDetailFeilds") != 'undefined') {
                        $("MainDetailFeilds").innerHTML = results[1];
                    }


                }
            }
        });


        tagValue = get_converted_html(tagValue);
        if (uitype == '13' || uitype == '104') {
            var temp_fieldname = 'internal_mailer_' + fieldName;
            if ($(temp_fieldname)) {
                var mail_chk_arr = $(temp_fieldname).innerHTML.split("####");
                var fieldId = mail_chk_arr[0];
                var internal_mailer_flag = mail_chk_arr[1];
                if (internal_mailer_flag == 1) {
                    //var email_link = "<a href=\"javascript:InternalMailer("+crmId+","+fieldId+",'"+fieldName+"','"+module+"','record_id');\">"+tagValue+"&nbsp;</a>";
                    var email_link = '';
                    if (tagValue != '') {
                        //zkt 20240725 BUG20240725-58 客户管理中，直接在单据详情界面的“公司Email”字段处编辑邮箱，点击邮箱地址右边的“邮箱管理”按钮，出现报错界面（进入单据的编辑界面点击保存后再点击详情界面邮箱地址右边的“邮箱管理”按钮，就没有报错了）
                        var tmpurlstring= "index.php?module=Emails&action=EmailsAjax&file=EditView&fieldlabel=" + fieldLabel + "&id=" + crmId + "&return_module=" + module + "&return_action=DetailView";
                        tmpurlstring= cls_encryptyurl.Puyoung_Encryptyurl(tmpurlstring,'');
                        var email_link = "<a style='display:block;float:left;' href='#' onclick='window.open(\""+tmpurlstring+"\",null,\"1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes\")'>" + tagValue + "&nbsp;</a>" +
                            "<a id='emailimg' style='display:;float:left;' href='#' " + "onclick='window.open(\""+tmpurlstring+"\",null,\"1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes\")'><img src='themes/images/email.png'/></a>";
                    }
                } else
                    var email_link = "<a href=\"mailto:" + tagValue + "\" target=\"_blank\">" + tagValue + "&nbsp;</a>";
            }

            getObj(dtlView).innerHTML = email_link;
            if (fieldName == "email" || fieldName == "email1") {
                var priEmail = getObj("pri_email");
                if (priEmail)
                    priEmail.value = tagValue;
            } else {
                var secEmail = getObj("sec_email");
                if (secEmail)
                    secEmail.value = tagValue;
            }
        } else if (uitype == 251 || uitype == 252) {
            getObj(dtlView).innerHTML = document.getElementById(fieldName).options[document.getElementById(fieldName).selectedIndex].text;
        } else if (uitype == '11') {
            if (typeof (use_asterisk) != 'undefined' && use_asterisk == true) {
                getObj(dtlView).innerHTML = "<a href=\"javascript:;\" onclick=\"startCall('" + tagValue + "','" + crmId + "')\">" + tagValue + "</a>";
            } else {
                getObj(dtlView).innerHTML = tagValue;
            }
        } else if (uitype == '17') {
            var matchPattern = /^[\w]+:\/\//;
            if (tagValue.match(matchPattern)) {
                getObj(dtlView).innerHTML = "<a href=\"" + tagValue + "\" target=\"_blank\">" + tagValue + "&nbsp;</a>";
            } else {
                getObj(dtlView).innerHTML = "<a href=\"http://" + tagValue + "\" target=\"_blank\">" + tagValue + "&nbsp;</a>";
            }
        } else if (uitype == '85') {
            getObj(dtlView).innerHTML = "<a href=\"skype://" + tagValue + "?call\">" + tagValue + "&nbsp;</a>";
        } else if (uitype == '53') {
            var hdObj = getObj(hdTxt);
            if (typeof (document.DetailView.assigntype[0]) != 'undefined') {
                var assign_type_U = document.DetailView.assigntype[0].checked;
                var assign_type_G = document.DetailView.assigntype[1].checked;
            } else {
                var assign_type_U = document.DetailView.assigntype.checked;
            }
            if (isAdmin == "0") {
                getObj(dtlView).innerHTML = hdObj.value;
            } else if (isAdmin == "1" && assign_type_U == true) {
                //alert(dtlView);
                //alert("<a href=\"index.php?module=Users&action=DetailView&record="+tagValue+"\">"+hdObj.value+"&nbsp;</a>");
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Users&action=DetailView&record=" + tagValue + "\">" + hdObj.value + "&nbsp;</a>";
            } else if (isAdmin == "1" && assign_type_G == true) {

                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Settings&action=GroupDetailView&groupId=" + tagValue + "\">" + hdObj.value + "&nbsp;</a>";
            }
        } else if (uitype == '52' || uitype == '77') {
            if (isAdmin == "1")
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Users&action=DetailView&record=" + tagValue + "\">" + document.getElementById(txtBox).options[document.getElementById(txtBox).selectedIndex].text + "&nbsp;</a>";
            else
                getObj(dtlView).innerHTML = document.getElementById(txtBox).options[document.getElementById(txtBox).selectedIndex].text;
        } else if (uitype == '56' || uitype == '156') {
            if (tagValue == '1') {
                ld("#" + popupobj.divid + " [name=" + dtlView + "]").html(arrJsPopLabel['YES']);
                //getObj(dtlView).innerHTML = arrJsPopLabel['YES'];
            } else {
                ld("#" + popupobj.divid + " [name=" + dtlView + "]").html(arrJsPopLabel['NO']);
                //	getObj(dtlView).innerHTML = arrJsPopLabel['NO'];
            }

        } else if (uitype == 116 || uitype == 117) {
            getObj(dtlView).innerHTML = document.getElementById(txtBox).options[document.getElementById(txtBox).selectedIndex].text;
        } else if (getObj(popupTxt)) {
            var popObj = getObj(popupTxt);
            if (uitype == '50' || uitype == '73' || uitype == '51') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Accounts&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '57') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Contacts&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '59') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Products&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '75' || uitype == '81') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Vendors&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";

            } else if (uitype == '76') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Potentials&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '78') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=Quotes&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '80') {
                getObj(dtlView).innerHTML = "<a href=\"index.php?module=SalesOrder&action=DetailView&record=" + tagValue + "\">" + popObj.value + "&nbsp;</a>";
            } else if (uitype == '53') {

                var hdObj = getObj(hdTxt);
                if (isAdmin == "0") {
                    getObj(dtlView).innerHTML = hdObj.value;
                } else if (isAdmin == "1") {
                    getObj(dtlView).innerHTML = "<a href=\"index.php?module=Users&action=DetailView&record=" + tagValue + "\">" + hdObj.value + "&nbsp;</a>";
                    ;
                }
            } else if (uitype == '56' || uitype == '156') {
                if (tagValue == '1') {
                    getObj(dtlView).innerHTML = arrJsPopLabel['YES'];
                } else {
                    getObj(dtlView).innerHTML = "";
                }

            } else {
                getObj(dtlView).innerHTML = popObj.value;
            }
        } else if (uitype == 153)//服务回访单-》原服务人员
        {
            tagValue = ld("#" + popupobj.divid + " [name=" + txtBox + "]").find("option:selected").text();
            getObj(dtlView).innerHTML = get_converted_html(tagValue);
        } else if (uitype == '15' || uitype == '16' || uitype == '31' || uitype == '32') {
            var popupobj = CrmPopup.getPopupObj("last");
            // var notaccess =document.getElementById(txtBox);
            //tagValue = notaccess.options[notaccess.selectedIndex].text;
            tagValue = ld("#" + popupobj.divid + " [name=" + txtBox + "]").val();
            getObj(dtlView).innerHTML = get_converted_html(tagValue);
        } else if (uitype == '33') {
            /* Wordwrap a long list of multi-select combo box items at the
                     * item separator string */
            var DETAILVIEW_WORDWRAP_WIDTH = "70"; // must match value in DetailViewUI.tpl.

            var lineLength = 0;
            for (var i = 0; i < notaccess_label.length; i++) {
                lineLength += notaccess_label[i].length + 2; // + 2 for item separator string
                /*if(lineLength > DETAILVIEW_WORDWRAP_WIDTH && i > 0) {
                        lineLength = notaccess_label[i].length + 2; // reset.
                        notaccess_label[i] = '<br/>&nbsp;' + notaccess_label[i]; // prepend newline.
                }*/

                notaccess_label[i] = get_converted_html(notaccess_label[i]);
                // Prevent a browser splitting multiword items:
                //notaccess_label[i] = notaccess_label[i].replace(/ /g, '&nbsp;');
                //17920: 所有模块>明细：字段类型为多选框时，小编辑按钮失效。
                //notaccess_label[i] = notaccess_label[i].replace(alert_arr.LBL_NOT_ACCESSIBLE,"<font color='red'>"+alert_arr.LBL_NOT_ACCESSIBLE+"</font>"); // for Not accessible label.
            }
            /* Join items with item separator string (which must match string in DetailViewUI.tpl,
             * EditViewUtils.php and CRMEntity.php)!!
             */
            getObj(dtlView).innerHTML = notaccess_label.join(", ");
        } else if (uitype == '19') {
            var desc = tagValue.replace(/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/g, "$1<a href=\"$2\" target=\"_blank\">$2</a>");
            desc = desc.replace(/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/g, "$1<a href=\"http://$2\" target=\"_blank\">$2</a>");
            desc = desc.replace(/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i, "$1<a href=\"mailto:$2@$3\">$2@$3</a>");
            desc = desc.replace(/,\"|\.\"|\)\"|\)\.\"|\.\)\"/, "\"");
            desc = desc.replace(/[\n\r]+/g, "<br>");
            //	getObj(dtlView).innerHTML = desc;
            ld("#" + popupobj.divid + " [name=" + dtlView + "]").html(desc);
        } else if (uitype == '1103') {
            //wyt 220819 BUG0055324 联系人的QQ字段，初始状态为空，点击小编辑进行录入，保存之后是没有图标的，重新打开单据，就可以看到QQ的图标
            var str = paymentstatus;
            str += ' <a style="display:block;float:left;" href="tencent://message/?uin={$keyval}&Menu=yes"  target="blank"> <img border="0" src=\'./themes/icon/qqenable.jpg\' width="20" height="20" style="margin-left:5px;"/></a>'
            getObj(dtlView).innerHTML = str;
        } else if (uitype == '71' || uitype == '72') {
            //详情页 货币类型 小编辑保存，千分位格式化
            ld("#" + popupobj.divid + " [name=" + dtlView + "]").html(tagValue.toString().replace(/(\d{1,3})(?=(\d{3})+(?:$|\.))/g, '$1,'));
        } else {
			//zkt 20231102 BUG0074911 kfbcrm-销售订单-单据详情-小编辑“汇率”字段，该字段设置的小数位数为6位，小编辑后小数位数不显示
            if(popupobj.dtlViewAjaxSave.retValue != ''){
                tagValue = popupobj.dtlViewAjaxSave.retValue;
            }
            ld("#" + popupobj.divid + " [name=" + dtlView + "]").html(tagValue.replace(/[\n\r]+/g, "<br>"));
            //getObj(dtlView).innerHTML = tagValue.replace(/[\n\r]+/g, "<br>");
        }
        //cmb_span_optiontext_rating
        // console.log(ld("#" + popupobj.divid + " [name=cmb_span_optiontext_" + txtBox + "]").css('color'));
        ld("#" + popupobj.divid + " [name=" + dtlView + "]").css('color', ld("#" + popupobj.divid + " [name=cmb_span_optiontext_" + txtBox + "]").css('color'));

        if (document.getElementById('callbutlername') != undefined) {
            saveCall(module, crmId);
        }
    })
    //UpdateProjectInfo(crmId);//项目计划模块小编辑状态字段时反写项目模块"已完成项目计划数"字段。
}
dtlViewAjaxSave.uitype=0;
dtlViewAjaxSave.module='';
dtlViewAjaxSave.crmid=0;
dtlViewAjaxSave.tagValue='';
dtlViewAjaxSave.retValue='';

dtlViewAjaxSave.afterOperation=function (fieldname)
{
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.dtlViewAjaxSave.module=='')
    {
        popupobj.dtlViewAjaxSave.module=gVTModule;
    }
  //026384: 设置允许编辑自己单据的手机字段，客户明细界面小编辑手机号后，必须刷新才受隐藏样式的控制和短信图标
   if(popupobj.dtlViewAjaxSave.uitype==1101)
   {
        var results=popupobj.dtlViewAjaxSave.retValue.split("##mobile##");
        var tagValue=trim(results[1]);
        if(tagValue=='##mobile##')
        {
            tagValue='';
            
        }
        var str='<i id="'+popupobj.dtlViewAjaxSave.module+'_img_'+fieldname+'" class="ld-fonticon ld-fonticon-phone" ';
        str+=' onclick="getMassSmsPopup(\''+tagValue+'\')"></i>';
        str+=' <i class="callcenterImg ld-fonticon ld-fonticon-phone" key_tablename="ld_accountscf" tag="'+fieldname+'" keyval="'+tagValue+'" style="display:none;"></i>';
        var dtlView = "dtlview_"+ fieldname;
        var ismbile = 1;
		if(ld('#'+fieldname+'_ismobile') != undefined){
			ismbile = ld('#'+fieldname+'_ismobile').val();
		}
        if(tagValue!='' && ismbile == 2)
        {
             getObj(dtlView).innerHTML = tagValue+str;
        }
        else
        {
            getObj(dtlView).innerHTML = tagValue;
        }
        //hjz 保存过程中需要重新刷新界面，先把颜色拿出来再保存
        var fieldvaluecolor = ld('#'+popupobj.divid+' [fieldname='+fieldname+']').css('color');
        if(fieldvaluecolor != ''){
            ld(getObj(dtlView)).css('color',fieldvaluecolor);
        }
        IsFrameElement();
   }
}
/*
*diony
*20141031
*呼叫中心界面小编辑
*/
function saveCall(module,crmId)
{
    var callbutlername=trim(document.getElementById('callbutlername').value);
    var callButlerRemarks=document.getElementById('txtbox_CallButlerRemarks').value;
    ldAjaxHtmlNoProgress('index.php?',"module=Users&action=SaveCall&crmid="+crmId+"&modulename="+module+"&callbutlername="+callbutlername+"&callButlerRemarks="+callButlerRemarks,function(response)
    {
        var results = response.split('&#&#&#');
        ld("#delayaccount_form_div").get(0).innerHTML=results[1];
        fnvshobj(obj, divid);
    });
}



function SaveTag(tagfield,crmId,module)
{
	var tagValue = ld(tagfield).get(0).value;
	tagValue = encodeURIComponent(tagValue);
	ld("#vtbusy_info").get(0).style.display="inline";
    ldAjaxHtmlNoProgress('index.php?',"file=TagCloud&module=" + module + "&action=" + module + "Ajax&recordid=" + crmId + "&ajxaction=SAVETAG&tagfields=" +tagValue,function(response) {
        if(response.indexOf(":#:FAILURE") > -1)
        {
            RemindsMsg("","LdPopWidth400px","","yes","yes",alert_arr.VALID_DATA);
        }else{
            getObj('tagfields').innerHTML = response;
            ld(tagfield).get(0).value = '';
        }
        ld("#vtbusy_info").get(0).style.display="none";
    });
    
}
function setSelectValue(fieldLabel)
{
    var popupobj=CrmPopup.getPopupObj('last');
	if(popupobj.globaluitype == 53)
	{
		if(typeof(document.DetailView.assigntype[0]) != 'undefined')
		{
			var assign_type_U = document.DetailView.assigntype[0].checked;
			var assign_type_G = document.DetailView.assigntype[1].checked;
			if(assign_type_U == true)
				var selCombo= 'txtbox_U'+fieldLabel;
			else if(assign_type_G == true)	
				var selCombo= 'txtbox_G'+fieldLabel;
		}else
		{
			var selCombo= 'txtbox_U'+fieldLabel;
		}
	}else
	{
			//var selCombo= 'txtbox_'+fieldLabel;
            var selCombo=fieldLabel;
	}
	var hdTxtBox = 'hdtxt_'+fieldLabel;
	var oHdTxtBox =ld("#"+popupobj.divid+" [name="+hdTxtBox+']').get(0);//  document.getElementById(hdTxtBox);
	var oSelCombo =ld("#"+popupobj.divid+" [name="+selCombo+']').get(0);// document.getElementById(selCombo);

	oHdTxtBox.value = oSelCombo.options[oSelCombo.selectedIndex].text;
}

//Added to ajax edit the folder name in Documents Module
function hndMouseClick(fieldLabel)
{
    var popupobj=CrmPopup.getPopupObj('last');
	var mouseArea="";
	mouseArea="mouseArea_"+ fieldLabel;
	if(itsonview)
	{
		return;
	}
	popupobj.globaldtlviewspanid= "dtlview_"+ fieldLabel;//valuespanid;
	popupobj.globaleditareaspanid="editarea_"+ fieldLabel;//textareapanid;
	popupobj.globalfieldlabel = fieldLabel;
	//popupobj.globaltxtboxid="txtbox_"+ fieldLabel;//textboxpanid;
    popupobj.globaltxtboxid= fieldLabel;//textboxpanid;
	$(popupobj.globaltxtboxid).value = $(globaldtlviewspanid).innerHTML;
	handleEdit();
	$(popupobj.globaltxtboxid).select();

}
/*editor:gyq date:20180125 reason:运单编号快递100查询*/
function express_no_query(obj){
    var detailviewpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    var company= trim(ld('#'+detailviewpopupobj.divid+ ' #dtlview_express_company').text());
    var express_no= trim(ld('#'+detailviewpopupobj.divid+ ' #dtlview_express_no').text());
    var tmpwidth= CrmPopup.getClientWidth() * 0.4;
    var tmpheight = CrmPopup.getClientHeight()*0.6;
    var headtitle =
        '<div class="flex_between">' +
        '<strong class="E_ptita" style="max-width: 815px;">' +
        '<span class="detail-header-title tip-items-list bindtip" data-tip="快递公司" data-direction="bottom" data-type="position">'+ company + '</span>' +
        '</strong> ' +
        '<strong class="E_ptita" style="max-width: 815px;">' +
        '<span class="detail-header-title tip-items-list bindtip" data-tip="快递单编号" data-direction="bottom" data-type="position">'+ express_no + '</span>' +
        '</strong> ' +
        '</div>';
    var urlstring = 'module='+detailviewpopupobj.module+'&action='+detailviewpopupobj.module+'Ajax&file=getExpress100Info&company='+company+'&express_no='+express_no;
    ldAjax('index.php?',urlstring,function(data){       //调用ldAjax.js里的方法,第三个参数为一个函数,用来验证是否走到后台,code值在后台返回为1,所以后台返回时code为1,加上alert,代表走到了后台
        if (data.code === 2){
            OpenNewWebTab("https://www.kuaidi100.com/chaxun?&nu="+express_no);
        }else if (data.code === -1){
            RemindsMsg("","LdPopWidth400px","","yes","",data.result.returnMessage);
        }
        else if(data.code === 1){                //触发刷新修改日志界面的点击事件
            var  popupobj= CrmPopup.load(headtitle,cancelCrmPopup,"",tmpwidth,"","",arrJsPopLabel['LBL_CLOSE'],"","");
            popupobj.prevshow();
            popupobj.createScrollDiv();
            popupobj.setHeight(tmpheight);
            popupobj.show(data.result.content);
            popupobj.center();
        }
        DelProgressObjs();    //去除加载圆圈
    });
}
var xhr;
function createXMLHttpRequest()
{
	if(window.ActiveXObject)
	{
		xhr = new ActiveXObject("Microsoft.XMLHTTP");
	}
	else if(window.XMLHttpRequest)
	{
		xhr = new XMLHttpRequest();
	}
}

//@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片(单据详情页点击个人头像编辑)
function upload_image(filename,module,recordid){ //filename  实则就是固定值imagename
    var fileObj = document.getElementById(""+filename+"").files[0];
    var filepath = ld('#'+filename).val();
    var extStart = filepath.lastIndexOf(".");
    var ext = filepath.substring(extStart, filepath.length).toUpperCase();
    var ext_arr = [".JPG",".GIF",".BMP",".PNG",".JPEG"];
    if(ld.inArray(ext, ext_arr) < 0 || fileObj == undefined){
        var confirm_str = arrJsPopLabel['PLEASESELECTFOLLOWINGEXTENSIONS']+'\n'+'jpg、gif、bmp、png、JPG、GIF、BMP、PNG';
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var formData = new FormData();
    formData.append("file",ld('#'+filename)[0].files[0]);
    formData.append("frommodule", module);
    formData.append("name", CrmPopup.getHtmlobjval(divid, filename + "_hidden"));

    var surl = 'index.php?module=Users&action=UsersAjax&file=File_Upload&frommodule='+module;
    //zkt 20231012 XUQIU1001341 登录记住密码优化+SQL注入
    surl= cls_encryptyurl.Puyoung_EncryptyFileurl(surl,formData);
    ld.ajax({
        url:surl,
        dataType:'json',
        type:'POST',
        async: false,
        data: formData,
        processData : false, // 使数据不做处理
        contentType : false, // 不要设置Content-Type请求头
        success: function(data){
            // console.log(data);
            if (data.success == true) {
                // 用不着给页面复制再去取值，这种赋值后页面input框value值始终为空，但是获取值是ok的，说明动态赋值成功只是没有显示出来。
                /*CrmPopup.setHtmlobjval(divid,filename+'-file_size_1',data.fileSize);
                CrmPopup.setHtmlobjval(divid,filename+'-file_name_1',data.oldName);
                CrmPopup.setHtmlobjval(divid,filename+'-file_path_1',data.filePaht);
                CrmPopup.setHtmlobjval(divid,filename+'-file_type_1',data.fileType);
                CrmPopup.setHtmlobjval(divid,filename+'-file_newfile_name_1',data.newfile_name);
                CrmPopup.setHtmlobjval(divid,filename+'-storage_location_1','local');*/

                var htmlurl = "";
                htmlurl += "&" + filename + "-file_name_1=" + encodeURIComponent(data.oldName);
                htmlurl += "&" + filename + "-file_type_1=" + data.fileType;
                htmlurl += "&" + filename + "-file_size_1=" + data.fileSize;
                htmlurl += "&" + filename + "-file_path_1=" + data.filePaht;
                htmlurl += "&" + filename + "-newfile_name_1=" + encodeURIComponent(data.newfile_name);
                htmlurl += "&" + filename + "-upload_from_1=" + encodeURIComponent( '');
                htmlurl += "&" + filename + "-storage_location_1=" + encodeURIComponent('local');
                htmlurl += "&" + filename + "-isEncrypt_1=" + data.isEncrypt;
                htmlurl += "&" + filename + "-file_num=1&"+filename+"&-attachmentcolumnname="+filename;

                var formData1 = new FormData();
                formData1.append("myfile",ld('#'+filename)[0].files[0]);
                var surl1 = 'index.php?module=Users&action=UsersAjax&file=upload_image&module='+module+'&record='+recordid+'&filename='+filename+htmlurl;
                //zkt 20231012 XUQIU1001341 登录记住密码优化+SQL注入
                surl1= cls_encryptyurl.Puyoung_Encryptyurl(surl1,formData1);
                ld.ajax({
                    url:surl1,
                    dataType:'json',
                    type:'POST',
                    async: false,
                    data: formData1,
                    processData : false, // 使数据不做处理
                    contentType : false, // 不要设置Content-Type请求头
                    success: function(data1){
                        if (data1.code == 1) {
                            hndCancel('dtlview_'+filename+'','editarea_'+filename+'',''+filename+'');
                            // hndCancel('dtlview_imagename','editarea_imagename','imagename');
                            var file_html = '<a style=" border:0px solid #000; width:250px; height:100px;" href="'+data1.result.file+'" target="_blank"><img class="userpicture" style="width:50%;" src="'+data1.result.file+'" title="diony" border="0"></a>';
                            ld('#dtlview_'+filename).html(file_html);
                            ld('#oamenubar .user-icon').css("background-image","url(" + data1.result.file + ")" ); //右上角头像动态更新

                            //更新列表界面的头像
                            var tmparra = new Array();
                            // tmparra.push(popupobj.record);
                            var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data1, tmparra);
                            tmpobj.eachrefreshlistbyModules(new Array(popupobj.module));
                        }else{
                            console.log('-1');
                        }

                    },
                    error:function(response){
                        console.log('error');
                    }
                });
            }else{
                console.log('-1');
            }

        },
        error:function(response){
            console.log('error');
        }
    });

}
/*function upload_image(filename,module,recordid){
	var fileObj = document.getElementById(""+filename+"").files[0];
	var filepath = ld('#'+filename).val();
	var extStart = filepath.lastIndexOf(".");
    var ext = filepath.substring(extStart, filepath.length).toUpperCase();
	var ext_arr = [".JPG",".GIF",".BMP",".PNG",".JPEG"];
	if(ld.inArray(ext, ext_arr) < 0 || fileObj == undefined){
		var confirm_str = arrJsPopLabel['PLEASESELECTFOLLOWINGEXTENSIONS']+'\n'+'jpg、gif、bmp、png、JPG、GIF、BMP、PNG';
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	var FileController = 'index.php?module=Users&action=UsersAjax&file=upload_image&module='+module+'&record='+recordid+'&filename='+filename;
	var form = new FormData();
	form.append("myfile", fileObj);
	createXMLHttpRequest();
	xhr.onreadystatechange = handleStateChange;
	xhr.open("post", FileController, true);
	xhr.send(form);
}*/

function handleStateChange()
{
	if(xhr.readyState == 4)
	{
		if (xhr.status == 200 || xhr.status == 0)
		{
			var result = xhr.responseText;
			var json = eval("(" + result + ")");
			hndCancel('dtlview_'+json.filename+'','editarea_'+json.filename+'',''+json.filename+'');
			var file_html = '<a style=" border:0px solid #000; width:250px; height:100px;" href="'+json.file+'" target="_blank"><img class="userpicture" style="width:50%;" src="'+json.file+'" title="diony" border="0"></a>';
			ld('#dtlview_'+json.filename).html(file_html);
		}
	}
}


function approveretraceOperation()
{
    //提交审批增加“回撤”功能
    // var popupobj=CrmPopup.getPopupObj("last");
    //BUG0067605 liushuai 20230606 出库单-提交审批单据-相关信息栏点击别的模块-回撤，弹出“该单据审批步骤已变化，请重新加载该单据！”的提示信息，回撤不了(popup.module错误)
    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    var alert_str = arrJsPopLabel['RETRACENotsubmitted'];
     RemindsMsg("","LdPopWidth400px",popupobj.module,"yes","yes",alert_str);
     var url = 'index.php?module=Approve&frommodule='+popupobj.module+'&action=ApproveAjax&file=RetractApprove&id='+popupobj.record;
    
     ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		 ldAjax(url,"",function(data){
			if(data.code == 1){
				var tmparra=new Array();
				tmparra.push(popupobj.record);
               
				var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,getEmptyValueInfo(),tmparra);
				
				tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);
                tmpobj.eachrefreshlistbyModules(data.result.refreshdetailmodules);
                //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
                
                ModelDataBindobj.setButtonName='approve_retrace';
                ModelDataBindobj.setpropertyname='approvesavebutton';
                DelProgressObjs();

                workflowCallApiPop(data.result);//工作流API弹窗
			}else{
				RemindsMsg("","LdPopWidth400px",popupobj.module,"yes","yes",data.msg);
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					//window.location.reload();    
				});
                DelProgressObjs();
				return false;
			}
		 })
               
       
     });
}

/*
             */
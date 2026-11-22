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
function splitValues(object) {
	var picklistObj=object;
	var pickListContent=picklistObj.value
	var pickListAry=new Array()
	var i=0;

	//Splitting up of Values
	if (pickListContent.indexOf("\n")!=-1) {
		while(pickListContent.length>0) {
			if(pickListContent.indexOf("\n")!=-1) {
				if (pickListContent.replace(/^\s+/g, '').replace(/\s+$/g, '').length>0) {
					pickListAry[i]=pickListContent.substr(0,pickListContent.indexOf("\n")).replace(/^\s+/g, '').replace(/\s+$/g, '')
					pickListContent=pickListContent.substr(pickListContent.indexOf("\n")+1,pickListContent.length)
					i++
				} else break;
			} else {
				pickListAry[i]=pickListContent.substr(0,pickListContent.length)
				break;
			}
		}
	} else if (pickListContent.replace(/^\s+/g, '').replace(/\s+$/g, '').length>0) {
		pickListAry[0]=pickListContent.replace(/^\s+/g, '').replace(/\s+$/g, '')
	}

	return pickListAry;
}


function validate(blockid) {
    var nummaxlength = 255;
	var fieldtype = document.getElementById('selectedfieldtype_'+blockid).value;
	var mode = document.getElementById('cfedit_mode').value;
    var errornumlength=document.getElementById('fldLength_'+blockid).value; //获取自定义字段输入的字符长度
        
	if(fieldtype == "" && mode != 'edit')
	{
	    var confirm_str = arrJsPopLabel['NOTSELECTEDFIELDTYPE'];
	    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    
    if(document.getElementById('fldLabels_'+blockid)!=undefined && document.getElementById('fldLabels_'+blockid) !=''){
	   var fieldtypes = document.getElementById('fldLabels_'+blockid).value;
      
    	if(fieldtypes == "" && mode != 'edit')
    	{
    		var confirm_str = arrJsPopLabel['LABELNAMENOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    		return false;
    	}

		var tmp_regex = /[\[\]'"]/;//BUG0072594 xxy 2023-10-20 页面设置，新增/编辑字段属性界面，若中文标签或英文标签填写内容含有特殊字符保存时，增加提示信息“标签中含有特殊字符，不允许保存”
		if(tmp_regex.test(fieldtypes))
        {
            var confirm_str = arrJsPopLabel['LabelContainSpecialCannotSave'];
			MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
    }
	lengthLayer=document.getElementById("lengthdetails_"+blockid)
	decimalLayer=document.getElementById("decimaldetails_"+blockid)
	var pickListLayer=document.getElementById("fldPickList_"+blockid);
	var fldlbl = document.getElementById("fldLabel_"+blockid);
   
    
	
 
	//if (!emptyCheck("fldLabel_"+blockid,arrJsPopLabel['TAG'],"text"))
	//	return false
/*	var re2=/[&\<\>\:\'\"\,\_]/
	if (re2.test(str))
	{
	    var confirm = arrJsPopLabel['SPECIALCHARACTERS']+" & < > ' \" : , _ "+arrJsPopLabel['PLEASETRYOTHERVALUES'];
		getJsScript('include/js/ListViewButton.js',function(){
			RemindsMsg('',confirm,'','yes');         
		});
		return false;
	}*/
    
    //Liver 2016-11-17,加判断自定义字段字符长度是否数字和不包含小数点
    var r2= /^[1-9]?[0-9]*\.[0-9]*$/;
    if(isNaN((errornumlength)) || r2.test(errornumlength)){
        var confirm_str = arrJsPopLabel['INVALID']+" "+arrJsPopLabel['ZIDUANLENGTH'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }

	var fieldlength = document.getElementById('fldLength_'+blockid);
	if (lengthLayer != null && lengthLayer.style.visibility=="visible") {
		if (!emptyCheck('fldLength_'+blockid,arrJsPopLabel['LENGTH']))
			return false
      
		if (!intValidate('fldLength_'+blockid,arrJsPopLabel['LENGTH']))
			return false

		if (!numConstComp('fldLength_'+blockid,arrJsPopLabel['LENGTH'],"G",0))
			return false
           

	}
	if ((fieldtype ==1) && document.getElementById('fldDecimal_'+blockid) != null && document.getElementById('fldDecimal_'+blockid) != undefined) {
		var fieldtypes = document.getElementById('fldDecimal_'+blockid).value;
    	if(fieldtypes == "" && mode != 'edit')
    	{
	    	var confirm_str = arrJsPopLabel['DECIMALCANNOTBEEMPTY'];
	    	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
    		return false;
    	}
        if (document.getElementById("fldDecimal_"+blockid).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length>0)
			if (!intValidate("fldDecimal_"+blockid,"Decimal"))
				return false;
		if (!numConstComp("fldDecimal_"+blockid,"Decimal","GE",0))
			return false;

		if (!numConstComp("fldDecimal_"+blockid,"Decimal","LE",30))
			return false;
	}

	var decimallength = '';
	if (document.getElementById('fldDecimal_'+blockid) != null && document.getElementById('fldDecimal_'+blockid) != undefined)
		decimallength = document.getElementById("fldDecimal_"+blockid).value;
        
	if(fieldValueArr[fieldtype] == 'Percent' || fieldValueArr[fieldtype] == 'Currency' || fieldValueArr[fieldtype] == 'Number')
	{
		if(decimallength == '')
			decimallength = 0;
		nummaxlength = 65 - (eval(decimallength) + 1);
	}
	var lengthObj = document.getElementById("lengthdetails_"+blockid);
	if ( lengthObj != null && lengthObj.style.visibility == "visible" && !numConstComp('fldLength_'+blockid,"Length","LE",nummaxlength))
		return false
   if(fieldValueArr[fieldtype].toLowerCase()=='picklist'||fieldValueArr[fieldtype].toLowerCase()=='multipicklist')
	{
        	/* var picklistObj=document.getElementById("fldPickList_"+blockid)
        	if (pickListLayer != null && getObj("picklistdetails_"+blockid).style.visibility=="visible") {
        		var pickListAry=new Array();
        		pickListAry=splitValues(pickListLayer);
        		if (emptyCheck("fldPickList_"+blockid,arrJsPopLabel['PickList']))        {
        
        			//Empty Check validation
        			for (i=0;i<pickListAry.length;i++) {
        				if (pickListAry[i]=="") {
        					var confirm_str = arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY'];
        					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        					picklistObj.focus();
        					return false
        				}
        			}
        
        			//Duplicate Values' Validation
        			for (i=0;i<pickListAry.length;i++) {
        				for (j=i+1;j<pickListAry.length;j++) {
        					if (trim(pickListAry[i].toUpperCase())== trim(pickListAry[j].toUpperCase())) {
        						var confirm_str = arrJsPopLabel['DUPLICATE_VALUES_FOUND'];
        						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        						picklistObj.focus();
        						return false
        					}
        				}
        			}
        
        		
        			return true
        		} else return false
        	}  */
            
    }
	return true;
}
var fieldValueArr = new Array('Text','Number','Percent','Currency','Date','Email','Phone','Picklist','URL','Checkbox','TextArea','MultiPickList','Skype','Time','DateTime','Mobile','Fax','QQ','LongTextArea','HandWriting',"relatedmodulefield",'reference','fileattachment','selectoneuser','selectmultiuser','qrcode','memberdepartment','richtext','signin','picture','express','MultiReference');
var fieldTypeArr = new Array('text','number','percent','currency','date','email','phone','picklist','url','checkbox','textarea','multipicklist','skype','time','datetime','mobile','rfax','qq','longtextarea','handwriting',"relatedmodulefield",'reference','fileattachment','selectoneuser','selectmultiuser','qrcode','memberdepartment','richtext','signin','picture','express','multireference');
var currFieldIdx=0,totFieldType;
var focusFieldType;

/*function init() {
        lengthLayer=getObj("lengthdetails")
        decimalLayer=getObj("decimaldetails")
        pickListLayer=getObj("picklist")
        totFieldType=fieldTypeArr.length-1
}*/


function setVisible() {
	if (focusFieldType==true) {
		var selFieldType=fieldLayer.getObj("field"+currFieldIdx)
		var height=findPosY(selFieldType)+selFieldType.offsetHeight

		if (currFieldIdx==0) {
			fieldLayer.document.body.scrollTop=0
		} else if (height>220) {
			fieldLayer.document.body.scrollTop+=height-220
		} else {
			fieldLayer.document.body.scrollTop-=220-height
		}

		if (window.navigator.appName.toUpperCase()=="OPERA") {
			var newDiv=fieldLayer.document.createElement("DIV")
			newDiv.style.zIndex="-1"
			newDiv.style.position="absolute"
			newDiv.style.top=findPosY(selFieldType)+"px"
			newDiv.style.left="25px"

			var newObj=fieldLayer.document.createElement("INPUT")
			newObj.type="text"

			fieldLayer.document.body.appendChild(newDiv)
			newDiv.appendChild(newObj)
			newObj.focus()

			fieldLayer.document.body.removeChild(newDiv)
		}
	}
}
function selFieldHtmlNone(blockid)
{
        var fieldtype=document.getElementById("tr_fieldtype_"+blockid);//字段类型(引用对象)
        var relatedmodule=document.getElementById("tr_relatedmodule_"+blockid);//(引用对象)
        var referencemodulefield=document.getElementById("tr_relatedmodulefield_"+blockid);//引用字段
        // var tr_activate_field=document.getElementById("tr_activate_field_"+blockid);//启用
        var tr_savedatabase=document.getElementById("tr_savedatabase_"+blockid);//保存到数据库
        var tr_allowedit=document.getElementById("tr_allowedit_"+blockid);//允许编辑
        // var tr_requiredfield=document.getElementById("tr_requiredfield_"+blockid);//必填字段
        // var tr_quickcreate=document.getElementById("tr_quickcreate_"+blockid);//快速创建

        var lengthLayer=document.getElementById("lengthdetails_"+blockid);
    	var decimalLayer=document.getElementById("decimaldetails_"+blockid);
    	var pickListLayer=document.getElementById("picklistdetails_"+blockid);
    	var allow_rewriting = document.getElementById("allow_rewriting_"+blockid);
		//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
    	var tr_memberrangetype = document.getElementById("tr_memberrangetype_"+blockid);
    	var memberrangedetails_All = document.getElementById("memberrangedetails_All_"+blockid);
		var memberrangedetails_Person = document.getElementById("memberrangedetails_Person_"+blockid);
		var memberrangedetails_Departments = document.getElementById("memberrangedetails_Departments_"+blockid);
    	var memberrangedetails_Roles = document.getElementById("memberrangedetails_Roles_"+blockid);
    	var memberrangedetails_Position = document.getElementById("memberrangedetails_Position_"+blockid);
    	var tr_showallgroupstructure_edit = document.getElementById("tr_showallgroupstructure_edit"+blockid);

    	decimalLayer.style.display="none";
		pickListLayer.style.display="none";
		allow_rewriting.style.display="none";
        fieldtype.style.display="none";
        relatedmodule.style.display="none";
        referencemodulefield.style.display="none";
        //tr_activate_field.style.display="none";
        tr_savedatabase.style.display='none';
        tr_allowedit.style.display='none';
		tr_memberrangetype.style.display='none';

	    memberrangedetails_All.style.display='none';
		memberrangedetails_Person.style.display='none';
		memberrangedetails_Departments.style.display='none';
		memberrangedetails_Roles.style.display='none';
		memberrangedetails_Position.style.display='none';
		tr_showallgroupstructure_edit.style.display='none';
      //  tr_requiredfield.style.display='none';
       // tr_quickcreate.style.display='none'; //@edit:liushuai,2020-12-28,reason: 页面设置，字段属性界面去掉【快速创建】一行【style="display: none;"】
		ld("#tr_disallowed_copy_"+blockid).css('display','')
		ld("#disallowed_copy_"+blockid).prop('checked',false);
		ld("#tr_auto_wordwrap_"+blockid).css('display','')
		ld("#auto_wordwrap_"+blockid).prop('checked',false);
		ld("#tr_helptips_"+blockid).css('display','')

        document.getElementById("tr_approvedemand_"+blockid).style.display='none';
        document.getElementById("tr_referencemodule_"+blockid).style.display='none';
		document.getElementById("tr_multireferencemodule_"+blockid).style.display='none';
        document.getElementById("tr_datarang_"+blockid).style.display="none";
        document.getElementById("tr_maxrowsshow_"+blockid).style.display="none";
        document.getElementById("tr_defaultvalue_"+blockid).style.display="";
        //document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
        //document.getElementById("tr_notallowduplicate_"+blockid).style.display="none";

        //document.getElementById("tr_massedit_"+blockid).style.display="none";

 	    document.getElementById("lengthdetails_"+blockid).style.display="none";
		 // wym 230804 BUG0070636 原来写的remove不能删去属性，只能删去元素。删去属性的jq方法是removeAttr
        ld("#defaultvalue_"+blockid+"_name").removeAttr('disabled');
        ld("#defaultvalue_"+blockid+"_name").css('cursor','');
        ld("#defaultchoose_btn").css("display",'none');
        ld("#defaultclear_btn").css("display",'none');
        document.getElementById("defaultvalue_"+blockid+"_chkbox").style.display="none";
        document.getElementById("defaultvalue_"+blockid+"_picklist").style.display='none';
        document.getElementById("defaultvalue_"+blockid+"_textarea").style.display='none';
        var popupobj=CrmPopup.getPopupObj('last');
        //下拉框默认值对象隐藏
         ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("display",'none');
         //日期时间  @edit:liushuai,2021-03-24,reason: 45065: 系统设置-页面设置，新增字段，先选择“日期时间”类型字段，再选择“文本”字段，日期时间类型的默认值没有隐藏。
		ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_date]").css("display",'none');
         //下拉多选隐藏
         ld("#defaultvalue_"+blockid+"_multipicklist").css("display",'none');
        ld("#defaultvalue_"+blockid+"_multipicklist").next().css("display",'none');
        document.getElementById("defaultvalue_"+blockid+"_date").style.display="none";

        document.getElementById("defaultchoose_btn_"+blockid).style.display='none';
		document.getElementById("defaultchoose_btn_"+blockid+"_multiple").style.display='none';
        document.getElementById("defaultclear_btn_"+blockid).style.display='none';
        document.getElementById("defaultvalue_"+blockid+"_name").style.width='90%';

	ld("#inputModeType_"+blockid).attr('disabled',false);

}
function selFieldType(id,scrollLayer,bool,blockid) {
	var popupobj=CrmPopup.getPopupObj('last'),
		PopupJqObj = ld(`#${popupobj.divid}`);
    selFieldHtmlNone(blockid);
    document.getElementById("tr_allowedit_"+blockid).style.display="";//BUG20240731-29 240801 允许编辑属性放开(路总)
    document.getElementById("tr_notallowduplicate_"+blockid).style.display="";
    document.getElementById("tr_massedit_"+blockid).style.display="";
    document.getElementById("defaultvalue_"+blockid+"_name").style.display="";
    document.getElementById("tr_requiredfield_"+blockid).style.display="";
    document.getElementById("tr_take_photo_only_check_"+blockid).style.display="none";
    //zxm 2021-04-08  二维码字段类型
	document.getElementById("codetype_"+blockid).style.display="none";
	document.getElementById("contentset_"+blockid).style.display="none";
	document.getElementById("tr_uploadwatermark_check_"+blockid).style.display="none";
	document.getElementById("tr_selectmemberfield_"+blockid).style.display="none";
	document.getElementById("tr_auto_signin_"+blockid).style.display="none";
	document.getElementById("tr_allowable_distance_"+blockid).style.display="none";

    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
    document.getElementById("tr_ShowHyperlinks_"+blockid).style.display="none";

	document.getElementById("tr_editview_signin_"+blockid).style.display="none";
	document.getElementById("tr_editview_resignin_"+blockid).style.display="none";

	//hzx 是否计算小计
	document.getElementById("tr_subtotalattr_"+blockid).style.display="none";
	document.getElementById("tr_auto_wordwrap_"+blockid).style.display="none";
	document.getElementById("tr_helptips_"+blockid).style.display="none";

	//edit: xll 2024/07/08 XUQIU20240628-14 附件、图片的条件预览、下载
	var setArr = ['FileAllowed'];// ['DownloadAllowed','PreviewAllowed'];
	ld.each(setArr,function (i,v) {
		PopupJqObj.find(`#tr_${v}_${blockid}`).css("display","none");
	})

	var valueFormatRow = PopupJqObj.find(`#tr_value_format_${blockid}`);
	//edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
	valueFormatRow.css("display","none");


	currFieldIdx = id;
	var type = fieldTypeArr[id];
	var lengthLayer = document.getElementById("lengthdetails_"+blockid);
	var decimalLayer = document.getElementById("decimaldetails_"+blockid);
	var pickListLayer = document.getElementById("picklistdetails_"+blockid);
	var allow_rewriting = document.getElementById("allow_rewriting_"+blockid);
    document.getElementById("fieldType_"+blockid).value = type;
    ld("#notallowduplicate_"+blockid).attr("disabled",false);
    //zkt 20221012 BUG0057564新增字段文本类型，可勾选必填，当更改类型为引用字段，再更改为原来的文本字段，不可勾选必填
    ld("#requiredfield_"+blockid).attr('disabled',false);
	ld("#allowedit_"+blockid).attr("disabled",false);
    ld("#tr_regexp_"+blockid).css('display','none');//启用正则验证（手机字段)
    ld("#regexp_"+blockid).prop("checked",false);
    ld("#tr_massedit_"+blockid).css('display','');
	// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）  新增字段添加提示"移动端内容无法复制"
	ld(" [name=mobilecontextnotcopy]").css('display','none');
	ld('#tr_word_watermark_'+blockid).css('display','none');
	ld('#tr_excel_watermark_'+blockid).css('display','none');
	ld("#inputModeType_"+blockid+" option").css("display","");//字段公式隐藏
	ld('#sqlContentDiv_'+blockid+' #definitionsqlformula_spantext').show();
	ld('#sqlContentDiv_'+blockid+' #definitionsqlformula_spanoneuser').hide();
	document.getElementById("sensitive_rule_"+blockid).style.display="none";//xxy 2023-11-8 敏感规则
	if(type == 'qq' || type == 'email' || type == 'currency' || type=='mobile'||type=='phone'||type=='number'||type=='text'||type=='textarea'||type=='longtextarea'){
		document.getElementById("sensitive_rule_"+blockid).style.display="";
	}
	if(type != 'signin' && type != 'fileattachment' && type != 'picture' && type != 'qrcode' && type != 'handwriting'){//xxy 2023-11-14 自动换行属性
		ld("#tr_auto_wordwrap_"+blockid).css('display','');
		if(type=='textarea' || type=='longtextarea'){
			ld("#auto_wordwrap_"+blockid).prop("checked",true);
		}
	}
	// 帮助信息
	if(type != 'signin'){
		ld("#tr_helptips_"+blockid).css('display','');
	} 

	//新增字段，应控制勾选了“不允许重复”后就不允许勾选“批量编辑”
	ld("#massedit_"+blockid).unbind("click").bind("click",function(){
		if(ld(this).prop("checked")) {
			ld("#notallowduplicate_"+blockid).attr("disabled",true);
			ld("#notallowduplicate_"+blockid).prop("checked",false);
		} else {
			ld("#notallowduplicate_"+blockid).attr("disabled",false);
		}
	});
	ld("#notallowduplicate_"+blockid).unbind("click").bind("click",function(){
		if(ld(this).prop("checked")) {
			ld("#massedit_"+blockid).attr("disabled",true);
			ld("#massedit_"+blockid).prop("checked",false);
		} else {
			ld("#massedit_"+blockid).attr("disabled",false);
		}
	});
    if(type=='mobile'||type=='phone'||type=='fax')
    {
        ld("#tr_massedit_"+blockid).css('display','none');
        if(type=='mobile')
        {
            ld("#tr_regexp_"+blockid).css('display','');
            ld("#regexp_"+blockid).prop("checked",false);
        }
    }
	if (type=='text') {
		//selFieldHtmlNone(blockid);
		lengthLayer.style.display="";
	}
    else if (type=='textarea') {
		document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
        document.getElementById("defaultvalue_"+blockid+"_textarea").style.display="";
	}
    else if (type=='longtextarea') {
		document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
        document.getElementById("defaultvalue_"+blockid+"_textarea").style.display="block";
	}
    else if(type=='checkbox')
    {
        document.getElementById("tr_notallowduplicate_"+blockid).style.display="none";
        document.getElementById("tr_requiredfield_"+blockid).style.display="none";
		document.getElementById("tr_multireferencemodule_"+blockid).style.display="none";
        //document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
        document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
        document.getElementById("defaultvalue_"+blockid+"_chkbox").style.display="";
    }
	else if(type == 'signin'){
    	document.getElementById("tr_auto_signin_"+blockid).style.display="";
		document.getElementById("tr_allowable_distance_"+blockid).style.display="";
		document.getElementById("tr_editview_signin_"+blockid).style.display="";
		document.getElementById("tr_editview_resignin_"+blockid).style.display="";
		document.getElementById("tr_notallowduplicate_"+blockid).style.display="none";
		document.getElementById("tr_massedit_"+blockid).style.display="none";
		document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
		ld("#tr_disallowed_copy_"+blockid).css('display','none');// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）

	}
    else if (type=='date'  || type=='time' || type=='datetime' ) {
		//chj 2021/1/14 43203: （61mis.com/kfbtest）系统设置-页面设置-客户（需要补丁）；在客户页面设置新增时间字段，保存后编辑打开该字段查看，默认值显示1
		if(type == 'time'){
			document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
		}else{
			document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
			document.getElementById("defaultvalue_"+blockid+"_date").style.display="";
			var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+blockid+"_date");
			cls_resetComboxHtmlobj.setComboxObjHtml();
			ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_date]").css("display",'block');
			ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_date]").css("position",'absolute');
		}
		// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
		ld("#disallowed_copy_"+blockid).prop("checked",true);//内容不允许复制
		ld("#inputModeType_"+blockid+" option[value=0]").css("selected","selected");//字段公式隐藏
		ld("#inputModeType_"+blockid+" option[value=2]").css("display","none");//字段公式隐藏

		// edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
		valueFormatRow.css("display","");
		var valueFormatSel = valueFormatRow.find(`#value_format_${blockid}`),
			tipObj = valueFormatRow.find(`#value_format_${blockid}_tip`),
			valueFormat = valueFormatSel.val(),
			timeFormatArr = getTimeFormatArr(),
			optionArr = timeFormatArr.options[type],
			tip = timeFormatArr.tips[type];
		if(optionArr && !optionArr.some(v => v.value === valueFormat)) {
			tipObj.attr('data-tip', getVarJsPop('TimeFieldHeplTip1',[tip])+' <br> '+ getVarJsPop('TimeFieldHeplTip2',[tip]));
			tooltip(tipObj, {transition: true, time: 200});
			var option = '',
				exampleObj = valueFormatRow.find(`#value_format_${blockid}_example`);
			ld.each(optionArr, function (index, info) {
				option += `<option value="${info.value}">${info.label}</option>`;
			})
			valueFormatSel.html(option);
			valueFormatSel.prop('selectedIndex', 0);
			exampleObj.find('span').html(optionArr[0].example);
			valueFormatSel.unbind('change').bind('change', function () {
				var selIndex = ld(this).prop('selectedIndex'),
					example = optionArr[selIndex].example;
				exampleObj.find('span').html(example);
			})
			var cls_resetComboxHtmlobj = new cls_resetComboxHtml(`value_format_${blockid}`);
			cls_resetComboxHtmlobj.setComboxObjHtml();
		}
	}
	else if (type=='number') {
    	selFieldHtmlNone(blockid);
    	//lengthLayer.style.display="";
    	decimalLayer.style.display="";
		ld("#tr_subtotalattr_"+blockid).css('display','');
		ld("#tr_subtotalattr_"+blockid).prop('checked',true);
	}
	else if(type == 'currency'){
		ld("#tr_subtotalattr_"+blockid).css('display','');
		ld("#tr_subtotalattr_"+blockid).prop('checked',true);
	}
    else if (type=='picklist' || type=='multipicklist') {
	    selFieldHtmlNone(blockid);
		pickListLayer.style.display="";//下拉框列表
		document.getElementById("defaultvalue_"+blockid+"_picklist").style.display='none';
		document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
		// @edit:liushuai,2021-07-16,reason:0046951: （https://81mis.com/kfbcrm/ [^]）系统设置->页面设置->客户->页面设置，新增“多选框”，下拉框列表值出现了两个框。
		ld("#fldpicklist_"+blockid).empty();
		ld("#fldpicklist_"+blockid).nextAll().remove();//清除多余框(多次【点击新增字段，字段类型为多选框时】，下拉框列表值输入框会有之前的框和值)
        //',', ';', '，', '；', ' '
		ld("#fldpicklist_"+blockid).select2({tags:true,width:'90%'
			,closeOnSelect: true
			//,tokenSeparators:['']
			,minimumResultsForSearch: Infinity
			// ,minimumInputLength:1
			/*,createTag: function(params) {
            	if (/[,;，； ]/.test(params.term)) {//支持【逗号】【分号】【空格】结尾生成tags
					var str = ld.trim(params.term);//.replace(/[,;，；]*$/, '');
					return { id: str, text: str,newTag: true }
				} else {
					return null;
				}
			}*/
        });
         /*
        ld(document).on('keyup', ld("#fldpicklist_"+blockid).next().find(" .select2-search__field"), function(event){

                        if(event.keyCode == 13){

                    		var $this = ld("#fldpicklist_"+blockid).next().find(" .select2-search__field");
                    		var optionText =$this.val();

                    		//如果没有就添加
                    		if(optionText != "" && $this.find("option[value='" + optionText + "']").length === 0){
                    			//我还不知道怎么优雅的定位到input对应的select
                                if (ld("#fldpicklist_"+blockid).find("option[value='" + optionText + "']").length) {

                                    ld("#fldpicklist_"+blockid).val(optionText).trigger('change');
                                   return ;
                                }
                    			var $select = $this.parents('.select2-container').prev("select");
                    			var newOption = new Option(optionText, optionText, true, true);
                    			$select.append(newOption).trigger('change');
                    			$this.val('');

                                ld("#fldpicklist_"+blockid).next().find(" .select2-search__field").focus();
                                ld(" .select2-results").remove();
                    		}
                    	}
            });
            */
		ld("#fldpicklist_"+blockid).select2("val", " ");
		ld("#fldpicklist_"+blockid).on("change", function (e)  {
			var select2obj=ld("#fldpicklist_"+blockid).select2('data');
			if(type=='multipicklist')
				{
                    ld("#defaultvalue_"+blockid+"_multipicklist").empty();
                    ld.each(select2obj,function(index,info){
						var text=info.text;
						ld("#defaultvalue_"+blockid+"_multipicklist").append("<option value='"+text+"'>"+text+'</option>');
                    });
			 	}
			 	else
			 	{
					ld("#defaultvalue_"+blockid+"_picklist").empty();
				 	ld("#defaultvalue_"+blockid+"_picklist").append("<option value=''></option>");
                    ld.each(select2obj,function(index,info){
						var text=info.text;
						ld("#defaultvalue_"+blockid+"_picklist").append("<option value='"+text+"'>"+text+'</option>');
                    });
                    //修改下拉框的样式
				 	var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+blockid+"_picklist");
				   	cls_resetComboxHtmlobj.setComboxObjHtml();

				  	// ld(" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("position",'block');
				   	ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("display",'block');
				   	ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("position",'absolute');
			 	}
	  		});
	 	if(type=='multipicklist')
	 	{
			ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("display",'none');
			ld("#defaultvalue_"+blockid+"_multipicklist").css("display",'');
		   	//  ld("#defaultvalue_"+blockid+"_multipicklist").next().css("display",'');
			ld("#defaultvalue_"+blockid+"_multipicklist").select2({width:'90%',closeOnSelect: true});
	 	}
	 	else
	 	{
			// ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("display",'');
		 	var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+blockid+"_picklist");
			cls_resetComboxHtmlobj.setComboxObjHtml();
			ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("display",'block');
			ld("#"+popupobj.divid+" [name=dv_cmb_defaultvalue_"+blockid+"_picklist]").css("position",'absolute');
	 	}
	}
	else if(type == 'handwriting'){
	 	selFieldHtmlNone(blockid);
		allow_rewriting.style.display="";
        ld("#tr_defaultvalue_"+blockid).css('display','none');
		ld("#tr_notallowduplicate_"+blockid).css('display','none');
		ld("#tr_massedit_"+blockid).css('display','none');
		ld("#tr_requiredfield_"+blockid).css('display','none');
		ld("#tr_disallowed_copy_"+blockid).css('display','none');
		ld("#tr_auto_wordwrap_"+blockid).css('display','none');
	}
    else if(type=='relatedmodulefield')
    {
      	//  document.getElementById("defaultvalue_"+blockid+"_name").style.display="none";
        //  引用对象
	 	selFieldHtmlNone(blockid);
        ld("#tr_defaultvalue_"+blockid).css('display','none');
	  	var fieldtype=document.getElementById("tr_fieldtype_"+blockid);//字段类型(引用对象)
        var relatedmodule=document.getElementById("tr_relatedmodule_"+blockid);//(引用对象)
        var referencemodulefield=document.getElementById("tr_relatedmodulefield_"+blockid);//引用字段
        var tr_activate_field=document.getElementById("tr_activate_field_"+blockid);//启用
        var tr_savedatabase=document.getElementById("tr_savedatabase_"+blockid);//保存到数据库
        var tr_allowedit=document.getElementById("tr_allowedit_"+blockid);//允许编辑
        var tr_requiredfield=document.getElementById("tr_requiredfield_"+blockid);//必填字段
        var tr_quickcreate=document.getElementById("tr_quickcreate_"+blockid);//快速创建
        // fieldtype.style.display="";

		ld("#tr_disallowed_copy_"+blockid).css('display','none');// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
        relatedmodule.style.display="";
        referencemodulefield.style.display="";
        tr_activate_field.style.display="";
        tr_activate_field.checked=true;
        tr_savedatabase.style.display='';
        tr_allowedit.style.display='';
        tr_requiredfield.style.display='';
        // tr_quickcreate.style.display='';
        ld("#activate_field_"+blockid).prop("checked",true);
        ld("#quickcreate_"+blockid).prop("checked",true);
        ld("#allowedit_"+blockid).attr("disabled",true);
        ld("#requiredfield_"+blockid).attr("disabled",true);
        ld("#requiredfield_"+blockid).prop("checked",false);
        ld("#notallowduplicate_"+blockid).prop("checked",false);
        ld("#notallowduplicate_"+blockid).attr("disabled",true);
        //date:2021-9-9 edit:duan reason:【ID1002003】自定义字段，“引用字段”字段类型，“保存到数据库”字段属性默认勾选
        ld("#savedatabase_"+blockid).prop("checked",true);
		if(ld("#relatedmodule_"+blockid).val()!='Users'){
			ld("#allowedit_"+blockid).attr("disabled",false);
		}
		ld("#inputModeType_"+blockid).attr('disabled',true);//引用字段默认没有高级属性。

        ld("#savedatabase_"+blockid).unbind("click").bind("click",function(){
			if(ld(this).prop("checked"))
			{
				//wym XUQIU1000290 页面设置，引用成员管理字段永远不允许编辑
				if(ld("#relatedmodule_"+blockid).val()!='Users'){
					ld("#allowedit_"+blockid).attr("disabled",false);
				}
			}
			else
			{
				ld("#allowedit_"+blockid).attr("disabled",true);
				ld("#requiredfield_"+blockid).attr('disabled',true);
				ld("#allowedit_"+blockid).prop("checked",false);
				ld("#requiredfield_"+blockid).prop("checked",false);
			}
        });
        ld("#allowedit_"+blockid).unbind("click").bind("click",function(){
            if(ld(this).prop("checked"))
            {
                ld("#requiredfield_"+blockid).attr("disabled",false);
                ld("#requiredfield_"+blockid).attr("disabled",false);
                ld("#notallowduplicate_"+blockid).attr("disabled",false);


            }
            else
            {
                ld("#requiredfield_"+blockid).attr('disabled',true);
                ld("#requiredfield_"+blockid).prop("checked",false);
			 	ld("#notallowduplicate_"+blockid).attr("disabled",true);
			 	ld("#notallowduplicate_"+blockid).removeAttr("checked");
			 	ld("#notallowduplicate_"+blockid).prop("checked",false);

			 	ld("#requiredfield_"+blockid).removeAttr("checked");
                ld("#requiredfield_"+blockid).prop("checked",false);

                ld("#requiredfield_"+blockid).attr("disabled",true);
            }
        })
        getReferencemoduleField(document.getElementById("relatedmodule_"+blockid),blockid,'');
        document.getElementById("tr_massedit_"+blockid).style.display="none";

	 	setTimeout(function(){
			ld(" [name=dv_cmb_relatedmodulefield_"+blockid+"]").css("display",'block');
	 	// ld(" [name=dv_cmb_relatedmodulefield_"+blockid+"]").css("position",'absolute');
	 	ld(" [name=dv_cmb_relatedmodulefield_"+blockid+"]").css("top",'205px');
	 	},200)
    }
    else if(type=='reference')
    {
        selFieldHtmlNone(blockid);
	 	ld("#activate_field_"+blockid).prop("checked",true);
        ld("#quickcreate_"+blockid).prop("checked",true);
      	// ld("#allowedit_"+blockid).attr("disabled",false);
        ld("#requiredfield_"+blockid).attr("disabled",false);
        document.getElementById("tr_activate_field_"+blockid).style.display='';

        document.getElementById("tr_requiredfield_"+blockid).style.display='';//必填字段
		// @edit:liushuai,2020-12-28,reason: 页面设置，字段属性界面去掉【快速创建】一行
        // document.getElementById("tr_quickcreate_"+blockid).style.display='';//快速创建

        document.getElementById("tr_referencemodule_"+blockid).style.display='';
        document.getElementById("tr_datarang_"+blockid).style.display="";
		//wym 路总说数据范围默认选项改为“有数据权限的”
		document.getElementById("datarange_"+blockid).selectedIndex=1;
        document.getElementById("tr_maxrowsshow_"+blockid).style.display="";
        document.getElementById("tr_defaultvalue_"+blockid).style.display="";
        document.getElementById("tr_notallowduplicate_"+blockid).style.display="";
        document.getElementById("tr_notallowduplicate_"+blockid).style.display="";
        document.getElementById("tr_approvedemand_"+blockid).style.display="";
        
        //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
        document.getElementById("tr_ShowHyperlinks_"+blockid).style.display="";
        
        var name='referencemodule_'+blockid;
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
        cls_resetComboxHtmlobj.setComboxObjHtml();//修改下拉框样式

	  	ld(" [name=dv_cmb_referencemodule_"+blockid+"]").css("display",'block');
	  	ld(" [name=dv_cmb_referencemodule_"+blockid+"]").css("position",'absolute');
        ld("#defaultvalue_"+blockid+"_name").val('');
        ld("#defaultvalue_"+blockid+"_name").attr('disabled','disabled');
        ld("#defaultvalue_"+blockid+"_name").css('cursor','not-allowed');
         
        ld("#defaultchoose_btn").css("display",'');
        ld("#defaultclear_btn").css("display",'');
	  	document.getElementById("defaultchoose_btn_"+blockid).style.display='';
	 	document.getElementById("defaultclear_btn_"+blockid).style.display='';
	 	document.getElementById("defaultvalue_"+blockid+"_name").style.width='70%';
    }
	else if(type=='multireference'){
		//wym 多选关联字段
		selFieldHtmlNone(blockid);
		ld("#activate_field_"+blockid).prop("checked",true);
		ld("#quickcreate_"+blockid).prop("checked",true);
		ld("#requiredfield_"+blockid).attr("disabled",false);
		document.getElementById("tr_activate_field_"+blockid).style.display='';
		document.getElementById("tr_multireferencemodule_"+blockid).style.display='';
		document.getElementById("tr_datarang_"+blockid).style.display="";
		document.getElementById("datarange_"+blockid).selectedIndex=1;
		document.getElementById("tr_maxrowsshow_"+blockid).style.display="";
		document.getElementById("tr_defaultvalue_"+blockid).style.display="";
		document.getElementById("defaultchoose_btn_"+blockid).style.display="none";
		document.getElementById("defaultchoose_btn_"+blockid+"_multiple").style.display="";
		document.getElementById("tr_notallowduplicate_"+blockid).style.display="";
		document.getElementById("tr_notallowduplicate_"+blockid).style.display="";
		document.getElementById("tr_approvedemand_"+blockid).style.display="";
		document.getElementById("tr_ShowHyperlinks_"+blockid).style.display="";

		var name='multireferencemodule_'+blockid;
		var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
		cls_resetComboxHtmlobj.setComboxObjHtml();//修改下拉框样式
		ld(" [name=dv_cmb_multireferencemodule_"+blockid).css("display",'block');
		ld(" [name=dv_cmb_multireferencemodule_"+blockid).css("position",'absolute');
		ld("#defaultvalue_"+blockid+"_name").val('');
		ld("#defaultvalue_"+blockid+"_name").attr('disabled','disabled');
		ld("#defaultvalue_"+blockid+"_name").css('cursor','not-allowed');

		ld("#defaultchoose_btn").css("display",'');
		ld("#defaultclear_btn").css("display",'');
		document.getElementById("defaultclear_btn_"+blockid).style.display='';
		document.getElementById("defaultvalue_"+blockid+"_name").style.width='70%';

	}
	else if(type == 'fileattachment' || type == 'picture'){	//附件、图片
		document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
		document.getElementById("tr_notallowduplicate_"+blockid).style.display="none";
		document.getElementById("tr_massedit_"+blockid).style.display="none";
		if (iskehu001 != "yes" && ld("#isOpenSignIn").val() == "yes") {
			document.getElementById("tr_uploadwatermark_check_"+blockid).style.display="";
		}
		document.getElementById("tr_take_photo_only_check_"+blockid).style.display="";
		// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）  新增字段添加提示"移动端内容无法复制"
		ld(" [name=mobilecontextnotcopy]").css('display','');
		if (type == 'fileattachment'){
			var uploadFileobj = new WebUploadFile();
			var WaterMarkWebUploadType=uploadFileobj.uploadType();
			if (WaterMarkWebUploadType != 'cos'){
				ld('#tr_word_watermark_'+blockid).css('display','');
				ld('#tr_excel_watermark_'+blockid).css('display','');
			}
		}

		//edit: xll 2024/07/08 XUQIU20240628-14 附件、图片的条件预览、下载
		ld.each(setArr,function (i,v) {
			PopupJqObj.find(`#tr_${v}_${blockid}`).css("display","");
			// 根据按钮启用状态，显示"设置条件"
			ld(`input#${v}_${blockid}`).siblings('a').css('display', ld(`input#${v}_${blockid}`).prop('checked') ? '' : 'none');
		})

	}
	else if(type == 'qrcode'){
		//zxm 2021-0410 二维码字段类型
		document.getElementById("tr_defaultvalue_"+blockid).style.display="none";
		document.getElementById("tr_notallowduplicate_"+blockid).style.display="none";
		document.getElementById("tr_requiredfield_"+blockid).style.display="none";
		document.getElementById("tr_massedit_"+blockid).style.display="none";
		document.getElementById("codetype_"+blockid).style.display="";
		document.getElementById("contentset_"+blockid).style.display="";
		ld("#tr_disallowed_copy_"+blockid).css('display','none');// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）

	}
	else if(type == 'memberdepartment'){//成员所属部门
		// ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）
		ld("#tr_defaultvalue_"+blockid).css('display','none');
		ld("#tr_allowedit_"+blockid).css('display','');
		ld("#tr_massedit_"+blockid).css('display','none');
		ld("#tr_selectmemberfield_"+blockid).css('display','');
		ld("#allowedit_"+blockid).attr("disabled",true);
		ld("#notallowduplicate_"+blockid).attr("disabled",true);
		ld("#requiredfield_"+blockid).attr("disabled",true);
		var cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectmemberfield_'+blockid);
		cls_resetComboxHtmlobj.setComboxObjHtml();//修改下拉框样式
		ld("#tr_disallowed_copy_"+blockid).css('display','none');// // ljj 20230901 BUG0072027 kfbcrm-成员所属部门字段 去掉“内容不允许复制”参数
	}
	else if(type == 'selectoneuser'){
    	ld('#sqlContentDiv_'+blockid+' #definitionsqlformula_spantext').hide();
		ld('#sqlContentDiv_'+blockid+' #definitionsqlformula_spanoneuser').show();
	}

}

function srchFieldType(ev) {
	if (browser_ie) {
		var keyCode=window.fieldLayer.event.keyCode
		var currElement=window.fieldLayer.event.srcElement
		if (currElement.id.indexOf("field")>=0) var doSearch=true
		else var doSearch=false
		window.fieldLayer.event.cancelBubble=true
	} else if (browser_nn4 || browser_nn6) {
		var keyCode=ev.which
		var currElement=ev.target
		if (currElement.type) doSearch=false
		else doSearch=true
	}

	if (doSearch==true) {
		switch (keyCode) {
			case 9  : //Reset Field Type
				resetFieldTypeHilite();
				break;
			case 33 : //Page Up
			case 36 : //Home
				selFieldType(0);
				break;
			case 34 : //Page Down
			case 35 : //End
				selFieldType(totFieldType);
				break;
			case 38 : //Up
				if (currFieldIdx!=0)
					selFieldType(currFieldIdx-1);
				else
					selFieldType(totFieldType,"yes");
				break;
			case 40 : //Down
				if (currFieldIdx!=totFieldType)
					selFieldType(currFieldIdx+1);
				else
					selFieldType(0,"yes");
			default : //Character Search
				if (keyCode>=65 && keyCode<=90) {
					var srchChar=String.fromCharCode(keyCode)
					if (currFieldIdx==totFieldType) var startIdx=0
					else var startIdx=currFieldIdx+1

					var loop=1
					for (i=startIdx;i<=totFieldType;) {
						currFieldStr=fieldLayer.getObj("field"+i).innerHTML
						currFieldStr=currFieldStr.replace(/^\s+/g, '').replace(/\s+$/g, '').substr(0,1)
						if (currFieldStr==srchChar) {
							selFieldType(i,"yes")
							i++
						} else if (i==totFieldType && loop<=2) {
							i=0
							loop++
						} else i++
					}
				}
		}
	}
}
function resetFieldTypeHilite() {
	fieldLayer.getObj("field"+currFieldIdx).className="fieldType sel"
}
function validateCustomFieldAccounts()
{
	var obj=document.getElementsByTagName("SELECT");
	var i,j=0,k=0,l=0;
	var n=obj.length;
	account = new Array;
	contact =  new Array;
	potential = new Array;
	for( i = 0; i < n; i++)
	{
		if(obj[i].name.indexOf("_account")>0)
		{
			account[j]=obj[i].value;
			j++;
		}
		if(obj[i].name.indexOf("_contact")>0)
		{
			contact[k]=obj[i].value;
			k++;
		}
		if(obj[i].name.indexOf("_potential")>0)
		{
			potential[l]=obj[i].value;
			l++;
		}
	}
	for( i = 0; i < account.length; i++)
	{
		for(j=i+1; j<account.length; j++)
		{
			if( account[i] == account[j] && account[i]!="None" && account[j] !="None")
			{
				var confirm_str = alert_arr.DUPLICATE_MAPPING_ACCOUNTS;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}
	for( i = 0; i < contact.length; i++)
	{
		for(k=i+1; k< contact.length; k++)
		{
			if( contact[i] == contact[k] && contact[i]!="None" && contact[k]!="None")
			{
				var confirm_str = alert_arr.DUPLICATE_MAPPING_CONTACTS;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}
	for( i = 0; i < potential.length; i++)
	{
		for(l=i+1; l<potential.length; l++)
		{
			if( potential[i] == potential[l] && potential[i]!="None" && potential[l]!="None")
			{
				var confirm_str = alert_arr.DUPLICATE_MAPPING_POTENTIAL;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}

	}
}


function gotourl(url)
{
	document.location.href=url;
}

function validateTypeforCFMapping(leadtype,leadtypeofdata,type,typeofdata,field_name,cf_form)
{
	var alertmessage = new Array(alert_arr.LBL_TYPEALERT_1,alert_arr.LBL_WITH,alert_arr.LBL_TYPEALERT_2,alert_arr.LBL_LENGTHALERT,alert_arr.LBL_DECIMALALERT,alert_arr.LBL_MAPPEDALERT);
	var combo_val = cf_form.options[cf_form.selectedIndex].value;
	if(combo_val != '')
	{
		if(leadtype == type)
		{
			if(leadtypeofdata == typeofdata)
			{
				return true;
			}
			else
			{
				var lead_tod = leadtypeofdata.split("~");
				var tod = typeofdata.split("~");
				switch (lead_tod[0]) {
					case "V"  :
						if(lead_tod[3] <= tod[3])
							return true;
						else
						{
							RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[3]);
							document.getElementById(field_name).value = '';
							return false;
						}
						break;
					case "N"  :
						if(lead_tod[2].indexOf(",")>0)
						{
							var lead_dec = lead_tod[2].split(",");
							var dec = tod[2].split(",");
						
						}
						else
						{
							var lead_dec = lead_tod[2].split("~");
							var dec = tod[2].split("~");
						}
						if(lead_dec[0] <= dec[0])
						{
							if(lead_dec[1] <= dec[1])
								return true;
							else
							{
								RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[4]);
								document.getElementById(field_name).value = '';
								return false;
							}
						}
						else
						{
							RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[3]);
							document.getElementById(field_name).value = '';
							return false;
						}
						break;
				}	
			}
		}
		else
		{
			var confirm_str = alertmessage[0]+" "+leadtype+" "+alertmessage[1]+" "+type+" "+alertmessage[2];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			document.getElementById(field_name).value = '';
			return false;
		}
	}
}

function cloneAndAddLeadMapping(nodeid,tableid){
	var mapTable=document.getElementById('mapTable');
	var mapBody=mapTable.getElementsByTagName("tbody")[0];
	newTR=document.createElement('tr');
	newRow=mapBody.appendChild(newTR);
	newRow.style.visibility="visible";
	
	snoHTML=document.getElementById("snoDiv").innerHTML;
	snoHTML=snoHTML.replace(/incId/g,incId);
	newCell=newRow.appendChild(document.createElement('td'));
	newCell.innerHTML=snoHTML;
	newCell.style.visibility="visible";

	leadHTML=document.getElementById('leadCloneDiv').innerHTML;
	leadHTML=leadHTML.replace(/leadClone/g, 'map['+incId+'][Leads]');
	leadHTML=leadHTML.replace(/incId/g,incId);
	newCell=newRow.appendChild(document.createElement('td'));
	newCell.innerHTML=leadHTML;
	newCell.style.visibility="visible";

	accHTML=document.getElementById('accountCloneDiv').innerHTML;
	accHTML=accHTML.replace(/accountClone/g, 'map['+incId+'][Accounts]');
	accHTML=accHTML.replace(/incId/g,incId);
	newCell=newRow.appendChild(document.createElement('td'));
	newCell.innerHTML=accHTML;
	newCell.style.visibility="visible";

	conHTML=document.getElementById('contactCloneDiv').innerHTML;
	conHTML=conHTML.replace(/contactClone/g, 'map['+incId+'][Contacts]');
	conHTML=conHTML.replace(/incId/g,incId);
	newCell=newRow.appendChild(document.createElement('td'));
	newCell.innerHTML=conHTML;
	newCell.style.visibility="visible";

	potHTML=document.getElementById('potentialCloneDiv').innerHTML;
	potHTML=potHTML.replace(/potentialClone/g, 'map['+incId+'][Potentials]');
	potHTML=potHTML.replace(/incId/g,incId);
	newCell=newRow.appendChild(document.createElement('td'));
	newCell.innerHTML=potHTML;
	newCell.style.visibility="visible";

	document.getElementById('map['+incId+'][Leads]').focus();

	++incId;

}

function validateMapping(id,chngSelect,field_id){
	var alertmessage = new Array(alert_arr.LBL_TYPEALERT_1,alert_arr.LBL_WITH,alert_arr.LBL_TYPEALERT_2,alert_arr.LBL_LENGTHALERT,alert_arr.LBL_DECIMALALERT,alert_arr.LBL_MAPPEDALERT);
	leadf=document.getElementById('map['+id+'][Leads]');
	accountf=document.getElementById('map['+id+'][Accounts]');
	contactf=document.getElementById('map['+id+'][Contacts]');
	potentialf=document.getElementById('map['+id+'][Potentials]');

	leadDataType=leadf.options[leadf.selectedIndex].getAttribute('typeofdata');
	accountDataType=accountf.options[accountf.selectedIndex].getAttribute('typeofdata');
	contactDataType=contactf.options[contactf.selectedIndex].getAttribute('typeofdata');
	potentialDataType=potentialf.options[potentialf.selectedIndex].getAttribute('typeofdata');

	leadType=leadf.options[leadf.selectedIndex].getAttribute('fieldtype');
	accountType=accountf.options[accountf.selectedIndex].getAttribute('fieldtype');
	contactType=contactf.options[contactf.selectedIndex].getAttribute('fieldtype');
	potentialType=potentialf.options[potentialf.selectedIndex].getAttribute('fieldtype');

	if(chngSelect.options[chngSelect.selectedIndex].value!=''){
		switch(chngSelect.getAttribute('module')){

			case 'Accounts':
				for(i=1;i<incId;i++){
					if(i==id){
						continue;
					}
					if(document.getElementById('map['+i+'][Accounts]').options[document.getElementById('map['+i+'][Accounts]').selectedIndex].value==document.getElementById('map['+id+'][Accounts]').options[document.getElementById('map['+id+'][Accounts]').selectedIndex].value){
						RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[5]);
						document.getElementById('map['+id+'][Accounts]').value='';
						return false;
					}
				}
				break;
			case 'Contacts':
				for(i=1;i<incId-1;i++){
					if(i==id){
						continue;
					}
					if(document.getElementById('map['+i+'][Contacts]').options[document.getElementById('map['+i+'][Contacts]').selectedIndex].value==document.getElementById('map['+id+'][Contacts]').options[document.getElementById('map['+id+'][Contacts]').selectedIndex].value){
						RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[5]);
						document.getElementById('map['+id+'][Contacts]').value='';
						return false;
					}
				}
				break;
			case 'Potentials':
				for(i=1;i<incId;i++){
					if(i==id){
						continue;
					}
					if(document.getElementById('map['+i+'][Potentials]').options[document.getElementById('map['+i+'][Potentials]').selectedIndex].value==document.getElementById('map['+id+'][Potentials]').options[document.getElementById('map['+id+'][Potentials]').selectedIndex].value){
						RemindsMsg("","LdPopWidth400px","","yes","",alertmessage[5]);
						document.getElementById('map['+id+'][Potentials]').value='';
						return false;
					}
				}
				break;
		}
	}

	var error=false;

	if(validateTypeforCFMapping(leadType,leadDataType,accountType,accountDataType,'map['+id+'][Accounts]',accountf)){
		error=true;
	}
	if(validateTypeforCFMapping(leadType,leadDataType,contactType,contactDataType,'map['+id+'][Contacts]',contactf)){
		error=true;
	}
	if(validateTypeforCFMapping(leadType,leadDataType,potentialType,potentialDataType,'map['+id+'][Potentials]',potentialf)){
		error=true;
	}

	if(error){
		return false;
	}
}
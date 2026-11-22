{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/ *}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/customview.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/PageLayout.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/PageValidata.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/AdvanceRelation.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_advance_process.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Settings/qrcodeTemplate.js"></script>

{*
/**
 *edit:kevin
 *date:2013-07-31
 *reason:4490
 */
 *}

<script language="JavaScript">
var tmpobj=new Object();
tmpobj.module='Settings';
tmpobj.frommodule='{$MODULE}';

var languagetype = '{$LANGUAGETYPE}';
    // tmpobj.divid='dv_layoutblocklist';
     CrmPopup.global_listPopupObj.push(tmpobj);
{literal}

function check(){
	var blocklabel = document.getElementById('blocklabel');
	var val = trim(blocklabel.value);
	if(val == "")
	{
		var confirm_str = arrJsPopLabel['CHINESEBLOCKNAMENOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}

    if(trim(document.getElementById('blocklabel2').value)=='')
    {
        var confirm_str = arrJsPopLabel['ENGLISHBLOCKNAMENOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
    }

	return true;
}
/**
 * 根据uitype判断是否为源单选择字段（200、201、202），如果是，则隐藏批量编辑多选框
 * @reason 0011655 佣金单叙事簿界面：批量编辑弹出层中，选择原单字段下拉框中没有值
 * @param fieldselect Integer 字段对应的fieldid值
 * @param uitype Integer 字段对应的uitype值
 * @author Tujt 2014-09-24
 */

function isuitypedisp(fieldselect,uitype){
	if(uitype == 200 || uitype == 201 || uitype == 202){//选择源单
		if(document.getElementById('massedit_check_'+fieldselect) != undefined){
			document.getElementById('massedit_check_'+fieldselect).checked = false;
			document.getElementById('massedit_check_'+fieldselect).disabled = true;
		}
	}
}

{/literal}


var charlenglabel="{'CHARACTER'|@getFixedLabel}";

function getCustomFieldList(customField)
{ldelim}
	var modulename = customField.options[customField.options.selectedIndex].value;
	$('module_info').innerHTML = '{'CUSTOMFIELDIN'|@getFixedLabel} "'+modulename+'" {'MODULE'|@getFixedLabel}';
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&fld_module='+modulename+'&parenttab=Settings&ajax=true',
		function(response) {ldelim}
			sethtml(document.getElementById('cfList'),response);
			//$("cfList").update(response.responseText);
		{rdelim}
	);
{rdelim}

function changeFieldorder(what_to_do,fieldid,blockid,modulename)
{ldelim}
	$('vtbusy_info').style.display = "block";
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=changeOrder&fld_module='+modulename+'&parenttab=Settings&what_to_do='+what_to_do+'&fieldid='+fieldid+'&blockid='+blockid+'&ajax=true',
		function(response){ldelim}
			sethtml(document.getElementById('cfList'),response);
			//$("cfList").update(response.responseText);
			$('vtbusy_info').style.display = "none";
		{rdelim}
	);
{rdelim}


function changeShowstatus(tabid,blockid,modulename)
{ldelim}
	var display_status = ld('#display_status_'+blockid).val();
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=changeOrder&fld_module='+modulename+'&parenttab=Settings&what_to_do='+display_status+'&tabid='+tabid+'&blockid='+blockid+'&ajax=true',
		function(response) {ldelim}

		{rdelim}
	);
{rdelim}



function changeBlockorder(what_to_do,tabid,blockid,modulename)
{ldelim}
	ldAjaxHtml('index.php','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=changeOrder&fld_module='+modulename+'&parenttab=Settings&what_to_do='+what_to_do+'&tabid='+tabid+'&blockid='+blockid+'&ajax=true',
		function(ajaxhtml) {ldelim}
			sethtml(document.getElementById('cfList'),ajaxhtml);
			DelProgressObjs();
			layoutblockEventClick();
		{rdelim}
	);
{rdelim}



{literal}
function deleteCustomField(id, fld_module, colName, uitype)
{
	var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//点击确定
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		//zsk BUG20240301-13  页面设置-删除字段时，加载动画 没有居中 解决方法：直接删除这个加载动画
        //$('vtbusy_info').style.display = "block";
		ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=deleteCustomField&ajax=true&fld_module='+fld_module+'&fld_id='+id+'&colName='+colName+'&uitype='+uitype,function(ajaxhtml) {
			puyoungJS_DialogBox.unblock();
			sethtml(document.getElementById('cfList'),ajaxhtml);
			gselected_fieldtype = '';
			$('vtbusy_info').style.display = "none";
			var popupobj=CrmPopup.getPopupObj('last');
			layoutblockEventClick();
			popupobj.CancelEvent();
		});
	});

	/*
	ld('input[onclick="msgConfirm()"]').unbind('click').on('click',function(){
		//fninvshnew('editfield_'+id);
	})

	ld('button[onclick="msgConfirm()"]').unbind('click').on('click',function(){
	//	fninvshnew('editfield_'+id);
	})*/
	return false;
}

function deleteCustomBlock(module,blockid,no){
	if(no > 0){
		var confirm_str = arrJsPopLabel['PLEASEMOVEFIELDTOOTERBLACKS'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}else{
		var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			$('vtbusy_info').style.display = "block";
			ldAjaxHtmlNoProgress('index.php','module=Settings&action=SettingsAjax&fld_module='+module+'&file=LayoutBlockList&sub_mode=deleteCustomBlock&ajax=true&blockid='+blockid+"&notip=no",function(ajaxhtml) {
				$('vtbusy_info').style.display = "none";
				if(ajaxhtml.indexOf('error##errror')>=0){
					var results=ajaxhtml.split('error##errror');
					var confirm_str = results[1];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
						ldAjaxHtmlNoProgress('index.php?module=Settings&action=SettingsAjax&fld_module='+module+'&file=LayoutBlockList&sub_mode=deleteCustomBlock&ajax=true&blockid='+blockid
								,{},function(response){


									sethtml(document.getElementById('cfList'),response);
									layoutblockEventClick();
								});
					});
					return false;
				}
				sethtml(document.getElementById('cfList'),ajaxhtml);
				//$("cfList").update(response.responseText);

				layoutblockEventClick();
			});
		});
	}
}

var isblocksave='yes';
function getCreateCustomBlockForm()
{
	var popupobj=CrmPopup.getPopupObj('last');
	var modulename=popupobj.module;
	var mode=popupobj.mode;
    if(isblocksave=='no')
    {
        return false;
    }
    isblocksave='no';
	var checlabel = check();
	if(checlabel == false)
	{
	   isblocksave='yes';
       return false;
	}
	var blocklabel = document.getElementById('blocklabel');
    var blocklabel2 = document.getElementById('blocklabel2');
	var val = trim(blocklabel.value);
    var val2 = trim(blocklabel2.value);
	var blockid = document.getElementById('after_blockid').value;

	// $('status').style.display = "block";
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=addBlock&fld_module='+modulename+'&parenttab=Settings&ajax=true&mode='+mode+'&blocklabel='+
			encodeURIComponent(val)+'&after_blockid='+blockid+'&blocklabel2='+encodeURIComponent(val2),function(ajaxhtml) {
		var str = ajaxhtml;
		isblocksave='yes';
		if(ajaxhtml.indexOf("#error#")>0)
		{
			var strs=ajaxhtml.split("#error#");
			RemindsMsg("","LdPopWidth400px","","yes","yes",strs[0]);
			return false;
		}
		if(str == 'ERROR'){

			var confirm_str = "区块标签不能重复";
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}else if(str == 'LENGTH_ERROR'){
			var confirm_str = arrJsPopLabel['LENGTHSHOULDLESSTHAN50CHAR'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}else{
			sethtml(document.getElementById('cfList'),ajaxhtml);
			//wym 240119 BUG20240119-30 后台设置--页面设置--新增区块弹窗，点击保存后实际新增了区块，但是没有关闭弹窗
			popupobj.CancelEvent();
			//$("cfList").update(str);
		}
		// $('status').style.display = "none";
		fninvshnew('addblock');
		layoutblockEventClick();
		gselected_fieldtype = '';
	});

    return false;
}

function fieldAllowEditClick(jqueryobj,fieldid)
{
    if(ld(jqueryobj).prop("checked"))
    {
        ld("#mandatory_check_"+fieldid).attr('disabled',false);
        ld("#massedit_check_"+fieldid).attr('disabled',false);
		ld("#take_photo_only_check_"+fieldid).attr('disabled',false);

    }
    else
    {
        ld("#mandatory_check_"+fieldid).attr('disabled',true);
        ld("#mandatory_check_"+fieldid).prop('checked',false);
        ld("#massedit_check_"+fieldid).attr('disabled',true);
        ld("#massedit_check_"+fieldid).prop('checked',false);
		//wym BUG0074100
		ld("#take_photo_only_check_"+fieldid).attr('disabled',true);
		ld("#take_photo_only_check_"+fieldid).prop('checked',false);
    }
}

async function saveFieldInfo(fieldid,module,sub_mode,typeofdata,uitype){
	var urlstring = '';
    var defaultvalue ="";//定位
    var popupobj=CrmPopup.getPopupObj("last"),
		popupJqObj = ld(`#${popupobj.divid}`);
	var mandatory_check = $('mandatory_check_'+fieldid);
	var presence_check = $('presence_check_'+fieldid);
	var quickcreate_check = $('quickcreate_check_'+fieldid);
	var massedit_check = $('massedit_check_'+fieldid);
    var fiedonly_check=$('fieldonly_check_'+fieldid);
	var defaultvalue_check = $('defaultvalue_check_'+fieldid);
	var fieldlabel=$('fieldlabel_'+fieldid);
	var fieldlabels=$('fieldlabels_'+fieldid);
    var alloweditobj=ld("#allowdit_"+fieldid);
    // zxm 2021-0408 二维码类型
	var fdcodetype_value = '';
	var qrcodetemplateid = '';

	var formulacontent='';
	var formulavar="";
	var formulacolumn="";
	//签到字段
	var auto_signin = 'no';
	var no_signin = 'no';
	var allowable_distance = 0;
	var editview_signin = 'no';
	var editview_resignin = 'no';
	var subtotal_attr = ld('#subtotalattr_'+fieldid);

	//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
	var memberrangetype=$('memberrangetype_'+fieldid);
	var memberrange='';
	// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
	var word_watermark = 'no';
	var excel_watermark = 'no';
	var helptips = '';

	if(popupobj.bigtype == 'signin'){
		if(ld('#auto_signin_'+fieldid).prop("checked")){
			auto_signin = 'yes';
		}
		if(ld('#no_signin_'+fieldid).prop("checked")){
			no_signin = 'yes';
			allowable_distance = ld('#allowable_distance_'+fieldid).val();
			if(allowable_distance == 'custom'){
				if(ld('#custom_allowable_distance_'+fieldid).val() == ''){
            		RemindsMsg("","LdPopWidth400px","",'yes','yes',arrJsPopLabel['Checkinerrorvaluecannotbeempty']);
            		return false;
            	}else{
            		allowable_distance = ld('#custom_allowable_distance_'+fieldid).val();
            	}
			}
		}
		if(ld("#editview_signin_"+fieldid).prop("checked")){
			editview_signin='yes';
		}
		if(ld("#editview_resignin_"+fieldid).prop("checked")){
			editview_resignin='yes';
		}
	}
	urlstring += '&auto_signin='+auto_signin+'&no_signin='+no_signin+'&allowable_distance='+allowable_distance;
	urlstring += '&editview_signin='+editview_signin+'&editview_resignin='+editview_resignin;
	if(uitype==1500||uitype==1501||uitype==1502){
		fdcodetype_value = ld("#fdcodetype_"+fieldid).val();
		qrcodetemplateid = ld("#qrcodeTemplateEdit").attr('data-templateid')?ld("#qrcodeTemplateEdit").attr('data-templateid'):ld("#qrcodeTemplateCreate").attr('data-templateid');
	}
    if(uitype==1503){
        fdcodetype_value = ld("#fdcodetype_"+fieldid).val();
        qrcodetemplateid = ld("#formqrcodeTemplateEdit").attr('data-templateid')
    }
	//zxm20211230 字段颜色 字段说明
	var labelvaluecolor = ld('#labelvaluecolor_' + fieldid).val(); //wsh 20240815 标签颜色
	var fieldvaluecolor = ld('#fieldvaluecolor_'+fieldid).val();
	var fieldplaceholder = ld('#fieldplaceholder_'+fieldid).val();
    if(fieldplaceholder == undefined){
        fieldplaceholder='';
    }
	urlstring += '&labelvaluecolor='+labelvaluecolor+'&fieldvaluecolor='+fieldvaluecolor+'&fieldplaceholder='+fieldplaceholder;

    var approve_demand=ld('#approve_demand_'+fieldid+' option:selected');
	// @edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮(编辑保存)
    var advance_demand=ld('#advance_demand_'+fieldid);
    var advance_demand_groups=ld('#advance_demand_groups_'+fieldid);
    if(ld("#regexp_"+fieldid).prop("checked"))
            var regexp=1;
    else
             var regexp=0;
    var maxrowsshow=5;
    var datarang='all';
    urlstring+="&regexp="+regexp;

    //ID1001652 “签到地址”字段增加控制签到水印是否显示
	var uploadwatermark = $('uploadwatermark_check_'+fieldid);

	if(approve_demand != null && approve_demand.val() != undefined){
		urlstring = urlstring+'&approve_demand=' + approve_demand.val();
	}else{
		urlstring = urlstring+'&approve_demand=2';
	}
	if(advance_demand != null && advance_demand.val() != undefined){
		urlstring = urlstring+'&advance_demand=' + advance_demand.val();
	}else{
		urlstring = urlstring+'&advance_demand=';
	}
	if(advance_demand_groups != null && advance_demand_groups.val() != undefined){
		urlstring = urlstring+'&advance_demand_groups=' + advance_demand_groups.val();
	}else{
		urlstring = urlstring+'&advance_demand_groups=';
	}
	if(mandatory_check != null){
		urlstring = urlstring+'&ismandatory=' + mandatory_check.checked;
        //zkt 20230517 BUG0066344 kfbcrm-项目立项-页面设置-快速创建-1.必填字段没有自动被勾选到已选字段里； //现在必填字段默认为快速创建已选字段里面
        if(mandatory_check.checked == true){
            urlstring = urlstring + '&quickcreate=' + true;
        }
        else{
            //zkt 20230526 BUG0066970 kfbcrm 付款单---页面设置--编辑 选择源单 ---保存没反应 
            if(quickcreate_check != null){            
                urlstring = urlstring + '&quickcreate=' + quickcreate_check.checked;
            }
        }
	}
	if(presence_check != null){
		urlstring = urlstring + '&isPresent=' + presence_check.checked;
	}
	if(massedit_check != null){
		urlstring = urlstring + '&massedit=' + massedit_check.checked;
	}
    allowedit='yes';
    if(alloweditobj.length>0)
    {
        if(!ld(alloweditobj).prop("checked"))
        {
            allowedit='no';
        }
    }
	if(alloweditobj.length>0)
	{
		if(!ld(alloweditobj).prop("checked"))
		{
			allowedit='no';
		}
	}
    urlstring = urlstring + '&allowedit=' + allowedit;
    if(subtotal_attr.length > 0 && subtotal_attr.prop("checked")){
		urlstring = urlstring + '&subtotal_attr=yes';
	}else{
		urlstring = urlstring + '&subtotal_attr=no';
	}
    if(fiedonly_check!=null)
    {
        if(fiedonly_check.checked&&uitype!=56)
        {
             urlstring = urlstring + '&fieldonly=1'  ;
        }
        else
        {
             urlstring = urlstring + '&fieldonly=0' ;
        }
    }
	// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
	var disallowed_copy_check=ld('#disallowed_copy_check_'+fieldid);
	if(disallowed_copy_check != null){
		var disallowed_copy=disallowed_copy_check.prop("checked") ?'yes':'no';
		urlstring = urlstring + '&disallowed_copy=' + disallowed_copy;
	}
    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
    var ShowHyperlinks_check = popupJqObj.find('#ShowHyperlinks_'+fieldid);
    if(ShowHyperlinks_check.length > 0)
    {
        var ShowHyperlinks = ShowHyperlinks_check.prop("checked") ? 'yes' : 'no';
        urlstring += '&ShowHyperlinks=' + ShowHyperlinks;
    }

    if(fieldlabel!=null)
    {
        if(fieldlabel.value=="")
        {
            var confirm_str = arrJsPopLabel['FIELDLABLENAMEEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }

        if(fieldlabels.value=="")
        {
            var confirm_str = arrJsPopLabel['FIELDLABLENAMEEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }

		var tmp_regex = /[\[\]'"]/;//BUG0072594 xxy 2023-10-20 页面设置，新增/编辑字段属性界面，若中文标签或英文标签填写内容含有特殊字符保存时，增加提示信息“标签中含有特殊字符，不允许保存”
		if(tmp_regex.test(fieldlabel.value))
        {
            var confirm_str = arrJsPopLabel['LabelContainSpecialCannotSave'];
			MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
        urlstring=urlstring+' &fieldlabel='+encodeURIComponent(fieldlabel.value)+' &fieldlabels='+encodeURIComponent(fieldlabels.value);
    }
	//zkt 20231108 增加“展示全部组织架构信息”
	var showallgroupstructure_check=ld('#showallgroupstructure_check_'+fieldid);
	if(showallgroupstructure_check != null){
		var showallgroupstructure='yes';
		showallgroupstructure=showallgroupstructure_check.prop("checked") ?'yes':'no';
		if(memberrangetype!=null&&memberrangetype.value=='All'){
			showallgroupstructure = 'yes';
		}
		urlstring = urlstring + '&showallgroupstructure=' + showallgroupstructure;
	}
	//xxy 2023-11-15 XUQIU1001176 页面设置/单据分录定制，增加“内容过多自动换行”字段属性
	var auto_wordwrap_check = ld('#auto_wordwrap_check_'+fieldid);
    if(auto_wordwrap_check != null)
    {
        var auto_wordwrap = auto_wordwrap_check.prop("checked") ? 'yes' : 'no';
        urlstring += '&auto_wordwrap=' + auto_wordwrap;
    }
	//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
	if(memberrangetype!=null){
		var member_other_condition=ld("#memberrange_other_condition"+fieldid).val();
		var member_other_condition_groups=ld("#memberrange_other_condition_groups"+fieldid).val();
		if(memberrangetype.value=='All' || memberrangetype.value=='Module') {
			memberrange='null####'+member_other_condition;
		}else if(memberrangetype.value=='Person'||memberrangetype.value=='Departments'||memberrangetype.value=='Roles'||memberrangetype.value=='Position'){
			memberrange=ld('#'+memberrangetype.value+'_'+fieldid).val()+'####'+member_other_condition;
			if(empty(ld('#'+memberrangetype.value+'_'+fieldid).val())){
				var confirm_str ='';
				if(memberrangetype.value == 'Person')
					confirm_str = arrJsPopLabel['Pleaseselectatleastoneperson'];
				else if(memberrangetype.value == 'Departments')
					confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
				else if(memberrangetype.value == 'Roles')
					confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
				else if(memberrangetype.value == 'Position')
					confirm_str = arrJsPopLabel['Pleaseselectatleaposition'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}
		memberrangetype=memberrangetype.value+"####"+member_other_condition_groups;
		urlstring=urlstring+' &memberrange=' +memberrange+'&memberrangetype='+memberrangetype;

	}

    if(popupobj.bigtype=='reference'||uitype==603||popupobj.bigtype=='multireference')
    {
		maxrowsshow=ld("#maxrowsshow_"+fieldid).val();//最大显示的行数
		datarang=ld("#datarang_"+fieldid).val();//数据查询范围
		if(uitype != 603&&document.getElementById('defaultvalue_'+fieldid)!=undefined){
			var defaultvalue = document.getElementById('defaultvalue_'+fieldid).value;
			urlstring = urlstring + '&defaultvalue=' + encodeURIComponent(defaultvalue);
		}
    }
    else
    {
		/* if(popupobj.bigtype=='selectsource')
		{
			defaultvalue_check=null;
		} */
		if(popupobj.bigtype != 'selectsource') {
			var defaultvalueelement = document.getElementById('defaultvalue_'+fieldid+"_name");
			if(defaultvalueelement != null) {

				var tmp_tmp=0;
				if(uitype==33)
				{
					var tmp_len=ld("#defaultvalue_"+fieldid +"_name option:selected").length-1;

					ld("#defaultvalue_"+fieldid +"_name option:selected").each(function(){
						var resultStr = ld(this).text().replace(/(^\s*)|(\s*$)/g, "");//删除左右空格

						resultStr = resultStr.replace(/[\r\n]/g, ""); //去掉回车换行
						if(tmp_len==tmp_tmp)
						{
							defaultvalue+=trim(resultStr);
						}
						else
							defaultvalue+=trim(resultStr)+'########'; //这里得到的就是
						tmp_tmp++;
					});
				}
				else if(uitype==15){
					// @edit:dong @date:2020/07/21 @reason:0035699 单据明细界面>页面设置>编辑任意下拉框字段>打开设置默认值下拉选项：添加一个搜索功能
					// defaultvalue =ld("#defaultvalue_"+fieldid +"_name").val();
					defaultvalue =ld("#"+popupobj.divid+ " #defaultvalue_"+fieldid +"_name").val();//ls 2022-07-06 BUG0053513 当新增字段里的blockid和编辑字段的fieldid一样时，是取不到值的。
				}else
				{
					defaultvalue+=ld("#"+popupobj.divid+ " #defaultvalue_"+fieldid +"_name").val();
				}

			
				/* if(defaultvalue_check.checked == true) { */
					var typeinfo = typeofdata.split('~');
					var inputtype = typeinfo[0];
					if(inputtype == 'C') {
						defaultvalue = (defaultvalueelement.checked == true)?'1':'0';
					}
						/*
						edit by andrew
						date:20131224
						reason:修改日期的控件为下拉框选择：今天，明天，下月，这里取消日期输入验证
						*/
					/*
					if(validateInputData(defaultvalue, alert_arr['LBL_DEFAULT_VALUE_FOR_THIS_FIELD'], typeofdata) == false) {
						document.getElementById('defaultvalue_'+fieldid+"_name").focus();
						return false;
					}
					*/
				/* } else {
					defaultvalue = '';
				} */
			} else {
				defaultvalue = '';
			}
		}
		else if(popupobj.bigtype=='selectsource')
		{
			defaultvalue='';//选择原单
		}
		if (defaultvalue === null || defaultvalue === undefined)  defaultvalue = '';//下拉框字段不设置默认值保存时，保存的时null
		urlstring = urlstring + '&defaultvalue=' + encodeURIComponent(defaultvalue);
	}
	if(uitype == 222){
		var defaultvalue_check = $('fldallow_rewriting_'+fieldid);
		if(defaultvalue_check.checked){
			urlstring += '&fldallow_rewriting=1';
		}else{
			urlstring += '&fldallow_rewriting=0';
		}
	}
	//zxm 2021-0408 二维码字段类型
	urlstring += "&fdcodetype_value="+fdcodetype_value+"&qrcodetemplateid="+qrcodetemplateid;
	//移动端仅允许拍照上传
	var take_photo_only = 0;
	if(uitype == 1108 || uitype == 1109 || uitype == 69){
		var _take_photo_only = $('take_photo_only_check_'+fieldid);
		if(_take_photo_only.checked){
			take_photo_only = 1;
		}
	}
	// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
	if(uitype == 1109 || uitype == 1108 || uitype == 28){
		word_watermark = ld('#word_watermark_check_'+fieldid).prop('checked')?'yes':'no';
		excel_watermark = ld('#excel_watermark_check_'+fieldid).prop('checked')?'yes':'no';
	}
	urlstring += '&word_watermark='+word_watermark;
	urlstring += '&excel_watermark='+excel_watermark;
	urlstring += '&take_photo_only='+take_photo_only;
	// $('status').style.display = "block";
    urlstring += '&maxrowsshow='+maxrowsshow+"&datarang="+datarang+"&fdcodetype_value="+fdcodetype_value+"&qrcodetemplateid="+qrcodetemplateid;
	//alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode='+sub_mode+'&parenttab=Settings'+'&fieldid='+fieldid+'&fld_module='+module+'&ajax=true'+urlstring);

	if(uploadwatermark != null){
		if (uploadwatermark.checked) {
			urlstring += '&uploadwatermark=yes';
		}else{
			urlstring += '&uploadwatermark=no';
		}
	}

	if(uitype != 306){
		if(ld('#helptips_'+fieldid)){
			helptips = ld('#helptips_'+fieldid).val();
			helptips = encodeURIComponent(helptips);
		}
		urlstring += '&helptips='+helptips;
	}

	//ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）
	if (ld('#selectmemberfield_'+fieldid) != null && ld('#selectmemberfield_'+fieldid).val() != undefined) {
		var selectmemberfield = ld('#selectmemberfield_'+fieldid).val();
		urlstring += '&selectmemberfield='+encodeURIComponent(selectmemberfield);
	}
	// ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
	//录入方式
	var inputModeType = ld('#inputModeType_'+fieldid).val();
	urlstring += '&inputModeType='+inputModeType;
	if(inputModeType == 2)
	{
		//通过公式计算
		formulacontent=ld('#definitionformula_'+fieldid).val().trim();
		if(formulacontent==''){
			ld('#rptContentLoading').hide();
			var confirm_str = arrJsPopLabel['Formulacontentcannotbeempty'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var tableobj=document.getElementById('toolfieldFormula_'+fieldid);
		for(i=0;i<tableobj.rows.length-1;i++)
		{
			var tmpcol=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
			var tmpletter=document.getElementById('formualtext_'+fieldid+"_"+i).value;
			if(tmpcol=='none'||ld.trim(tmpletter)=='')
			{
				continue;
			}
			formulavar+=document.getElementById('formualtext_'+fieldid+"_"+i).value;
			formulacolumn+=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
			if(i!=tableobj.rows.length-2){
				formulavar+=",";
				formulacolumn+=",";
			}
			tableobj[document.getElementById('formualtext_'+fieldid+"_"+i).value]=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
		}

		var formulacontent=document.getElementById('definitionformula_'+fieldid).value;
		formulacontent=formulacontent.replace(/(^\s*)|(\s*$)/g, "");
		var formualValidata_msg = formualValidata(formulacontent,tableobj);

		if(formualValidata_msg != '') {
			ld('#rptContentLoading').hide();
			MessagePopup.TipTwo_warning(formualValidata_msg);
			try { //BUG0069684 xxy 2023-7-18 字段公式设置错误，弹窗 2s后自动消失
				await iscontinuefun(); //用异步函数实现点击弹出层确定键能够继续执行，点击取消则阻断保存函数继续执行
			} catch {
				// console.log(err);
				return;
			}
		}
		urlstring += '&formulacontent='+encodeURIComponent(formulacontent)+'&formulavar='+encodeURIComponent(formulavar)+'&formulacolumn='+encodeURIComponent(formulacolumn);

	}else if(inputModeType == 1){//分录函数
		var functioncolumn = ld('#attributeField_'+fieldid).val();
		var functiontype = ld('#functionType_'+fieldid).val();
		urlstring += '&functiontype='+functiontype+'&functioncolumn='+functioncolumn;
	}else if(inputModeType == 3){ //通过SQL查询
		formulacontent=ld('#definitionsqlformula_'+fieldid).val().trim();
		if(formulacontent==''){
			ld('#rptContentLoading').hide();
			var confirm_str = arrJsPopLabel['SQLFormulaCannotEmpty'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var tableobj=document.getElementById('toolfieldFormula_'+fieldid);
		for(i=0;i<tableobj.rows.length-1;i++)
		{
			var tmpcol=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
			var tmpletter=document.getElementById('formualtext_'+fieldid+"_"+i).value;
			if(tmpcol=='none'||ld.trim(tmpletter)=='')
			{
				continue;
			}
			formulavar+=document.getElementById('formualtext_'+fieldid+"_"+i).value;
			formulacolumn+=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
			if(i!=tableobj.rows.length-2){
				formulavar+=",";
				formulacolumn+=",";
			}
			tableobj[document.getElementById('formualtext_'+fieldid+"_"+i).value]=document.getElementById('formualcombox_'+fieldid+"_"+i).options[document.getElementById('formualcombox_'+fieldid+"_"+i).selectedIndex].value;
		}

		urlstring += '&formulacontent='+encodeURIComponent(formulacontent)+'&formulavar='+encodeURIComponent(formulavar)+'&formulacolumn='+encodeURIComponent(formulacolumn);
	}
	//敏感规则启用状态
	var sensitivepresence = '';
	if(ld("#"+popupobj.divid+' table.SensitiveTable').length > 0){
		sensitivepresence = ld("#"+popupobj.divid+" [name=sensitivepresence]").is(':checked'); //敏感规则开启状态
		if(sensitivepresence == true){
			sensitivepresence = 'yes';
		}
		else{
			sensitivepresence = 'no'
		}
	}
	
	urlstring += '&sensitivepresence='+sensitivepresence;

	//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
	var keyArr = ['DownloadAllowed','PreviewAllowed'];
	popupobj['PreviewAllowed'] = popupobj['DownloadAllowed'];
	var checkObj = popupJqObj.find(`#FileAllowed_${fieldid}`);
	ld.each(keyArr,function (i,v) {
		if(typeof popupobj[v] !== "undefined" && checkObj.length > 0 && checkObj.prop("checked")) {
			urlstring += `&${v}=yes`;
			ld.each(popupobj[v], function (set_key, set_val) {
				urlstring += `&${v}_${set_key}=${set_val}`;
			})
		}
	})

	// edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
	var formatTypeArr = ['date', 'datetime', 'time'];
	if(formatTypeArr.includes(popupobj.bigtype)) {
		urlstring += `&value_format=${popupobj.valueFormat}`;
	}

    //zkt 2022-02-28 【页面设置，字段显示并支持修改字符长度】-- 字段编辑保存 
    if (uitype == 1 &&ld('#fldlength_'+fieldid) != null && ld('#fldlength_'+fieldid).val() != undefined){
        var fldlength = parseInt(ld('#fldlength_'+fieldid).val());
        var fldlength_old = parseInt(ld('#fldlength_old_'+fieldid).val());
        if(fldlength==''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",charlenglabel+arrJsPopLabel['LENGTH']+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}
		if(isNaN(fldlength)){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHARACTERLENGTH']);
			return false;
		}
        urlstring += '&fldlength='+encodeURIComponent(fldlength);
        if(fldlength<fldlength_old)
        {
            var confirm_str = arrJsPopLabel['CHANGEEXISTINGDATACONTINUE'];//'可能会改变已有数据，是否继续？'
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            var lastpopupobj = CrmPopup.getPopupObj("last");
            ld("#"+lastpopupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                
                
                saveFieldInfosavedata(sub_mode,fieldid,module,urlstring);//保存事件
        	})
            return ;
        }
        else
        {
            
            saveFieldInfosavedata(sub_mode,fieldid,module,urlstring);//保存事件
        }
        
    }
    else if (uitype == 7 &&ld('#fldDecimal_'+fieldid) != null && ld('#fldDecimal_'+fieldid).val() != undefined){
        var fldDecimal = parseInt(ld('#fldDecimal_'+fieldid).val());
        var fldDecimal_old = parseInt(ld('#fldDecimal_old_'+fieldid).val());
        if(isNaN(fldDecimal)){
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Decimal']+arrJsPopLabel['CANOTEMPTY']);
            return false;
        }
        if(fldDecimal>53){
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Decimal']+arrJsPopLabel['CANNOTTHAN']+"53");
            return false;
        }
        urlstring += '&fldDecimal='+encodeURIComponent(fldDecimal);
        if(fldDecimal<fldDecimal_old)
        {
            var confirm_str = arrJsPopLabel['CHANGEEXISTINGDATACONTINUE'];//'可能会改变已有数据，是否继续？'
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            var lastpopupobj = CrmPopup.getPopupObj("last");
            ld("#"+lastpopupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                
                
                saveFieldInfosavedata(sub_mode,fieldid,module,urlstring);//保存事件
        	})
            return ;
        }
        else
        {
            saveFieldInfosavedata(sub_mode,fieldid,module,urlstring);//保存事件
        }
        
    }
    else{
        saveFieldInfosavedata(sub_mode,fieldid,module,urlstring);//保存事件
    }
}
function iscontinuefun() {//BUG0069684 xxy 2023-7-18 字段公式设置错误，弹窗 2s后自动消失 需要异步执行
	return new Promise((resolve, reject) => {
		var popupobj=CrmPopup.getPopupObj('last');
		ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
			ld('#rptContentLoading').show();
			resolve();
		})
		ld('#'+popupobj.divid+' [tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
			reject();
		})
	});
}
var ColorTypeArr = ["text","textarea","longtextarea","number","currency","date","time","datetime","percent","phone","mobile"];//hjz 可设置颜色的字段类型数组
function saveFieldInfosavedata(sub_mode,fieldid,module,urlstring){
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode='+sub_mode+'&parenttab=Settings'+
			'&fieldid='+fieldid+'&fld_module='+module+'&ajax=true'+urlstring+'&ColorTypeArr='+ColorTypeArr,function(ajaxhtml) {
		var str = trim(ajaxhtml);
		if(str == "CHECKSQLERROR")
		{
			MessagePopup.TipOne_warning(arrJsPopLabel['QuerySqlError']);
			return false;
		}


		//$("cfList").update(response.responseText);
		sethtml(document.getElementById('cfList'),ajaxhtml);
		// $('status').style.display = "none";

		//fninvshnew('layoutlist_editfield');
		var popupobj=CrmPopup.getPopupObj('last');
		layoutblockEventClick();
		var worker = new Worker("include/js/CacheWork.js");
		var url_arr=window.location.href.split("?");
		worker.postMessage({'module':"Settings","url":url_arr[0],'fieldmodule':module});
		worker.onmessage = function(event) {

			worker.terminate();

		}
		setTimeout(function(){
					puyoungJS_DialogBox.unblock();
					popupobj.CancelEvent();
					ld('#rptContentLoading').hide();
				},
				500)




	});
}
 /*
   edit:can
   date:20130802
   reason:自定义设置不允许重复
   */
function fieldonlyCheck(obj,elementName)
{
	//wym BUG0075357 kfbcrm-服务合同-关联选择单据字段，应控制不能同时勾选“不允许重复”和“批量编辑”
	var ele = $(elementName);
	if (obj.checked == true) {
		ele.checked = false;
		ele.disabled = true;
	} else {
		if(ld(ele).attr('orignaldisabled') != 'true'){
			ele.disabled = false;
		}
	}
}

function enableDisableCheckBox(obj, elementName, uitype) {


	var ele = $(elementName);

	if (obj == null || ele == null) return;
    if(ele.getAttribute('allowhide')=='no')
    {
        return ;
    }
	if (obj.checked == true) {
		ele.checked = true;
		if(uitype != 53 && uitype != 4){
			ele.disabled = true;
		}
	} else {
		if(uitype != 53 && uitype != 4){
			ele.disabled = false;
		}
	}
}
//BUG0066578 yujun 2023-6-7 增加了一个对复选框控制的方法
function enableDisableCheckBox_ressing(obj,resing_id){
	var other_obj = $(resing_id);
	other_obj.disabled = obj.checked == false?true:false;
	if(obj.checked == false) other_obj.checked = false;
}

function showHideTextBox(obj, elementName) {
	var ele = $(elementName);
	if (obj == null || ele == null) return;
	if (obj.checked == true) {
		ele.disabled = false;
	} else {
		ele.disabled = true;
	}
}


/**
 formulacontent:字段公式内容
 formualvar:字段公式变量(数组)
 */
function formualValidata(formulacontent,formualvar)
{
	var onechar;
	var nextchar;
	var operations=new Array('+','-','*','/','%');
	var Brackets=new Array('(',')','[',']','（','）');
	var digits=new Array('0','1','2','3','4','5','6','7','8','9','.');
	var errpr_msg = '';
	for(i=0;i<formulacontent.length;i++)
	{
		onechar=formulacontent.substr(i,1);
		nextchar=formulacontent.substr(i+1,1);
		if(nextchar=='' ||trim(onechar)=='')
		{
			continue;
		}
		if(ld.inArray(onechar,letters)>=0)//如果该字符为变量
		{
			//如果该字符为变量,下一个字符串不能为变量
			if(ld.inArray(nextchar,letters)>=0)
			{
				errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
				return errpr_msg;
			}
			if(formualvar[onechar]=='')
			{
				errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
				return errpr_msg;
				//alert('字段公式验证错误');
				// return false;
			}
		}
		else if(ld.inArray(onechar,operations)>=0)//如果是运算符号
		{

			if(ld.inArray(nextchar,operations)>=0)//下一个字符一定不能是运算符号
			{
				errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
				return errpr_msg;
			}
		}
		else if(ld.inArray(onechar,Brackets)>=0)
		{

		}
		else if(ld.inArray(onechar,digits)>=0)
		{

		}
		else
		{


			errpr_msg = arrJsPopLabel['Fieldformulavalidationerror'];
			return errpr_msg;
		}
	}

	return errpr_msg;
}

//hjz addField函数移至addPicklistField.tpl
//字段颜色 选择
function chooseFieldColor(obj,trid){
	var colpick_num = 1;
	var pick_color = ld(obj).css('background-color');
	pick_color = getColorInHex(pick_color);
	var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
	var trobj = ld('#tr_fieldvaluecolor_'+trid);
	var inputobj = ld('#fieldvaluecolor_'+trid);
	// 20240509 ljj BUG20240506-44 新增字段所有选择颜色添加预设颜色功能
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
	crmPopupobj.prevshow();
	var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
	var dataurl='selectedcolor='+css_type;
	ldAjaxNoProgress(url,dataurl,function (data){
		if (data.code == 1){
			crmPopupobj.setParams(data.result.title,'',"","LdPopWidth400px",'Settings',"",'',"",'');
			crmPopupobj.show(data.result.content);
			var divid=crmPopupobj.divid;
			//加载自定义
			getColPick(obj,trobj,inputobj,crmPopupobj,trid);
			//页签点击事件
			ld("#"+divid+" #changetab").find('[name=tag]').unbind('click').bind('click',function () {
				//隐藏之前选中的页签
				var selected=ld("#"+divid+" #changetab").find('.ld-change-tab-active');
				ld('#'+divid+' #'+selected.attr('tag')).hide();
				selected.removeClass('ld-change-tab-active');
				//显示选中页签
				var tag=ld(this).attr('tag');
				ld(this).addClass('ld-change-tab-active');
				ld('#'+divid+' #'+tag).show();
			});
			//浅色亮色色块点击事件
			var color=ld('#'+divid+' #preset').find('[name=presetcolor_li]');
			ld(color).unbind('click').bind('click',function () {
				var selectedcolor=ld(this).find('[name=presetcolor]').attr('color');
				// var rgba=that.getColorRgba(selectedcolor);
				crmPopupobj.CancelEvent();
				inputobj.val(selectedcolor);
				trobj.find('div[name="color_div"]').css('background',selectedcolor);
			})
		}
	});
}
function chooseLabelColor(obj,trid){
	var colpick_num = 1;
	var pick_color = ld(obj).attr('color');
	var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
	var trobj = ld('#tr_labelvaluecolor_'+trid);
	var inputobj = ld('#labelvaluecolor_'+trid);
	// 20240509 ljj BUG20240506-44 新增字段所有选择颜色添加预设颜色功能
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
	crmPopupobj.prevshow();
	var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
	var dataurl='selectedcolor='+css_type;
	ldAjaxNoProgress(url,dataurl,function (data){
		if (data.code == 1){
			crmPopupobj.setParams(data.result.title,'',"","LdPopWidth400px",'Settings',"",'',"",'');
			crmPopupobj.show(data.result.content);
			var divid=crmPopupobj.divid;
			//加载自定义
			getColPick(obj,trobj,inputobj,crmPopupobj,trid);
			//页签点击事件
			ld("#"+divid+" #changetab").find('[name=tag]').unbind('click').bind('click',function () {
				//隐藏之前选中的页签
				var selected=ld("#"+divid+" #changetab").find('.ld-change-tab-active');
				ld('#'+divid+' #'+selected.attr('tag')).hide();
				selected.removeClass('ld-change-tab-active');
				//显示选中页签
				var tag=ld(this).attr('tag');
				ld(this).addClass('ld-change-tab-active');
				ld('#'+divid+' #'+tag).show();
			});
			//浅色亮色色块点击事件
			var color=ld('#'+divid+' #preset').find('[name=presetcolor_li]');
			ld(color).unbind('click').bind('click',function () {
				var selectedcolor=ld(this).find('[name=presetcolor]').attr('color');
				// var rgba=that.getColorRgba(selectedcolor);
				crmPopupobj.CancelEvent();
				inputobj.val(selectedcolor);
				trobj.find('div[name="color_div"]').css('background',selectedcolor);
			})
		}
	});
}
// 20240509 ljj BUG20240506-44 新增字段所有选择颜色添加预设颜色功能
function getColPick(obj,trobj,inputobj,crmPopupobj,trid) {
	var pick_color = ld(obj).css('background-color');
	pick_color = getColorInHex(pick_color);
	var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
	getJsScript('include/js/colpick/colpick.js',function(){
		getJsScript('include/js/colpick/plugin.js',function(){
			var divid = popupobj.divid;
			CrmPopup.findHtmlobj(divid,'picker').colpick({
				color:css_type,
				flat:true,
				layout:'RGB',
				submitText:'确认',
				onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
					var _color = '#'+hex;
					inputobj.val(_color);
					trobj.find('div[name="color_div"]').css('background',_color);
					popupobj.CancelEvent();
				}

			});
			popupobj.center();
			// var windowWidth = document.documentElement.clientWidth;
			// var windowHeight = document.documentElement.clientHeight;
			// if(colpick_num == 1)
			//     var popupHeight = ld('#'+divid).height()-126;
			// else{
			//     var popupHeight = ld('#'+divid).height();
			// }
			// colpick_num++;
			// var popupWidth = ld('#'+divid).width();
			// ld('#'+divid).css({
			//     "position": "fixed",
			//     "top": (windowHeight-popupHeight)/2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
			//     "left": (windowWidth-popupWidth)/2
			// });
		});
	});
}

//电话，手机字段颜色 选择 2023-5-5 xxy XUQIU1001310 “手机”和“电话”字段文字颜色增加默认色
function phone_chooseFieldColor(obj,trid){
	var colpick_num = 1;
	var pick_color = ld(obj).css('background-color');
	pick_color = getColorInHex(pick_color);
	var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
	var trobj = ld('#tr_phone_fieldvaluecolor_'+trid);
	var inputobj = ld('#phone_fieldvaluecolor_'+trid);
	// 20240509 ljj BUG20240506-44 新增字段所有选择颜色添加预设颜色功能
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
	crmPopupobj.prevshow();
	var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
	var dataurl='selectedcolor='+css_type;
	ldAjaxNoProgress(url,dataurl,function (data){
		if (data.code == 1){
			crmPopupobj.setParams(data.result.title,'',"","LdPopWidth400px",'Settings',"",'',"",'');
			crmPopupobj.show(data.result.content);
			var divid=crmPopupobj.divid;
			//加载自定义
			getColPick(obj,trobj,inputobj,crmPopupobj,trid);
			//页签点击事件
			ld("#"+divid+" #changetab").find('[name=tag]').unbind('click').bind('click',function () {
				//隐藏之前选中的页签
				var selected=ld("#"+divid+" #changetab").find('.ld-change-tab-active');
				ld('#'+divid+' #'+selected.attr('tag')).hide();
				selected.removeClass('ld-change-tab-active');
				//显示选中页签
				var tag=ld(this).attr('tag');
				ld(this).addClass('ld-change-tab-active');
				ld('#'+divid+' #'+tag).show();
			});
			//浅色亮色色块点击事件
			var color=ld('#'+divid+' #preset').find('[name=presetcolor_li]');
			ld(color).unbind('click').bind('click',function () {
				var selectedcolor=ld(this).find('[name=presetcolor]').attr('color');
				// var rgba=that.getColorRgba(selectedcolor);
				crmPopupobj.CancelEvent();
				inputobj.val(selectedcolor);
				trobj.find('div[name="color_div"]').css('background',selectedcolor);
			})
		}
	});
}
// 转换颜色为十六进制
function getColorInHex(color) {
    if (!color) {
        return null;
    }
    // 如果已经是十六进制格式，‌则直接返回
    if (color.startsWith('#')) {
        return color;
    }
    // 移除可能的空格和"rgb()"或"rgba()"字符串
    color = color.match(/\d+/g);
    if (!color || color.length !== 3 && color.length !== 4) {
        return null; // 无效的颜色格式
    }

    // 转换RGB或RGBA为十六进制
    var hex = '#';
    for (var i = 0; i < 3; i++) {
        var intVal = parseInt(color[i], 10);
        if (isNaN(intVal)) {
            return null; // 无效的颜色分量
        }
        hex += intVal.toString(16).padStart(2, '0');
    }

    return hex;
}

//字段类型图标
var selectfieldtypeImages={'0':'text.gif','10':'text.gif'
                    ,'7':'cfpicklist.gif','11':"cfpicklist.gif",'9':'checkbox.gif'
                    ,'1':'number.gif','6':'phone.gif','15':'sendmsg.png','4':'date.gif'
                    ,'14':'datetime.gif','17':'QQ.gif','5':'email.gif','12':'skype.gif','13':'time.PNG'
                    ,'2':'percent.gif','3':'cfcurrency.gif','8':'url.gif','16':'rfax.gif','19':'autograph.png'
                    ,'20':'referencefield.png','21':'referencefield.png','18':'text.gif'};

function selectfieldtypeImage(state) {

  if (!state.id) {
    return state.text;
  }

  var $state = ld(
    // '<span><img src="themes/images/'+selectfieldtypeImages[state.id]+'" class="img-flag" /> ' + state.text + '</span>'
    '<span>' + state.text + '</span>'
  );
  return $state;
};
function addFieldCancel(blockid)
{
    fninvshnew('addfield_'+blockid);
    //sethtml(document.getElementById('cfList'),ld('#cfList').html());
    CrmPopup.global_listPopupObj.pop();
}
//签到
function allowable_distance_click(obj,blockid){
	var allowable_distance_type = ld(obj).val();
	if('custom' == allowable_distance_type){
		ld('#custom_allowable_distance_'+blockid).show();
	}else{
		ld('#custom_allowable_distance_'+blockid).hide();
	}
}
//字段类型为二维码  二维码类型切换的时候 内容定制按钮的显示隐藏
function qrcodeTypeChange(obj,blockid){
	var qrcodeType = ld(obj).val();
	if(qrcodeType=='1502'){
		ld(obj).next('span').show();
        if(blockid>0){
            ld('#fieldset_'+blockid).hide();
            ld('#contentset_'+blockid).hide();
        }else{
            ld('#qrcodeTemplateEditTr').hide();
            ld('#formqrcodeTemplateEditTr').hide();
        }
    }else if(qrcodeType=='1503'){
        ld(obj).next('span').hide();
        if(blockid>0){
            ld('#contentset_'+blockid).hide();
            ld('#fieldset_'+blockid).show();
        }else{
            ld('#qrcodeTemplateEditTr').hide();
            ld('#formqrcodeTemplateEditTr').show();
        }
	}else{
		ld(obj).next('span').hide();
        if(blockid>0){
            ld('#fieldset_'+blockid).hide();
            ld('#contentset_'+blockid).show();
        }else{
            ld('#qrcodeTemplateEditTr').show()
            ld('#formqrcodeTemplateEditTr').hide();
        }

	}
}
/*
获取相关对象的引用字段
*/
function getReferencemoduleField(obj,blockid,fld_module)
{
    var popupobj=CrmPopup.getPopupObj('last');
	var curmodule=ld(obj).data('curmodule');
	//wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（这个字段不能允许编辑,否则详情页编辑页显示会有问题）
	if(ld(obj).val()=='Users'){
		ld("#tr_selectmemberfield_"+blockid).css('display','');
		//wym attr无法修改checked属性,必须用prop
		ld("#allowedit_"+blockid).prop("checked",false);//允许编辑
		ld("#allowedit_"+blockid).attr("disabled",true);
		ld("#requiredfield_"+blockid).prop("checked",false);//必填
		ld("#requiredfield_"+blockid).attr('disabled',true);
		ld("#notallowduplicate_"+blockid).prop("checked",false);//不允许重复
		ld("#notallowduplicate_"+blockid).attr('disabled',true);
		var cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectmemberfield_'+blockid);
		cls_resetComboxHtmlobj.setComboxObjHtml();//修改下拉框样式
	}else{
		ld("#allowedit_"+blockid).attr("disabled",false);
		ld("#tr_selectmemberfield_"+blockid).css('display','none');
	}
    var name="relatedmodulefield_"+blockid;
	ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=getReferenceField&fld_module='+ld(obj).val()+'&frommodule='+curmodule,'',function(data) {
		if(data.code==1) {
			ld("#"+popupobj.divid+" [name="+name+"]").empty();
			ld.each(data.result.list,function(index,info){
				var fieldname=info.fieldname;
				var fieldlabel=info.fieldlabel;
				//edit: xll 2023/06/06 XUQIU1001203 引用字段增加“显示超链接”字段属性
				var isHrefField = info.isHrefField;
				ld("#"+popupobj.divid+" [name="+name+"]").append("<option value='"+fieldname+"' isHrefField='"+isHrefField+"'>"+fieldlabel+"</option>");
			});
			var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
			cls_resetComboxHtmlobj.setComboxObjHtml();
			if(ld(obj).val()=='Users' && data.result.selectuser!=null ){ //wym 240424 BUG0077149 切换引用模块时刷新引用对象下拉框
				ld("#"+popupobj.divid+" [name=selectmemberfield_"+blockid+"]").empty();
				ld.each(data.result.selectuser,function(user_id,user_name){
					ld("#"+popupobj.divid+" [name=selectmemberfield_"+blockid+"]").append("<option value='"+user_id+"' >"+user_name+"</option>");
				});
				var cls_resetComboxHtmlobj=new cls_resetComboxHtml("selectmemberfield_"+blockid);
				cls_resetComboxHtmlobj.setComboxObjHtml();
			}
			selectedIsHrefFiled(ld("#"+popupobj.divid+" [name="+name+"]")[0],blockid);
		}
	});
}
/*
 *edit: xll
 *2023/06/07 XUQIU1001203
 *判断引用的字段是否是超链接字段
 */
function selectedIsHrefFiled(obj,blockid){
    var isHrefField = ld(obj.options[obj.selectedIndex]).attr('isHrefField');
    if(isHrefField == 'yes'){
        document.getElementById("tr_ShowHyperlinks_"+blockid).style.display="";
    }else{
        document.getElementById("tr_ShowHyperlinks_"+blockid).style.display="none";
    }
}
function setChooseDefaultvalue(fld_module,blockid)
{
    //选择单据设置默认值
    var module=ld("#referencemodule_"+blockid).val();
    var maxrowsshow=ld("#maxrowsshow_"+blockid).val();
    //var approvedemand=
	var  posturl="index.php?module=Users&action=UsersAjax&file=select_related_popu&selectmodule="+module+"&frommodule="+fld_module+"&fieldname=defaultvalue_"+blockid;
    posturl+="&maxrowsshow="+maxrowsshow;
	ldAjaxNoProgress(posturl,'',function(data) {
		$("status").style.display="none";

		if(data.code==1)
		{

			var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","",CrmPopup.getSmallpopupwidth(),fld_module,"","","","","",module);
			selectsearchpopupobj.prevshow();
			CrmPopup.setPopupobjHtmlContent_scroll_jquery(selectsearchpopupobj,data.result.content);
			selectsearchpopupobj.blockid = blockid;

			selectsearchpopupobj.popuptype = 'select_related_popup';
			selectsearchpopupobj.pop_type = 'selectRelatedPopup';
			selectsearchpopupobj.module = selectmodule;

			var listresizeobj=new List_ResizeTable(selectsearchpopupobj);
			listresizeobj.setPopupResizeTable_Init(selectsearchpopupobj.module);
			selectsearchpopupobj.listresizeobj = listresizeobj;

			selectsearchpopupobj.getSearch=function (){
				var fieldname = ld('#'+this.divid+' [name=fieldname]').val();
				selectSearch(fieldname);
			};
			//  selectsearchpopupobj.reload_showrelationlistobj=reload_showrelationlistobj;


		}

	});

// @edit:liushuai,2021-05-19,reason:【ID1001646】页面设置，字段属性设置“默认”值后，则默认值前面的“复选框”自动勾选并生效(关联选择单据（单选）)
	ld("#defaultvalue_check_"+blockid).prop('checked',true);
}
// wym 1000016 多选关联字段 新增编辑字段设置默认值
function setChooseDefaultvalueMutiple(formmodule,blockid)
{
	var popupobj=CrmPopup.getPopupObj('last');
	//选择单据设置默认值
	var selectmodule=ld("#multireferencemodule_"+blockid).val();
	var maxrowsshow=ld("#maxrowsshow_"+blockid).val();
	var datarange=ld("#datarange_"+blockid).val();
	var approvedemand=ld("#approve_demand_"+blockid).val();
	var advancedemand=ld('#advance_demand_'+blockid).val();
	var advancedemandgroups=ld('#advance_demand_groups_'+blockid).val();
	ld("#defaultvalue_check_"+blockid).prop('checked',true);
	getJsScript('include/js/SystemPopup/MultiplePopup.js',function () {
		var chooseentityidarr = [];
		if(ld("#"+popupobj.divid+" #defaultvalue_"+blockid).val() != ''){
			chooseentityidarr = ld("#"+popupobj.divid+" #defaultvalue_"+blockid).val().split(',');
		}
		var MultiplePopupobj = new MultiplePopup();
		MultiplePopupobj.init(selectmodule,'&fieldname=defaultvalue_'+blockid+'&maxrowsshow='+maxrowsshow+'&datarange='+datarange+'&approvedemand='+approvedemand+'&advancedemand='+encodeURIComponent(advancedemand)+'&advancedemandgroups='+encodeURIComponent(advancedemandgroups),formmodule);
		MultiplePopupobj.setChooseEntityidArr(chooseentityidarr);
		MultiplePopupobj.showPopup();
		MultiplePopupobj.setReturnField(popupobj,"defaultvalue_"+blockid,"defaultvalue_"+blockid+"_name");
	})
}
function clear_ChooseDefaultvalue(blockid)
{

    ld("#defaultvalue_"+blockid).val("");
    ld("#defaultvalue_"+blockid+"_name").val("");
	// @edit:liushuai,2021-05-25,reason:0046028:）页面设置字段默认值问题；系统设置-页面设置，模块自定义表单10，“关联单选”字段，在清除默认值时，默认值复选框能否自动取消勾选
	ld("#defaultvalue_check_"+blockid).prop('checked',false);
}

function show_move_hiddenfields(modulename,tabid,blockid,sub_mode){

	if(sub_mode == 'showhiddenfields'){
	var selectedfields = document.getElementById('hiddenfield_assignid_'+blockid);
	var selectedids_str = '';
	for(var i=0; i<selectedfields.length; i++) {
		if (selectedfields[i].selected == true) {
			selectedids_str = selectedids_str + selectedfields[i].value + ":";
		}
	}
	}else{
		var selectedfields = document.getElementById('movefield_assignid_'+blockid);
		var selectedids_str = '';
		for(var i=0; i<selectedfields.length; i++) {
			if (selectedfields[i].selected == true) {
				selectedids_str = selectedids_str + selectedfields[i].value + ":";
			}
		}
	}
	// $('status').style.display = "block";
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode='+sub_mode+'&fld_module='+modulename+'&parenttab=Settings&ajax=true&tabid='+tabid+'&blockid='+blockid+'&selected='+selectedids_str,function(ajaxhtml) {
		puyoungJS_DialogBox.unblock();
		sethtml(document.getElementById('cfList'),ajaxhtml);
		//$("cfList").update(response.responseText);
		// $('status').style.display = "none";
		layoutblockEventClick();
	});
}

function changeRelatedListorder(what_to_do,tabid,sequence,id,module)
{
	$('vtbusy_info').style.display = "block";
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=changeRelatedInfoOrder&sequence='+sequence+'&fld_module='+module+'&parenttab=Settings&what_to_do='+what_to_do+'&tabid='+tabid+'&id='+id+'&ajax=true',function(ajaxhtml) {
		$("relatedlistdiv").innerHTML=ajaxhtml;
		$('vtbusy_info').style.display = "none";
	});
}
function callRelatedList(obj,module){

	$('vtbusy_info').style.display = "block";
	ldAjaxHtmlNoProgress('index.php','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=getRelatedInfoOrder&parenttab=Settings&formodule='+module+'&ajax=true',function(ajaxhtml) {
		$("relatedlistdiv").innerHTML=ajaxhtml;
		$('vtbusy_info').style.display = "none";
		fnvshobj(obj, 'relatedlistdiv');
	});
}
//修改区块名称
function Modifiedblockname(obj,tabid,blockid){
	////BUG0066295: 模块管理>页面设置>编辑属性弹出框可以进行拖拽  余俊  2023/5/15
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();

	var surl='module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=relatedlistdiv_blockname&parenttab=Settings&tabid='+tabid+'&blockid='+blockid+'&ajax=true';
	ldAjaxNoProgress('index.php?'+surl,'',function(data)
	{

		if(data.code==1)
		{
			//approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
			//EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
			crmPopupobj.setParams(data.result.title,SaveresultsForlabel,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
		}
	});
}
//验证提交修改区块名称
function SaveresultsForlabel(){
	var popupobj = CrmPopup.getPopupObj('last');
    var fildlable_zh=document.forms['Saveresults_blocks'].fildlable_zh.value;
    var fildlable_en=document.forms['Saveresults_blocks'].fildlable_en.value;
    if(fildlable_zh.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
    {
        //alert('区块中文名称不能为空');
		var confirm_str = arrJsPopLabel['BLOCKCHINESENAMECANNOTBEEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    if(fildlable_en.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
    {
        var confirm_str = arrJsPopLabel['BLOCKENGLISHNAMECANNOTBEEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        //alert('区块英文名称不能为空');
        return false;
    }
	// $('status').style.display = "block";
	var search_form = document.Saveresults_blocks;
	var tabid = search_form.tabid.value;
	var blockid = search_form.blockid.value;
	var fildlable_zh_old = search_form.fildlable_zh_old.value;
	var fildlable_en_old = search_form.fildlable_en_old.value;
	popupobj.CancelEvent();
	var surl = 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=relatedlist_blocknameSave&parenttab=Settings&tabid='+tabid+'&blockid='+blockid+'&fildlable_zh_old='+fildlable_zh_old+'&fildlable_zh='+fildlable_zh+'&fildlable_en_old='+fildlable_en_old+'&fildlable_en='+fildlable_en+'&ajax=true';
	ldAjaxHtmlNoProgress('index.php?',surl,function(response) {
		if(response.indexOf("#error#")>0)
		{
			var strs=response.split("#error#");
			RemindsMsg("","LdPopWidth400px","","yes","yes",strs[0]);
			return false;
		}
		if(languagetype == 'zh'){
			ld('#block_name_'+blockid).html(fildlable_zh);
		}else{
			ld('#block_name_'+blockid).html(fildlable_en);
		}
		fninvshnew('relatedlistdiv_blockname');
		// $('status').style.display = "none";
	});
}
//相关项目设置
 //edit:can 2021-03-15 044977: （https://61mis.com/kfbcrm [^]）进入页面设置后再进入单据查看详情界面，点击【相关信息设置】->【保存】，弹出层没有关闭
//相关信息显示设置保存
function saveRelatedList(){
	var popupobj=CrmPopup.getPopupObj("last");
   // var divid=popupobj.divid;
   //edit:can 2021-01-27 44464: （https://61mis.com/kfbcrm/ [^]）客户问题（熊少波），客户->页面设置->相关信息页签，点击【保存】没有反应（需要补丁）
     divid="dv_relateinfo_content";
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
	var opennewpage_presence = ld(" #opennewpage_presence").prop('checked')?'yes':'no';//xxy 2023-11-24 XUQIU1002162 相关信息设置弹出层中，增加“相关模块显示“打开新页签”按钮”参数，可自定义相关模块打开新页签图标按钮是否显示
    //alert(selectedColumnsObj.options.length);
    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
	 CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val(selectedColStr);

    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    var ColumnsObj=getObj("AssmablyList")
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
		ColStr += ColumnsObj.options[i].value + ";"
    }
	CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val(ColStr);
	var formodule = CrmPopup.findHtmlobj(divid,'formodule').val();
   //edit:can 2021-01-27 44464: （https://61mis.com/kfbcrm/ [^]）客户问题（熊少波），客户->页面设置->相关信息页签，点击【保存】没有反应（需要补丁）
    var url='module=Settings&formodule='+popupobj.frommodule+"&action=SettingsAjax&file=LayoutBlockList&sub_mode=SetRelatedlistsSave&ajax=true&AssmablyColumnsString="+CrmPopup.findHtmlobj(divid,'AssmablyColumnsString').val()+"&selectedAssmablyColumnsString="+CrmPopup.findHtmlobj(divid,'selectedAssmablyColumnsString').val()+'&OpenNewPage='+opennewpage_presence;
	//jby 2024/12/13 XUQIU20241127-04 相关信息设置弹出层中，增加"置客户相关信息可以看见下级单据的数据"参数
	if(ld(" #superior_account_see").length>0){
		var superior_account_see = ld(" #superior_account_see").prop('checked')?'yes':'no';
		url += '&SuperiorAccountSee='+superior_account_see;
	}
	url+="&tabid="+CrmPopup.findHtmlobj(divid,'tabid').val();
	ldAjaxHtmlNoProgress('index.php',url,function(response) {
		MessagePopup.TipOne_success(arrJsPopLabel.SUCCESSFULLYSAVED);
	});
}
//快捷操作设置
function QuickSetactions(obj,module,BLOCKIDSETTING,FIELDIDSETTING)
{
    // $('status').style.display = "block";
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=QuickSetActions&parenttab=Settings&modulename='+module+'&ajax=true&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,function(response) {
		if(response.indexOf('###SUCCESS###')>-1){
			var results=response.split('###SUCCESS###');
			ld("#Quicksetactions_div").get(0).innerHTML=results[1];
			// $('status').style.display = "none";
			fnvshobj(obj, 'Quicksetactions_div');
		}
	});
}
function checkoptionvalus(from,type)
{
    formSelectColumnString(type);


    from.submit();
}
function formSelectColumnString(type)
{
    if(type == '1')
    {
        selectedColumnsObj=getObj("selectedAssmablyColumns");
    }
    else
    {
        selectedColumnsObj=getObj("beselected_module");
    }
    //selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    //alert(selectedColumnsObj.options.length);

    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + ";"
    }
    if(type == '1')
    {
        document.forms['Saveresults'].selectedAssmablyColumnsString.value = selectedColStr;
    }
    else
    {
        document.forms['Quicksetactions'].beselected_module_String.value = selectedColStr;
    }

    //document.getElementById['selectedAssmablyColumnsString'].value = selectedColStr;
    if( type == '1')
    {
        ColumnsObj=getObj("AssmablyList")
    }
    else
    {
        ColumnsObj=getObj("tobeselecte_module")
    }
    var ColStr = "";
    for (i=0;i<ColumnsObj.options.length;i++)
    {
    ColStr += ColumnsObj.options[i].value + ";"
    }
    if( type =='1')
    {
        document.forms['Saveresults'].AssmablyColumnsString.value = ColStr;
    }
    else
    {
        document.forms['Quicksetactions'].tobeselecte_module_String.value = ColStr;
    }

}
function ModuleDetailmoveUp(objid)
{
var elem = document.getElementById(objid);
    if(elem.options.selectedIndex>=0){
    	for (var i=1;i<elem.options.length;i++){
    		if(elem.options[i].selected == true){
    			//swap with one up
    			var first = elem.options[i-1];
    			var second = elem.options[i];
    			var temp = new Array();

    			temp.value = first.value;
    			temp.innerHTML = first.innerHTML;

    			first.value = second.value;
    			first.innerHTML = second.innerHTML;

    			second.value = temp.value;
    			second.innerHTML = temp.innerHTML;

    			first.selected = true;
    			second.selected = false;
    		}
    	}
    }

}
function ProductDetailmoveDown(objid)
{
var elem = document.getElementById(objid);
	if(elem.options.selectedIndex>=0){
		for (var i=elem.options.length-2;i>=0;i--){
			if(elem.options[i].selected == true){
				//swap with one down
				var first = elem.options[i+1];
				var second = elem.options[i];
				var temp = new Array();

				temp.value = first.value;
				temp.innerHTML = first.innerHTML;

				first.value = second.value;
				first.innerHTML = second.innerHTML;

				second.value = temp.value;
				second.innerHTML = temp.innerHTML;

				first.selected = true;
				second.selected = false;
			}
		}
	}
}
function showProperties(field,man,pres,quickc,massed){
	var str='<table class="small" cellpadding="2" cellspacing="0" border="0"><tr><th>'+field+'</th></tr>';
	if (man == 0 || man == 2)
 		str = str+'<tr><td>'+arrJsPopLabel['REQUIREDFIELDS']+'</td></tr>';
	if (pres == 0 || pres == 2)
 		str = str+'<tr><td>'+arrJsPopLabel['ENABLE']+'</td></tr>';
	if(massed == 0 || massed == 1)
		str = str+'<tr><td>'+arrJsPopLabel['VISIBLEBULKMODIFICATION']+'</td></tr>';
    //快速创建
    if (quickc == 0 || quickc == 2)
		str = str+'<tr><td>'+arrJsPopLabel['VISIBLERAPIDCREATION']+'</td></tr>';
	str = str + '</table>';
	return str;
}
//页面设置：下拉框字段设定，选择下拉框字段不为空时，下拉框对应的checkbox选项默认选中
function setCheckBox(obj,fieldid){
    if(fieldid !=''){
        if(document.getElementById('defaultvalue_check_'+fieldid) != undefined){
            if(obj.value !='' && obj.value != '--无--'){
                document.getElementById('defaultvalue_check_'+fieldid).checked=true;
            }else{
                document.getElementById('defaultvalue_check_'+fieldid).checked=false;
            }
        }
    }
}
function updateTabDuplicate(module){
	var isduplicate = ld('#tab_isduplicate').val();
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=updateTabDuplicate&parenttab=Settings&modulename='+module+'&ajax=true'+'&isduplicate='+isduplicate, function(response) {
		if(response.indexOf('###SUCCESS###')>-1){
			$('status').style.display = "none";
		}
	});
}


var gselected_fieldtype = '';

var cls_pagelayoutobj=new cls_pagelayout();
//var cls_pagevalidataobj=new  cls_PageValidata();

//wym 230423 页面设置添加“模块管理”按钮返回模块管理界面
function returnToModulemanger(){
	ld("[name=VTLIB_LBL_MODULE_MANAGER]").click();
}

{/literal}

</script>

<link href="themes/softed/Control.css" rel="stylesheet" type="text/css"/>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
			<a style="margin-left: 0px;" id="returnToModulemanger" onclick="returnToModulemanger()">{'VTLIB_LBL_MODULE_MANAGER'|@getFixedLabel}</a>
			&gt; {'LBL_PAGE_SET'|@getFixedLabel} &gt; {$MODULE|@getTranstab}
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
			<a href="javascript:;" class="ld-button ld-button-primary" onclick="fun_createblock('{$MODULE}');" name="btn_addblock" title="{'NEWBLOCK'|@getFixedLabel}">{'NEWBLOCK'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button ld-button-primary" name="btn_add" title="{'CREATE'|@getFixedLabel}" style="display: none;">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="layoutblock" class="cont_wrap clear_float">
            {assign var=entries value=$CFENTRIES}
            {assign var=entries_key value=$CFENTRIESKEYWORDS}
			{if $CFENTRIES.0.tabpresence eq '0' }
			    {if $MODULE eq 'Events'}
			    	{assign var=MODULE value='Calendar'}
			    {/if}
				<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" id="vtbusy_info" style="display:none;position:fixed;top:10%;right:10%;position:fixed; z-index:99;" border="0" />
			    <form action="index.php" method="post" name="currencyForm" onsubmit="puyoungJS_DialogBox.block();">
			  		<input type="hidden" name="module" value="Settings"/>
			  		<input type="hidden" name="action" value="CurrencyEditView"/>
			  		<input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
				    <div class="DivCR">
				        <div class="D_Tab_div tabHieght LayoutBlocklistTable_stickytop marB5" id="LayoutBlocklistTable">
{*				          <table width="100%" cellspacing="0" cellpadding="0" border="0">*}
{*				            <tbody>*}
{*				              <tr>*}
{*				                <td class="L" valign="top">*}
{*				                  <ul>*}
{*				                    <li onclick="cls_pagelayoutobj.changetabcontent(this)" dvidname='cfList'><a class="On">{'FieldLayout'|@getFixedLabel}</a></li>*}
{*				                    <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_pagerule'><a>{'LayoutRules'|@getFixedLabel}</a></li>*}
{*                                     <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_pagevalidata'><a>{'CheckValidataRules'|@getFixedLabel}</a></li>*}
{*									<li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_advance'><a>{'SFAProgress'|@getFixedLabel}</a></li>*}
{*				                    <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_relateinfo'><a>{'MOREINFORMATION'|@getFixedLabel}</a></li>*}
{*									{if $display_quickly_create eq 'yes'}*}
{*									*}{*ls 2021-10-18 【1002087】带分录的表单，页面设置中去掉“快速创建”页签*}
{*				                    <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_quickcreate'><a>{'Quickly_create'|@getFixedLabel}</a></li>*}
{*									{/if}*}
{*									{if $MODULE eq 'Accounts'}*}
{*										<li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_mapviewlist'><a>{'mapviewlist'|@getFixedLabel}</a></li>*}
{*										<li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_mapviewdetails'><a>{'mapviewdetails'|@getFixedLabel}</a></li>*}
{*									{/if}*}
{*									  <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_fieldlist'><a>{'FieldList'|@getFixedLabel}</a></li>*}
{*                                      <li onclick="cls_pagelayoutobj.changetabcontent(this);" dvidname='dv_cfoperationlog'><a>{'CFOPERATIONLOG'|@getFixedLabel}</a></li>*}
{*				                  </ul>*}
{*				                </td>*}
{*				                <td class="R" style="text-align: right;">*}
{*				                </td>*}
{*				              </tr>*}
{*				            </tbody>*}
{*				          </table>*}
				        </div>

				        <div class="pad10" style="padding:0px;">
				          	<div id="cfList">
				            	{include file="Settings/LayoutBlockEntriesNew.tpl"}
				          	</div>
				          	<div id="dv_pagerule" class="" style="display:none">
				          	</div>
              	             <div id="dv_pagevalidata" class="" style="display:none">
				          	</div>
					        <div id="dv_relateinfo" style="display:none;">
					            <div class="divRelateinfo">
					              <div>{'SetDetailRelatedModules'|@getFixedLabel}</div>
					              <div id="dv_relateinfo_content"></div>
					              <div><input type="button" class="ld-button ld-button-primary" onclick="saveRelatedList();" alt="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}"></div>
					            </div>
					        </div>
					        <div id="dv_quickcreate" style="display:none">
					            <div class="divQuickcreate">
					              <div id="dv_quickcreate_content"></div>
					              <div><input type="button" class="ld-button ld-button-primary" onclick="savequickcreatefieldsetting();" alt="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}"></div>
					            </div>
					        </div>
							<div id="dv_mapview" style="display:none">
					            <div class="divQuickcreate">
					              <div id="dv_mapview_content"></div>
					              <div><input type="button" class="createauto" onclick="savemapfield();" alt="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}"></div>
					            </div>
					        </div>
							{*txy BUG0069250 优化自动化进度设置界面隔行换色*}
							<div id="dv_advance" class="DivCTable" style="display:none">
					            <div class="divadvance">
					              <div id="dv_advance_content" style="position: relative;">


								  </div>

									<div class="ctextalign marT10" style="display:none"><input type="button" class="createauto" onclick="AdvanceRelation.saveModuleAdvance();" alt="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}"></div>
					            </div>
					        </div>

							<div id="dv_fieldlist" style="display:none">
								<div class="dvFieldlist">
									<div id="dv_fieldlist_content"></div>
{*									<div><input type="button" class="createauto" onclick="savefieldlist();" alt="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" value="{'SAVE'|@getFixedLabel}"></div>*}
								</div>
							</div>
                            
                            <div id="dv_cfoperationlog" style="display:none">
								<div class="dvcfoperationlog">
									<div id="dv_cfoperationlog_content"></div>									
								</div>
							</div>

				        </div>
				    </div>
			     </form>
			{else}
				<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>
				<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'>
					<tr>
						<td align='center'>
						    <div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
						    	<table border='0' cellpadding='5' cellspacing='0' width='98%'>
							    	<tbody><tr>
							    	<td rowspan='2' width='11%'><img src="{'denied.gif'|@lingdang_imageurl:$THEME}" ></td>
							    	<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>{'NOPERMITTEDEXECUTE'|@getFixedLabel}</span></td>
							    	</tr>
							    	<tr>
							    	<td class='small' align='right' nowrap='nowrap'>
							    	<a href='javascript:window.history.back();'>{'RETURN'|@getFixedLabel}</a><br>								   						     </td>
							    	</tr>
							    	</tbody>
							    </table>
						    </div>
						</td>
					</tr>
				</table>
			{/if}
        </div>
    </div>
</div>

<div id="relatedlistdiv" class="LdPop_box LdPopWidth300px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="relatedlistdiv_blockname" class="D_pop_box LdPopWidth300px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="Quicksetactions_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>

<!--编辑属性-->
<div id="layoutlist_editfield"style="display:none;width:400px;">
<div id="layoutlist_editfield_div"></div>
</div>
<!--新增区块-->
<div id="layoutlist_createblock" style="display:none;width:300px;">
<div id="layoutlist_createblock_div"></div>
</div>
<script>
	var module = '{$MODULE}';
	var isShowMap = '{$isShowMap}';
	var display_quickly_create = '{$display_quickly_create}';
    var display_validata_rule = '{$display_validata_rule}';
    var display_advance = '{$display_advance}';
	var languageType = '{$LANGUAGETYPE}';
	var LayoutBlocklist = ['FieldLayout','LayoutRules','CheckValidataRules','SFAProgress','MOREINFORMATION','Quickly_create','mapviewlist','mapviewdetails','DataDictionary','CFOPERATIONLOG'];
	var tablewidth = parseInt(ld('#LayoutBlocklistTable').get(0).clientWidth)-172;
	var listwidth = 0;
	var show_LayoutBlocklist_list = [];
	var show_LayoutBlocklist_more = [];
	for(let i = 0;i<LayoutBlocklist.length;i++){
		var bnt_lable = '';
		var dvidname = '';
		switch (LayoutBlocklist[i]){
			case 'FieldLayout':
				bnt_lable = "{'FieldLayout'|@getFixedLabel}";
				dvidname = 'cfList';
				break;
			case 'LayoutRules':
				bnt_lable = "{'LayoutRules'|@getFixedLabel}";
				dvidname = 'dv_pagerule'
				break;
			case 'CheckValidataRules':
                if(display_validata_rule != 'no'){
                    bnt_lable = "{'CheckValidataRules'|@getFixedLabel}";
				    dvidname = 'dv_pagevalidata';
                }
				break;
			case 'SFAProgress':
                if(display_advance != 'no'){
                    bnt_lable = "{'SFAProgress'|@getFixedLabel}";
				    dvidname = 'dv_advance';
                }
				break;
			case 'MOREINFORMATION':
				bnt_lable = "{'MOREINFORMATION'|@getFixedLabel}";
				dvidname = 'dv_relateinfo';
				break;
			case 'Quickly_create':
				if(display_quickly_create == 'yes'){
					bnt_lable = "{'Quickly_create'|@getFixedLabel}";
					dvidname = 'dv_quickcreate';
				}
				break;
			case 'mapviewlist':
				if(module == 'Accounts' || isShowMap == 'yes'){
					bnt_lable = "{'mapviewlist'|@getFixedLabel}";
					dvidname = 'dv_mapviewlist';
				}else{
					bnt_lable = '';
				}
				break;
			case 'mapviewdetails':
				if(module == 'Accounts' || isShowMap == 'yes'){
					bnt_lable = "{'mapviewdetails'|@getFixedLabel}";
					dvidname = 'dv_mapviewdetails';
				}else{
					bnt_lable = '';
				}
				break;
			case 'DataDictionary':
				bnt_lable = "{'DataDictionary'|@getFixedLabel}";
				dvidname = 'dv_fieldlist';
				break;
			case 'CFOPERATIONLOG':
				bnt_lable = "{'CFOPERATIONLOG'|@getFixedLabel}";
				dvidname = 'dv_cfoperationlog';
				break;
			default:
				break;

		}
		if(bnt_lable.length > 0) {
			if (languageType == 'zh') {
				listwidth += (bnt_lable.length * 12) + 40;
			} else {
				listwidth += (bnt_lable.length * 7) + 40;
			}
			var bnt_info = {};
			bnt_info['lable'] = bnt_lable;
			bnt_info['dvidname'] = dvidname;
			if(listwidth<tablewidth){
				show_LayoutBlocklist_list.push(bnt_info);
			}else{
				show_LayoutBlocklist_more.push(bnt_info);
			}
		}
	}
	var LayoutBlocklist_content = '<table width="100%" cellspacing="0" cellpadding="0" border="0">';
	LayoutBlocklist_content += '<tbody>';
	LayoutBlocklist_content += '<tr>';
	LayoutBlocklist_content += '<td class="L" valign="top">';
	LayoutBlocklist_content += '<ul>';
	for(let i = 0;i<show_LayoutBlocklist_list.length;i++){
		if(i == 0){
			LayoutBlocklist_content += '<li onclick="cls_pagelayoutobj.changetabcontent(this)" dvidname="'+show_LayoutBlocklist_list[i]['dvidname']+'"><a class="On">'+show_LayoutBlocklist_list[i]['lable']+'</a></li>';
		}else {
			LayoutBlocklist_content += '<li onclick="cls_pagelayoutobj.changetabcontent(this)" dvidname="' + show_LayoutBlocklist_list[i]['dvidname'] + '"><a>' + show_LayoutBlocklist_list[i]['lable'] + '</a></li>';
		}
	}
	if(show_LayoutBlocklist_more.length > 0){
		LayoutBlocklist_content += '<li class="LayoutBlocklistTable_bntmore"><a>'+'{"MORE"|@getFixedLabel}'+'<i class="relationdown"></i></a><ul class="LayoutBlocklistTable_more">';
		for(let i = 0;i<show_LayoutBlocklist_more.length;i++){
			LayoutBlocklist_content += '<li onclick="cls_pagelayoutobj.changetabcontent(this)" dvidname="' + show_LayoutBlocklist_more[i]['dvidname'] + '"><span>' + show_LayoutBlocklist_more[i]['lable'] + '</span></li>';
		}
		LayoutBlocklist_content += '</ul></li>';
	}
	LayoutBlocklist_content += '</ul>';
	LayoutBlocklist_content += '</td>';
	LayoutBlocklist_content += '</tr>';
	LayoutBlocklist_content += '</tbody>';
	LayoutBlocklist_content += '</table>';
	ld('#LayoutBlocklistTable').append(LayoutBlocklist_content);
{literal}
//页面设置拖动
layoutblockEventClick();

{/literal}

</script>
<style>
	.LayoutBlocklistTable_bntmore:hover .LayoutBlocklistTable_more{
		display: block;
	}
	.LayoutBlocklistTable_more{
		font-size: 13px;
		position: absolute;
		z-index: 999;
		top: 46px;
		display: none;
		width: 180px;
		overflow: hidden;
		overflow-x: auto;
		background-color: #fff;
		border: 1px solid #bbbbbb;
		border-bottom-color: rgb(187, 187, 187);
		border-bottom-style: solid;
		border-bottom-width: 1px;
		border-bottom: 3px solid #bbbbbb;
		border-radius: 4px;
	}
	.LayoutBlocklistTable_more li{
		line-height: 100%;
		width: 100%;
		height: 35px;
		cursor: pointer;
		line-height: 35px;
		color: #3B7CFF;
	}
	.LayoutBlocklistTable_more li:hover{
		background-color: #e7f4fe;
	}
	.LayoutBlocklistTable_more li span{
		float: left;
		text-decoration: none;
		text-align: left;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		height: 35px;
		line-height: 35px;
		padding: 0 10px;
	}
	.relationdown{
		display: inline-block;
		width: 16px;
		height: 7px;
		margin-left: 6px;
		background: url("./themes/icon/down.png") no-repeat center;
		top: -2px;
		position: relative;
	}
	.LayoutBlocklistTable_stickytop{
		position: sticky;
		top: 0;
		background-color: #fff;
		z-index: 99;
	}
</style>
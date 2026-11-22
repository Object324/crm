<!-- quick create UI starts -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>帮我吧服务管理平台</title>
<meta name="keywords" content="帮我吧服务管理平台" />
<meta name="description" content="" />
<!-- <script type="text/javascript" src="../include/jquery/jquery-3.5.1.min.js"></script> -->
<script type="text/javascript" src="../include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="../include/jquery/jquery-migrate.min.js"></script>
<script type="text/javascript" src="../include/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" src="../include/jquery/jquery.percentageloader.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
	var language='{$LANUGAGETYPE}';
	if(language=='zh')
	{ldelim}
		language='zh-cn';
	{rdelim}
</script>
<script language="JavaScript" type="text/javascript" src="../include/language/{$LANUGAGETYPE}.js"></script>
<script language="javascript" type="text/javascript" src="../include/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/picklist.js"></script>
<script type='text/javascript' src='../modules/Reminds/Reminds.js' language="javascript"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/QuickCreate.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/language/zh.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/popupselectfield.js"></script>
<script type="text/javascript" src="../include/js/FieldDependencies.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/CommonPagePopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/PopupDrag.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/CrmPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/QcPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/selectSearchPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/PageRecordPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/PopupLayer.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/MassEditPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/CreatePagePopup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/PopupUserGroup.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/SaveDataRecord.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/selectSearchField.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/webuploader/webuploader.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/webuploader.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="../include/js/SystemPopup/ComboxPopup.js"></script>
<script language="javascript" type="text/javascript" src="../My97DatePicker/WdatePicker.js"></script>

<link rel="stylesheet" type="text/css"  href="../themes/softed/style.css"/>
<link rel="stylesheet" type="text/css"  href="../themes/softed/selfstyle.css"/>
<link rel="stylesheet" type="text/css"  href="../themes/softed/global.css"/>
<link rel="stylesheet" type="text/css"  href="../themes/softed/popup.css"/>
<link rel="stylesheet" type="text/css"  href="../themes/softed/liststyle.css"/>
<link rel="stylesheet" type="text/css"  href="../themes/softed/PickList.css"/>
</head>
<body>
<div id="selectrelateddiv" class="D_pop_box LdPopWidth800px" style="display:none; z-index:10000;"></div>
<div id="div_pagerecord" class="DivC">
<div class="Top">
<form action="" method="POST" name="QcEditView">
	<input type="hidden" name="save_bw8" value="yes" />
	<input type="hidden" value="Accounts" name="module">
	<input type="hidden" value="" id="record" name="record">
	<input type="hidden" value="{$CLIENTID}" name="clientid">
	<input type="hidden" value="{$AUTHCODE}" name="authCode">
	<input type="hidden" value="{$TYPE}" name="type">
	<input type="hidden" value="{$SUPPORTNAME}" name="supportname">
	
	<table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="1" border="0" style="font-size:12px;margin:0px;">
		<tbody>
			<tr class="lvtColData">
				<td width="50%" align="left"><font color="red">*</font>客户名称:</td>
				<td width="50%">
					<input name="acc_accountname" value="" type="text" style="width:105px;">
				</td>
			</tr>
			<tr class="lvtColData">
				<td width="50%" align="left">公司电话:</td>
				<td width="50%">
					<input name="acc_phone" value="" type="text" style="width:105px;">
				</td>
			</tr>
			<tr class="lvtColData">
				<td width="50%" align="left">地址:</td>
				<td width="50%">
					<textarea name="acc_bill_street" style="height: 50px; width:105px; overflow: hidden; overflow-wrap: break-word; resize: horizontal;"></textarea>
				</td>
			</tr>
			<tr class="lvtColData">
				<td width="50%" align="left">产品类别</td>
				<td width="50%">
					<select name="acc_productcategory" style="width:110px;">
						<option value=""></option>
					 {foreach item=category from=$PRODUCTCATEGORY}
						<option value="{$category}">{$category}</option>
					 {/foreach}
					</select>
				</td>
			</tr>
			<tr class="lvtColData">
				<td width="50%" align="left"><font color="red">*</font>联系人姓名:</td>
				<td width="50%">
					<input name="con_lastname" value="" type="text" style="width:105px;">
				</td>
			</tr>
			<tr class="lvtColData">
				<td width="50%" align="left">手机:</td>
				<td width="50%">
					<input name="con_mobile" value="" type="text" style="width:105px;">
				</td>
			</tr>
		</tbody>
	</table>
<div class="D_pbtn">
<input type="button" name="button" id="btn_save"  class="createauto" style="width:70px;margin-right:0px;" value="保存" onclick="repeat_AccountName(this,this.form);"/>
<span>&nbsp;</span>
<input type="button" name="button" class="cancelauto" style="width:70px;margin-right:0px;" value="取消" onclick="Back('{$SUPPORTNAME}','{$CLIENTID}','{$AUTHCODE}','{$TYPE}')"/>
</div>
</form>
</div>
</div>
<SCRIPT id="qcvalidate">
	var userDateFormat = "{$USER_DATE_FORMAT}";
	var qcfieldname = new Array({$VALIDATION_DATA_FIELDNAME});
	var qcfieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
	var qcfielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
	{literal}
	function Back(supportname,clientid,authcode,stype){
		//alert("bw8accountinfo.php?getList=yes&supportAccount="+supportname+'&clientid='+clientid+'&authCode='+authcode+'&type='+stype);
		window.location="bw8accountinfo.php?restbind=yes&getList=yes&supportAccount="+supportname+'&userId='+clientid+'&authCode='+authcode+'&type='+stype;
	}
	function repeat_AccountName(obj,obj_form){
		if(ld("input[name=acc_accountname]") != undefined){
			var accountname = ld("input[name=acc_accountname]").val();
			var con_lastname = ld("input[name=con_lastname]").val();
			if(accountname == ''){
				var confirm_str = '客户名称不能为空！';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			if(con_lastname == ''){
				var confirm_str = '联系人姓名不能为空！';
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			var url_string = '';
			ld.ajax({
             type: "GET",
             url: "bw8account_create.php",
             data: {accountname:accountname,Ajax:'yes'},
             dataType: "text",
             success: function(data){
				 if(data == '##error##'){
					var confirm_str = '客户名称已存在！';
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					ld("input[name=acc_accountname]").focus();
					ld('#btn_save').removeAttr("disabled");
					return false;
				 }else{
					obj_form.submit();
				 }
             }
			});
		}
	}
	{/literal}
</SCRIPT>
</body>
</html>
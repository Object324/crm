{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/ColorPicker2.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<link rel="stylesheet" href="include/jquery/treeview/jquery.treeview.css" />
<script language="JAVASCRIPT" type="text/javascript" src="include/jquery/treeview/jquery.treeview.js"></script>

<script language="JavaScript" type="text/javascript">

 	var cp2 = new ColorPicker('window');
	
function pickColor(color)
{ldelim}
	ColorPicker_targetInput.value = color;
        ColorPicker_targetInput.style.backgroundColor = color;
{rdelim}	


</script>	

<script language="javascript">
//允许设置用户的角色和数据权限
var ALLSETROLEDATAPROFILE="{$ALLSETROLEDATAPROFILE}";
var USER_MODE="{$USER_MODE}";
function check_registerCount()
{ldelim}
	var recordid=document.EditView.record.value;
	var userstatus;
	if(document.EditView.status != undefined){
		userstatus=document.EditView.status.options[document.EditView.status.selectedIndex].value;
	}
	if (recordid=="")
	{ldelim}
		recordid=-1;
	{rdelim}

	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
		method: 'post',
		postBody: 'module=Users&action=UsersAjax&file=Save&ajax=true&register_check=true&userStatus='+userstatus+'&userid='+recordid,
		onComplete: function(response) {ldelim}
			if(response.responseText.indexOf('SUCCESS') > -1)
			{ldelim}
				if(recordid>0)
				{ldelim}
					document.EditView.submit();
				{rdelim}

				return true;
			{rdelim}
			else
			{ldelim}
				puyoungJS_DialogBox.unblock();
				var confirm_str = response.responseText;
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				{rdelim}
			{rdelim}
		{rdelim}
	);

{rdelim}
function check_duplicate()
{ldelim}
	var user_name = window.document.EditView.user_name.value;
	if(user_name == '')
	{ldelim}
		puyoungJS_DialogBox.unblock();
		return true;
	{rdelim}
	puyoungJS_DialogBox.block();
	var status = CharValidation(user_name,'name');
	var recordid=document.EditView.record.value;
	var userstatus;
	if(document.EditView.status != undefined){
		userstatus=document.EditView.status.options[document.EditView.status.selectedIndex].value;	
	}
	var dup_check=false;
      if (recordid=="")
      {ldelim}
		  recordid=-1;
		  dup_check=true;
      {rdelim}
     
        if(status)
	{ldelim}
        	new Ajax.Request(
                        'index.php',
                        {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: 'module=Users&action=UsersAjax&file=Save&ajax=true&dup_check='+dup_check+'&register_check=yes&userName='+user_name+'&userStatus='+userstatus+'&userid='+recordid,
                                onComplete: function(response) {ldelim}
        							if(response.responseText.indexOf('SUCCESS') > -1)
        							{ldelim}
                                        if(ALLSETROLEDATAPROFILE=='no'&&USER_MODE!='edit')
                                        {
                                          var confirm_str = arrJsPopLabel['USESAVEREMINDROLEPROFILE'];
                                          RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                        }
        							//	$('user_status').disabled = false;
                          document.EditView.submit();			
        							{rdelim}
        			       				else 
                                        {ldelim}
											puyoungJS_DialogBox.unblock();
                                            if(response.responseText.indexOf('用户账户已经存在！') > -1)
                                            {ldelim}
                                          var confirm_str = arrJsPopLabel['USERACCOUNTEXISTS'];
                                          RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                            {rdelim}
                                            else
                                            {ldelim}
                                          confirm_str = response.responseText;
                                          RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                            {rdelim}
        						        {rdelim}
        			            {rdelim}
                        {rdelim}
                );
	{rdelim}
	else
     {ldelim}
                confirm_str = arrJsPopLabel['ACCOUNTBYTO'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		 puyoungJS_DialogBox.unblock();
     {rdelim}
{rdelim}

</script>

<!-- vtlib customization: Help information assocaited with the fields -->
{if $FIELDHELPINFO}
<script type='text/javascript'>
{literal}var fieldhelpinfo = {}; {/literal}
{foreach item=FIELDHELPVAL key=FIELDHELPKEY from=$FIELDHELPINFO}
	fieldhelpinfo["{$FIELDHELPKEY}"] = "{$FIELDHELPVAL}";
{/foreach}
</script>
{/if}

<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />

<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    {if $CATEGORY eq 'Settings'}
    <td class="TdLeft" valign="top" style="width:200px;">
	   {include file='SetMenuNew.tpl'}
    </td>
    {/if}
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form name="EditView" method="POST" action="index.php" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Users"/>
		<input type="hidden" name="record" value="{$ID}"/>
		<input type="hidden" name="mode" value="{$MODE}"/>
		<input type='hidden' name='parenttab' value='{$PARENTTAB}'/>
		<input type="hidden" name="activity_mode" value="{$ACTIVITYMODE}"/>
		<input type="hidden" name="action"/>
		<input type="hidden" name="return_module" value="{$RETURN_MODULE}"/>
		<input type="hidden" name="return_id" value="{$RETURN_ID}"/>
		<input type="hidden" name="return_action" value="{$RETURN_ACTION}"/>			
		<input type="hidden" name="tz" value="Europe/Berlin"/>			
		<input type="hidden" name="holidays" value="de,en_uk,fr,it,us,"/>			
		<input type="hidden" name="workdays" value="0,1,2,3,4,5,6,"/>			
		<input type="hidden" name="namedays" value=""/>			
		<input type="hidden" name="weekstart" value="1"/>
		<input type="hidden" name="hour_format" value="24"/>
		<input type="hidden" name="start_hour" value="08:00"/>
		<input type="hidden" name="form_token" value="{$FORM_TOKEN}"/>
       <input   type="hidden" name="time_zone" value="Asia/Brunei" /> 
        <input type="hidden" name="date_format" value="yyyy-mm-dd"/>
        <input type='hidden' name="activity_view" value="This Week"/> 
        <input type='hidden' name="lead_view" value="Last 2 Days"/>
         <input type='hidden' name="currency_id" value="1"/>
         <input type='hidden' name="language" value="zh_cn"/>
         <input type='hidden' name="currency_grouping_pattern" value="123,456,789"/>
         <input type="hidden" name="currency_decimal_separator" value="."/>
         <input type="hidden" name="currency_grouping_separator" value=","/>
         <input type="hidden" name="currency_symbol_placement" value="$1.0"/>
         <input type='hidden' name="reminder_interval" value="1 Minute"/>
         <input type="hidden"  name="theme" value="softed"/>
         <input type="hidden" name="email2" value=""/>
         <input type="hidden" name="reports_to_id" value=""/>
         <input type="hidden" name="use_asterisk" value="0"/>
         <input type="hidden" name="asterisk_extension" value=""/>
         <input type="hidden" name="secondaryemail" value=""/>
         <input type="hidden" name="phone_other" value=""/> 
         <input type="hidden" name="forumDisplay"/>
         <!--add by tifa 20130216 -->
		<input type="hidden" name="old_password" />
		<input type="hidden" name="new_password" />	
        <input type="hidden" name="changepassword" />
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        
      <div class="DivCR" id="div_pagerecord">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
          		{if $PARENTTAB neq ''}	
					{if $BLOCKIDSETTING > 0 && $FIELDIDSETTING > 0}
						{'CONTROLPANEL'|@getFixedLabel} &gt; 
					{/if}
                        <a href="index.php?module=Administration&action=index&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'LBL_USERS'|@getFixedLabel}</a> &gt; 
					{if $MODE eq 'edit'}
						{'EDIT'|@getFixedLabel} "{$USERNAME}" 
					{else}
						{if $DUPLICATE neq 'true'}
						{'CREATE'|@getFixedLabel}
						{else}
						{'COPY'|@getFixedLabel} "{$USERNAME}"
						{/if}
					{/if}
				{else}       
                    {'PERSONALSETTINGS'|@getFixedLabel}
                {/if}
                
            </span>
        </div>
        <div class="ControlDiv2">
        	<div class="F_l">
            {if $MODE eq 'edit'}
				{'EDITUSERDETAILS'|@getFixedLabel} "{$USERNAME}"
			{/if}
            </div>
        </div>
        <div class="pad10" >
            <table width="100%"  border="0" cellspacing="0" cellpadding="0">
            	<tr>
            		<td nowrap align="center" style="padding-bottom:10px;">
                  <input title="{'SAVE'|@getFixedLabel}" class="saveauto b_radius3"  name="button" value="{'SAVE'|@getFixedLabel}"  onclick="this.form.action.value='Save';if( formValidate()) return FieldDuplicateValidate('Users',this.form);else return false; " style="width: 70px;" type="button" />
                  <input title="{'CANCEL'|@getFixedLabel}" class="cancelauto b_radius3" name="button" value="{'CANCEL'|@getFixedLabel}" onclick="window.history.back()" style="width: 70px;margin-left: 10px;" type="button" />
           			</td>
                </tr>
            	<tr>
            		<td align="left">
            				{foreach key=header name=blockforeach item=data from=$USERBLOCKS}
            				        <!--
                                zyh
                                新增修改时不显示附件
                                PROT197 
                                20150420
                            -->
                            {if $header eq '附件'}
                                <table style="display:none"></table>
                            {else}
                				<table class="ControlTable1 TitleHeading noborderB" border="0" cellpadding="0" cellspacing="0" width="100%">
                					<tr>
                						{strip}
                						 <th colspan="2" align="left">
                						  {$smarty.foreach.blockforeach.iteration}. {$header}
                						 </th>
                						 
                					  {/strip}
                					</tr>
                				</table>
                            {/if}
            				<table class="DetailContentTable" border="0" cellpadding="0" cellspacing="0" width="100%">
            				<!-- Handle the ui types display -->
            					{include file="DisplayFields.tpl"}
            				</table>
            				{assign var=list_numbering value=$smarty.foreach.blockforeach.iteration}
            			   {/foreach}
            					 
            				<!-- Added for User Based TagCloud -->
            				<table style="display:none" class="TitleHeading" border="0" cellpadding="5" cellspacing="0" width="100%">
            					<tr>
            						 <td class="big">
            							<strong>{$list_numbering+2}. {$UMOD.LBL_TAGCLOUD_DISPLAY}</strong>
            						 </td>
            						 <td align="right">&nbsp;</td>
            					</tr>
            				</table>
            				<!-- End of Header -->
                            <table style="display:none" border="0" cellpadding="5" cellspacing="0" width="100%">
            					<tr>
            						<td class="dvtCellLabel" align="right" width="30%" style="display:none">{$UMOD.LBL_TAG_CLOUD}</td>
            						{if $TAGCLOUDVIEW eq 'true'}
            						<td class="dvtCellInfo" align="center" width="5%"><input name="tagcloudview" value="true"  type="radio"></td>
            						<td class="dvtCellInfo" align="left" >{$UMOD.LBL_SHOW}</td>
            						<td class="dvtCellInfo" align="center" width="5%"><input name="tagcloudview" value="false" checked type="radio"></td>
            						<td class="dvtCellInfo" align="left">{$UMOD.LBL_HIDE}</td>
            						{else}
            						<td class="dvtCellInfo" align="center" width="5%"><input name="tagcloudview" value="true" type="radio"></td>
            						<td class="dvtCellInfo" align="left">{$UMOD.LBL_SHOW}</td>
            						<td class="dvtCellInfo" align="center" width="5%"><input name="tagcloudview" value="false" checked type="radio"></td>
            						<td class="dvtCellInfo" align="left">{$UMOD.LBL_HIDE}</td>
            						{/if}
            					</tr>
            			   </table>
                    		<!--end of Added for User Based TagCloud -->
                </td>
            	</tr>										
            				
            	<tr>
            		<td colspan=4 align="center" style="padding-top:10px;">
            			<input title="{'SAVE'|@getFixedLabel}" class="saveauto b_radius3"  name="button" value="{'SAVE'|@getFixedLabel}"  onclick="this.form.action.value='Save';if( formValidate()) return FieldDuplicateValidate('Users',this.form);else return false; " style="width: 70px;" type="button" />
            			<input title="{'CANCEL'|@getFixedLabel}" class="cancelauto b_radius3" name="button" value="{'CANCEL'|@getFixedLabel}" onclick="window.history.back()" style="width: 70px;margin-left: 10px;" type="button" />
      						<!-- 高级用户设置 -->
      						<input type="hidden" name="scopeuserid" id="scopeuserid" value=""/>
      						<input type="hidden" name="scopeuserid_name" id="scopeuserid_name"/>
      						<!-- 必须选中 -->
      						<input type="hidden" name="selectscopeuserid" id="selectscopeuserid" value="{$ID}"/>
            		</td>
            	</tr>							
            </table>
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->
{include file='EditViewBottom.tpl'}

<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
{$JAVASCRIPT}
<script type='text/javascript' language='JavaScript'>
var mode = "{$MODE}";
var duplicate = "{$DUPLICATE}";
var isadmin = "{$IS_ADMIN}";
var lbl_viewuser_title = "{'SELECTUSER'|@getFixedLabel}";
var lbl_viewuser_close = "{'CLOSE'|@getFixedLabel}";
var fieldinfoobjs = '';
var PageRecordPopupobj=PageRecordPopup.load("Users");
PageRecordPopupobj.fieldname={$VALIDATION_DATA_FIELDNAME};
 PageRecordPopupobj.fieldlabel={$VALIDATION_DATA_FIELDLABEL};
 PageRecordPopupobj.fielddatatype={$VALIDATION_DATA_FIELDDATATYPE};
 
{literal}
function set_password(form) {
/**
 * @by andy
 * @reason 0008213: 非管理员：个人设置界面，修改密码，当用户的旧密码为空时，无法修改密码系统提示：请输入您的旧密码!
 * @date 20140527
 * @others NONE
*/
    /*
	if (form.is_admin.value == 1 && trim(form.old_password.value) == "") {
		alert(arrJsPopLabel['ENTEROLDPASSWORD']);
		return false;
	}*/
	if (trim(form.new_password.value) == "") {
		var confirm_str = arrJsPopLabel['ENTERNEWPASSWORD'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	if (trim(form.confirm_new_password.value) == "") {
		var confirm_str = arrJsPopLabel['ENTERNEWPASSWORDAGAIN'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    var formname=document.forms['ChangePassword'];
	if (trim(form.new_password.value) == trim(form.confirm_new_password.value)) {
		   if (form.is_admin.value == 1) document.EditView.old_password.value = encodeURIComponent(form.old_password.value);
		document.EditView.new_password.value = encodeURIComponent(form.new_password.value);
		document.EditView.return_module.value = 'Users';
		document.EditView.return_action.value = 'EditView';
		document.EditView.changepassword.value = 'true';
		document.EditView.return_id.value =document.EditView.record.value;
		document.EditView.action.value = 'Save';
		document.EditView.submit();
		return true;       
       
	}
	else {
		var confirm_str = arrJsPopLabel['PASSWORDINCONSISTENT'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
}
//创建用户时，默认全景为选择状态
window.onload = function(){
	/**
	 * 创建时默认客户全景就是选择的，并没有区分是否为复制模式
	 * 现在添加是否复制判断，复制时不对客户全景做修改
	 * @reason 0013925: 控制面板 > 用户管理 ：复制功能错误。
	 * @author Tujt 2015-03-10
	 */
	if('create' == mode && !duplicate){
	//	document.EditView.accountallview.checked = true;16133: 用户资料中的checkbox选项的默认值应该从数据库中设置，而不是代码控制
	}
	if(isadmin){//管理员
		//获取单选框对象（三个）
		var userset = ld('form[name=EditView] input[name=scopeauthority]');
		var userimg = ld(userset).parent().find('img');//获取高级单选框旁边的img图标对象
		//给单选框添加鼠标移入移出事件
		ld(userset).on('mouseover',function(){
			ld(userset).css('cursor','pointer');
		});
		ld(userset).on('mouseout',function(){
			ld(userset).css('cursor','');
		});
		ld(userset).on('click',function(){//点击高级单选框时，调用图标事件
			if('2' == ld(this).val()){//高级
				ld(userimg).click();
			}
		});
		//给图标对象添加移入移出事件
		ld(userimg).on('mouseover',function(){
			ld(userimg).css('cursor','pointer');
		});
		ld(userimg).on('mouseout',function(){
			ld(userimg).css('cursor','');
		});
		//点击图标，弹出高级用户弹出层
		ld(userimg).on('click',function(){
			getJsScript('include/jquery/treeview/jquery.treeview.js',function(){
                getJsScript('include/js/higerUser.js',function(){
					userset[2].checked = true;
					var obj = {'field':'scopeuserid','type':'userscope'};
                    ViewUserPopup(obj);
                });
            });
		});
	}
}
{/literal}
</script>
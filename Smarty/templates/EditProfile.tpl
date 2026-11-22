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
{literal}
<style>
.showTable{
	display:inline-table;
}
.hideTable{
	display:none;
}
</style>
{/literal}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>

<div id="moduleoption">
	<form action="index.php" method="post" name="profileform" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Users">		
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="action" value="{$ACTION}">		
		<input type="hidden" name="mode" value="{$MODE}">	
		<input type="hidden" name="profileid" id="profileid" value="{$PROFILEID}">
		<input type="hidden" name="profile_name" value="{$PROFILE_NAME}">
		<input type="hidden" name="profile_description" value="{$PROFILE_DESCRIPTION}">
		<input type="hidden" name="parent_profile" value="{$PARENTPROFILEID}">
		<input type="hidden" name="radio_button" value="{$RADIOBUTTON}">	
		<input type="hidden" name="return_action" value="{$RETURN_ACTION}">	
		<input type="hidden" name="return_module" value="{$RETURN_MODULE}"/>
	  
		<input type="hidden" name="description" value="{$PROFILE_DESCRIPTION}"/>
		<input type="hidden" name="parentrole" value="{$PARENTROLE}"/>
		<input type="hidden" name="copyRoleId" value="{$COPYPROFILEID}" />
		<input type='hidden' name="copyRole" value="{$copyRole}"/>
		<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
		<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        <input type="hidden" name="maxActionId" value="{$MAXACTIONID}"/>

		<div id="EditProfilePopHead">
			<div class="ld-pop-container padB0">
				<div class="ld-pop-contnet-title-items">
					<div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
				</div>
			</div>
			<table class="ld-public-content-small padB0" border="0" cellpadding="0" cellspacing="0" width="100%" style="position: sticky;top: 0px;z-index: 99;">
				<tbody>
					<tr style="position: sticky;top: 42px;background-color: #fff;">
						<td class="ld-form-item-label"><font color="red">*</font>{'ROLENAME'|@getFixedLabel}</td>
						<td class="ld-form-item-content">
							{assign var=tcopy value='COPY'|@getFixedLabel}
							{if $RESOURCE eq $tcopy}
								<input class="ld-input-inner" id="profilename" name="profilename" type="text" value="" style="width:90%" />
							{else}
								{*zxm 2020-1123 推广大使角色不允许修改名称*}
								{if $PROFILE_NAME eq "推广大使"}
									{$PROFILE_NAME}
									<input type="hidden" class="ld-input-inner" id="profilename" name="profilename" type="text" value="{$PROFILE_NAME}"  style="width:90%" />
								{else}
									<input class="ld-input-inner" id="profilename" name="profilename" type="text" value="{$PROFILE_NAME}"  style="width:90%" />
								{/if}
							{/if}
						</td>
						<td class="ld-form-item-label">{'DESCRIPTION'|@getFixedLabel}</td>
						<td class="ld-form-item-content">
							{*wym 230727 加上了最小高度，使不输入值时不会出现滚动条影响美观，以及与其他输入框保持同高度*}
							<textarea style="resize: vertical;min-height: 30px" class="ld-textarea-inner" rows="1" name="description" id="description">{$PROFILE_DESCRIPTION}</textarea>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		{include file="RolesProfile/RolesProfileContent.tpl"}
	</form>
</div>
<script language="javascript" type="text/javascript">
var oftenusereporttabid='{$OFTENUSEREPORTTABID}';
var reportnames='{$OFTENREPORTNAMES}';
var mobilereportnames='{$MOBILEREPORTNAMES}';
var all_tabid = '{$ALLTABLEID}';
{literal}
//initialiseprofile();
//edit:can 20200724 42095: (61mis.com/kfbcrm)成员管理>序时簿界面：角色权限列点击“销售人员”，点击“编辑”按钮，“销售线索”点击全选没反应
if(typeof checkMember=='undefined')
     AjaxJSPage( "Role_js", 'include/js/Settings/Roles.js');
function btnCancel(obj,event)
{
window.location.href="index.php?module=Settings&action=listroles&parenttab=Settings";
}
window.onload = function(){
	$('profilename').focus();
    $('tab_chk_com_75').checked = true;  //zyh 20150515 0014981
}
{/literal}
</script>
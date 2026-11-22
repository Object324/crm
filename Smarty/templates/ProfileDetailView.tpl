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
<div id="moduleoption">
	<form method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="action" value="createrole">{* PRFILEPRIVILEGES *}
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="return_action" value="listroles.php">
		<input type="hidden" name="mode" value="edit">
		<input type="hidden" name="profileid" value="{$PROFILEID}">
		<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
		<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
		
		<div id="EditProfilePopHead">
			<div class="ld-pop-container padB0">
				<div class="ld-pop-contnet-title-items">
					<div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
				</div>
			</div>
			<table class="ld-public-content-small padB0" border="0" cellpadding="0" cellspacing="0" width="100%" style="position: sticky;top: 0px;z-index: 99;">
				<tbody>
					<tr style="background-color: #fff;">
						{* wyt 221008 BUG0057240 角色权限，图中部分加上冒号 *}
						<td class="ld-form-item-label"><font color="red">*</font>{'ROLENAME'|@getFixedLabel}:</td>
						<td class="ld-form-item-content">
							<span style="margin-left:5px;" id="rolename" name="rolename">{$PROFILE_NAME}</span>
						</td>
						<td class="ld-form-item-label">{'DESCRIPTION'|@getFixedLabel}:</td>
						<td class="ld-form-item-content">
							<span style="margin-left:5px;">{$PROFILE_DESCRIPTION}</span>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		{* 设定每个模块的权限 begin *}
		{include file="RolesProfile/RolesProfileContent.tpl"}
		{* 设定每个模块的权限 end *}
	</form>
</div>
<div id="selectModuleFieldList"></div>
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
{if $navbar_type eq 'setusers'}
	<div id="SetUsers_BtnArea" style="padding: 16px;float: right;">
		<input name="adduser" class="ld-button ld-button-primary" id="adduser" value="{'AddUser'|@getFixedLabel}" type="button">
	</div>
	<div id="SetUsersTableDiv" class="ld-table-container ld-table-container-lines" style="padding: 0px 16px;">
		<table class="ld-rolesprofile-setuserstable"  border="0" cellpadding="0" cellspacing="0" width="100%">
			<thead>
				<tr>
					<th style="width:20%;">{$setusers_tableheader[0]}</th>
					<th style="width:30%;">{$setusers_tableheader[1]}</th>
					<th style="width:40%;">{$setusers_tableheader[2]}</th>
					<th style="width:10%;">{$setusers_tableheader[3]}</th>
				</tr>
			</thead>
			{if !empty($allUsersInfo_arr)}
				{foreach key=userid item=userinfo from=$allUsersInfo_arr}
					<tr name="userTr" userid="{$userid}">
						<td style="">{$userinfo.last_name}</td>
						<td style="">{$userinfo.groupname}</td>
						<td style="">{$userinfo.userlevel}</td>
						<td>
							<a href="javascript:;" name="deleteuser" class="Anu3_a" data-userid="{$userid}"><span>{'DELETE'|@getFixedLabel}</span></a>
						</td>
					</tr>
				{/foreach}
			{else}
				<td colspan="4" style="text-align: center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
			{/if}
		</table>
	</div>
{else}
	{include file="RolesProfile/RolesProfileContent.tpl"}
	{* 底部 *}
	<div class="ld-rolesprofile-listviewright-bottom" id="RolesProfile_RightBottom">
		<div style="display: flex;">
			<div id="selectall">
				<input type="checkbox" onclick="hideTabAll();" id="all_tab" name="all_tab" style="">
				<span>{'ALLSELECT'|@getFixedLabel}</span>
			</div>
			<div id="quickpremission" style="margin-left: 32px;">
				<span>{'SELECTTHESELECTEDPERMISSIONS'|@getFixedLabel}</span>
				<div class="ld-form-item-content" style="width: 130px;margin-left: 16px;">
					{$profileactionhtml}
				</div>
				<div class="select-input" style="margin-left: 16px;">
					<input type="radio" onclick="hideAllTabProfile('open')" name="all_tabprofile">
					<label class="padR10">{'Authorize'|@getFixedLabel}</label>
					<input type="radio" onclick="hideAllTabProfile('close')"  name="all_tabprofile">
					<label class="padR10">{'RevokePermissions'|@getFixedLabel}</label>
				</div>
			</div>
		</div>
		<div>
			<input name="saveroleprofile" class="ld-button ld-button-primary" id="saveroleprofile" value="{'SAVE'|@getFixedLabel}" type="button">
		</div>
	</div>
{/if}
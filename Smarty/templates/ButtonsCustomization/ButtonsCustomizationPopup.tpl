{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/WorkflowCustomization.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
<form action="index.php" method="post" name="ButtonsCustomization" >
	<input type="hidden" name="tabid" value="{$FROMMODULE_TABLE}" />
	<input type="hidden" name="workflow_id" value="{$WORKFLOW_ID}" />
	<div class="divPopOverflow padT20">
		{* 基本信息 *}
		<div class="ld-pop-container padT0 padB0">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'BASICINFORMATION'|@getFixedLabel}</div>
			</div>
		</div>
		<table class="ld-public-content-small" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'suoshumodule'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					{if $MODE eq 'edit'}
						<span>{$buttoninfo_arr.modulelabel}</span>
					{* 新增时可通过下拉框选择模块 *}
					{else}
						<select name="selectmodule" class="ld-select-inner" fieldtype="selecttype">
							{foreach item=moduleinfo from=$optionmodule_arr}
								<option value="{$moduleinfo.tabid}" {if $moduleinfo.tabid eq $FROMMODULE_TABLE}selected{/if}>{$moduleinfo.label}</option>
							{/foreach}
						</select>
					{/if}
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">{'ACTIVATE'|@getFixedLabel}</td>{*wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”*}
				<td class="ld-form-item-content">
					<input type="checkbox" name="is_active" class="second_switch" {if $buttoninfo_arr.is_active eq 'yes'}checked{/if}/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'ButtonName'|@getFixedLabel}（ZH）</td>
				<td class="ld-form-item-content">
					<input type="text" id="button_label_zh" name="button_label_zh" value="{$buttoninfo_arr.label_zh}" size="100" class="ld-input-inner"/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'ButtonName'|@getFixedLabel}（EN）</td>
				<td class="ld-form-item-content">
					<input type="text" id="button_label_en" name="button_label_en" value="{$buttoninfo_arr.label_en}" size="100" class="ld-input-inner"/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					{'REMARK'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<textarea class="ld-textarea-inner" tabindex="d" fieldonly="0" name="description" id="description" cols="90" style="overflow-y:auto; overflow-wrap: break-word;">{$buttoninfo_arr.description}</textarea>
				</td>
			</tr>
		</table>
		{* 按钮位置 *}
		<div class="ld-pop-container padT8 padB0">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'ButtonPosition'|@getFixedLabel}</div>
			</div>
		</div>
		<table class="ld-public-content-small" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="ld-form-item-label">
					{$btnposition_label_arr.pc_detail}
				</td>
				<td class="ld-form-item-content">
					<input type="checkbox" name="btnposition" data-name="pc_detail" class="second_switch" {$buttoninfo_arr.pc_detail}/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					{$btnposition_label_arr.pc_listlink}
				</td>
				<td class="ld-form-item-content">
					<input type="checkbox" name="btnposition" data-name="pc_listlink" class="second_switch" {$buttoninfo_arr.pc_listlink}/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					{$btnposition_label_arr.mobile_detail}
				</td>
				<td class="ld-form-item-content">
					<input type="checkbox" name="btnposition" data-name="mobile_detail" class="second_switch" {$buttoninfo_arr.mobile_detail}/>
				</td>
			</tr>
		</table>
		{* 按钮权限 *}
		<div class="ld-pop-container padT8 padB0">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'ButtonPermissions'|@getFixedLabel}（{'EmptyMeansEveryoneCanOperate'|@getFixedLabel}）</div>
			</div>
		</div>
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
			<tr id="role_name_tr">
				<td class="ld-form-item-label">
					{'SPECIFYROLE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<div>
						<input class="ld-input-inner-div ld-input-inner-add" type="text" name="role_name" id="role_name" readonly="true" value="{$PROFILENAME}" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
						<input type="hidden" name="user_role" id="user_role" value="{$PROFILEID}"/>
						<a class="ld-text-clear" href="javascript:;" title="清除" onclick="ld('#role_name').val('');ld('#user_role').val('');">+</a>
						<a class="ld-text-select" href="javascript:selectPopupProfile('user_role','{'SPECIFYROLE'|@getFixedLabel}');">+</a>
					</div>
				</td>
			</tr>
			<tr id="username_tr" >
				<td class="ld-form-item-label">{'SPECIFYUSER'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<div>
						<div class="ld-input-inner-div ld-input-inner-add" type="text" name="userid_name" id="userid_name" readonly="true"  onclick="approve_selectuser();" value="{$USERNAME}" style="overflow: hidden;">{$USERNAME}</div>
						<input type="hidden" name="userid" id="userid" value="{$USERID}"/>
						<a class="ld-text-clear" href="javascript:;" title="清除" onclick="ld('#userid_name').html('');ld('#userid').val('');">+</a>
						<a class="ld-text-select" href="javascript:;" onclick="approve_selectuser();">+</a>
					</div>
				</td>
			</tr>
			<tr class="ChangeApprove">
				<td class="ld-form-item-label">{'USERFIELD'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select name="selectuserfields" class="selectfields" multiple="">
						{foreach key=fieldid  item=fieldlabel from=$userfields_arr}
							<option value="{$fieldid}" {if $USERFIELDID|@is_array && $fieldid|in_array:$USERFIELDID}selected{/if} >{$fieldlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
		</table>
		<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
		<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
		<div name='adv_filter_div'>
			{include file="ButtonsCustomization/ButtonsCustomizationAdvSearch.tpl"}
		</div>
		{* 工作流操作区块 *}
		{include file='WorkflowCustomization/WorkflowCustomizationActionBlock.tpl'}
	</div>
</form>
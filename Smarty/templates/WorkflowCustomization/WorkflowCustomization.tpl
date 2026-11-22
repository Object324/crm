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
<form action="index.php" method="post" name="workflow" >
<input type="hidden" name='mode' value="save"/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="WorkflowCustomizationSave"/>
<input type="hidden" name="tabid" value="{$FROMMODULE_TABLE}" /> 
<input type="hidden" name="workflow_id" value="{$WORKFLOW_ID}" /> 
<input type="hidden" name="jdyisv" value="{$JDYISV}" />
	<div class="divPopOverflow padT20">
		<div class="ld-pop-container padT0 padB0">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'BASICINFORMATION'|@getFixedLabel}</div>
			</div>
		</div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ld-public-content-small">
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'suoshumodule'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<!-- BUG0058298 20230425 列表选择全部时，新增页可以选择其他模块，列表选择某一模块时，新增页不可再选其他模块 -->
					{if  $frommodule_tabid lt 0 and ($WORKFLOW_ID eq ''|| $WORKFLOW_ID eq '0')}
						<select name="flowmodulelist" class="btn-radius-system width150" fieldtype="selecttype">

							{foreach key=listindex item=arr from=$TabList}
								{if  $tabid eq $arr.tabid}
									<option value="{$arr.tabid}" selected="">{$arr.tabname}</option>
								{else}
									<option value="{$arr.tabid}">{$arr.tabname}</option>
								{/if}
							{/foreach}
						</select>
						<span style="display:none" name="workflowmodulelabel">{$MODULENAME}</span>
					{else}
						<span>{$MODULENAME}</span>
						<select name="flowmodulelist" style="display:none">
						</select>
					{/if}
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">{'ACTIVATE'|@getFixedLabel}</td>{*wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”*}
				<td class="ld-form-item-content">
					<input type="checkbox" name="workflow_status" class="second_switch" {if $DATA.status eq 'Active'}checked{/if} tag="status" workflow_id={$workflow_id} />
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'WorkflowName'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input type="text" id="workflow_name" tag="{'WorkflowName'|@getFixedLabel}" name="workflow_name" value="{$DATA.name}" size="100" class="ld-input-inner"/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					{'REMARK'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<textarea class="ld-textarea-inner" tabindex="d" fieldonly="0" name="workflow_description" id="workflow_description" cols="90">{$DATA.description}</textarea>
				</td>
			</tr>
		</table>
		<div class="ld-pop-container padT8 padB0">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'ApplicationScenarios'|@getFixedLabel}</div>
			</div>
		</div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ld-public-content-small">
			<tr>
				<td class="ld-form-item-label">{'TriggerTime'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<div style="position: relative;float: left;" class="select-input">
						<input type="radio" id="workflow_triggertime_Creation" name="workflow_triggertime"  value="Creation" {if $DATA.triggertime eq 'Creation' || $DATA.triggertime eq ''}checked{/if}>
						<label for="workflow_triggertime_Creation">{'NEW'|@getFixedLabel}</label>

						<input type="radio" id="workflow_triggertime_Updated" name="workflow_triggertime" value="Updated" {if $DATA.triggertime eq 'Updated'}checked{/if} style="margin-left: 15px;">
						<label for="workflow_triggertime_Updated">{'UpdatedIncludesCreation'|@getFixedLabel}</label>
						{if $haveApproval eq 'yes'}
							<input type="radio" id="workflow_triggertime_Approval" name="workflow_triggertime" value="Approval" {if $DATA.triggertime eq 'Approval'}checked{/if} style="margin-left: 15px;">
							<label for="workflow_triggertime_Approval">{'APPROVAL'|@getFixedLabel}</label>
						{/if}
						{if $haveAdvance eq 'yes'}
							<input type="radio" id="workflow_triggertime_Advanced" name="workflow_triggertime" value="Advanced" {if $DATA.triggertime eq 'Advanced'}checked{/if} style="margin-left: 15px;">
							<label for="workflow_triggertime_Advanced">{'ADVANCE'|@getFixedLabel}</label>
						{/if}
						{if $haveAllocate eq 'yes'}
							<input type="radio" id="workflow_triggertime_Allocated" name="workflow_triggertime" value="Allocated" {if $DATA.triggertime eq 'Allocated'}checked{/if} style="margin-left: 15px;">
							<label for="workflow_triggertime_Allocated">{'ALLOCATE'|@getFixedLabel}</label>
						{/if}

						<input type="radio" id="workflow_triggertime_Shared" name="workflow_triggertime" value="Shared" {if $DATA.triggertime eq 'Shared'}checked{/if} style="margin-left: 15px;">
						<label for="workflow_triggertime_Shared">{'SHARE'|@getFixedLabel}</label>

						<input type="radio" id="workflow_triggertime_Deleted" name="workflow_triggertime" value="Deleted" {if $DATA.triggertime eq 'Deleted'}checked{/if} style="margin-left: 15px;">
						<label for="workflow_triggertime_Deleted">{'DELETE'|@getFixedLabel}</label>
					</div>
				</td>
			</tr>
			<tr name="tr_RepeatMode" {if $DATA.triggertime eq 'Updated' || $DATA.triggertime eq 'Advanced' || $DATA.triggertime eq 'Allocated' || $DATA.triggertime eq 'Shared'}{else}style="display:none;"{/if}>
				<td class="ld-form-item-label">{'REPEATMODE'|@getFixedLabel}</td>
				<td class="ld-form-item-content" style="line-height: 150%;">
					<div style="position: relative;float: left;" class="select-input">
						<input type="radio" id="workflow_triggertype_only" name="workflow_triggertype" value="only" {if $DATA.repeatmode eq 'only'}checked{/if}>
						<label for="workflow_triggertype_only">{'Onlyfirsttimeconditonsaremet'|@getFixedLabel}</label><br>
						<input type="radio" id="workflow_triggertype_every" name="workflow_triggertype" value="every" {if $DATA.repeatmode eq 'every' || $DATA.repeatmode eq ''}checked{/if}>
						<label for="workflow_triggertype_every">{'Everytimeconditonsareme'|@getFixedLabel}</label>
					</div>
				</td>
			</tr>
			<tr name="tr_ApprovalNode" {if $DATA.triggertime eq 'Approval'}{else}style="display:none;"{/if}>
				<td class="ld-form-item-label"><font color="red">*</font>{'ApprovalNode'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<div style="position: relative;float: left;" class="select-input">
						<input type="checkbox" id="workflow_Submit" name="workflow_approvetime[]" value="Submit" {if $APPROVENODE_ARRAY.Submit eq 'yes'}checked{/if}>
						<label for="workflow_Submit">{'SUBMITAPPROVAL'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;
						<input type="checkbox" id="workflow_Approved" name="workflow_approvetime[]" value="Approved" {if $APPROVENODE_ARRAY.Approved eq 'yes'}checked{/if}>
						<label for="workflow_Approved">{'Approvals'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;
						<input type="checkbox" id="workflow_Rejected" name="workflow_approvetime[]" value="Rejected" {if $APPROVENODE_ARRAY.Rejected eq 'yes'}checked{/if}>
						<label for="workflow_Rejected">{'Rejected'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;
						<input type="checkbox" id="workflow_Dismissed" name="workflow_approvetime[]" value="Dismissed" {if $APPROVENODE_ARRAY.Dismissed eq 'yes'}checked{/if}>
						<label for="workflow_Dismissed">{'Dismissed1'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;

						<input type="checkbox" id="workflow_RetractApprove" name="workflow_approvetime[]" value="RetractApprove" {if $APPROVENODE_ARRAY.RetractApprove eq 'yes'}checked{/if}>
						<label for="workflow_RetractApprove">{'RETRACEMENT'|@getFixedLabel}</label>
					</div>
				</td>
			</tr>
		</table>
		<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
		<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
		<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
		<div name='adv_filter_div'>
			{include file="WorkflowCustomization/WorkflowAdvSearch.tpl"}
		</div>
		{* 工作流操作区块 *}
		{include file='WorkflowCustomization/WorkflowCustomizationActionBlock.tpl'}
	</div>
</form>
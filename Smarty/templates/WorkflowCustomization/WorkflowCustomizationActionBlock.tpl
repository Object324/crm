<div class="ld-pop-container padT8 padB0">
	<div class="ld-pop-contnet-title-items">
		<div class="ld-pop-contnet-title-item">
			{'WorkflowActions'|@getFixedLabel}
		</div>
	</div>
	<div class="create-entity-toolbar prelative" style="float: right;margin-top: -26px">
		<div class="ld-button ld-button-primary" name="workflow_add_action">
			{'AddAction'|@getFixedLabel}
			<b class="ld-button-arrow-down"></b>
		</div>
	</div>
</div>
<div style="float: right;margin: 6px 10px 6px 0;position: relative;">
	<div id="workflow_add_action_list" class="ld_VisualAnalysis_Tool" tabindex="-101" style="top: 30px;">
		<ul>
			<li data-actiontype="api">
				{'CallAPI'|@getFixedLabel}
			</li>
			<li data-actiontype="link2erp">
				{'CallLink2ERP'|@getFixedLabel}
			</li>
			{*触发器中的触发点选择“删除”时，工作流操作中去掉“自动共享”和“更新字段”*}
			<li data-actiontype="auto_share" {if $DATA.triggertime eq 'Deleted'}style="display: none;"{/if}>
				{'AUTOSHARE'|@getFixedLabel}
			</li>
			<li data-actiontype="update_fields" {if $DATA.triggertime eq 'Deleted'}style="display: none;"{/if}>
				{'updatefields'|@getFixedLabel}
			</li>
			<li data-actiontype="excute_sql">
				{'ExcuteSQL'|@getFixedLabel}
			</li>
		</ul>
	</div>
</div>
<div class="ld-pop-container ld-table-container ld-table-container-lines">
	<table class="" name="table_workflow_actions" width="100%" cellspacing="0" cellpadding="0" border="0">
		<thead>
			<tr>
				<th>#</th>
				<th title="{'OPERATORTYPE'|@getFixedLabel}" width="200px" align="left">{'OPERATORTYPE'|@getFixedLabel}</th>
				<th title="{'ActionTitle'|@getFixedLabel}" width="200px" align="left">{'ActionTitle'|@getFixedLabel}</th>
				<th title="{'ACTIVATE'|@getFixedLabel}" width="200px" align="left">{'ACTIVATE'|@getFixedLabel}</th>{*wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”*}
				<th title="{'OPERATING'|@getFixedLabel}" width="17%" align="left">{'OPERATING'|@getFixedLabel}</th>
			</tr>
		</thead>
		<tbody>
			{if $MODE eq 'edit'}
				{assign var="i" value=0}
				{include file='WorkflowCustomization/WorkflowCustomizationContentEntries.tpl'}
			{else}
				<tr>
					<td colspan="5" style="text-align: center;">{'NONE'|@getFixedLabel}</td>
				</tr>
			{/if}
		</tbody>
	</table>
</div>
<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
	<input type="hidden" name="workflow_aciton_type" value="UpdateFields" />
	<input type="hidden" name="workflow_id" value="{$WORDFLOW_ID}" />
	<input type="hidden" name="tabid" value="{$TABID}" />
	<input type="hidden" name="mode" value="save" />
	<input type="hidden" name="please_select_module_fields" value="{'PLEASESELECTFIELD'|@getFixedLabel}" />
	<input type="hidden" name="referecemodule_json" value='{$referencemodule_json}' />
	<input type="hidden" name="workflow_actionid" value='{$workflow_actionid}' />
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'ActionTitle'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="action_title" tag="{'ActionTitle'|@getFixedLabel}"  value="{$ACTION_TITLE}" />
            </td>
        </tr>
    </table>
	<div style="width: 100%;padding: 0 24px;">
		<ul class="test_ul padT0" name="datacategory_tabletitle">
			<li style="width: 25%;">{'SELECTMODULE'|@getFixedLabel}</li>
			<li style="width: 20%;">{'Select_field'|@getFixedLabel}</li>
			<li style="">{'setvalue'|@getFixedLabel}</li>
		</ul>
	</div>
	<div style="width: 100%;padding: 0 24px 20px;">
		<table class="" name="conditiongrouptable" width="100%" cellspacing="1" cellpadding="0" border="0">
			<tbody>
			{if $ACITON_DATA_CNT gte 1}
				{foreach item=action_info from=$ACITON_DATA}
					<tr rowindex={$action_info.rowid}>
						<input type="hidden" value="{$action_info.setmode}" name="select_mode" />
						<input type="hidden" value="{$action_info.setvalue}" name="select_value" />
						<input type="hidden" value="{$action_info.fieldname}" name="select_fieldname" />
						<input type="hidden" value='{if setmode=='Field'}{$action_info.fieldlabel}{else}{$action_info.setvalue_label}{/if}' name="select_label" />
						<input type="hidden" value="{$action_info.field_uitype}" name="field_uitype" />
						<td width="25%" align="left" class="padB16">
							<select name="referencemodule" rowid="{$action_info.rowid}" tag="reference_module" class="ld-select-inner gwidth100" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">
								<option value="">{'PLEASESELECTMODULE'|@getFixedLabel}</option>
								{foreach key=module item=module_label from=$referencemodules}
									<option value="{$module}" {if $action_info.module eq $module}selected{/if}>{$module_label}</option>
								{/foreach}
							</select>
						</td>
						<td width="20%" align="left" class="padB16">
							<select name="referencemodule_fields" tag="reference_module_fields" rowid="{$action_info.rowid}" class="ld-select-inner width200" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">
								{$action_info.moduelfield}
							</select>
						</td>
						<td align="left" name="td_fval" class="padB16">
							{if $action_info.select_html neq ''}
								{$action_info.select_html}
							{else}
								{if $action_info.setmode eq 'Field'}
									<input type="text" style="width: 100%;" class="ld-input-inner" name="fval" readonly="" value="{$action_info.fieldlabel}" rowid="{$action_info.rowid}" tag="fval">
								{elseif $action_info.setmode eq 'User_one' || $action_info.setmode eq 'User_more'}
									<div type="text" style="width: 100%;color: #3B4859;font-size: 13px;padding: 5px;line-height: 20px;" class="ld-input-inner" name="fval" readonly="" value="" rowid="{$action_info.rowid}" tag="fval">{$action_info.setvalue_label}</div>
								{else}
									<input type="text" class="ld-input-inner gwidth90" name="fval" readonly="" value="{$action_info.setvalue}" rowid="{$action_info.rowid}" tag="fval">
								{/if}
							{/if}
						</td>
						<td width="100px" align="left" class="padB16"><a href="javascript:void(0);" name="fdeleted" rowid="{$action_info.rowid}" tag="fdeleted" title="{'DELETE'|@getFixedLabel}" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">{'DELETE'|@getFixedLabel}</a>
						</td>
					</tr>
				{/foreach}
			{else}
				<tr rowindex=1>
					<input type="hidden" value="" name="select_mode" />
					<input type="hidden" value="" name="select_value" />
					<input type="hidden" value="" name="select_label" />
					<input type="hidden" value="" name="field_uitype" />
					<td width="25%" align="left" class="padB16">
						<select name="referencemodule" rowid="1" tag="reference_module" class="ld-select-inner gwidth90" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">
							<option value="">{'PLEASESELECTMODULE'|@getFixedLabel}</option>
							{foreach key=module item=module_label from=$referencemodules}
								<option value="{$module}">{$module_label}</option>
							{/foreach}
						</select>
					</td>
					<td width="20%" align="left" class="padB16">
						<select name="referencemodule_fields" tag="reference_module_fields" rowid="1" class="ld-select-inner gwidth90" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">
							<option value="">{'PLEASESELECTFIELD'|@getFixedLabel}</option>
						</select>
					</td>
					<td align="left" name="td_fval" class="padB16">
						<input type="text" class="ld-input-inner gwidth90" name="fval" readonly="" rowid="1" tag="fval">
					</td>
					<td width="100px" align="left" class="padB16"><a href="javascript:void(0);" name="fdeleted" rowid="1" tag="fdeleted" title="{'DELETE'|@getFixedLabel}" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">{'DELETE'|@getFixedLabel}</a>
					</td>
				</tr>
			{/if}
			</tbody>
		</table>
		<a href="javascript:void(0);" name="addConditiongroup" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">{'newfields'|@getFixedLabel}</a>
	</div>
</form>
<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
	<input type="hidden" name="workflow_id" value="{$WORDFLOW_ID}" />
	<input type="hidden" name="tabid" value="{$TABID}" />
	<input type="hidden" name="mode" value="save" />
	<input type="hidden" name="rowid" value="{$ROWID}" />
	<div name="conditiongroup_1">
		<table class="ld-pop-container" name="conditiongrouptable" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody>
			<tr name="conditioncolumn_1">
				<td width="25%" align="left" >
					<select class="ld-select-inner gwidth100" name="select_setmode">
						{if $is_user_one == 'yes'}
						<option value="User_one" {if $SELECT_MODE eq 'User_one'}selected{/if}>{'LBL_USERS'|@getFixedLabel}</option>
						{elseif $is_user_more == 'yes'}
						<option value="User_more" {if $SELECT_MODE eq 'User_more'}selected{/if}>{'LBL_USERS'|@getFixedLabel}</option>
						{else}
						<option value="Text" {if $SELECT_MODE eq 'Text'}selected{/if}>{'Text'|@getFixedLabel}</option>
						{/if}
						<option value="Field" {if $SELECT_MODE eq 'Field'}selected{/if}>{'FIELDS'|@getFixedLabel}</option>
						<!--<option value="Expression">表达式</option>-->
						<!--<option value="Text">Sql</option>-->
					</select>
				</td>
				<td width="25%" align="left" style="font-size: 13px;" class="ld-form-item-content padL10">
					<select class="ld-select-inner width200 marL10" name="select_module_field"  {if $SELECT_MODE eq 'Field'}{else}style="display:none;"{/if}>
						{$moduelfield}
					</select>
					<input name="workflow_action_updatefields_selectuser_one" data-isshow="{$is_user_one}" style="display:none;" value="{$SELECT_VALUE}" >
					<div name="workflow_action_updatefields_selectuser_more" data-selectlabel="{'SelectMultiUser'|@getFixedLabel}" {if $is_user_more eq 'yes' && $SELECT_MODE == 'User_more'}{else}style="display:none;"{/if}>
						<div class="commonDetailedTextBox gwidth70 bgwhite lfloat" id="workflow_action_updatefields_selectuser_more_div" name="workflow_action_updatefields_selectuser_more_div" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;height: 30px;line-height: 30px;">{$SELECT_LABEL}</div>
						<a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" id="updatefields_selectuser_more" title="{'SELECT'|@getFixedLabel}"></a>
						<input class="icon-homeimg icon-clear inpb-reset lfloat marT2" id="workflow_action_updatefields_selectuser_more_clear" type="button" title="{'CLEAR'|@getFixedLabel}">
						<input type="hidden" value="{$SELECT_VALUE}" id="workflow_action_updatefields_selectuser_more_value">
					</div>
				</td>
				<td width="50%" align="left" class="padL10">
					<select class="ld-select-inner width200 marL10" name="select_function" style="display:none;">
						<option value="">使用函数</option>
						<option value="contact">CONCAT(str1,str2,...)</option>
						<option value="timediff">TIMEDIFF(expr1,expr2)</option>
						<option value="date_add">DATE_ADD(date,INTERVAL n DAY)</option>
						<option value="ate_add_month">ATE_ADD(date,INTERVAL n MONTH)</option>
						<option value="ate_add_year">ATE_ADD(date,INTERVAL n YEAR)</option>
						<option value="date_sub_day">DATE_SUB(date,INTERVAL n DAY)</option>
						<option value="date_sub_month">DATE_SUB(date,INTERVAL n MONTH)</option>
						<option value="date_sub_year">DATE_SUB(date,INTERVAL n YEAR)</option>
					</select>
				</td>
			</tr>
			<tr name="tr_text_setvalue" {if $SELECT_MODE eq 'Text'}{else}style="display:none;"{/if}>
				<td align="left" colspan="3">
					<input class="ld-input-inner marT20" type="text" name="text_setvalue"  value="{$SELECT_VALUE}" />
				</td>
			</tr>
			</tbody>
		</table>
	</div>
</form>
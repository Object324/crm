<div>
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr {if $pushback_presence eq 'no'}style="display:none"{/if}>
			<td class="ld-form-item-label select-input">
				<input type="radio" value="specified" name="advance_stage_type" checked />
	            <label onclick="AdvanceStage.selectlabel(this)">{'Advancetospecifiedstage'|@getFixedLabel}</label>
			</td>
			<td class="ld-form-item-content" style="overflow: inherit;">
				<select name="specified_advance_stage" onchange="ld(':radio[name=advance_stage_type][value=specified]').prop('checked', 'checked');AdvanceStage.changeNextStep(ld(this))" class="ld-select-inner">
					{* wym XUQIU20240204-09 销售线索可编辑追踪字段*}
					{if $moduleadvance_method eq 'field'}
						{foreach key=advanceid item=val from=$ADVANCE_STAGE_ALLOWPUSH}
							<option value="{$val['stagename_target']}" data-mapmodule="{$val['map_module']}"  advanceid="{$advanceid}" {if $CUR_ADVANCESTAGE_VALUE eq $val['stagename_target']}selected{/if}>{$val['stagename_target']}</option>
						{/foreach}
					{else}
						{foreach key=advanceid item=val from=$ADVANCE_STAGE_ALLOWPUSH}
							<option value="{$advanceid}" data-mapmodule="{$val['map_module']}"  advanceid="{$advanceid}" {if $CUR_ADVANCESTAGE_VALUE eq $val}selected{/if}>{$val}</option>
						{/foreach}
					{/if}
				</select>
				{if $ISADMIN eq 'on' && $MODULE eq 'Leads'}
					<a id="advance_stage_upgrade"
					   {if empty($CUR_ADVANCESTAGE_MAPMODULE) || $CUR_ADVANCESTAGE_MAPMODULE=='close'}style="display:none;"{/if}{* wym XUQIU20240204-09 销售线索可编辑追踪字段*}
					   onclick="advance_stage_upgrade({$RECORD})" title="{'SETTINGS'|@getFixedLabel}" style="cursor:pointer;">{'FIELDMAPPING'|@getFixedLabel}</a>
				{/if}
				<br/>
			</td>
		</tr>
		<tr name="fileurereason_tr" style="display:none;">
			<td class="ld-form-item-label">
	            <font color="red">*</font>{if $LANGUAGETYPE eq 'zh'}
					{'FAILLEDTOCOLSE'|@getFixedLabel}{'Reason'|@getFixedLabel}
				{else}
					{'Reason'|@getFixedLabel}
				{/if}
	        </td>
	        <td class="ld-form-item-content">
				<textarea name="fileurereason" rows="4" style="height: 50px; overflow: hidden; overflow-wrap: break-word;" class="ld-textarea-inner" tag="{if $LANGUAGETYPE eq 'zh'}{'FAILLEDTOCOLSE'|@getFixedLabel}{'Reason'|@getFixedLabel}{else}{'Reason'|@getFixedLabel}{/if}"></textarea>
			</td>
		</tr>
	</table>
	{if $TASKINFO['taskvalue']|@is_array && sizeof($TASKINFO['taskvalue']) > 0}
		<div name="advancetasklabel" id="advancetasklabel" style="padding: 8px 24px 0 24px;">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{"ADVANCETASK"|@getFixedLabel}</div>
			</div>
		</div>
		<div name="AllTaskvalue" class="ld-advance-task" id="AllTaskvalue" style="width:100%;overflow-y:unset;max-height:100%;padding: 0 14px 0 5px;">
		    {include file="Taskprogress.tpl"}
		</div>
	{else}
		<div name="AllTaskvalue" id="AllTaskvalue" style="width:100%;">
		    <span style="margin-top:10px;"></span>
		</div>
	{/if}
</div>
{*<div class="main_grid_top">	*}
{*	<div class="clear"></div>*}
{*	<div class="divButtons">*}
{*		<div class="PageDiv0" style="margin-top: 20px;">*}
{*			<ul>*}
{*				<input id="curPage" name="page" style="width:50px;margin-right:4px;" type="hidden" value="{$PAGE}">*}
{*				<li> {'TOTALOF'|@getFixedLabel} {$total_nums} {'RECORDNUMS'|@getFixedLabel}</li>*}
{*				{if $PREVPAGE eq 'yes'}*}
{*					<li><span class="icon-prevpage" title="{'PREVPAGE'|@getFixedLabel}" tag="prev" onclick="WorkflowCustomization.setPage(this,event)"></span></li>*}
{*				{else}*}
{*					<li><span class="no-icon-prevpage"></span></li>*}
{*				{/if}*}
{*				<li class="Input">{$PAGE}/{$total_pages}</li>*}
{*				{if $NEXTPAGE eq 'yes'}*}
{*					<li><span class="icon-nextpage" title="{'NEXTPAGE'|@getFixedLabel}" tag="next" onclick="WorkflowCustomization.setPage(this,event)"></span></li>*}
{*				{else}*}
{*					<li><span class="no-icon-nextpage"></span></li>*}
{*				{/if}*}
{*			</ul>*}
{*		</div>*}
{*	</div>*}

{*</div>*}
<table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr style="position: sticky; top:0px;z-index:1;">
		<th>#</th>
		<th title="{'suoshumodule'|@getFixedLabel}" style="width:10%">{'suoshumodule'|@getFixedLabel}</th>
		<th title="{'WorkflowName'|@getFixedLabel}" style="width:20%">{'WorkflowName'|@getFixedLabel}</th>
		<th title="{'TriggerTime'|@getFixedLabel}">{'TriggerTime'|@getFixedLabel}</th>
		<th title="{'REPEATMODE'|@getFixedLabel}">{'REPEATMODE'|@getFixedLabel}</th>
		<th title="{'CAMCARDCAPTION'|@getFixedLabel}" style="width:30%">{'CAMCARDCAPTION'|@getFixedLabel}</th>
		<th title="{'ACTIVATE'|@getFixedLabel}">{'ACTIVATE'|@getFixedLabel}</th>{*wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”*}
		{if $LANGUAGETYPE eq 'en'}
			<th width="150">{'OPERATING'|@getFixedLabel}</th>
		{else}
			<th width="110">{'OPERATING'|@getFixedLabel}</th>
		{/if}
	</tr>
	{if $DATALENGTH gte 1}
		{assign var="i" value=0}
		{foreach key=workflow_id item=arr from=$DATA}
			{assign var="j" value=$i++}
			{if $j mod 2 eq '0'}
				<tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
			{else}
				<tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
			{/if} 
				<td>{$j+1}</td>
				<td>{$arr.modulename}</td>
				<td>{$arr.name}</td>
				<td>{$arr.triggertime_label}</td>
				<td>{if $arr.repeatmode eq 'only'}{'Onlyfirsttimeconditonsaremet'|@getFixedLabel}{elseif $arr.repeatmode eq 'every'}{'Everytimeconditonsareme'|@getFixedLabel}{/if}</td>
				<td>{$arr.description}</td>
                <td><input type="checkbox" class="second_switch" {if $arr.status eq 'Active'}checked{/if} onclick="WorkflowCustomization.operateWorkflow(this,event)" tag="status" workflow_id={$workflow_id} /></td>
				<td>
					<a class="Anu3_a" href="javascript:void(0);" onclick="WorkflowCustomization.operateWorkflow(this,event)" workflow_id={$workflow_id} tag="edit">{'EDIT'|@getFixedLabel}</a>
					<a class="Anu3_a redFont" href="javascript:void(0);" onclick="WorkflowCustomization.operateWorkflow(this,event)" workflow_id={$workflow_id} tag="delete">{'DELETE'|@getFixedLabel}</a>
				</td>
			</tr>
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="8" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
		</tr>
	{/if}
</table>
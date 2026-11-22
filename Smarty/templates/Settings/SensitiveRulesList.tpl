{*敏感规则列表*}
<table class="settingTable fir-center SensitiveTable" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<th>#</th>
		<th title="{'RULENAME'|@getFixedLabel}" style="width:35%">{'RULENAME'|@getFixedLabel}</th>
		<th title="{'RULETYPE'|@getFixedLabel}" style="width:30%">{'RULETYPE'|@getFixedLabel}</th>
		<th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
		{if $LANGUAGETYPE eq 'en'}
			<th width="150">{'OPERATING'|@getFixedLabel}</th>
		{else}
			<th width="110">{'OPERATING'|@getFixedLabel}</th>
		{/if}
	</tr>
	{if is_array($sensitiverules) && count($sensitiverules) gte 1}
		{assign var="i" value=0}
		{foreach key=index item=rule from=$sensitiverules}
			{assign var="j" value=$i++}
			{if $j mod 2 eq '0'}
				<tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" ruleid={$rule.sensitiveid}>
			{else}
				<tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" ruleid={$rule.sensitiveid}>
			{/if} 
				<td>{$j+1}</td>
				<td>{$rule.sensitivename}</td>
				<td>{$rule.ruletypelabel}</td>
				<td><input type="checkbox" class="second_switch" {if $rule.rulestatus eq 'yes'}checked{/if} onclick="SensitiveRules.getInstance().changerulestatus(this,{$FIELDID},{$rule.sensitiveid},'{$MODULE}')" tag="status" fieldid="{$FIELDID}" ruleid="{$rule.sensitiveid}"/></td>
				<td>
					<a class="Anu3_a" href="javascript:void(0);" onclick="SensitiveRules.getInstance().create({$FIELDID},{$rule.sensitiveid},'edit','{$MODULE}')" fieldid="{$FIELDID}" ruleid="{$rule.sensitiveid}" tag="edit">{'EDIT'|@getFixedLabel}</a>
					<a class="Anu3_a redFont" href="javascript:void(0);" onclick="SensitiveRules.getInstance().delete({$FIELDID},{$rule.sensitiveid},'{$MODULE}')" fieldid="{$FIELDID}" ruleid="{$rule.sensitiveid}" tag="delete">{'DELETE'|@getFixedLabel}</a>
				</td>
			</tr>
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="8" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
		</tr>
	{/if}
</table>
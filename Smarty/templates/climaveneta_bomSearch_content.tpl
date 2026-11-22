
<div class="t-table" style="overflow:auto;">
<table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1200px;">
	<tr>
		<th style="width:50px"><span title="{$LANG['cxh']}">{$LANG['cxh']}</span></th>
		<th style="width:130px"><span title="{$LANG['cbjh']}">{$LANG['cbjh']}</span></th>
		<th style="width:350px"><span title="{$LANG['cbjmc']}">{$LANG['cbjmc']}</span></th>
		{if $FIELDPERMISSIONS eq 'yes'}
			<th style="width:100px"><span title="{$LANG['cxsdj']}">{$LANG['cxsdj']}</span></th>
		{/if}
		<th style="width:100px"><span title="{$LANG['cjgyxq']}">{$LANG['cjgyxq']}</span></th>
		<th style="width:80px"><span title="{$LANG['cxqsl']}">{$LANG['cxqsl']}</span></th>
		<th style="width:50px"><span title="{$LANG['cdw']}">{$LANG['cdw']}</span></th>
		<th style="width:50px"><span title="{$LANG['cdj']}">{$LANG['cdj']}</span></th>
		<th style="width:50px"><span title="{$LANG['csfjy']}">{$LANG['csfjy']}</span></th>
	</tr>
	{if $DATA|@count neq 0}
		{foreach key=is_key item=row from=$DATA name=fordata}
			<tr class="lvtColData">
				<td>{$smarty.foreach.fordata.iteration}</td>
				<td title="{$row.idnrk}">{$row.idnrk}</td>
				<td title="{if $LANGUAGE eq 'zh'}{$row.sparepart}{else}{$row.sparepart_E}{/if}">{if $LANGUAGE eq 'zh'}{$row.sparepart}{else}{$row.sparepart_E}{/if}</td>
				{if $FIELDPERMISSIONS eq 'yes'}
					<td title="{$row.price}">{$row.price}</td>
				{/if}
				<td title="{$row.validity}">{$row.validity}</td>

				<td title="{$row.enmng}">{$row.enmng}</td>
				<td title="{$row.meins}">{$row.meins}</td>
				<td	title="{$row.zspuc}">{$row.zspuc}</td>
				<td title="{$row.discontinued}">{if $row.discontinued eq 1 && $LANGUAGE eq 'zh'}禁用{/if}{if $row.discontinued eq 1 && $LANGUAGE eq 'en'}Replaced{/if}</td>
			</tr>
		{/foreach}
		
	{else}
		<tr class="lvtColData">
			<td colspan="9">
				<i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
			</td>
		</tr>
	{/if}
</table>
</div>

<script>
{literal}
	var windowWidth = document.documentElement.clientWidth;
    ld('.t-table').css('width', parseInt(windowWidth-20)+'px');
    ld('.t-table').css('height', parseInt(ld(window).height()-186)+'px');
{/literal}
</script>
<!--集家网报表-->
<div id="change_table_div_cheer100" style="margin-top:-1px;margin-left:-1px;display:none;">
    <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    {if $PRESENCE.cheer100.cheer100.name eq 'cheer100' && $PRESENCE.cheer100.cheer100.presence eq 0}
		<tr>
			<td><a href="javascript:popup_jjwang()">{'cheer100'|@getFixedLabel}</a></td>
		</tr>
	{/if}
    </table>
</div>
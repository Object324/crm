<!--励等报表-->
<div id="change_table_div_lideng" style="margin-top:-1px;margin-left:-1px;display:none;">
    <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
		{if $PRESENCE.lideng.lidengSunsalestotal.name eq 'lidengSunsalestotal' && $PRESENCE.lideng.lidengSunsalestotal.presence eq 0}
			<tr align="center">
				<td><a href="javascript:popup_lideng()">销售统计表报表</a></td>
			</tr>
		{/if}
    </table>
</div>
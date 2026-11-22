<!--鼎捷报表-->
<div id="change_table_div_xinfan" style="margin-top:-1px;margin-left:-1px;display:none;">
    <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
		{if $PRESENCE.xinfan.xinfanSalesDetail.name eq 'xinfanSalesDetail' && $PRESENCE.xinfan.xinfanSalesDetail.presence eq 0}
			<tr>
				<td><a href="javascript:popup_dingjie()">销售统计表报表</a></td>
			</tr>
		{/if}
    </table>
</div>
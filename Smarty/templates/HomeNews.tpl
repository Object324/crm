<!--修改编码格式:统一编码：UTF-8-->
<div style='overflow: hidden;'>
<table border='0' cellpadding='2' cellspacing='0' width="100%">
	<tr valign=top>
		<td align='left'><b>{$APP.LBL_LINGDANG_NEWS}</b></td>
		<td align='right'>&nbsp;</td>
		<td align='right'>
			<a class="icon-homeimg icon-close" style='padding-left: 10px;' href="javascript:;" onclick="fninvshnew('lingdangNewsPopupLay');"></a></td>
	</tr>

	<tr>
		<td colspan='3'><hr></td>
	</tr>

	{foreach item=NEWS from=$NEWSLIST}
	<tr>
		<td colspan='3' align='left'><a class='small' href='{$NEWS->get_link()}' target='_blank' style='color: #0070BA;'>{$NEWS->get_title()}</a></td>
	</tr>
	{foreachelse}
	<tr>
		<td colspan='3'>{$MOD.LBL_NEWS_NO}</td>
	</tr>
	{/foreach}
</table>
</div>
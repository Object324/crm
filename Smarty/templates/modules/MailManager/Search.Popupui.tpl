<!--修改编码格式:统一编码：UTF-8-->
{strip}
<form method="POST" action="javascript:void(0);" style="display:inline;">
<table border="0" cellspacing="0" cellpadding="0" width="90%" class="mailClient mailClientBg">
<tr>
<td>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" class="small">
	<tr>
		<td class="mailSubHeader moduleName" background="themes/images/qcBg.gif">
			<b>{'SEARCH'|getFixedLabel}</b>
		</td>
		<td class="mailSubHeader" background="themes/images/qcBg.gif" align="right">
			<a class="icon-homeimg icon-close cursorPointer" href="javascript:;" onclick="MailManager.popup_close();"></a>
		</td>
	</tr>
	</table>
	<table border="0" cellspacing="0" cellpadding="5" width="100%" class="small">
	<tr>
		<td class="dvtCellLabel" nowrap="nowrap">
			<input type="text" id="_search_popupui_input_" name="_search_popupui_input_">
			<input type="hidden" id="_search_popupui_target_" name="_search_popupui_target_">
		</td>
	</tr>
	<tr>
		<td align="center">
			<input type="button" class="editauto" value="{'CONFIRMED'|getFixedLabel}" onclick="MailManager.search_consume_input(this.form);">
			<span>&nbsp;&nbsp;</span>
            <input type="button" class="cancelauto" value="{'CANCEL'|getFixedLabel}" onclick="MailManager.popup_close();">
		</td>
	</tr>
	</table>
</td>
</tr>
</table>

</form>

{/strip}
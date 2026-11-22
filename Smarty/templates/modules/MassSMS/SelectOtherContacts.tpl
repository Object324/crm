<!--修改编码格式:统一编码：UTF-8-->

<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
  <tr>
	<td class="Note">
		<div>
			{'LBL_PLEASE_SELECT'|@getFixedLabel}{'CONTACTS'|@getFixedLabel}
		</div>
		<div class="divTextRecipient">
			{foreach item=arr from=$RESSEND}
				<input type="checkbox" name="selectcontacts" tag="{$arr.value}" /> {$arr.lastname}：{$arr.mobile} <br />
			{/foreach}
		</div>

	</td>
  </tr>
</table>
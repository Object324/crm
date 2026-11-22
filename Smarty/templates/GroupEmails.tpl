<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
  <tr>
	<td>
	
	<table style="color:#666;font-size:12px;">
	{if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
		<tr><td>{'PCWYWTSTMTMP'|@getFixedLabel}</td></tr>
	{else}
		<tr><td>{'PCWYWTSETE'|@getFixedLabel}</td></tr>
	{/if}
	 {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
		{if $MODULE eq 'Accounts' }
			{$html_accounttype_SMS}
		{elseif $MODULE eq 'Contacts'}
			 {$html_contact_SMS}
		{else}
			{$html_contact_SMS}
		{/if}
	{else}
		{if $MODULE eq 'Accounts'}
			{$html_accounttype_Email}
		{elseif $MODULE eq 'Contacts'}
		   {$html_contact_Email}
		{else}
		   {$html_contact_Email}
		{/if}
	{/if}
	 </table>
	</td>
  </tr>
</table>
<div class="D_pbtn">
		{if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
			{if $MODULE eq 'Accounts'}
				<input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="account_btn_MassSMS();"/><span>&nbsp;</span>
			{else if $MODULE eq 'ServiceCharge'}
                <input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="servicecharge_btn_MassSMS();"/><span>&nbsp;</span>
            {else}
				<input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="contact_btn_MassSMS();"/><span>&nbsp;</span>
			{/if}
		{else}
			{if $MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge'}
				<input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="account_btn_Email();"/><span>&nbsp;</span>
			{else if $MODULE eq 'ServiceCharge'}
                <input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="servicecharge_btn_MassSMS();"/><span>&nbsp;</span>
            {else}
				<input type="button" id="chose_checkbox" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="contact_btn_Email();"/><span>&nbsp;</span>
			{/if}
		{/if}
	<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="cancelCrmPopup('');"/> 
</div>
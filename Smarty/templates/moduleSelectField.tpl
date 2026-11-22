<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
	{if $FIELDTYPE eq 'email'}
		<tr><td>{'PCWYWTSETE'|@getFixedLabel}</td></tr>
	{elseif $FIELDTYPE eq 'sms'}
		<tr><td>{'PCWYWTSTMTMP'|@getFixedLabel}</td></tr>
	{else}
		{if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
			<tr><td>{'PCWYWTSTMTMP'|@getFixedLabel}</td></tr>
		{else}
			<tr><td>{'PCWYWTSETE'|@getFixedLabel}</td></tr>
		{/if}
	{/if}
	{$html_contact_SMS}
</table>
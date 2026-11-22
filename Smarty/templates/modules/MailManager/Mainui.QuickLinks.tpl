{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************+*}
<!--修改编码格式:统一编码：UTF-8-->
<table cellpadding=0 cellspacing=0 border=0 class="small" width="98%">
<tr>
	<td class="greenFont" style="padding-left: 5px;"><strong>{'MAILBOX'|@getTranslatedString}</strong></td>
</tr>
<tr>
	<td style="padding-left: 5px;" class="dvtContentSpace">
	<table cellpadding=2 cellspacing=0 border=0 class="small" width="100%">

		
		<tr>
			<td>
                <input type="hidden" name="mm_selected_folder" id="mm_selected_folder">
                <input type="hidden" name="_folder" id="mailbox_folder">
			</td>
		</tr>
        {if $MAILBOX && $MAILBOX->exists()}
		<tr>
			<td nowrap="nowrap"><img src="{'compose.gif'|@lingdang_imageurl:$THEME}" border='0'></td>
			<td><a href="#Compose" id="_mailfolder_mm_compose" onclick="MailManager.mail_compose();">{'LBL_Compose'|@getTranslatedString}</a></td>
		</tr>
		<tr>
			<td nowrap="nowrap"><img src="{'reload.gif'|@lingdang_imageurl:$THEME}" border='0'/></td>
			<td><a href='#Reload' id="_mailfolder_mm_reload" onclick="MailManager.reload_now();">{'REFRESH'|@getTranslatedString}</a></td>
		</tr>
		{/if}

		<tr>
			<td nowrap="nowrap"></td>
			<td><a href='#Settings' id="_mailfolder_mm_settings" onclick="MailManager.open_settings();">{'SETTINGS'|@getTranslatedString}</a></td>
		</tr>
		<tr>
			<td width="5px" nowrap="nowrap"><img src="{'mymail.gif'|@lingdang_imageurl:$THEME}" border='0'/></td>
            <td><a href="#Drafts" id="_mailfolder_mm_drafts" onclick="MailManager.folder_drafts();">{'LBL_Drafts'|@getTranslatedString}</a></td>
		</tr>
	</table>
		{include file="SentMailFolders.tpl"}
	</td>
</tr>
</table>
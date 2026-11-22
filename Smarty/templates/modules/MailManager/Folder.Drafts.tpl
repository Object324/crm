<!--************************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<span class="moduleName" id="mail_fldrname">{'LBL_Drafts'|@getTranslatedString}</span>
<div class="mailClientBg mm_outerborder" id="email_con" name="email_con">

	<table width="100%" cellpadding=3 cellspacing=0 border=0 class="small">
		{if $FOLDER->mails()}
		<tr>
			<td>
				
			</td>
			<td align="right" colspan=2>
				<table><tr>
				{if $FOLDER->hasPrevPage()}
					<td><a href="#{$FOLDER->name()}/page/{$FOLDER->pageCurrent(-1)}" onclick="MailManager.folder_drafts({$FOLDER->pageCurrent(-1)});"
					><img border="0" src="modules/Webmails/images/previous.gif" title="{'PREVPAGE'|@getTranslatedString}"></a> </td>{/if}
				<td><b>{$FOLDER->pageInfo()}</b></td>
				{if $FOLDER->hasNextPage()} <td><a href="#{$FOLDER->name()}/page/{$FOLDER->pageCurrent(1)}" onclick="MailManager.folder_drafts({$FOLDER->pageCurrent(1)});"
				><img border="0" src="modules/Webmails/images/next.gif" title="{'NEXTPAGE'|@getTranslatedString}"></a> </td>{/if}
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="5">
			<table class="mm_tableHeadBg" width="100%" cellspacing="0" border="0" cellpadding="2px" >
				<tr>
					<td align="left" style="width: 10%;" nowrap="nowrap">
					<input align="left" type="checkbox" class='small'  name="selectall" id="parentCheckBox" onClick='MailManager.toggleSelect(this.checked,"mc_box");'/>&nbsp;&nbsp;
					<input type="button" class='delete' onclick="MailManager.massMailDelete('__vt_drafts');" name="{'DELETE'|@getTranslatedString}" value="{'DELETE'|@getTranslatedString}" />
				</td>
				<td class="moduleName" align="right">{'SEARCH'|@getTranslatedString}
					<input type="text" id='search_txt' />&nbsp;
					<select class='small' id="search_type">
						{foreach item=label key=value from=$SEARCHOPTIONS}
							<option value="{$value}" >{$label|@getTranslatedString:$module}</option>
						{/foreach}
					</select>
					<input type="button" class="edit" onclick="MailManager.search_drafts();" value="{'SEARCH'|@getTranslatedString}" id="mm_search"/>
				</td>
			</tr>
			</table>
			</td>
		</tr>
	</table>
	{/if}

	{if $FOLDER->mails()}
	<table class="mm_mailwrapper" cellpadding="0" cellspacing="0" border="0" width="100%">

		{foreach item=MAIL from=$MAILS}
		<tr style="cursor: pointer" class="mm_lvtColData mm_normal" id="_mailrow_{$MAIL.id}"
            onmouseover='MailManager.highLightListMail(this);' onmouseout='MailManager.unHighLightListMail(this);'>
			<td width="3%"><input type='checkbox' value = "{$MAIL.id}" name = 'mc_box' class='small'
                                  onclick="MailManager.toggleSelectMail(this.checked, this);"></td>
			<td width="27%" onclick="MailManager.mail_draft('{$MAIL.id}')">{$MAIL.saved_toid}</td>
			<td onclick="MailManager.mail_draft('{$MAIL.id}')"> {$MAIL.subject}</td>
			<td width="17%" align="right" onclick="MailManager.mail_draft('{$MAIL.id}')">{$MAIL.date_start}</td>
		</tr>
		{/foreach}
	</table>
	{/if}

	{if $FOLDER->mails() eq null}
	<table  cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td><a href='javascript:void(0);' onclick="MailManager.folder_drafts();"><b>{'LBL_Drafts'|@getTranslatedString}</b></a></td>
		</tr>
		<tr>
			<td>{'NOEMAIL'|@getTranslatedString}</td>
		</tr>
	{/if}
	</table>
</div>
<!--**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<div class="InboxField"><span id="mail_fldrname">{'INBOX'|@getFixedLabel}</span></div>
<div id="open_email_con" name="open_email_con">
    <div class="back">
        <a href='javascript:void(0);' onclick="MailManager.mail_close();">&#171; {'RETURN'|@getFixedLabel}</a>
        <span id="_mailopen_subject">{$MAIL->subject()}</span>
        {if $MAIL->msgno() > 1}
			<a class="icon-homearr icon-next" title="{'NEXTDATA'|@getFixedLabel}" style="float:right;margin:8px 8px 0px 0px;" href='javascript:void(0);' onclick="MailManager.mail_open( '{$FOLDER->name()}', {$MAIL->msgno(-1)} );">
			</a>
		{/if}
        {if $MAIL->msgno() < $FOLDER->count()}
			<a class="icon-homearr icon-lastdis" title="{'PREVDATA'|@getFixedLabel}" style="float:right;margin:8px 8px 0px 0px;" href='javascript:void(0);' onclick="MailManager.mail_open( '{$FOLDER->name()}', {$MAIL->msgno(1)} );">
				</a>
		{/if}
		
	</div>
    <!--相关记录being-->
    <div class="RelatedRecord">
        <table width=100% cellpadding=0 cellspacing=0 border=0 class="rightMailMerge">
		<tr>
			<td align="center"><b>{'LBL_RELATED_RECORDS'|@getFixedLabel}</b></td>
		</tr>
		<tr>
			<td align="center">
				<input type="button" id="_mailrecord_findrel_btn_" onclick="MailManager.mail_find_relationship();" value="{'FINDRELATIONNOW'|@getFixedLabel}"/>
				<div id="_mailrecord_relationshipdiv_"></div>
			</td>
		</tr>
		</table>
    </div>
    <!--相关记录end-->
    <div class="emailBtn">
        <ul>
        <li><input type="button" class="saveauto" onclick="MailManager.mail_reply(true);" value="{'LBL_Reply_All'|@getFixedLabel}"/></li>
        <li><input type="button" class="saveauto" onclick="MailManager.mail_reply(false);" value="{'Reply'|@getFixedLabel}"/></li>
        <li><input type="button" class="saveauto" onclick="MailManager.mail_forward({$MAIL->msgno()});" value="{'FORWARDING'|@getFixedLabel}"/></li>
        <li><input type="button" class="saveauto" onclick="MailManager.mail_mark_unread('{$FOLDER->name()}', {$MAIL->msgno()});" value="{'LBL_Mark_As_Unread'|@getFixedLabel}"/></li>
        <li><input type="button" class="deleteauto" id = 'mail_delete_dtlview' onclick="MailManager.maildelete('{$FOLDER->name()}',{$MAIL->msgno()},true);" value="{'DELETE'|@getFixedLabel}"/></li>
		</ul>
        
    </div>
    <div class="emailTitle">
    	<span id="_mailopen_msgid_" style="display:none;">{$MAIL->_uniqueid|@escape:'UTF-8'}</span>
		<table width="88%" cellpadding=2 cellspacing=0 border=0 >
		<tr>
			<td width="100" align="right">{'Sender'|@getFixedLabel}:</td>
			<td id="_mailopen_from">
				{foreach item=SENDER from=$MAIL->from()}
					{$SENDER}
				{/foreach}
			</td>
		</tr>
		{if $MAIL->to()}
		<tr>
			<td width="100" align="right">{'TOMAIL'|@getFixedLabel}:</td>
			<td id="_mailopen_to">
				{foreach item=RECEPIENT from=$MAIL->to() name="TO"}
					{if $smarty.foreach.TO.index > 0}, {/if}{$RECEPIENT}
				{/foreach}
			</td>
		</tr>
		{/if}
		
		{if $MAIL->cc()}
		<tr>
			<td width="100" align="right">{'CC'|@getFixedLabel}:</td>
			<td id="_mailopen_cc">
				{foreach item=CC from=$MAIL->cc() name="CC"}
					{if $smarty.foreach.CC.index > 0}, {/if}{$CC}
				{/foreach}
			</td>
		</tr>
		{/if}
		
		{if $MAIL->bcc()}
		<tr>
			<td width="100" align="right">{'BCC'|@getFixedLabel}:</td>
			<td id="_mailopen_bcc">
				{foreach item=BCC from=$MAIL->bcc() name="BCC"}
					{if $smarty.foreach.BCC.index > 0}, {/if}{$BCC}
				{/foreach}
			</td>
		</tr>
		{/if}
		
		<tr>
			<td width="100" align="right">{'TIMES'|@getFixedLabel}:</td>
			<td id="_mailopen_date">{$MAIL->date()}</td>
		</tr>
		
		{if $MAIL->attachments(false)}
		<tr>
			<td width="100" align="right">{'Attachment'|@getFixedLabel}:</td>
			<td>
				{foreach item=ATTACHVALUE key=ATTACHNAME from=$MAIL->attachments(false) name="attach"}
					<img border=0 src="{'attachment.gif'|@lingdang_imageurl:$THEME}">
					<a href="index.php?module={$MODULE}&action={$MODULE}Ajax&file=index&_operation=mail&_operationarg=attachment_dld&_muid={$MAIL->muid()}&_atname={$ATTACHNAME|@escape:'htmlall':'UTF-8'}">{$ATTACHNAME}</a>
					&nbsp;
				{/foreach}
					<input type="hidden" id="_mail_attachmentcount_" value="{$smarty.foreach.attach.total}" >
			</td>
		</tr>
		{/if}
		
		</table>
    </div>
    
    <div class='emailDetail' id="_mailopen_body">
    	{$MAIL->body()}
    </div>

</div>
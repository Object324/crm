<!--************************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<div class="InboxField"><span id="mail_fldrname">{$FOLDER->name()|@getFixedLabel}</span></div>
<div class="mailClientDiv" id="email_con" name="email_con">
{if $FOLDER->mails()}
<div class="emailBtn">
    <ul>
        <li>
            <div style="margin-top:9px;">
                <input type="button" class='deleteauto' onclick="MailManager.massMailDelete('{$FOLDER->name()}');" value="{'DELETE'|@getFixedLabel}"/>
            </div>
        </li>
       
        <li>{'SEARCH'|@getFixedLabel}</li>
        <li>
            <div style="margin-top:9px;">
                <select class="txtinput" id="search_type">
        			{foreach item=arr from=$SEARCHOPTIONS}
        				{if $arr eq $TYPE}
        					<option value="{$arr}" selected>{$arr|@getFixedLabel}</option>
        				{else}
        					<option value="{$arr}" >{$arr|@getFixedLabel}</option>
        				{/if}
        			{/foreach}
        		</select>
            </div>
        </li>       
        <li><div style="margin-top:9px;"><input class="txtinput" style="height:20px;" type="text" id='search_txt' value="{$QUERY}" /></div></li>
        <li><div style="margin-top:9px;"><input type="submit" class="editauto" onclick="MailManager.search_mails('{$FOLDER->name()}');" value="{'FINDNOW'|@getFixedLabel}" id="mm_search"/></div></li>
    </ul>
    <ul class="page lfloat">
        {if $FOLDER->hasPrevPage()}
        <li>
            <a href="#{$FOLDER->name()}/page/{$FOLDER->pageCurrent(-1)}" onclick="MailManager.folder_open('{$FOLDER->name()}', {$FOLDER->pageCurrent(-1)});">
			<span class="icon-prevpage" title="{'PREVDATA'|@getFixedLabel}"></span></a>
		</li>
        {/if}
        <li >显示&nbsp;{$FOLDER->pageInfo()}&nbsp;条记录</li>
        {if $FOLDER->hasNextPage()}
        <li>
            <a href="#{$FOLDER->name()}/page/{$FOLDER->pageCurrent(1)}" onclick="MailManager.folder_open('{$FOLDER->name()}', {$FOLDER->pageCurrent(1)});">
			<div style="margin-top:9px;"><span class="icon-nextpage" title="{'NEXTDATA'|@getFixedLabel}"></span></a></div>
		</li>
        {/if}
    </ul>
    
</div>
{/if}

<table class="listEntries fir-center" cellpadding="0" cellspacing="1" border="0" width="100%">
    <tr>
        <th><input type="checkbox"  name="selectall" id="parentCheckBox" onclick='MailManager.toggleSelect(this.checked,"mc_box");'/></th>
        <th width="62%">{'FROMMAIL'|@getFixedLabel}</th>
        <th width="21%">{'Theme'|@getFixedLabel}</th>            
        <th width="14%">{'TIMES'|@getFixedLabel}</th>
	</tr>
    {foreach item=MAIL name=emailNum from=$FOLDER->mails()}
    {assign var="emailNum" value=$smarty.foreach.emailNum.iteration}
    {if $emailNum mod 2 eq '1'}
	<tr bgcolor="white" class="Hover" id="_mailrow_{$MAIL->msgNo()}" >
    {else}
    <tr bgcolor="white" class="lvtColDataBj Hover" id="_mailrow_{$MAIL->msgNo()}">
    {/if}
		<td>
            <input type='checkbox' value = "{$MAIL->msgNo()}" name = 'mc_box' onclick='MailManager.toggleSelectMail(this.checked, this);'/>
        </td>
		<td width="62%" onclick="MailManager.mail_open('{$FOLDER->name()}', {$MAIL->msgNo()});">{$MAIL->from(30)}</td>
		<td width="21%" onclick="MailManager.mail_open('{$FOLDER->name()}', {$MAIL->msgNo()});">{$MAIL->subject()}</td>
		<td width="14%" onclick="MailManager.mail_open('{$FOLDER->name()}', {$MAIL->msgNo()});">{$MAIL->date(true)}</td>
	</tr>
	{foreachelse}
</table>
<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border:1px solid #ddd;">
<tr>
	<td height="30" align="center"><a href='#{$FOLDER->name()}' onclick="MailManager.folder_open('{$FOLDER->name()}');"><b>{$FOLDER->name()|@getFixedLabel}</b></a></td>
</tr>
<tr>
	<td height="30" align="center">{'NOEMAIL'|@getFixedLabel}</td>
</tr>
{/foreach}
</table>
</div>
<script type="text/javascript">

    closeNewDiv();
</script>
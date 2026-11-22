{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="modules/Webmails/Webmails.js"></script>

<div class="emDetailsBtn">
    {if $BLOCKS neq ''}
    <ul>
        <li><input type="button" name="forward" value="{'FORWARDING'|@getFixedLabel} " class="editauto" onclick="OpenCompose('{$ID}','forward')"/></li>
        {if $EMAIL_FLAG neq 'WEBMAIL'}
        <li><input type="button" name="Send" value=" {'SEND'|@getFixedLabel} " class="editauto" onclick="OpenCompose('{$ID}','edit')"/></li>
        <li><input type="button" name="Reply" value=" {'Reply'|@getFixedLabel} " class="editauto" onclick="ReplyCompose('{$ID}','reply')"/></li>
        <li><input type="button" title="{'PRINT'|@getFixedLabel}" name="{'PRINT'|@getFixedLabel}" value="{'PRINT'|@getFixedLabel}" class="editauto" onclick="OpenCompose('{$ID}','print')"/></li>
        {else}
        <li><input type="button" name="Send" value=" {'Reply'|@getFixedLabel} " class="editauto" onclick="OpenCompose('{$ID}','edit')"/></li>
        {/if}
        {foreach item=row from=$BLOCKS}	
		{*{foreach item=elements key=title from=$row}	
			{if $elements.fldname eq 'filename' && $elements.value != ''}
                <li><input type="button" name="download" value=" {'DOWNLOADFILE'|@getFixedLabel} " class="editauto" /></li>
            {/if}
		{/foreach}*}
		{/foreach}
        <li style="float:right;"><input type="button" name="Button" value=" {'DELETE'|@getFixedLabel} "  class="deleteauto" onclick="DeleteEmail('{$ID}')"/></li>
    </ul>
    {/if}
    
</div>
<div class="emailInfo">
    {foreach item=row from=$BLOCKS}	
	{foreach item=elements from=$row}	
	{if $elements.fldname eq 'subject'}
    <ul>
        {if $EMAIL_FLAG neq 'WEBMAIL'}
        <li><span>{'Sender'|@getFixedLabel}</span>{$FROM_MAIL}</li>
        <li><span>{'ADDRESSEE'|@getFixedLabel}</span>{$TO_MAIL}</li>
            {if 'ccmail'|@emails_checkFieldVisiblityPermission eq '0'}
            <li><span>&nbsp;&nbsp;{'CC'|@getFixedLabel}</span>{$CC_MAIL}</li>
            {/if}
      		{if 'bccmail'|@emails_checkFieldVisiblityPermission eq '0'}
            <li><span>&nbsp;&nbsp;{'BCC'|@getFixedLabel}</span>{$BCC_MAIL}</li>
            {/if}
        {else}
        <li><span>{'Sender'|@getFixedLabel}</span>{$TO_MAIL}</li>
        {/if}
        <li><span>&nbsp;&nbsp;{'MAILTITLE'|@getFixedLabel}</span>{$elements.value}</li>
    </ul>
    {elseif $elements.fldname eq 'description'}
		<div class="EmContent">
			{$elements.value}
		</div>
    {/if}
	{/foreach}
	{/foreach}
</div>
<div class="clear"></div>

{foreach item=row from=$BLOCKS}	
	{foreach item=elements key=title from=$row}	
	{if $elements.fldname eq 'filename'}
	{*onmouseout="fninvshnew('reportLay')" onmouseover="fnvshNrm('reportLay')"*}
	<div id="reportLay" style="width:130px;">
		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		{foreach item=attachments from=$elements.options}
		<tr>
			<td style="border-bottom: 1px solid rgb(204, 204, 204); padding: 5px;">
				{$attachments}
			</td>
		</tr>
		{/foreach}
		</table>
	</div>
	{/if}
	{/foreach}
{/foreach}
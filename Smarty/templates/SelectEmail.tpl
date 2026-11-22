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
 修改编码格式:统一编码：UTF-8
-->*}
<input name="excludedRecords" type="hidden" id="excludedRecords" value="{$EXE_REC}">
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH_URL}'>
<input name='viewid' id="viewid" type='hidden' value='{$VIEWID}'>
<input name='recordid' id="recordid" type='hidden' value='{$RECORDID}'>
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td colspan="2">
      {if $ONE_RECORD eq 'true'}
        {$ENTITY_NAME} {'PLEASECHOOSESENDEMAIL'|@getFixedLabel}<br>
      {else}
        {'FOLLOWINGMESSAGEWITHSELECT'|@getFixedLabel} {'CHOOSERECEIVEeMAIL'|@getFixedLabel}<br>
      {/if}
    </td>
  </tr>
	{foreach name=emailids key=fieldid item=elements from=$MAILINFO}
	<tr>
		{if $smarty.foreach.emailids.iteration eq 1}	
		  <td align="center" width="20"><input type="checkbox" checked value="{$fieldid}" name="semail" /></td>
		{else}
		  <td align="center" width="20"><input type="checkbox" value="{$fieldid}" name="semail"  /></td>
		{/if}
		{if $PERMIT eq '0'}
		{if $ONE_RECORD eq 'true'}	
		<td align="left">{$elements.0}<br>{$MAILDATA[$smarty.foreach.emailids.index]}</td>
		{else}
		<td align="left">{$elements.0}</td>
		{/if}
		{else}
    <td align="left">{$elements.0}<br>{$MAILDATA[$smarty.foreach.emailids.index]}</td>
    {/if}
	</tr>
	{/foreach}
</table>
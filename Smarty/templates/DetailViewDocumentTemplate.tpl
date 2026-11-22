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
<form method="post" action="index.php" name="etemplatedetailview" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="action" value="editDocumentstemplate">
	<input type="hidden" name="module" value="Documents">
	<input type="hidden" name="templatename" value="{$TEMPLATENAME}">
	<input type="hidden" name="templateid" value="{$TEMPLATEID}">
	<input type="hidden" name="foldername" value="{$FOLDERNAME}">
	<input type="hidden" name="parenttab" value="{$PARENTTAB}">
  
  <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td width="120" align="right">{'MAILNAME'|@getFixedLabel}</td>
			<td>{$TEMPLATENAME}</td>
		  </tr>
		<tr>
			<td align="right">{'DESCRIPTION'|@getFixedLabel}</td>
			<td>{$DESCRIPTION}</td>
		</tr>
    <tr>
      <td align="right">{'Content'|@getFixedLabel}</td>
      <td style="word-break: break-all;word-wrap: break-word;">{$BODY}</td>
    </tr>
  </table>
</form>
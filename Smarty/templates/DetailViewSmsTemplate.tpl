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
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />

<form method="post" action="index.php" name="etemplatedetailview" onsubmit="puyoungJS_DialogBox.block();">
  <input type="hidden" name="action" value="EditSMSTeplate">
  <input type="hidden" name="module" value="SmsPhrases">
  <input type="hidden" name="templatename" value="{$TEMPLATENAME}">
  <input type="hidden" name="templateid" value="{$TEMPLATEID}">
  <input type="hidden" name="parenttab" value="Marketing">
  <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
  <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
  
  <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td width="20%" align="right">{'TEMPLATENAME'|@getFixedLabel}</td>
      <td width="80%">{$TEMPLATENAME}</td>
    </tr>	
    <tr>
      <td width="20%" align="right">{'MESSCATEGORY'|@getFixedLabel}</td>
      <td width="80%">{$TEMPLATE_TYPE}</td>
    </tr>	
    <tr>
      <td align="right">{'Content'|@getFixedLabel}</td>
      <td style="white-space: inherit;padding: 5px 10px;">{$BODY}</td>
    </tr>
  </table>
</form>
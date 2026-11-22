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
<div class="divPopOverflow">
  <form action="index.php" method="post" name="templatecreate" id="templatecreate" onsubmit="if(check4null(templatecreate)) { puyoungJS_DialogBox.block(); } else { return false; }">
  <input type="hidden" name="action"/>
  <input type="hidden" name="mode" value="{$EMODE}"/>
  <input type="hidden" name="module" value="Documents"/>
  <input type="hidden" name="templateid" value="{$TEMPLATEID}"/>
  <input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
  <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
  <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="ld-public-content-small">
      <tr>
        <td class="ld-form-item-label"><font color="red">*</font>{'MAILNAME'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
          <input name="templatename" type="text" value="{$TEMPLATENAME}" class="ld-input-inner" tabindex="1"/>
        </td>
      </tr>
      <tr>
        <td class="ld-form-item-label">{'DESCRIPTION'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
          <input name="description" type="text" value="{$DESCRIPTION}" class="ld-input-inner" tabindex="2"/>
        </td>
      </tr>
      <tr>
        <td class="ld-form-item-label">{'Content'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
          <textarea id="documentbody" name="documentbody" class="gwidth100" type="text/plain" style="height:260px;">{$BODY}</textarea>
        </td>
      </tr>
    </table>
  </form>
</div>
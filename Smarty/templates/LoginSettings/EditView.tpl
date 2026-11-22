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
<form action="index.php" method="post" name="company" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action" value="LoginSettingSave"/>
    <div id="CamCardViewDetail">
        {include file='LoginSettings/DisplayEditView.tpl'}
    </div>
</form>
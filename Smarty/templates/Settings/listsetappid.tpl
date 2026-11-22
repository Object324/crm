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
{*create zhouxiaomei 2020-9-23 公司信息增加公司产品简介弹窗模板*}
<div style="max-height: 500px;overflow-y: scroll;">
    <form action="index.php?module=Settings&action=add2db" method="post" name="index" enctype="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();" class="ajax_form">
        <table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>app_id</td>
                <td class="ld-form-item-content"><input type="text" name="app_id" class="ld-input-inner" value="{$app_id}"/></td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>app_secret</td>
                <td class="ld-form-item-content"><input type="text" name="app_secret" class="ld-input-inner" value="{$app_secret}"/></td>
            </tr>
        </table>
    </form>
</div>
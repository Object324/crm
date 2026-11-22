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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<div class="divPopOverflow">
<!--中间-->
  <form action="index.php" method="post" name="index" id="form" onsubmit="puyoungJS_DialogBox.block();">
  <input type="hidden" name="module" value="Settings"/>
  <input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
  <input type="hidden" name="action" value="index"/>
  <input type="hidden" name="record" value="{$ID}"/>
  <input type="hidden" name="detailview" value="{$detailview}"/>
  <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td class="ld-form-item-label">{'CURRENCYNAME'|@getFixedLabel}</td>
      <td class="ld-form-item-content">{$CURRENCY_NAME|@getTranslatedCurrencyString}</td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'CURRENCYCODE'|@getFixedLabel}</td>
      <td class="ld-form-item-content">{$CURRENCY_CODE}</td>
    </tr>
    <tr >
      <td class="ld-form-item-label">{'CURRENCYSYMBOL'|@getFixedLabel}</td>
      <td class="ld-form-item-content">{$CURRENCY_SYMBOL}</td>
    </tr>
    <tr >
      <td class="ld-form-item-label">{'CONVERSIONRATE'|@getFixedLabel}<br>({'BASECURRENCY'|@getFixedLabel}{$MASTER_CURRENCY|@getTranslatedCurrencyString})</td>
      <td class="ld-form-item-content">{$CONVERSION_RATE}</td>
    </tr>
    <tr>
      <td class="ld-form-item-label">{'STATUS'|@getFixedLabel}</td>
      <td class="ld-form-item-content">{$CURRENCY_STATUS}</td>
    </tr>
  </table>
</form>
</div>
<!--中间 end-->
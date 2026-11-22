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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Inventory.js?v={$GLOBALMINVERSION}"></script>

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_TAX_SETTINGS'|@getFixedLabel}<font>（{'LBL_TAX_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="TaxConfigContents" class="cont_wrap clear_float">
            {include file='Settings/TaxConfigEntries.tpl'}
        </div>
    </div>
</div>
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
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'TRACKPOSITONINGGROUP'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="" href="javascript:;" class="ld-button ld-button-primary"   title="{'CREATE'|@getFixedLabel}" style="margin-left: auto;" onclick="CreateTracks(0,'create')">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<table width="100%" border="0" cellspacing="1" cellpadding="0">
<tr>
<td>{$TRACKTREE}</td>

</tr>
</table>
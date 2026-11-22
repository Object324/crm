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
<script language="JAVASCRIPT" type="text/javascript" src="expansion/camcard/camcard.js"></script>
<!--修改编码格式:统一编码：UTF-8-->
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_EXPANSION_CAMCARD'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" class="btn-radius-system width150" id="CamCardModule" name="CamCardModule" onchange="camcard.getInstance().switchModuleDetail()">
          {foreach item=item key=key from=$CAMCARDMODULELIST}
            {if $key eq 'Contacts'}
              <option value="{$item.comparid}" status="{$item.status}" selected="true">{$item.fieldlabel}</option>
            {else}
              <option value="{$item.comparid}" status="{$item.status}">{$item.fieldlabel}</option>
            {/if}
          {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="camcard.getInstance().button_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="CamCardViewDetail" class="cont_wrap clear_float">
            {include file='camcard/DisplayViewDetail.tpl'}
        </div>
    </div>
</div>
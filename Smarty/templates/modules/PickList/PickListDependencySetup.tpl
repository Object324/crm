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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js?v={$GLOBALMINVERSION}"></script>

<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/json.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/PickList/DependencyPicklist.js?v={$GLOBALMINVERSION}"></script>

<script type="text/javascript">
jQuery.noConflict();
{literal}
function containeropts_click(fldname){
	jQuery('#'+fldname).change();
}
{/literal}
</script>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_PICKLIST_DEPENDENCY_SETUP'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" style="display:none;" name="pickmodule" id="pickmodule" class="btn-radius-system width150" onChange="changeDependencyPicklistModule('{$BLOCKIDSETTING}','{$FIELDIDSETTING}');">
          <option value="">{'ALL'|@getFixedLabel}</option>
          {foreach key=modulelabel item=module from=$MODULE_LISTS}
            <option value="{$module}" {if $MODULE eq $module} selected {/if}>{$modulelabel|@getTranstab}</option>
          {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="addNewDependencyPicklist('{$BLOCKIDSETTING}','{$FIELDIDSETTING}');" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="picklist_datas" class="cont_wrap clear_float">
            {if $SUBMODE eq 'editdependency'}
              {include file='modules/PickList/PickListDependencyContents.tpl'}
            {else}
              {include file='modules/PickList/PickListDependencyList.tpl'}
            {/if}
        </div>
    </div>
</div>
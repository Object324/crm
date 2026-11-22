<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/MobileMainInfo.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/MobileDetailInfo.js?v={$GLOBALMINVERSION}"></script>

<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'MobileAppMainInfoCustomization'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" style="width:150px;display:none;" class="btn-radius-system" ondblclick="addColumn('tabList','selectedtabColumns')" id="modulename" name="modulename">
            {foreach key = number item = value from =$ALLMODULE name=pname}
                <option value="{$value.module}">{$value.tabname}</option>
            {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="mobile_maininfo_create" href="javascript:;"  class="ld-button ld-button-primary" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
            {include file="MobileMainInfoEntries.tpl"}
        </div>
    </div>

</div>
</form>

<div id="maininfo_create"style="display:none;width:450px;">
<div id="maininfo_create_div"></div>
</div>

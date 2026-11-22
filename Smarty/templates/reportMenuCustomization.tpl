{*editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/6 16:33 ID1000638*}
<script language="JavaScript" type="text/javascript" src="include/js/MobileList.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'report_menu_customization'|@getFixedLabel}
            {if $LANGUAGETYPE eq 'zh'}
                <font>（{'report_menu_customization_describ'|@getFixedLabel}）</font>
            {/if}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <input type="hidden" id="hiddentabid" name="hiddentabid" value="{$TABID}" />
            <input type="hidden" id="setting_position" name="setting_position" value="report" />
            <a id="mobile_block_create" href="javascript:;" class="ld-button ld-button-primary" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
{*            <a id="mobile_block_sort" href="javascript:;" class="ld-button" title="{'SortMenu'|@getFixedLabel}">{'SortMenu'|@getFixedLabel}</a>*}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
            {include file="MobileListEntries.tpl"}
        </div>
    </div>
</div>
</form>
<div id="block_sort" class="D_pop_box LdPopWidth300px" style="display:none;">
<div id="block_sort_div"></div>
</div>
<div id="block_create" class="D_pop_box" style="display:none;width:570px;">
<div id="block_create_div"></div>
</div>

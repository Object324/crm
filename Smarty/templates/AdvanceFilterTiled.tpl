{*// edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能*}
<div id="AdvanceTiledSearch" style="display: none" class="ld-advance-tiled-search">
    <div id="AdvanceTiledSearchDiv" name="AdvanceTiledSearchDiv" onkeyup="searchSubmit(event,'AdvanceTiled')" class="ld-advance-tiled-div ld-flex-start">

    </div>
    <div id="AdvanceTiledSearchBtnDiv" class="ld-advance-tiled-btn-div ld-flex-end" style="margin-top: 8px">
        <div class="ld-button ld-button-primary" onclick="callSearch('AdvanceTiled');">
            {'screen'|@getFixedLabel}
        </div>
        <div class="ld-button " onclick="AdvanceFilterTiled.getInstance().clearAllFValInput()">
            {'ClearTiledFilterValues'|@getFixedLabel}
        </div>
        <div id="showHideTiledBtn_div" class="ld_Select-component ld-advance-tiled-showhidebtn-div" style="display: none;padding-right: 10px" data-status="{$advanceTildShowStatus}">
            <span style="margin-right: 5px">{'EXPANSION'|@getFixedLabel}</span>
            <b class="ld_Select_arrowicon" style="margin: -14px 2px 0 2px;"></b>
        </div>
    </div>
</div>
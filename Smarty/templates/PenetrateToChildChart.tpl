<div class="main_grid lfloat main_grid_list">
    <div class="main_grid_top">
        <div class="ld-flex-between gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach">
            <div class="ld-flex-start ld-flex-wrap">
                {$SearchBtnHtml}
                <div class="ld-listview-chooseusers" style="margin-top: 11px;">
                    <div class="Showselect LdShowselect" id="showselectsearchscope_chuantou" style="margin-top: 5px;padding-left: 12px;{if $languageType eq 'en'}width: 265px;{else}width: 245px;{/if}">
                        <label style="font-size: 14px;padding-top: 1px;">{'VIEWRANGE'|@getFixedLabel}:</label>
                        <select id="ChuantouSmOwnerSearchScope" name="ChuantouSmOwnerSearchScope" style="width: 130px;margin-top:1px">
                        </select>
                        <a id="icon_range" class="icon-range" style="margin-top: 2px;" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}" tag="icon"></a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div id="myChart"></div>
        </div>
    </div>
</div>
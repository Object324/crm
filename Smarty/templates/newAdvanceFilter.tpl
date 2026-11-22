<script language="JavaScript" type="text/javascript" src="include/js/AdvanceFilterTiled.js"></script>
<div name="advanceSearchDiv" id="advanceSearchDiv">
    <div style="background-color: #fff;padding-right: 0px;width: 100%" class="ld-pop-container" name="pop_adv_filter_div" id="pop_adv_filter_div">
        <div style="width: 820px;">
            {if $showSearchHistory eq 'yes'}
                <div id="searchHistoryDiv" class="ld-table-container ld-table-container-lines padB16" style="overflow: unset">
                    <div class="ld-pop-contnet-title-items padB12">
                        <div class="ld-pop-contnet-title-item">{'SEARCHHISTORY'|@getFixedLabel}</div>
                    </div>
                    <div name="SearchHistory" class="ld-form-item-content advanceFilterSearchHistory">
                        <select class="ld-select-inner" name="SearchHistorySelect" style="width: 820px;">
                            <option>{'NOTSEARCHHISTORY'|@getFixedLabel}</option>
                        </select>
                    </div>
                </div>
            {/if}
            <div id="advanceFilterDiv" class="ld-table-container ld-table-container-lines padT8">
                <div class="ld-pop-contnet-title-items padB12">
                    <div class="ld-pop-contnet-title-item">{'SetFiltering'|@getFixedLabel}</div>
                </div>
                <div name="advanceFilterDashedDiv" class="advanceFilterDashedDiv">
                    <div name="advanceFilterGroupAddBtn" class="advanceFilterGroupAddBtn">
                        <i tag="addGroup" class="ld-fonticon ld-fonticon-add"></i>
                        <span tag="addGroup" style="padding-left: 4px;">{'NEWCOMBINATION'|@getFixedLabel}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
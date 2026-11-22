<div class="ld-pop-container padT8 padB0">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">
            {'DisplayConditions'|@getFixedLabel}
            <select class="ld-select-inner commonSelectPop" style="width: 200px;margin-left: 10px;" name="effectivemethod">
                <option value="meetcondition" {if $buttoninfo_arr.effectivemethod eq "meetcondition"}selected{/if}>{'DisplayWhenMet'|@getFixedLabel}</option>
                <option value="notmeetcondition" {if $buttoninfo_arr.effectivemethod eq "notmeetcondition"}selected{/if}>{'DisplayWhenNotMet'|@getFixedLabel}</option>
            </select>
        </div>
    </div>
</div>
<div style="width: 100%;padding: 0 10px;" >
    <div style="background-color: #fff;padding-right: 0px;width: 100%" class="advanceFilterNoDashedDiv" name="pop_adv_filter_div" id="pop_adv_filter_div" >
        <div name="advanceFilterDashedDiv" class="advanceFilterDashedDiv">
            <div name="advanceFilterGroupAddBtn" class="advanceFilterGroupAddBtn">
                <i tag="addGroup" class="ld-fonticon ld-fonticon-add"></i>
                <span tag="addGroup" style="padding-left: 4px">{'NEWCOMBINATION'|@getFixedLabel}</span>
            </div>
        </div>
    </div>
</div>